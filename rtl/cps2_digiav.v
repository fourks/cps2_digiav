//
// Copyright (C) 2016-2019  Markus Hiienkari <mhiienka@niksula.hut.fi>
//
// This file is part of CPS2 Digital AV Interface project.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
//

module cps2_digiav(
    input [3:0] R_in,
    input [3:0] G_in,
    input [3:0] B_in,
    input [3:0] F_in,
    input CSYNC_in,
    input PCLK2x_in,
    input MCLK_SI,
    input PCLK_SI,
    input YM_o1,
    input YM_SH1,
    input YM_SO,
    input WM_SO,
    input BTN_volminus,
    input BTN_volplus,
    inout sda,
    output scl,
    //output HDMI_TX_RST_N,
    output [7:0] HDMI_TX_RD,
    output [7:0] HDMI_TX_GD,
    output [7:0] HDMI_TX_BD,
    output HDMI_TX_DE,
    output HDMI_TX_HS,
    output HDMI_TX_VS,
    output HDMI_TX_PCLK,
    input HDMI_TX_INT_N,
    output HDMI_TX_I2S_DATA,
    output HDMI_TX_I2S_BCK,
    output HDMI_TX_I2S_WS
    //output HDMI_TX_I2S_MCLK
);

reg reset_n = 1'b0;
reg [3:0] reset_n_ctr;

reg [3:0] R_in_L, G_in_L, B_in_L, F_in_L;
reg CSYNC_in_L, CSYNC_in_L_prev, HSYNC, VSYNC;
reg [9:0] hsync_ctr;

reg WM_LRCLK;

reg sg_reset_n_L, sg_reset_n_LL;
reg sg_hsync_ref_L, sg_hsync_ref_LL;
reg sg_vsync_ref_L, sg_vsync_ref_LL;


wire [31:0] h_info, v_info, x_info;

wire [7:0] R_out, G_out, B_out;
wire HSYNC_out;
wire VSYNC_out;
wire PCLK_out;
wire DE_out;

wire v_change;
wire clk25;

wire I2S_WS_2x;
wire I2S_DATA_2x;
wire I2S_BCK_out;
wire [7:0] clkcnt_out;

wire [11:0] hcnt_sg;
wire [10:0] vcnt_sg;
wire [8:0] hcnt_sg_lbuf;
wire [5:0] vcnt_sg_lbuf;
wire [2:0] hctr_sg, vctr_sg;
wire HSYNC_sg, VSYNC_sg, DE_sg, mask_enable_sg;

wire BTN_volminus_debounced;
wire BTN_volplus_debounced;


// Latch inputs syncronized to PCLKx2_in (negedge)
always @(negedge PCLK2x_in or negedge reset_n)
begin
    if (!reset_n) begin
        R_in_L <= 4'h0;
        G_in_L <= 4'h0;
        B_in_L <= 4'h0;
        F_in_L <= 4'h0;
        CSYNC_in_L <= 1'b0;
    end else begin
        R_in_L <= R_in;
        G_in_L <= G_in;
        B_in_L <= B_in;
        F_in_L <= F_in;
        CSYNC_in_L <= CSYNC_in;
    end
end

always @(posedge PCLK2x_in or negedge reset_n) begin
    if (!reset_n) begin
        HSYNC <= 1'b1;
        VSYNC <= 1'b1;
    end else begin
        if ((CSYNC_in_L_prev == 1'b1) && (CSYNC_in_L == 1'b0))
            hsync_ctr <= 0;
        else
            hsync_ctr <= hsync_ctr + 1'b1;

        if (hsync_ctr == 128)
            VSYNC <= CSYNC_in_L;

        CSYNC_in_L_prev <= CSYNC_in_L;
        HSYNC <= (hsync_ctr < 64) ? 1'b0 : 1'b1;
    end
end

always @(negedge YM_SH1) begin
    WM_LRCLK <= ~WM_LRCLK;
end

