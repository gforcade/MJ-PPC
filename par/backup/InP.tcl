!(
#-------------------------------
# Simply used provided paramter file InP.par
#-------------------------------
set fd [open ../par/InP.par]
while {[gets $fd line] >=0} {
   puts $line
}
close $fd
