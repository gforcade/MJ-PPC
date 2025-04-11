# Plot light J-V and P-V curves and extract Photovoltaic parameters 
# or Plot dark J-V characteristics 

# #setdep @node|-2@

set N     @node@
set i     @node:index@
# Conversion constant to get units of J mA/cm^2
## set jConv [expr 1e11 / @wtot@]
set jConv 1.0 

# proj_load  @plot@ PLT_JV($N)
proj_load  n@previous@_des.plt PLT_JV($N)

#- Automatic alternating color assignment tied to node index
#----------------------------------------------------------------------#
set COLORS  [list orange green blue red violet brown orange magenta]
set NCOLORS [llength $COLORS]
set color   [lindex  $COLORS [expr $i%$NCOLORS]]

# Plot light J-V characteristics and extract PV parameters
cv_create Jdata($N)  "PLT_JV($N) anode OuterVoltage" "PLT_JV($N) anode TotalCurrent"
cv_write plt gaJdata.plt Jdata($N) 
set vlt [cv_getValsX "Jdata($N)"]
set cur [cv_getValsY "Jdata($N)"]
# convert to absolute values and compute power
set Pm($N) 0
set numPoints [llength $vlt]
set lastJ 1.0 
set Voc($N) 0.0
for {set ix 0} {$ix < $numPoints} {incr ix} {
  set v [lindex $vlt $ix]
  set j [expr $jConv * (-[lindex $cur $ix])]
  lset cur $ix $j
  #Compute Power and save in list
  set p [expr $v * $j]
  lappend pwr $p 
  # Determining maximum power point
  if {$p > $Pm($N)} { set Pm($N) $p }
  # Jsc - should always have $v = 0.0
  if {$v == 0.0} {set Jsc($N) $j}
  # Voc - need to find j close to 0
  if { $Voc($N) == 0.0 } {
     if {$j == 0.0 || $j < 1e-6 } {
        set Voc($N) $v
     } elseif { [expr $j * $lastJ] < 0.0 } {
        set Voc($N) [expr ($v + $lastv)/2.0]
     } else {
        set lastJ $j
        set lastV $v
     }
  }
}
puts "Voc=$Voc($N), Jsc=$Jsc($N)"
# Compute Fill Factor
#Compute FillFactor
set FF($N) [expr $Pm($N)/($Voc($N)*$Jsc($N))*100]
#Compute Efficiency Eff

set conc @concentration@

set Ps [expr 0.1*$conc]  ;#Incident light power density for 1-sun radiation in W/cm^2
set Eff($N) [expr $Pm($N)*100.0/$Ps]

#Create curves for display
cv_createFromScript J($N) $vlt $cur
cv_createFromScript P($N) $vlt $pwr
cv_setCurveAttr J($N)  "light-JV" $color solid  2 circle 3 defcolor 1 defcolor
cv_setCurveAttr P($N)  "light-PV" $color dashed  2 none 3 defcolor 1 defcolor

gr_setAxisAttr X {Voltage (V)}  16 0 {} black 1 14 0 5 0
gr_setAxisAttr Y {Current Density (A/cm^2)} 16 0 {}  black 1 14 0 5 0

# Display the curves
cv_display J($N)

# For display in Work Bench
ft_scalar Jsc [format %.4f $Jsc($N)]
ft_scalar Voc [format %.4f $Voc($N)]
ft_scalar FF  [format %.4f $FF($N)]
ft_scalar Eff  [format %.4f $Eff($N)]


