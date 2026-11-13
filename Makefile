# ==========================================
# Diretorios
# ==========================================
RTL_DIR = rtl
TB_DIR  = tb

# ==========================================
# Arquivos RTL
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
	$(RTL_DIR)/minisoc_aes/minisoc_aes_inv_mix_columns.sv \
	$(RTL_DIR)/minisoc_aes/minisoc_aes_key_exp.sv \
	$(RTL_DIR)/minisoc_aes/minisoc_aes_dp.sv

# ==========================================
# Arquivos de testbench
# ==========================================
TB_SEMANA02 = $(TB_DIR)/minisoc_aes/tb_semana02.sv
TB_SEMANA03 = \
	$(TB_DIR)/minisoc_aes/tb_semana03_round_transformations.sv \
	$(TB_DIR)/minisoc_aes/tb_semana03_inverse_transformations.sv
TB_SEMANA04 = $(TB_DIR)/minisoc_aes/tb_semana04_aes128.sv

# ==========================================
# Top dos testbenches
# ==========================================
TOP_SEMANA02 = tb_semana02
TOP_SEMANA03 = tb_semana03_round_transformations
TOP_SEMANA03_INVERSE = tb_semana03_inverse_transformations
TOP_SEMANA04 = tb_semana04_aes128

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

.PHONY: all syntax run \
	compile_semana02 run_semana02 wave_semana02 \
	compile_semana03 run_semana03 wave_semana03 \
	compile_semana03_inverse run_semana03_inverse wave_semana03_inverse \
	compile_semana04 run_semana04 wave_semana04 \
	clean_sim clean

# ==========================================
# Verificacao de sintaxe
# ==========================================
syntax:
	vlogan $(VLOGAN_FLAGS) \
		$(RTL_FILES) \
		$(TB_SEMANA02) \
		$(TB_SEMANA03) \
		$(TB_SEMANA04)

# ==========================================
# Semana 02 - S-box, SubBytes e ShiftRows
# ==========================================
compile_semana02: syntax
	vcs $(VCS_FLAGS) -top $(TOP_SEMANA02) -o simv_semana02

run_semana02: compile_semana02
	./simv_semana02

wave_semana02:
	verdi -ssf waves_semana02.fsdb &

# ==========================================
# Semana 03 - Transformacoes de rodada
# ==========================================
compile_semana03: syntax
	vcs $(VCS_FLAGS) -top $(TOP_SEMANA03) -o simv_semana03

run_semana03: compile_semana03
	./simv_semana03

wave_semana03:
	verdi -ssf waves_semana03_round.fsdb &

# ==========================================
# Semana 03 - Transformacoes inversas
# ==========================================
compile_semana03_inverse: syntax
	vcs $(VCS_FLAGS) -top $(TOP_SEMANA03_INVERSE) -o simv_semana03_inverse

run_semana03_inverse: compile_semana03_inverse
	./simv_semana03_inverse

wave_semana03_inverse:
	verdi -ssf waves_semana03_inverse.fsdb &

# ==========================================
# Semana 04 - Expansao de chave e AES-128
# ==========================================
compile_semana04: syntax
	vcs $(VCS_FLAGS) -top $(TOP_SEMANA04) -o simv_semana04

run_semana04: compile_semana04
	./simv_semana04

wave_semana04:
	verdi -ssf waves_semana04_aes128.fsdb &

# ==========================================
# Executar todas as semanas
# ==========================================
all: run

run: run_semana02 \
	 run_semana03 \
	 run_semana03_inverse \
	 run_semana04

# ==========================================
# Limpeza da simulacao
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
		*.log

# ==========================================
# Limpeza total
# ==========================================
clean: clean_sim
