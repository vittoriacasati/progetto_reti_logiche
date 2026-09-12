# Definisce un clock a 100 MHz (periodo 10 ns) sulla porta chiamata 'CLK'
create_clock -period 10.000 -name sys_clk_pin -waveform {0.000 5.000} [get_ports CLK]