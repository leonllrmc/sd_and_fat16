//Copyright (C)2014-2026 GOWIN Semiconductor Corporation.
//All rights reserved.
//File Title: Timing Constraints file
//Tool Version: V1.9.12.03 (64-bit) 
//Created Time: 2026-10-17 17:26:54

create_clock -name clk -period 37.037 [get_ports {clk}]

report_timing -setup
report_max_frequency -mod_ins {sdCmd}
