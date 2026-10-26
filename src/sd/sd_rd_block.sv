module sd_rd_block(
   input clk,
   input rst_n,

   input [31:0] block_index,

   output reg busy,

   input start_read,
   input start_write,

   output reg [7:0] read_stream_data,
   output reg read_stream_data_ready,
   input read_stream_data_sendnext,

   // only doing read for now, because would need to modify whole sd_cmd block
   //input [7:0] write_stream_data,
   //input write_stream_data_ready,
   //output reg write_stream_data_sendnext,


   output stream_end, // when read/write sent count is good (512)
   output reg stream_error,
   output [6:0] last_R1,

   output [31:0] debug_LBA_block,

   // SPI master
   input sd_spi_miso,
   output sd_spi_mosi,
   output sd_spi_sck,
   output reg sd_spi_cs
);

// init = busy
// then after init => fetch block 0, skip until LBA and store
// => then adds it automatically to requested block index
// when rd pulse => start read (use data mode) => then ready and stream until 512 = end
// when wr => start write and stream byte => finish

// init fsm part => init and then set signal = done + wether to use byte or block address => in same always block

// flow: CMD0 => CMD8       (should do CMD58, but not mandatory)
// if illegal command => do CMD55 , then ACMD41 => repeat with CMD55 until return byte == 0 (set flag for byte level addressing)
// else => ACMD41 0x40000000 => repeat with CMD55 until 0x00
// maybe set flag for SDv1 or v2 and share path
// ex: acmd_arg = sdv1 ? 0 : 0x40..., and next_state at end => fetch CMD58 = set CCS/byte|block level addressing

// main FSM flow
// wait for init done -> start page read -> skip bytes -> read LBA addr
//-> wait for pulse
// read pulse => send command [addr+LBA], and then only act as intermediary with result (set use data)

reg init_done;

reg [9:0] cmd_recv_bytecount;
reg [2:0] init_recv_bytecount;
reg cmd_recv_sendnext;
reg init_recv_sendnext;
reg cmd_send, init_cmd_send;
reg [5:0] sd_cmd_id;
reg [5:0] init_cmd_id;
reg [31:0] sd_cmd_arg;
reg [31:0] init_cmd_arg;
reg sd_use_data_mode;

wire [7:0] sd_recv_data;
wire recv_data_ready;
wire recv_data_end;
wire sd_cmd_busy;

reg [6:0] init_last_R1;
reg [6:0] cmd_last_R1;
assign last_R1 = init_done ? init_last_R1 : cmd_last_R1;

