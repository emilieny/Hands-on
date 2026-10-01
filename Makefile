# ==========================================
# Diretórios
# ==========================================
RTL_DIR   = rtl
SIM_DIR   = tb
SYNTH_DIR = syn
DFT_DIR   = dft

# ==========================================
# Arquivos
# ==========================================
PKG_FILES =

RTL_FILES =

TB_FILES =

# ==========================================
# Top do testbench
# ==========================================
TOP =

# ==========================================
# Flags
# ==========================================
TIMESCALE = 1ns/1ps

VLOGAN_FLAGS = -full64 \
		       -sverilog \
		       -kdb \
		       +lint=all

VCS_FLAGS = -full64 \
		    -timescale=$(TIMESCALE) \
		    -debug_access+all \
		    -kdb

# ==========================================
# Verificação de sintaxe
# ==========================================
syntax:
	vlogan $(VLOGAN_FLAGS) \
		$(PKG_FILES) \
		$(RTL_FILES) \
		$(TB_FILES)

# ==========================================
# Compilação / Elaboração
# ==========================================
compile: syntax
	vcs $(VCS_FLAGS) -top $(TOP)

# ==========================================
# Simulação
# ==========================================
run: compile
	./simv

# ==========================================
# Abrir waveform
# ==========================================
wave:
	verdi -ssf waves.fsdb &

# ==========================================
# Síntese
# ==========================================
synth:
	dc_shell -f $(SYNTH_DIR)/synth.tcl

# ==========================================
# Síntese DFT
# ==========================================
.PHONY: dft
dft:
	dc_shell -f $(DFT_DIR)/dft_insert.tcl

# ==========================================
# Limpeza da síntese
# ==========================================
clean_synth:
	rm -rf \
		./alib-52 \
		./default.svf \
		./work* \
		$(SYNTH_DIR)/*.rpt \
		$(SYNTH_DIR)/*.ddc \
		$(SYNTH_DIR)/*.db \
		$(SYNTH_DIR)/*_syn.v

# ==========================================
# Limpeza da simulação
# ==========================================
clean_sim:
	rm -rf \
		csrc \
		simv* \
		*.daidir \
		novas* \
		AN.DB \
		ucli.key \
		verdi* \
		DVEfiles \
		.vlogan* \
		*.fsdb \
		*.log \
		*.pvl \
		*.svf \
		FM_INFO \
		cksum_dir \
		*.mr \
		*.syn

# ==========================================
# Limpeza total
# ==========================================
clean: clean_sim clean_synth

.PHONY: syntax compile run wave synth clean clean_sim clean_synth