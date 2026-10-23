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
