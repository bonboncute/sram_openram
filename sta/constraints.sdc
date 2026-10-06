create_clock -name clk -period 10 [get_ports clk]
set_input_delay 1.0 -clock clk [get_ports {psel penable pwrite paddr[*] pwdata[*] s_dout[*]}]
set_output_delay 1.0 -clock clk [get_ports {prdata[*] pready s_cs s_we s_addr[*] s_din[*]}]
set_false_path -from [get_ports rstn]
