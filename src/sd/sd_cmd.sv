module sd_cmd(
   input clk,
   input rst_n,

   // to next layer
   input cmd_send_pulse,
   input [5:0] cmd_id,
   input [31:0] cmd_arg,

   output reg cmd_busy,

   // at end => fetch 1 byte => ready = 1 =[ready=0]> when sendnext |^| => fetch 1 byte => ready,...
   // when all byte fetched => rdy = 1 && end = 1 (pulse)
   input [10:0] recv_byte_count,
   output reg [7:0] recv_data,
   input recv_data_sendnext, // when supervisor ready to recieve next recv data byte
   output reg recv_data_ready, // sent after data are avaible
   output reg recv_data_end, // sent after recv_byte_count done (all bytes read)

   input use_data_mode,

   // SPI master
   input sd_spi_miso,
   output sd_spi_mosi,
   output sd_spi_sck,
   output reg sd_spi_cs
);

   // MARK: CRC7
   reg crc_compute_pulse;
   wire [6:0] crc_result;
   wire crc_busy;

   CRC7 crc_gen(
      .clk(clk),
      .rst_n(rst_n),
      .start_pulse(crc_compute_pulse),
      .data({2'b01, cmd_id, cmd_arg}),
      .computedCRC(crc_result),
      .donePulse(),
      .busy(crc_busy)
   );

   // MARK: SPI master
   reg spi_send_pulse;
   reg [7:0] spi_mosi_data;
   wire [7:0] spi_miso_data;
   wire spi_done_pulse;
   wire spi_busy;

   reg [10:0] recv_byte_left;
      
   spi_master #(
      .CLK_DIV(4)//2) // 25 MHz = max, supposed to go down to about 400kHz during init tho
   ) spi (
      .clk(clk)         , // Top level system clock input.
      .rst_n(rst_n)      , // Asynchronous active low reset.

      .sclk(sd_spi_sck),
      .mosi(sd_spi_mosi),
      .miso(sd_spi_miso),
      .cs_n(),    // active-low chip select; low for the whole

      .send(spi_send_pulse),    // duration of a frame (or a back-to-back run)
      .din(spi_mosi_data),
      .dout(spi_miso_data),
      .done(spi_done_pulse),
      .busy(spi_busy)
   );
   // MARK: FSM
   /*
      init => cmd_busy = 1 => and do the 80 cycle of ncs=1 + send 10 dummy bytes
      IDLE -[start CRC compute]> assert -> send {, arg} => send *5 {arh} => [check !crc_busy] send {crc,} => if recv_count == 0
      -> [rxstart] recieve byte =[done]> [recv_store] data=miso; ready=1 =[sendnext]> [rx start]
      [rxstart] => recv_count_left == 0 => recv_data_end = pulse, deassert ->IDLE

      if use_data_mode -> until data = 0xFE, recv_count_left not changed, automatic get without sendnext
      => supervisor should disabled datamode after first byte is read
      usage [get cmd data] -> use_data_mode = 1 (implmented in state after recieve byte (in else pulse and ack))

      recv_store: if((recv_count == recv_total) && (res & 0x80)) -> rxstart
      elif(use_data_mode && (res != 0xFE)) -> rxstart
      else => done = 1, recv_count--, -> "wait for ack"
   */

   typedef enum logic[3:0] {STATE_START, STATE_SDPOWERUP, STATE_IDLE,
                           STATE_ASSERT_BEFORECS, STATE_ASSERT_AFTERCS, STATE_SEND_CMD, START_SEND_ARGS, 
                           /* CRC should be done at that time*/ STATE_CHECK_CRC_DONE, STATE_SEND_CRC,
                           STATE_RX_BYTE, STATE_RX_RECV, STATE_AWAIT_GETNEXT, STATE_DEASSERT_BEFORECS, STATE_DEASSERT_INTCS, STATE_DEASSERT_AFTERCS} crc_compute_state;
   crc_compute_state state;

   reg [3:0] sd_powerup_counter;
   reg [1:0] arg_send_index;

   always_ff @(posedge clk or negedge rst_n) begin
      if(~rst_n) begin
         state <= STATE_START;

         sd_spi_cs <= 1'b1;
         cmd_busy <= 1'b1;

         recv_data_end <= 1'b1;

         sd_powerup_counter <= 4'd0;
      end else begin
         case (state)
            STATE_START: begin
               cmd_busy <= 1'b1;
               sd_spi_cs <= 1'b1;

               spi_send_pulse <= 1'b1;
               spi_mosi_data <= 8'hFF;

               sd_powerup_counter <= 4'd1;

               state <= STATE_SDPOWERUP;
            end

            STATE_SDPOWERUP: begin
               spi_send_pulse <= 1'b0;
               sd_spi_cs <= 1'b1;

               if(spi_done_pulse) begin
                  if(sd_powerup_counter >= 4'd10) begin
                     cmd_busy <= 1'b0;
                     state <= STATE_IDLE;
                  end else begin
                     spi_send_pulse <= 1'b1;
                     sd_powerup_counter <= sd_powerup_counter + 4'd1;
                  end
               end
            end

            STATE_IDLE: begin
               sd_spi_cs <= 1'b1;

               cmd_busy <= 1'b0;


               if(cmd_send_pulse) begin
                  // decrementing
                  recv_byte_left <= recv_byte_count;

                  crc_compute_pulse <= 1'b1;

                  cmd_busy <= 1'b1;
                  
                  spi_mosi_data <= 8'hFF;
                  spi_send_pulse <= 1'b1;
                  state <= STATE_ASSERT_BEFORECS;
               end
            end

            STATE_ASSERT_BEFORECS: begin
               spi_send_pulse <= 1'b0;

               crc_compute_pulse <= 1'b0;

               if(spi_done_pulse) begin
                  sd_spi_cs <= 1'b0;


                  spi_mosi_data <= 8'hFF;
                  spi_send_pulse <= 1'b1;

                  state <= STATE_ASSERT_AFTERCS;
               end
            end

            STATE_ASSERT_AFTERCS: begin
               spi_send_pulse <= 1'b0;

               if(spi_done_pulse) begin
                  state <= STATE_SEND_CMD;

                  spi_mosi_data <= {2'b01, cmd_id};
                  spi_send_pulse <= 1'b1; 
               end
            end

            STATE_SEND_CMD: begin
               spi_send_pulse <= 1'b0;

               if(spi_done_pulse) begin
                  arg_send_index <= 2'd1;
                  spi_mosi_data <= cmd_arg[31:24];
                  spi_send_pulse <= 1'b1; 

                  state <= START_SEND_ARGS;
               end
            end

            START_SEND_ARGS: begin
               spi_send_pulse <= 1'b0;

               if(spi_done_pulse) begin
                  if(arg_send_index == 2'd0) begin // overflow
                     spi_send_pulse <= 1'b0;
                     state <= STATE_CHECK_CRC_DONE;
                  end else begin
                     case(arg_send_index)
                        //2'd0: spi_mosi_data <= cmd_arg[31:24];
                        2'd1: spi_mosi_data <= cmd_arg[23:16];
                        2'd2: spi_mosi_data <= cmd_arg[15:8];
                        2'd3: spi_mosi_data <= cmd_arg[7:0];
                     endcase

                     arg_send_index <= arg_send_index + 2'd1;

                     spi_send_pulse <= 1'b1;
                  end
               end
            end

            STATE_CHECK_CRC_DONE: begin
               if(~crc_busy) begin
                  spi_mosi_data <= {crc_result, 1'b1};
                  spi_send_pulse <= 1'b1;

                  state <= STATE_SEND_CRC;
               end
            end

            STATE_SEND_CRC: begin
               spi_send_pulse <= 1'b0;

               if(spi_done_pulse) begin
                  if(recv_byte_count == 10'd0) begin
                     recv_data_end <= 1'b1;
                     state <= STATE_DEASSERT_BEFORECS;
                  end else begin
                     recv_data_end <= 1'b0;
                     state <= STATE_RX_BYTE;
                  end
               end
            end

            STATE_RX_BYTE: begin
               if(recv_byte_left == 10'd0) begin
                  recv_data_ready <= 1'b1;
                  recv_data_end <= 1'b1;
                  state <= STATE_DEASSERT_BEFORECS;
               end else begin
                  spi_send_pulse <= 1'b1;
                  spi_mosi_data <= 8'hFF;

                  state <= STATE_RX_RECV;
               end
            end

            STATE_RX_RECV: begin
               spi_send_pulse <= 1'b0;

               if(spi_done_pulse) begin
                 //if(use_data_mode && (spi_miso_data != 8'hFE))
                    // data block starts with 0xFE char
                   // state <= STATE_RX_BYTE;
 //  else if((recv_byte_count == recv_byte_left) && (spi_miso_data[7]))
 //     // R1 reply (first byte of all) has byte 7 == 0
 //     state <= STATE_RX_BYTE; this is note code, just to check if commment working
                  //else begin
                     recv_data_ready <= 1'b1;
                     recv_data <= spi_miso_data;

                     if(!(use_data_mode && (spi_miso_data != 8'hFE)))
                        recv_byte_left <= recv_byte_left - 11'd1;

                     state <= STATE_AWAIT_GETNEXT;
                  //end
               end
            end

            STATE_AWAIT_GETNEXT: begin
               if(recv_data_sendnext) begin
                  recv_data_ready <= 1'b0;
                  state <= STATE_RX_BYTE;
               end
            end

            STATE_DEASSERT_BEFORECS: begin
               recv_data_ready <= 1'b0;
               //sd_spi_cs <= 1'b0;
               spi_mosi_data <= 8'hFF;
               spi_send_pulse <= 1'b1;

               
               recv_data_end <= 1'b1;

               state <= STATE_DEASSERT_INTCS;
            end

            STATE_DEASSERT_INTCS: begin
               spi_send_pulse <= 1'b0;

               if(spi_done_pulse) begin
                  sd_spi_cs <= 1'b1;
                  spi_send_pulse <= 1'b1;

                  state <= STATE_DEASSERT_AFTERCS;
               end
            end

            STATE_DEASSERT_AFTERCS: begin
               spi_send_pulse <= 1'b0;

               if(spi_done_pulse) begin
                  state <= STATE_IDLE;
               end
            end

         endcase
      end
   end

endmodule