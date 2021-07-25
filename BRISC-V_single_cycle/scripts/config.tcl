# User config
set ::env(DESIGN_NAME) RISC_V_Core
# Change if needed
set ::env(VERILOG_FILES) [glob $::env(DESIGN_DIR)/src/*.v]

# Fill this
set ::env(CLOCK_PERIOD) "160"
set ::env(CLOCK_PORT) "clock"

set filename $::env(DESIGN_DIR)/$::env(PDK)_$::env(STD_CELL_LIBRARY)_config.tcl
if { [file exists $filename] == 1} {
        source $filename
}


set ::env(FP_PDN_CHECK_NODES) 0
set ::env(CTS_REPORT_TIMING)
#set ::env(SYNTH_STRATEGY) "DELAY 0"
set ::env(GENERATE_FINAL_SUMMARY_REPORT) 1
set ::env(GLB_RT_ADJUSTMENT) 0.9
set ::env(DIE_AREA) "0 0 1565.595 1576.315"
set ::env(FP_PDN_CORE_RING) 0
set ::env(PL_TARGET_DENSITY) 0.55
# Go fast
set ::env(ROUTING_CORES) 6

# It's overly worried about congestion, but it's fine
set ::env(GLB_RT_ALLOW_CONGESTION) 1

# Avoid li1 for routing if possible
set ::env(GLB_RT_MINLAYER) 2

# Don't route on met5
set ::env(GLB_RT_MAXLAYER) 5
set filename $::env(DESIGN_DIR)/$::env(PDK)_$::env(STD_CELL_LIBRARY)_config.tcl
if { [file exists $filename] == 1} {
	source $filename
}

