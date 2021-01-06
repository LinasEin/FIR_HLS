add wave -hex -group "FIRFilterStreaming_top" -group "ports"  {*}[lsort [find nets -ports [lindex [find instances -bydu FIRFilterStreaming_top] 0]/*]]
add wave -hex -group "FIRFilterStreaming_top" -group "FIRFilterStreaming" -group "ports"  {*}[lsort [find nets -ports [lindex [find instances -r /FIRFilterStreaming_inst] 0]/*]]