// MARK: sd cmd
   sd_cmd sdCmd (
   .clk(clk),
   .rst_n(rst_n),

   // to next layer
   .cmd_send_pulse(init_done ? cmd_send : init_cmd_send),
   .cmd_id(init_done ? sd_cmd_id : init_cmd_id),
   .cmd_arg(init_done ? sd_cmd_arg : init_cmd_arg),

   .cmd_busy(sd_cmd_busy),
   .disable_response_preample_skip(1'b0),

   // at end => fetch 1 byte => ready = 1 =[ready=0]> when sendnext |^| => fetch 1 byte => ready,...
   // when all byte fetched => rdy = 1 && end = 1 (pulse)
   .recv_byte_count(init_done ? cmd_recv_bytecount : {7'h00, init_recv_bytecount}),
   .recv_data(sd_recv_data),
   .recv_data_sendnext(init_done ? cmd_recv_sendnext : init_recv_sendnext), // when supervisor ready to recieve next recv data byte
   .recv_data_ready(recv_data_ready), // sent after data are avaible
   .recv_data_end(recv_data_end), // sent after recv_byte_count done (all bytes read)

   .use_data_mode(init_done ? sd_use_data_mode : 1'b0), // todo: implement in debugger

   // SPI master
   .sd_spi_miso(sd_spi_miso),
   .sd_spi_mosi(sd_spi_mosi),
   .sd_spi_sck(sd_spi_sck),
   .sd_spi_cs(sd_spi_cs)
);


// then can accept R/W

reg sd_version; // 0 = v1, 1 = v2
reg use_byte_addressing; // 0 = block addressing, 1 = byte addressing

reg [3:0] sd_cmd_version;
reg [3:0] sd_cmd_voltage;


typedef enum logic[4:0] {ISTATE_AWAIT_BOOT, ISTATE_CMD0, /*ISTATE_CMD0_CHECK,*/ ISTATE_CMD8, ISTATE_CMD8_DETECT_VERSION, ISTATE_CMD8_GETCMDVERSION,
 ISTATE_CHECK_CMD8_VOLTAGE, ISTATE_CHECK_CMD8_ECHO, ISTATE_CMD55_SET_APPMODE, ISTATE_CMD55_AWAIT, ISTATE_ACMD41_SEND,
  ISTATE_ACMD41_CHECKRDY, ISTATE_ACMD41_DONE, ISTATE_CMD58_R1, ISTATE_CMD58_CHECKCCS, ISTATE_CMD58_FINISH, ISTATE_DONE, ISTATE_ERROR} sd_init_state;
sd_init_state istate;


always_ff @(posedge clk or negedge rst_n) begin
   if(~rst_n) begin
      istate <= ISTATE_AWAIT_BOOT;

      init_done <= '0;
      sd_version <= '0;
      //sd_use_data_mode <= '0;

      init_recv_bytecount <= '0;
      init_recv_sendnext <= '0;
      init_cmd_send <= '0;
      init_cmd_id <= '0;
      init_cmd_arg <= '0;

      init_last_R1 <= '0;
   end else begin
      init_cmd_send <= 1'b0;
      init_recv_sendnext <= 1'b0;

      case (istate)
         ISTATE_AWAIT_BOOT: begin
            if(!sd_cmd_busy) begin
               init_cmd_id <= 6'h00;
               init_cmd_arg <= 32'h00000000;
               init_recv_bytecount <= 3'd1;
               
               init_cmd_send <= 1'b1;

               istate <= ISTATE_CMD0;
            end
         end

         ISTATE_CMD0: begin
            if(recv_data_ready) begin
               init_last_R1 <= sd_recv_data;

               if(sd_recv_data > 8'd1) begin
                  istate <= ISTATE_ERROR;
               end else
                  istate <= ISTATE_CMD8;
            end
         end

         ISTATE_CMD8: begin
            if(!sd_cmd_busy) begin
               init_cmd_id <= 6'd8;
               init_cmd_arg <= 32'h000001AA; // 01 = 2.7-3.6V, AA = echo
               init_recv_bytecount <= 3'd5;

               init_cmd_send <= 1'b1;

               istate <= ISTATE_CMD8_DETECT_VERSION;
            end else
               init_recv_sendnext <= 1'b1; // be sure not data left and blocking
         end

         ISTATE_CMD8_DETECT_VERSION: begin
            if(recv_data_ready) begin
               init_last_R1 <= sd_recv_data;

               if(sd_recv_data[6:1] == 6'b000010) begin // illegal command
                  sd_version <= 1'b0;
                  istate <= ISTATE_CMD55_SET_APPMODE;
               end else if(sd_recv_data > 8'd1) begin
                  istate <= ISTATE_ERROR;
               end else begin
                  sd_version <= 1'd1;
                  init_recv_sendnext <= 1'b1;
                  istate <= ISTATE_CMD8_GETCMDVERSION;
               end
            end
         end

         ISTATE_CMD8_GETCMDVERSION: begin
            if(recv_data_ready) begin
               sd_cmd_version <= sd_recv_data[7:4];
               init_recv_sendnext <= 1'b1;
               
               istate <= ISTATE_CHECK_CMD8_VOLTAGE;
            end
         end

         ISTATE_CHECK_CMD8_VOLTAGE: begin
            if(recv_data_ready) begin
               sd_cmd_voltage <= sd_recv_data[3:0];
               init_recv_sendnext <= 1'b1;
               
               istate <= ISTATE_CHECK_CMD8_ECHO;
            end
         end

         ISTATE_CHECK_CMD8_ECHO: begin
            if(recv_data_ready) begin
               //if(sd_recv_data != 8'hAA) put back when fixed
               //   istate <= ISTATE_ERROR;
               //else
                  istate <= ISTATE_CMD55_SET_APPMODE;
            end
         end

         ISTATE_CMD55_SET_APPMODE: begin
            if(sd_cmd_busy)
               init_recv_sendnext <= 1'b1; // clear stream and await for finish
            else begin
               init_cmd_id <= 6'd55;
               init_cmd_arg <= 32'h00000000;
               init_recv_bytecount <= 3'd0;

               init_cmd_send <= 1'b1;

               istate <= ISTATE_CMD55_AWAIT;
            end
         end

         ISTATE_CMD55_AWAIT: begin
            if(recv_data_end) begin
               istate <= ISTATE_ACMD41_SEND;
            end
         end

         ISTATE_ACMD41_SEND: begin
            if(sd_cmd_busy)
               init_recv_sendnext <= 1'b1; // clear stream and await for finish
            else begin
               init_cmd_id <= 6'd41;
               init_cmd_arg <= 32'h40000000;
               init_recv_bytecount <= 3'd1;

               init_cmd_send <= 1'b1;

               istate <= ISTATE_ACMD41_CHECKRDY;
            end
         end

         ISTATE_ACMD41_CHECKRDY: begin
            if(recv_data_ready) begin
               if(sd_recv_data == '0) begin
                  istate <= ISTATE_ACMD41_DONE;
               end else if(sd_recv_data > 8'd1) begin
                  istate <= ISTATE_ERROR;
               end else begin
                  // loop until SD ready
                  istate <= ISTATE_CMD55_SET_APPMODE;
               end
            end
         end

      ISTATE_ACMD41_DONE: begin
         if(sd_cmd_busy)
            init_recv_sendnext <= 1'b1; // clear stream and await for finish
         else begin
            if(sd_version == 1'b0) begin
               istate <= ISTATE_DONE;
            end else begin
               init_cmd_id <= 6'd58;
               init_cmd_arg <= 32'h40000000;
               init_recv_bytecount <= 3'd1;

               init_cmd_send <= 1'b1;

               istate <= ISTATE_CMD58_R1;
            end
         end
      end

      ISTATE_CMD58_R1: begin
         if(recv_data_ready) begin
            if(sd_recv_data == '0) begin
               init_recv_sendnext <= 1'b1;
               istate <= ISTATE_CMD58_CHECKCCS;
            end else begin
               istate <= ISTATE_ERROR;
            end
         end
      end

      ISTATE_CMD58_CHECKCCS: begin
         if(recv_data_ready) begin
            use_byte_addressing <= ~sd_recv_data[6];

            istate <= ISTATE_CMD58_FINISH;
         end
      end

      ISTATE_CMD58_FINISH: begin
         if(!sd_cmd_busy)
            istate <= ISTATE_DONE;
      end

      ISTATE_DONE: begin
         init_done <= 1'b1;
      end

      ISTATE_ERROR: begin
      end
   endcase

   end
end

typedef enum logic[3:0] {STATE_AWAIT_INIT, STATE_FETCH_BLOCK0, STATE_CHECK_BLOCK0_R1, STATE_SKIPTOLBA, STATE_FINISH_LBA_READ, STATE_READ_LBA, STATE_IDLE, STATE_ERROR} block_rd_state;
block_rd_state state;

reg [8:0] block_lba_skip_counter;
reg [1:0] lba_index;
reg [31:0] LBA_block;
assign debug_LBA_block = LBA_block;

localparam LBA_START_OFFSET = 9'd446;

always_ff @(posedge clk or negedge rst_n) begin
   if(~rst_n) begin
      state <= STATE_AWAIT_INIT;

      cmd_recv_bytecount <= '0;
      cmd_recv_sendnext <= '0;
      cmd_send <= '0;
      sd_cmd_id <= '0;
      sd_cmd_arg <= '0;
      sd_use_data_mode <= '0;

      LBA_block <= '0;
      block_lba_skip_counter <= '0;
      
      cmd_last_R1 <= '0;
   end else begin
      cmd_send <= 1'b0;
      cmd_recv_sendnext <= 1'b0;

      case (state)
         STATE_AWAIT_INIT: begin
            if(init_done)
               state <= STATE_FETCH_BLOCK0;
         end

         STATE_FETCH_BLOCK0: begin
            sd_cmd_id <= 6'd17;
            sd_cmd_arg <= '0;
            cmd_recv_bytecount <= 10'd514;

            cmd_send <= 1'b1;

            state <= STATE_CHECK_BLOCK0_R1;
         end

         STATE_CHECK_BLOCK0_R1: begin
            if(recv_data_ready) begin
               if(sd_recv_data != '0) begin
                  cmd_last_R1 <= sd_recv_data[6:0];
                  state <= STATE_ERROR;
               end else begin
                  sd_use_data_mode <= 1'b1;
                  cmd_recv_sendnext <= 1'b1; // maybe remove and add +1 offset to LBA skip
                  state <= STATE_SKIPTOLBA;
               end
            end
         end

         STATE_SKIPTOLBA: begin
            if(recv_data_ready) begin
               sd_use_data_mode <= 1'b0;
               block_lba_skip_counter <= block_lba_skip_counter + 9'd1;

               cmd_recv_sendnext <= 1'b1;

               if(block_lba_skip_counter == LBA_START_OFFSET) begin
                  LBA_block[7:0] <= sd_recv_data;
                  lba_index <= 2'd1;
                  state <= STATE_READ_LBA;
               end
            end
         end

         STATE_READ_LBA: begin
            if(recv_data_ready) begin
               lba_index <= lba_index + 2'd1;
               cmd_recv_sendnext <= 1'b1;

               case(lba_index)
                  2'd1: LBA_block[15:8] <= sd_recv_data;
                  2'd2: LBA_block[23:16] <= sd_recv_data;
                  2'd3: LBA_block[31:24] <= sd_recv_data;
               endcase

               if(lba_index == 2'd0)
                  state <= STATE_FINISH_LBA_READ;
            end
         end

         STATE_FINISH_LBA_READ: begin
            if(sd_cmd_busy)
               cmd_recv_sendnext <= 1'b1;
            else
               state <= STATE_IDLE;
         end

      STATE_ERROR: begin
      end
         
      endcase
   end
end

always_ff @(posedge clk) begin
   busy <= ~(init_done && (state == STATE_IDLE));
   stream_error <= (istate == ISTATE_ERROR) || (state == STATE_ERROR);
end

endmodule