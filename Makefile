# ==========================================
# Diretórios
# ==========================================
RTL_DIR = rtl
TB_DIR  = tb

# ==========================================
# Arquivos
# ==========================================
RTL_FILES = \
	$(RTL_DIR)/minisoc_aes/minisoc_aes_sbox.sv \
	$(RTL_DIR)/minisoc_aes/minisoc_aes_sub_bytes.sv \
	$(RTL_DIR)/minisoc_aes/minisoc_aes_shift_rows.sv


TB_FILES = \
	$(TB_DIR)/minisoc_aes/tb_semana02.sv

# Top do testbench
TOP = tb_semana02

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