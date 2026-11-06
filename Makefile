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
	$(RTL_DIR)/minisoc_aes/minisoc_aes_shift_rows.sv \
	$(RTL_DIR)/minisoc_aes/minisoc_aes_mix_columns.sv \
	$(RTL_DIR)/minisoc_aes/minisoc_aes_add_round_key.sv \
	$(RTL_DIR)/minisoc_aes/minisoc_aes_inv_sbox.sv \
	$(RTL_DIR)/minisoc_aes/minisoc_aes_inv_sub_bytes.sv \
	$(RTL_DIR)/minisoc_aes/minisoc_aes_inv_shift_rows.sv \
	$(RTL_DIR)/minisoc_aes/minisoc_aes_inv_mix_columns.sv


TB_FILES = \
	$(TB_DIR)/minisoc_aes/tb_semana02.sv \
	$(TB_DIR)/minisoc_aes/tb_semana03_round_transformations.sv \
	$(TB_DIR)/minisoc_aes/tb_semana03_inverse_transformations.sv

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
	vcs -full64 -debug_access+all -kdb -o simv_semana02 $(TOP)

	
# ==========================================
# 3. Rodar simulação
# ==========================================
run: compile
	./simv_semana02
	$(MAKE) run_semana03
	$(MAKE) run_semana03_inverse

run_semana02: compile
	./simv_semana02

compile_semana03: syntax
	vcs -full64 -debug_access+all -kdb -o simv_semana03 tb_semana03_round_transformations

run_semana03_inverse: syntax
	vcs -full64 -debug_access+all -kdb -o simv_semana03_inverse tb_semana03_inverse_transformations
	./simv_semana03_inverse

run_semana03: compile_semana03
	./simv_semana03


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