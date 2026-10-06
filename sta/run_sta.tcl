read_liberty tech/Nangate45_typ.lib
read_liberty out/sram_1kb_32b_TT_1p0V_25C.lib
read_verilog build/mem_ctrl_gate.v
link_design mem_ctrl
read_sdc constraints/constraints.sdc
report_checks -path_delay min_max -fields {slew cap input_pins} > build/sta_report.txt
report_worst_slack > build/sta_worst_slack.txt
report_tns > build/sta_tns.txt