always @(posedge clk25) begin
    if (reset_n_ctr == 4'hf)
        reset_n <= 1'b1;
    else
        reset_n_ctr <= reset_n_ctr + 1'b1;
end

//assign HDMI_TX_RST_N = reset_n;
assign HDMI_TX_DE = DE_out;
assign HDMI_TX_PCLK = PCLK_out;
assign HDMI_TX_HS = HSYNC_out;
assign HDMI_TX_VS = VSYNC_out;
assign HDMI_TX_I2S_DATA = I2S_DATA_2x;
assign HDMI_TX_I2S_BCK = I2S_BCK_out;
assign HDMI_TX_I2S_WS = I2S_WS_2x;
//assign HDMI_TX_I2S_MCLK = 0;
assign HDMI_TX_RD = R_out;
assign HDMI_TX_GD = G_out;
assign HDMI_TX_BD = B_out;

always @(posedge PCLK_SI) begin
    sg_reset_n_L <= x_info[31] & ~v_change;
    sg_reset_n_LL <= sg_reset_n_L;
    sg_hsync_ref_L <= HSYNC;
    sg_hsync_ref_LL <= sg_hsync_ref_L;
    sg_vsync_ref_L <= VSYNC;
    sg_vsync_ref_LL <= sg_vsync_ref_L;
end

sys sys_inst(
    .clk_clk                            (clk25),
    .reset_reset_n                      (reset_n),
//    .pio_0_ctrl_in_export               ({BTN_volminus_debounced, BTN_volplus_debounced, 30'h0}),
    .pio_0_ctrl_in_export               ({1'b1, 1'b1, 30'h0}),
    .pio_1_h_info_out_export            (h_info),
    .pio_2_v_info_out_export            (v_info),
    .pio_3_x_info_out_export            (x_info),
    .i2c_opencores_0_export_scl_pad_io  (scl),
    .i2c_opencores_0_export_sda_pad_io  (sda)
);

scanconverter scanconverter_inst (
    .PCLK_in        (PCLK2x_in),
    .PCLK_ext       (PCLK_SI),
    .reset_n        (reset_n),
    .R_in           (R_in_L),
    .G_in           (G_in_L),
    .B_in           (B_in_L),
    .F_in           (F_in_L),
    .HSYNC_in       (HSYNC),
    .VSYNC_in       (VSYNC),
    .hcnt_ext       (hcnt_sg[10:0]),
    .vcnt_ext       (vcnt_sg),
    .hcnt_ext_lbuf  (hcnt_sg_lbuf),
    .vcnt_ext_lbuf  (vcnt_sg_lbuf),
    .hctr_ext       (hctr_sg),
    .vctr_ext       (vctr_sg),
    .v_change       (v_change),
    .HSYNC_ext      (HSYNC_sg),
    .VSYNC_ext      (VSYNC_sg),
    .DE_ext         (DE_sg),
    .mask_enable_ext(mask_enable_sg),
    .x_info         (x_info),
    .PCLK_out       (PCLK_out),
    .R_out          (R_out),
    .G_out          (G_out),
    .B_out          (B_out),
    .HSYNC_out      (HSYNC_out),
    .VSYNC_out      (VSYNC_out),
    .DE_out         (DE_out)
);

pll_pclk pll_pclk_inst (
    .inclk0 ( PCLK2x_in ),
    .c0 ( clk25 ),
    .locked ( )
);

syncgen u_sg (
    .PCLK           (PCLK_SI),
    .reset_n        (sg_reset_n_LL),
    .HSYNC_ref      (sg_hsync_ref_LL),
    .VSYNC_ref      (sg_vsync_ref_LL),
    .h_info         (h_info),
    .v_info         (v_info),
    .HSYNC_out      (HSYNC_sg),
    .VSYNC_out      (VSYNC_sg),
    .DE_out         (DE_sg),
    .hcnt           (hcnt_sg),
    .vcnt           (vcnt_sg),
    .hcnt_lbuf      (hcnt_sg_lbuf),
    .vcnt_lbuf      (vcnt_sg_lbuf),
    .mask_enable    (mask_enable_sg),
    .h_ctr          (hctr_sg),
    .v_ctr          (vctr_sg),
);

i2s_upsampler_asrc upsampler0 (
    .AMCLK_i        (MCLK_SI),
    .nARST          (reset_n),
    .ASCLK_i        (YM_o1),
    .ASDATA_i       (YM_SO),
    .ALRCLK_i       (YM_SH1),
    .ASCLK_WM_i     (YM_o1),
    .ASDATA_WM_i    (WM_SO),
    .ALRCLK_WM_i    (WM_LRCLK),
    .ASCLK_o        (I2S_BCK_out),
    .ASDATA_o       (I2S_DATA_2x),
    .ALRCLK_o       (I2S_WS_2x)
);

btn_debounce #(.MIN_PULSE_WIDTH(25000)) deb0 (
    .i_clk          (clk25),
    .i_btn          (BTN_volminus),
    .o_btn          (BTN_volminus_debounced)
);

btn_debounce #(.MIN_PULSE_WIDTH(25000)) deb1 (
    .i_clk          (clk25),
    .i_btn          (BTN_volplus),
    .o_btn          (BTN_volplus_debounced)
);

endmodule
