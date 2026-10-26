module gw_gao(
    \sd_rd/sd_recv_data[7] ,
    \sd_rd/sd_recv_data[6] ,
    \sd_rd/sd_recv_data[5] ,
    \sd_rd/sd_recv_data[4] ,
    \sd_rd/sd_recv_data[3] ,
    \sd_rd/sd_recv_data[2] ,
    \sd_rd/sd_recv_data[1] ,
    \sd_rd/sd_recv_data[0] ,
    \sd_rd/sd_use_data_mode ,
    \sd_rd/sdCmd/spi_miso_data[7] ,
    \sd_rd/sdCmd/spi_miso_data[6] ,
    \sd_rd/sdCmd/spi_miso_data[5] ,
    \sd_rd/sdCmd/spi_miso_data[4] ,
    \sd_rd/sdCmd/spi_miso_data[3] ,
    \sd_rd/sdCmd/spi_miso_data[2] ,
    \sd_rd/sdCmd/spi_miso_data[1] ,
    \sd_rd/sdCmd/spi_miso_data[0] ,
    \sd_rd/sdCmd/cmd_id[5] ,
    \sd_rd/sdCmd/cmd_id[4] ,
    \sd_rd/sdCmd/cmd_id[3] ,
    \sd_rd/sdCmd/cmd_id[2] ,
    \sd_rd/sdCmd/cmd_id[1] ,
    \sd_rd/sdCmd/cmd_id[0] ,
    \sd_rd/sdCmd/spi_mosi_data[7] ,
    \sd_rd/sdCmd/spi_mosi_data[6] ,
    \sd_rd/sdCmd/spi_mosi_data[5] ,
    \sd_rd/sdCmd/spi_mosi_data[4] ,
    \sd_rd/sdCmd/spi_mosi_data[3] ,
    \sd_rd/sdCmd/spi_mosi_data[2] ,
    \sd_rd/sdCmd/spi_mosi_data[1] ,
    \sd_rd/sdCmd/spi_mosi_data[0] ,
    \sd_rd/sdCmd/recv_data_ready ,
    \sd_rd/istate[4] ,
    \sd_rd/istate[3] ,
    \sd_rd/istate[2] ,
    \sd_rd/istate[1] ,
    \sd_rd/istate[0] ,
    \sd_rd/state[3] ,
    \sd_rd/state[2] ,
    \sd_rd/state[1] ,
    \sd_rd/state[0] ,
    \sd_rd/init_done ,
    \sd_rd/lba_index[1] ,
    \sd_rd/lba_index[0] ,
    \debug_LBA_block[31] ,
    \debug_LBA_block[30] ,
    \debug_LBA_block[29] ,
    \debug_LBA_block[28] ,
    \debug_LBA_block[27] ,
    \debug_LBA_block[26] ,
    \debug_LBA_block[25] ,
    \debug_LBA_block[24] ,
    \debug_LBA_block[23] ,
    \debug_LBA_block[22] ,
    \debug_LBA_block[21] ,
    \debug_LBA_block[20] ,
    \debug_LBA_block[19] ,
    \debug_LBA_block[18] ,
    \debug_LBA_block[17] ,
    \debug_LBA_block[16] ,
    \debug_LBA_block[15] ,
    \debug_LBA_block[14] ,
    \debug_LBA_block[13] ,
    \debug_LBA_block[12] ,
    \debug_LBA_block[11] ,
    \debug_LBA_block[10] ,
    \debug_LBA_block[9] ,
    \debug_LBA_block[8] ,
    \debug_LBA_block[7] ,
    \debug_LBA_block[6] ,
    \debug_LBA_block[5] ,
    \debug_LBA_block[4] ,
    \debug_LBA_block[3] ,
    \debug_LBA_block[2] ,
    \debug_LBA_block[1] ,
    \debug_LBA_block[0] ,
    \sd_rd/sdCmd/spi_send_pulse ,
    clk,
    \sd_rd/sdCmd/recv_data_sendnext ,
    \sd_rd/sd_cmd_busy ,
    \sd_rd/sdCmd/spi/send ,
    tms_pad_i,
    tck_pad_i,
    tdi_pad_i,
    tdo_pad_o
);

