# ============================================================
# Script de Síntese
# ============================================================

# ============================================================
# Configuração do projeto
# ============================================================

set TOP aes_spi_top
set RTL_FILES [concat \
  [glob -nocomplain rtl/aes/*.sv] \
  [glob -nocomplain rtl/spi/*.sv] \
  [glob -nocomplain rtl/sync/*.sv] \
  [glob -nocomplain rtl/reg_file/*.sv] \
  [glob -nocomplain rtl/power_ctrl/*.sv] \
  [glob -nocomplain rtl/${TOP}.sv]]

if {[llength $RTL_FILES] == 0} {
  error "Nenhum arquivo SystemVerilog encontrado em rtl/."
}

# ------------------------------------------------------------
# Ler RTL
# ------------------------------------------------------------

analyze -format sverilog $RTL_FILES

# ------------------------------------------------------------
# Elaborar
# ------------------------------------------------------------

elaborate $TOP
link

# ------------------------------------------------------------
# Constraints
# ------------------------------------------------------------

read_sdc syn/constraints.sdc

# ------------------------------------------------------------
# Verificação do design
# ------------------------------------------------------------

puts "\n=================================================="
puts "CHECK DESIGN"
puts "=================================================="

file mkdir syn/reports
redirect syn/reports/check_design.rpt {
  check_design
}

# ------------------------------------------------------------
# Relatórios pré-síntese
# ------------------------------------------------------------

file mkdir syn/reports
redirect syn/reports/area_pre.rpt {
  report_area -hierarchy
}

redirect syn/reports/timing_pre.rpt {
  report_timing -max_paths 10
}

# ------------------------------------------------------------
# Síntese
# ------------------------------------------------------------

puts "\n=================================================="
puts "INICIANDO SÍNTESE"
puts "=================================================="

file mkdir syn/reports
set_svf syn/reports/default.svf
set_max_area 0
compile_ultra -no_autoungroup

# ------------------------------------------------------------
# Relatórios pós-síntese
# ------------------------------------------------------------

file mkdir syn/reports
redirect syn/reports/area_pos.rpt {
  report_area -hierarchy
}

redirect syn/reports/timing_relatorio.rpt {
  report_timing -max_paths 10
}

redirect syn/reports/power.rpt {
  report_power
}

redirect syn/reports/setup_violations.rpt {
  report_constraint -all_violators
}

# ------------------------------------------------------------
# Exportar netlist
# ------------------------------------------------------------

write -format verilog -hierarchy -output syn/${TOP}_netlist.v
write -format verilog -hierarchy -output syn/${TOP}_syn.v
write -format ddc -hierarchy -output syn/${TOP}_syn.ddc
write_file -format ddc -hierarchy -output syn/${TOP}.ddc

puts "\n=================================================="
puts "SÍNTESE CONCLUÍDA"
puts "=================================================="
puts "Arquivos gerados:"
puts "  syn/reports/area_pos.rpt"
puts "  syn/reports/timing_relatorio.rpt"
puts "  syn/reports/power.rpt"
puts "  syn/reports/setup_violations.rpt"
puts "  syn/reports/default.svf"
puts "  syn/${TOP}_netlist.v"
puts "  syn/${TOP}_syn.v"
puts "  syn/${TOP}_syn.ddc"
puts "=================================================="