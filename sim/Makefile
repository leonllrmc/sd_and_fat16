SHELL := /bin/bash # to use source <script>

SRC_DIRS := -I../src/ -I../src/sd

run_test_crc7: test_crc7
	./obj_dir/Vuvm_pkg

test_crc7: ../src/sd/crc7.sv crc7_tb.sv init_verilator_uvm
	verilator -j 19 --binary -f ${AF_VLT_UVM_HOME}/scripts/af_uvm_src.f ${SRC_DIRS} crc7_tb.sv

test_verilator: init_verilator_uvm
	verilator -j 19 --binary -f ${AF_VLT_UVM_HOME}/scripts/af_uvm_src.f ${SRC_DIRS} test.sv

.PHONY: init_verilator_uvm

init_verilator_uvm:
	cd af_vlt_uvm && source setup.sh