input \sd_rd/sd_recv_data[7] ;
input \sd_rd/sd_recv_data[6] ;
input \sd_rd/sd_recv_data[5] ;
input \sd_rd/sd_recv_data[4] ;
input \sd_rd/sd_recv_data[3] ;
input \sd_rd/sd_recv_data[2] ;
input \sd_rd/sd_recv_data[1] ;
input \sd_rd/sd_recv_data[0] ;
input \sd_rd/sd_use_data_mode ;
input \sd_rd/sdCmd/spi_miso_data[7] ;
input \sd_rd/sdCmd/spi_miso_data[6] ;
input \sd_rd/sdCmd/spi_miso_data[5] ;
input \sd_rd/sdCmd/spi_miso_data[4] ;
input \sd_rd/sdCmd/spi_miso_data[3] ;
input \sd_rd/sdCmd/spi_miso_data[2] ;
input \sd_rd/sdCmd/spi_miso_data[1] ;
input \sd_rd/sdCmd/spi_miso_data[0] ;
input \sd_rd/sdCmd/cmd_id[5] ;
input \sd_rd/sdCmd/cmd_id[4] ;
input \sd_rd/sdCmd/cmd_id[3] ;
input \sd_rd/sdCmd/cmd_id[2] ;
input \sd_rd/sdCmd/cmd_id[1] ;
input \sd_rd/sdCmd/cmd_id[0] ;
input \sd_rd/sdCmd/spi_mosi_data[7] ;
input \sd_rd/sdCmd/spi_mosi_data[6] ;
input \sd_rd/sdCmd/spi_mosi_data[5] ;
input \sd_rd/sdCmd/spi_mosi_data[4] ;
input \sd_rd/sdCmd/spi_mosi_data[3] ;
input \sd_rd/sdCmd/spi_mosi_data[2] ;
input \sd_rd/sdCmd/spi_mosi_data[1] ;
input \sd_rd/sdCmd/spi_mosi_data[0] ;
input \sd_rd/sdCmd/recv_data_ready ;
input \sd_rd/istate[4] ;
input \sd_rd/istate[3] ;
input \sd_rd/istate[2] ;
input \sd_rd/istate[1] ;
input \sd_rd/istate[0] ;
input \sd_rd/state[3] ;
input \sd_rd/state[2] ;
input \sd_rd/state[1] ;
input \sd_rd/state[0] ;
input \sd_rd/init_done ;
input \sd_rd/lba_index[1] ;
input \sd_rd/lba_index[0] ;
input \debug_LBA_block[31] ;
input \debug_LBA_block[30] ;
input \debug_LBA_block[29] ;
input \debug_LBA_block[28] ;
input \debug_LBA_block[27] ;
input \debug_LBA_block[26] ;
input \debug_LBA_block[25] ;
input \debug_LBA_block[24] ;
input \debug_LBA_block[23] ;
input \debug_LBA_block[22] ;
input \debug_LBA_block[21] ;
input \debug_LBA_block[20] ;
input \debug_LBA_block[19] ;
input \debug_LBA_block[18] ;
input \debug_LBA_block[17] ;
input \debug_LBA_block[16] ;
input \debug_LBA_block[15] ;
input \debug_LBA_block[14] ;
input \debug_LBA_block[13] ;
input \debug_LBA_block[12] ;
input \debug_LBA_block[11] ;
input \debug_LBA_block[10] ;
input \debug_LBA_block[9] ;
input \debug_LBA_block[8] ;
input \debug_LBA_block[7] ;
input \debug_LBA_block[6] ;
input \debug_LBA_block[5] ;
input \debug_LBA_block[4] ;
input \debug_LBA_block[3] ;
input \debug_LBA_block[2] ;
input \debug_LBA_block[1] ;
input \debug_LBA_block[0] ;
input \sd_rd/sdCmd/spi_send_pulse ;
input clk;
input \sd_rd/sdCmd/recv_data_sendnext ;
input \sd_rd/sd_cmd_busy ;
input \sd_rd/sdCmd/spi/send ;
input tms_pad_i;
input tck_pad_i;
input tdi_pad_i;
output tdo_pad_o;

