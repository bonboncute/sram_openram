SIMV=out/simv
VCD=out/dump.vcd
RTL=rtl/sram_behav.v rtl/mem_ctrl.v
TB=tb/tb_top.v

sim:
	iverilog -g2012 -o $(SIMV) $(RTL) $(TB)
	$(SIMV)
	@echo "VCD: $(VCD)"
view:
	gtkwave $(VCD) &
clean:
	rm -f $(SIMV) $(VCD) out/*.log
