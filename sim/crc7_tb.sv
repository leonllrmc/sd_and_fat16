timeunit      10ns;
timeprecision 1ns;

`define ASSERT_TIMEOUT(NAME, CLK, RST_N, ACTIVE, MAX_CYC, MSG) \
  int unsigned NAME``_cnt = 0; \
  always @(posedge CLK) begin \
    if (!(RST_N) || !(ACTIVE)) NAME``_cnt <= 0; \
    else begin \
      NAME``_cnt <= NAME``_cnt + 1; \
      if (NAME``_cnt == MAX_CYC) $error(MSG); \
    end \
  end


module crc7_tb;
  import af_uvm_pkg::*;

  logic clk;
  initial begin
    clk = 0;
  end

  always @* begin
   clk = !clk;
   #1;
  end

  logic rst_n;
  logic start_pulse;

  logic [39:0] crc_data_in;
  logic [6:0] computedCRC;
  logic donePulse;
  logic busy;

  CRC7 crc7_compute(
   .clk(clk),
   .rst_n(rst_n),
   .start_pulse(start_pulse),
   .data(crc_data_in),
   .computedCRC(computedCRC),
   .donePulse(donePulse),
   .busy(busy)
  );

  initial begin
    $dumpfile("crc7_tb.vcd");
    $dumpvars(0, crc7_tb);
    
   `af_uvm_display("Starting CRC7 TB")

    crc_data_in = 40'h000000000000;
   rst_n = 1'b0;
   start_pulse = 1'b0;
   #10
   rst_n = 1'b1;

   if(computedCRC != 7'h00) 
    `af_uvm_error($sformatf("ComputedCRC not reseted: got 0x%0h exp 0x%0h", computedCRC, 7'h00));

    crc_data_in = 40'b0101000100000000000000000000000000000000;
    start_pulse = 1'b1;
    #2
    start_pulse = 1'b0;


    //CRC_compute_duration : assert property (@(posedge clk) $rose(busy) |-> ##[1:100] !busy)
    //  else $error("CRC compute taking too long");

    //`ASSERT_TIMEOUT(CRC_compute_duration, clk, rst_n, busy, 100, "CRC compute taking too long")
    // TODO

    wait(busy == 1'b0);

    checkDonePulse: assert(donePulse)
      $display("Done pulse present at right time");
      else $error("No done pulse!");



    checkResult: assert (computedCRC == 7'b0101010)
      $display("Valid CRC");
      else `af_uvm_error($sformatf("bad computed CRC: got 0x%0h exp 0x%0h", computedCRC, 7'b0101010));

    $display(computedCRC);

    $finish;
  end
endmodule : crc7_tb