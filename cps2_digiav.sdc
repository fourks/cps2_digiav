### Clocks ###

create_clock -period 147MHz -name clk_1080p [get_ports PCLK_SI]
create_clock -period 10.74MHz -name pclk [get_ports PCLK_in]
create_clock -period 1.2MHz -name clk5 [get_ports I2S_BCK]
create_clock -period 24.576MHz -name mclk [get_ports MCLK_SI]

#derive_pll_clocks
#create_generated_clock -source {pll_pclk_inst|altpll_component|auto_generated|pll1|inclk[0]} -multiply_by 3 -duty_cycle 50.00 -name clk25 {pll_pclk_inst|altpll_component|auto_generated|pll1|clk[0]}
#create_generated_clock -source {pll_pclk_inst|altpll_component|auto_generated|pll1|inclk[0]} -multiply_by 5 -duty_cycle 50.00 -name pclk_5x {pll_pclk_inst|altpll_component|auto_generated|pll1|clk[1]}

create_generated_clock -source [get_ports MCLK_SI] -divide_by 8 -multiply_by 1 -duty_cycle 50.00 -name i2s_clkout {i2s_upsampler_asrc:upsampler0|i2s_tx_asrc:i2s_tx|mclk_div_ctr[1]}
derive_clock_uncertainty


### IO constraints ###

set critinputs [get_ports {R_in* G_in* B_in* HSYNC_in VSYNC_in}]
set_input_delay -clock pclk -min 0 $critinputs
set_input_delay -clock pclk -max 1.5 $critinputs

set i2s_inputs [get_ports {I2S_WS I2S_DATA}]
set_input_delay -clock clk5 -min 0 $i2s_inputs
set_input_delay -clock clk5 -max 1.5 $i2s_inputs

set_input_delay -clock mclk 0 [get_ports {sda HDMI_TX_INT_N BTN*}]

set critoutputs_hdmi {HDMI_TX_RD* HDMI_TX_GD* HDMI_TX_BD* HDMI_TX_DE HDMI_TX_HS HDMI_TX_VS}
set i2soutputs_hdmi {HDMI_TX_I2S_DATA HDMI_TX_I2S_WS}
set_output_delay -reference_pin HDMI_TX_PCLK -clock clk_1080p 0 $critoutputs_hdmi
set_output_delay -reference_pin HDMI_TX_I2S_BCK -clock i2s_clkout 0 $i2soutputs_hdmi
set_false_path -to [remove_from_collection [all_outputs] "$critoutputs_hdmi $i2soutputs_hdmi"]


### CPU/scanconverter clock relations ###

set_clock_groups -exclusive \
-group {clk5 i2s_clkout} \
-group {pclk} \
-group {clk_1080p} \
-group {mclk}

set_false_path -from [get_clocks i2s_clkout] -to [get_clocks clk5]

# Ignore paths from registers which are updated only at the end of vsync
#set_false_path -from [get_cells {scanconverter_inst|H_* scanconverter_inst|V_* scanconverter_inst|X_*}]


### JTAG Signal Constraints ###

#constrain the TCK port
#create_clock -name tck -period "10MHz" [get_ports altera_reserved_tck]
#cut all paths to and from tck
set_clock_groups -exclusive -group [get_clocks altera_reserved_tck]
#constrain the TDI port
set_input_delay -clock altera_reserved_tck 20 [get_ports altera_reserved_tdi]
#constrain the TMS port
set_input_delay -clock altera_reserved_tck 20 [get_ports altera_reserved_tms]
#constrain the TDO port
#set_output_delay -clock altera_reserved_tck 20 [get_ports altera_reserved_tdo]
