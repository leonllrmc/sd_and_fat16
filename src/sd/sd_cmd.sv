module sd_cmd(
   input clk,
   input rst_n,

   // to next layer
   input cmd_send_pulse,
   input [5:0] cmd_id,
   input [31:0] cmd_arg,

   input [10:0] recv_byte_count,

   // SPI master
   input sd_spi_miso,
   output sd_spi_mosi,
   output sd_spi_sck,
   output sd_spi_cs
);

// MARK: FSM
   
   module spi_master #(
    .CLK_DIV(2) // 25 MHz = max, supposed to go down to about 400kHz during init tho
) (
    .clk(clk)         , // Top level system clock input.
    .rst_n(rst_n)      , // Asynchronous active low reset.

    .sclk(sd_spi_sck),
    .mosi(sd_spi_mosi),
    .miso(sd_spi_miso),
    .cs_n(),    // active-low chip select; low for the whole

    input  wire             send,    // duration of a frame (or a back-to-back run)
    input  wire [WIDTH-1:0] din,
    output reg  [WIDTH-1:0] dout = {WIDTH{1'b0}},
    output reg              done = 1'b0,
    output reg              busy = 1'b0
);

endmodule