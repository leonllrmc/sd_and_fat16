module top(
    input clk,
    input rst_n,
    input uart_rx,
    output uart_tx,

    input sd_spi_miso,
    output sd_spi_mosi,
    output sd_spi_sck,
    output sd_spi_cs,

    output [5:0] debug_leds
);

   //assign sd_spi_cs = 1'b0;

   // manual debug => send [cmd][5*arg][recv_count[1 byte]] => get all bytes

   reg uart_rx_en;
   wire uart_rx_valid;
   wire [7:0] uart_rx_data;

   reg sd_use_data_mode;

   uart_rx debug_rx(
      .clk(clk)         , // Top level system clock input.
      .resetn(rst_n)      , // Asynchronous active low reset.
      .uart_rxd(uart_rx)     , // UART Recieve pin.
      .uart_rx_en(uart_rx_en), // Recieve enable
      .uart_rx_break(), // Did we get a BREAK message?
      .uart_rx_valid(uart_rx_valid), // Valid data recieved and available.
      .uart_rx_data(uart_rx_data)   // The recieved data.
   );


   wire uart_tx_busy;
   reg uart_tx_en;
   reg [7:0] uart_tx_data;

   uart_tx debug_tx(
      .clk(clk)         , // Top level system clock input.
      .resetn(rst_n)      , // Asynchronous active low reset.
      .uart_txd(uart_tx)    , // UART transmit pin.
      .uart_tx_busy(uart_tx_busy), // Module busy sending previous item.
      .uart_tx_en(uart_tx_en), // Send the data on uart_tx_data
      .uart_tx_data(uart_tx_data)  // The data to be sent
   );


   reg sd_cmd_send_pulse;
   reg [5:0] sd_cmd_id;
   reg [31:0] sd_cmd_arg;
   wire sd_cmd_busy;

   reg [7:0] sd_recv_count;
   wire [7:0] sd_recv_data;
   reg recv_data_sendnext;
   wire recv_data_ready;
   wire recv_data_end;


wire [31:0] debug_LBA_block;
wire bsy;
sd_rd_block sd_rd(
   .clk(clk),
   .rst_n(rst_n),

   .block_index(0),

   .busy(bsy),

  .start_read(0),
  .start_write(0),

   .read_stream_data(),
   .read_stream_data_ready(),
   .read_stream_data_sendnext(0),

   // only doing read for now, because would need to modify whole sd_cmd block
   //input [7:0] write_stream_data,
   //input write_stream_data_ready,
   //output reg write_stream_data_sendnext,


   .stream_end(), // when read/write sent count is good (512)
   .stream_error(),
   .last_R1(),

   .debug_LBA_block(debug_LBA_block),


   // SPI master
   .sd_spi_miso(sd_spi_miso),
   .sd_spi_mosi(sd_spi_mosi),
   .sd_spi_sck(sd_spi_sck),
   .sd_spi_cs(sd_spi_cs)
);

assign debug_leds[3:0] = debug_LBA_block[27:24];
assign debug_leds[4] = bsy;
assign debug_leds[5] = rst_n;

   /*
   // at end of await boot => send char
   typedef enum logic[3:0] {STATE_AWAIT_BOOT, STATE_IDLE, STATE_RECV_CMD, STATE_RECV_ARGS,
                           STATE_RECV_BYTECOUNT, STATE_AWAIT_SDCMD, STATE_DISPLAY_ACK, 
                           STATE_DISPLAYBYTE, STATE_READBYTE} debug_cmd_state;
   debug_cmd_state state;

   reg [1:0] arg_send_index;

   assign debug_leds = ~{2'b00, state};


   always_ff @(posedge clk or negedge rst_n) begin
      if(~rst_n) begin
         state <= STATE_AWAIT_BOOT;

         uart_tx_en <= 1'b0;
         uart_rx_en <= 1'b1;

         arg_send_index <= 2'd0;

         sd_use_data_mode <= 1'b0;
      end else begin
         case(state)
            STATE_AWAIT_BOOT: begin
               if(~sd_cmd_busy) begin
                  uart_tx_data <= 8'h40;
                  uart_tx_en <= 1'b1;

                  state <= STATE_IDLE;
               end
            end

            STATE_IDLE: begin
                  uart_tx_en <= 1'b0;
                  uart_rx_en <= 1'b1;
                  sd_use_data_mode <= 1'b0;

                  if(uart_rx_valid) begin
                     sd_cmd_id <= uart_rx_data[5:0];
                     
                     state <= STATE_RECV_CMD;
                  end
            end

            STATE_RECV_CMD: begin
               if(sd_cmd_id == 5'h11)
                  sd_use_data_mode <= 1'b1; 

               if(uart_rx_valid) begin
                  arg_send_index <= 2'd1;

                  sd_cmd_arg[31:24] <= uart_rx_data;

                  state <= STATE_RECV_ARGS;
               end
            end

            STATE_RECV_ARGS: begin
               if(uart_rx_valid) begin
                  arg_send_index <= arg_send_index + 2'd1;

                  case(arg_send_index)
                     //2'd0: sd_cmd_arg[31:24] <= uart_rx_data;
                     2'd1: sd_cmd_arg[23:16] <= uart_rx_data;
                     2'd2: sd_cmd_arg[15:8] <= uart_rx_data;
                     2'd3: sd_cmd_arg[7:0] <= uart_rx_data;
                  endcase

                  if(arg_send_index == 2'd0) begin
                        sd_recv_count <= uart_rx_data;

                        state <= STATE_RECV_BYTECOUNT;
                     end
                  else
                     state <= STATE_RECV_ARGS;
               end
            end

            STATE_RECV_BYTECOUNT: begin
               recv_data_sendnext <= 1'b0;

               sd_cmd_send_pulse <= 1'b1;

               state <= STATE_AWAIT_SDCMD;
            end

            STATE_AWAIT_SDCMD: begin
               sd_cmd_send_pulse <= 1'b0;
               recv_data_sendnext <= 1'b0;

               if(recv_data_ready) begin
                  //uart_tx_data <= 8'h23; // "#"
                  
                  sd_use_data_mode <= 1'b0;
                  uart_tx_data <= sd_recv_data;

                  uart_tx_en <= 1'b1;

                  state <= STATE_DISPLAY_ACK;
               end
            end

            STATE_DISPLAY_ACK: begin
               uart_tx_en <= 1'b0;

               if((!uart_tx_busy)) begin
                  recv_data_sendnext <= 1'b1;
                  state <= STATE_DISPLAYBYTE;
               end
            end

            STATE_DISPLAYBYTE: begin
               recv_data_sendnext <= 1'b0;

               if(recv_data_end)
                  state <= STATE_IDLE;
               else if(recv_data_ready) begin

                  uart_tx_data <= sd_recv_data;
                  uart_tx_en <= 1'b1;

                  state <= STATE_READBYTE;
               end
            end

            STATE_READBYTE: begin
               uart_tx_en <= 1'b0;

               if(!uart_tx_busy) begin
                  recv_data_sendnext <= 1'b1;
                  state <= STATE_DISPLAYBYTE;
               end
            end
         endcase
      end
   end

   */


endmodule