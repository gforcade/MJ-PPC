# $Id: PhysicalConstants.tcl,v 1.3 2007/08/31 10:21:30 sameers Exp $
# Fundamental Physical Constants
# Reference: http://www.ioffe.rssi.ru/SVA/NSM/Constants/index.html
# History: Created on 2007/06/08 by Sameer Shah

set ::h    6.62606876e-34       ;# [J-s]
set ::kB   1.3806503e-23        ;# [J-K^-1]
set ::q    1.602176462e-19      ;# Coulomb  
set ::kBeV [expr {$::kB/$::q}]	;# [eV-K^-1]
set ::heV [expr {$::h/$::q}]	;# [eV-s]
set ::m0   9.10938188e-31       ;# [kg]
set ::eps0 8.854187817e-12      ;# [F-m^-1]
set ::pi   [expr {2*asin(1.0)}] ;# [1]
set ::c 299792458               ;# [m/s]
