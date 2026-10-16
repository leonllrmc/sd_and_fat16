module CRC7(
   input clk,
   input rst_n,
   input start_pulse,
   input [39:0] data,
   ouput [6:0] computedCRC
);

reg [46:0] crc;

  typedef enum logic[1:0] {STATE_IDLE, STATE_COMPUTING, STATE_DONE} crc_compute_state;

always_ff @(posedge lk or negedge rst_n) begin
   if(~rst_n) begin
      crc <= 47'h000000000000;
   end
end
   
endmodule