wire \sd_rd/sd_recv_data[7] ;
wire \sd_rd/sd_recv_data[6] ;
wire \sd_rd/sd_recv_data[5] ;
wire \sd_rd/sd_recv_data[4] ;
wire \sd_rd/sd_recv_data[3] ;
wire \sd_rd/sd_recv_data[2] ;
wire \sd_rd/sd_recv_data[1] ;
wire \sd_rd/sd_recv_data[0] ;
wire \sd_rd/sd_use_data_mode ;
wire \sd_rd/sdCmd/spi_miso_data[7] ;
wire \sd_rd/sdCmd/spi_miso_data[6] ;
wire \sd_rd/sdCmd/spi_miso_data[5] ;
wire \sd_rd/sdCmd/spi_miso_data[4] ;
wire \sd_rd/sdCmd/spi_miso_data[3] ;
wire \sd_rd/sdCmd/spi_miso_data[2] ;
wire \sd_rd/sdCmd/spi_miso_data[1] ;
wire \sd_rd/sdCmd/spi_miso_data[0] ;
wire \sd_rd/sdCmd/cmd_id[5] ;
wire \sd_rd/sdCmd/cmd_id[4] ;
wire \sd_rd/sdCmd/cmd_id[3] ;
wire \sd_rd/sdCmd/cmd_id[2] ;
wire \sd_rd/sdCmd/cmd_id[1] ;
wire \sd_rd/sdCmd/cmd_id[0] ;
wire \sd_rd/sdCmd/spi_mosi_data[7] ;
wire \sd_rd/sdCmd/spi_mosi_data[6] ;
wire \sd_rd/sdCmd/spi_mosi_data[5] ;
wire \sd_rd/sdCmd/spi_mosi_data[4] ;
wire \sd_rd/sdCmd/spi_mosi_data[3] ;
wire \sd_rd/sdCmd/spi_mosi_data[2] ;
wire \sd_rd/sdCmd/spi_mosi_data[1] ;
wire \sd_rd/sdCmd/spi_mosi_data[0] ;
wire \sd_rd/sdCmd/recv_data_ready ;
wire \sd_rd/istate[4] ;
wire \sd_rd/istate[3] ;
wire \sd_rd/istate[2] ;
wire \sd_rd/istate[1] ;
wire \sd_rd/istate[0] ;
wire \sd_rd/state[3] ;
wire \sd_rd/state[2] ;
wire \sd_rd/state[1] ;
wire \sd_rd/state[0] ;
wire \sd_rd/init_done ;
wire \sd_rd/lba_index[1] ;
wire \sd_rd/lba_index[0] ;
wire \debug_LBA_block[31] ;
wire \debug_LBA_block[30] ;
wire \debug_LBA_block[29] ;
wire \debug_LBA_block[28] ;
wire \debug_LBA_block[27] ;
wire \debug_LBA_block[26] ;
wire \debug_LBA_block[25] ;
wire \debug_LBA_block[24] ;
wire \debug_LBA_block[23] ;
wire \debug_LBA_block[22] ;
wire \debug_LBA_block[21] ;
wire \debug_LBA_block[20] ;
wire \debug_LBA_block[19] ;
wire \debug_LBA_block[18] ;
wire \debug_LBA_block[17] ;
wire \debug_LBA_block[16] ;
wire \debug_LBA_block[15] ;
wire \debug_LBA_block[14] ;
wire \debug_LBA_block[13] ;
wire \debug_LBA_block[12] ;
wire \debug_LBA_block[11] ;
wire \debug_LBA_block[10] ;
wire \debug_LBA_block[9] ;
wire \debug_LBA_block[8] ;
wire \debug_LBA_block[7] ;
wire \debug_LBA_block[6] ;
wire \debug_LBA_block[5] ;
wire \debug_LBA_block[4] ;
wire \debug_LBA_block[3] ;
wire \debug_LBA_block[2] ;
wire \debug_LBA_block[1] ;
wire \debug_LBA_block[0] ;
wire \sd_rd/sdCmd/spi_send_pulse ;
wire clk;
wire \sd_rd/sdCmd/recv_data_sendnext ;
wire \sd_rd/sd_cmd_busy ;
wire \sd_rd/sdCmd/spi/send ;
wire tms_pad_i;
wire tck_pad_i;
wire tdi_pad_i;
wire tdo_pad_o;
wire tms_i_c;
wire tck_i_c;
wire tdi_i_c;
wire tdo_o_c;
wire [9:0] control0;
wire [9:0] control1;
wire gao_jtag_tck;
wire gao_jtag_reset;
wire run_test_idle_er1;
wire run_test_idle_er2;
wire shift_dr_capture_dr;
wire update_dr;
wire pause_dr;
wire enable_er1;
wire enable_er2;
wire gao_jtag_tdi;
wire tdo_er1;

