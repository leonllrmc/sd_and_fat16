module af_hello_world_uvm;
  import af_uvm_pkg::*;

  int addr, data;

  initial begin
    printAfBanner();                          // prints AsFigo copyright in sim log
    `af_uvm_display("Welcome to UVM + Verilator!")
    #10;
    `uvm_info("AsFigo", "Hello from uvm_info!", UVM_MEDIUM)
    #10;
    `af_uvm_display("Hello from af_uvm_display!")
    `AF_UVM_RAND_STD(addr)                    // std::randomize with error check
    `AF_UVM_RAND_STD_WITH(data, { data inside {[0:255]}; })
    `af_uvm_printf(("addr=0x%0h data=0x%0h", addr, data))
    #10;
    $finish;
  end
endmodule : af_hello_world_uvm