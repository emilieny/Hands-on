# ============================================================
# Clocks do sistema AES via SPI
# ============================================================

# Valores iniciais: sistema a 50 MHz e SPI a 10 MHz.
create_clock -name clk_sys -period 20 [get_ports clk_sys]
create_clock -name sclk -period 100 [get_ports sclk]

set_clock_uncertainty 0.5 [get_clocks clk_sys]
set_clock_uncertainty 2.5 [get_clocks sclk]
set_clock_transition 0.1 [get_clocks clk_sys]
set_clock_transition 0.5 [get_clocks sclk]

# SPI e sistema são domínios assíncronos; a travessia é feita pelo bloco sync.
set_clock_groups -asynchronous \
	-group [get_clocks clk_sys] \
	-group [get_clocks sclk]

# ============================================================
# Atrasos de entrada e saída
# ============================================================
set system_inputs [remove_from_collection [all_inputs] [get_ports {clk_sys sclk}]]
set_input_delay 3.0 -clock clk_sys $system_inputs
set_input_delay 10.0 -clock sclk [get_ports {cs_n mosi}]
set_output_delay 3.0 -clock clk_sys [get_ports {miso}]

# ============================================================
# Modelo inicial de carga e acionamento
# ============================================================
set_max_fanout 8 [current_design]
set_load 0.05 [all_outputs]
set_driving_cell -lib_cell INVX1 $system_inputs