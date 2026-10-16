# verilog-basics  -  simulation targets
#
#   make            everything
#   make alu        a single module
#   make day5       one day
#   make clean      remove build artifacts

IV   = iverilog -g2005
VVP  = vvp

# ---------------- Day 1 : first modules ----------------
and:
	$(IV) -o sim_and.out and_gate.v and_gate_tb.v
	$(VVP) sim_and.out

mux2:
	$(IV) -o sim_mux2.out mux2_1bit.v mux2_tb.v
	$(VVP) sim_mux2.out

# ---------------- Day 2 : combinational ----------------
mux4:
	$(IV) -o sim_mux4.out mux4.v tb_mux4.v
	$(VVP) sim_mux4.out

decoder:
	$(IV) -o sim_decoder.out decoder3to8.v tb_decoder3to8.v
	$(VVP) sim_decoder.out

adder:
	$(IV) -o sim_adder.out ripple_carry_adder.v tb_ripple_carry_adder.v
	$(VVP) sim_adder.out

# ---------------- Day 3 : sequential ----------------
dff:
	$(IV) -o sim_dff.out dff.v tb_dff.v
	$(VVP) sim_dff.out

shift:
	$(IV) -o sim_shift.out shift_reg8.v tb_shift_reg8.v
	$(VVP) sim_shift.out

counter:
	$(IV) -o sim_counter.out counter_mod10.v tb_counter_mod10.v
	$(VVP) sim_counter.out

# ---------------- Day 4 : finite state machines ----------------
seq:
	$(IV) -o sim_seq.out seq_detector.v tb_seq_detector.v
	$(VVP) sim_seq.out

traffic:
	$(IV) -o sim_traffic.out traffic_light.v tb_traffic_light.v
	$(VVP) sim_traffic.out

# ---------------- Day 5 : ALU and FIFO ----------------
# alu pulls in ripple_carry_adder.v from Day 2 - it instantiates it
alu:
	$(IV) -o sim_alu.out alu.v ripple_carry_adder.v tb_alu.v
	$(VVP) sim_alu.out

fifo:
	$(IV) -o sim_fifo.out sync_fifo.v tb_sync_fifo.v
	$(VVP) sim_fifo.out

# ---------------- aggregates ----------------
day1: and mux2
day2: mux4 decoder adder
day3: dff shift counter
day4: seq traffic
day5: alu fifo
all:  day1 day2 day3 day4 day5

clean:
	rm -f *.out *.vcd

.PHONY: all day1 and mux2 day2 day3 day4 day5 mux4 decoder adder dff shift counter seq traffic alu fifo clean