IBUF tms_ibuf (
    .I(tms_pad_i),
    .O(tms_i_c)
);

IBUF tck_ibuf (
    .I(tck_pad_i),
    .O(tck_i_c)
);

IBUF tdi_ibuf (
    .I(tdi_pad_i),
    .O(tdi_i_c)
);

OBUF tdo_obuf (
    .I(tdo_o_c),
    .O(tdo_pad_o)
);

GW_JTAG  u_gw_jtag(
    .tms_pad_i(tms_i_c),
    .tck_pad_i(tck_i_c),
    .tdi_pad_i(tdi_i_c),
    .tdo_pad_o(tdo_o_c),
    .tck_o(gao_jtag_tck),
    .test_logic_reset_o(gao_jtag_reset),
    .run_test_idle_er1_o(run_test_idle_er1),
    .run_test_idle_er2_o(run_test_idle_er2),
    .shift_dr_capture_dr_o(shift_dr_capture_dr),
    .update_dr_o(update_dr),
    .pause_dr_o(pause_dr),
    .enable_er1_o(enable_er1),
    .enable_er2_o(enable_er2),
    .tdi_o(gao_jtag_tdi),
    .tdo_er1_i(tdo_er1),
    .tdo_er2_i(1'b0)
);

gw_con_top  u_icon_top(
    .tck_i(gao_jtag_tck),
    .tdi_i(gao_jtag_tdi),
    .tdo_o(tdo_er1),
    .rst_i(gao_jtag_reset),
    .control0(control0[9:0]),
    .control1(control1[9:0]),
    .enable_i(enable_er1),
    .shift_dr_capture_dr_i(shift_dr_capture_dr),
    .update_dr_i(update_dr)
);

ao_top_0  u_la0_top(
    .control(control0[9:0]),
    .trig0_i(\sd_rd/sdCmd/spi_send_pulse ),
    .data_i({\sd_rd/sd_recv_data[7] ,\sd_rd/sd_recv_data[6] ,\sd_rd/sd_recv_data[5] ,\sd_rd/sd_recv_data[4] ,\sd_rd/sd_recv_data[3] ,\sd_rd/sd_recv_data[2] ,\sd_rd/sd_recv_data[1] ,\sd_rd/sd_recv_data[0] ,\sd_rd/sd_use_data_mode ,\sd_rd/sdCmd/spi_miso_data[7] ,\sd_rd/sdCmd/spi_miso_data[6] ,\sd_rd/sdCmd/spi_miso_data[5] ,\sd_rd/sdCmd/spi_miso_data[4] ,\sd_rd/sdCmd/spi_miso_data[3] ,\sd_rd/sdCmd/spi_miso_data[2] ,\sd_rd/sdCmd/spi_miso_data[1] ,\sd_rd/sdCmd/spi_miso_data[0] ,\sd_rd/sdCmd/cmd_id[5] ,\sd_rd/sdCmd/cmd_id[4] ,\sd_rd/sdCmd/cmd_id[3] ,\sd_rd/sdCmd/cmd_id[2] ,\sd_rd/sdCmd/cmd_id[1] ,\sd_rd/sdCmd/cmd_id[0] ,\sd_rd/sdCmd/spi_mosi_data[7] ,\sd_rd/sdCmd/spi_mosi_data[6] ,\sd_rd/sdCmd/spi_mosi_data[5] ,\sd_rd/sdCmd/spi_mosi_data[4] ,\sd_rd/sdCmd/spi_mosi_data[3] ,\sd_rd/sdCmd/spi_mosi_data[2] ,\sd_rd/sdCmd/spi_mosi_data[1] ,\sd_rd/sdCmd/spi_mosi_data[0] ,\sd_rd/sdCmd/recv_data_ready ,\sd_rd/istate[4] ,\sd_rd/istate[3] ,\sd_rd/istate[2] ,\sd_rd/istate[1] ,\sd_rd/istate[0] ,\sd_rd/state[3] ,\sd_rd/state[2] ,\sd_rd/state[1] ,\sd_rd/state[0] ,\sd_rd/init_done ,\sd_rd/lba_index[1] ,\sd_rd/lba_index[0] ,\debug_LBA_block[31] ,\debug_LBA_block[30] ,\debug_LBA_block[29] ,\debug_LBA_block[28] ,\debug_LBA_block[27] ,\debug_LBA_block[26] ,\debug_LBA_block[25] ,\debug_LBA_block[24] ,\debug_LBA_block[23] ,\debug_LBA_block[22] ,\debug_LBA_block[21] ,\debug_LBA_block[20] ,\debug_LBA_block[19] ,\debug_LBA_block[18] ,\debug_LBA_block[17] ,\debug_LBA_block[16] ,\debug_LBA_block[15] ,\debug_LBA_block[14] ,\debug_LBA_block[13] ,\debug_LBA_block[12] ,\debug_LBA_block[11] ,\debug_LBA_block[10] ,\debug_LBA_block[9] ,\debug_LBA_block[8] ,\debug_LBA_block[7] ,\debug_LBA_block[6] ,\debug_LBA_block[5] ,\debug_LBA_block[4] ,\debug_LBA_block[3] ,\debug_LBA_block[2] ,\debug_LBA_block[1] ,\debug_LBA_block[0] }),
    .clk_i(clk)
);

ao_top_1  u_la1_top(
    .control(control1[9:0]),
    .trig0_i(\sd_rd/sdCmd/spi/send ),
    .data_i({\sd_rd/istate[4] ,\sd_rd/istate[3] ,\sd_rd/istate[2] ,\sd_rd/istate[1] ,\sd_rd/istate[0] ,\sd_rd/sdCmd/spi_miso_data[7] ,\sd_rd/sdCmd/spi_miso_data[6] ,\sd_rd/sdCmd/spi_miso_data[5] ,\sd_rd/sdCmd/spi_miso_data[4] ,\sd_rd/sdCmd/spi_miso_data[3] ,\sd_rd/sdCmd/spi_miso_data[2] ,\sd_rd/sdCmd/spi_miso_data[1] ,\sd_rd/sdCmd/spi_miso_data[0] ,\sd_rd/sdCmd/recv_data_ready ,\sd_rd/sdCmd/recv_data_sendnext ,\sd_rd/sd_cmd_busy }),
    .clk_i(clk)
);

endmodule
