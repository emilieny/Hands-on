# ==========================================
# Diretórios
# ==========================================
RTL_DIR = rtl
TB_DIR  = tb

# ==========================================
# Arquivos
# ==========================================
RTL_FILES = $(RTL_DIR)/porta_and.sv
TB_FILES  = $(TB_DIR)/tb_porta_and.sv

# Top do testbench
TOP = tb_porta_and

# ==========================================
# 1. Verificação de sintaxe
# ==========================================
syntax:
	vlogan -full64 -sverilog -kdb +lint=all $(RTL_FILES) $(TB_FILES)

# ==========================================
# 2. Compilação / Elaboração
# ==========================================
compile: syntax
	vcs -full64 -debug_access+all -kdb $(TOP)
# ==========================================
# 3. Rodar simulação
# ==========================================
run: compile
	./simv

# ==========================================
# Abrir waveform no Verdi
# ==========================================
wave:
	verdi -ssf waves.fsdb &

# ==========================================
# Limpeza
# ==========================================
clean:
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
	    *.log