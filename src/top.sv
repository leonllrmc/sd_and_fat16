module top(
    input clk,
    input rst_n,
    output uart_tx,

    input sd_spi_miso,
    output sd_spi_mosi,
    output sd_spi_sck,
    output sd_spi_cs
);

assign sd_spi_cs = 1'b0;



uart_tx debug_tx(
    .clk(clk)         , // Top level system clock input.
    .resetn(rst_n)      , // Asynchronous active low reset.
    .uart_txd(uart_tx)    , // UART transmit pin.
    .uart_tx_busy(), // Module busy sending previous item.
    .uart_tx_en(1'b1)  , // Send the data on uart_tx_data
   .uart_tx_data(8'h40)  // The data to be sent
);



endmodule