module CRC7(
   input clk,
   input rst_n,
   input start_pulse,
   input [39:0] data,
   output reg [6:0] computedCRC,
   output reg donePulse,
   output reg busy
);

   reg [46:0] crc_val;
   reg [5:0] crc_index;

  typedef enum logic[1:0] {STATE_IDLE, STATE_COMPUTING, STATE_DONE} crc_compute_state;
  crc_compute_state state;

   wire [7:0] poly = 8'h89;

   always_ff @(posedge clk or negedge rst_n) begin
      if(~rst_n) begin
         crc_val <= 47'h000000000000;
         state <= STATE_IDLE;
         donePulse <= 1'b0;
         crc_index <= 6'd47;
         computedCRC <= 7'h00;
         busy <= 1'b0;
      end else begin
         donePulse <= 1'b0;

         case (state)
            STATE_IDLE: begin
               if(start_pulse) begin
                  crc_index <= 6'd47;
                  crc_val <= {data, 7'h00};

                  busy <= 1'b1;

                  state <= STATE_COMPUTING;
               end
            end

            STATE_COMPUTING: begin
               if((crc_index == 6'd0) || (crc_val[46:7] == 40'd0)) begin
                  state <= STATE_DONE;
               end else begin
                  crc_index <= crc_index - 6'd1;

                  if(crc_val[crc_index]) begin
                     //  -: 8 => crc_index:crc_index-7
                     crc_val[crc_index -: 8] <= crc_val[crc_index -: 8] ^ poly;
                  end
               end
            end

            STATE_DONE: begin
               computedCRC <= crc_val[6:0];
               donePulse <= 1'b1;
               busy <= 1'b0;

               state <= STATE_IDLE;
            end
         endcase
      end
   end
   
endmodule