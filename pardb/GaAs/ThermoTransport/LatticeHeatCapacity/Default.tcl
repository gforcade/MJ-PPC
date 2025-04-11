#----------------------------------------------------------------------#
# $Id: Default.tcl,v 1.1 2007/08/10 12:17:11 sameers Exp $
#----------------------------------------------------------------------#
#! MODEL: Temperature dependent model from sdevice
#! MATERIAL: GaAs
#! PROPERTY: Lattice Heat Capacity
#! EXPRESSION: 
#! cv(T) = cv + cv_b * T + cv_c * T^2 + cv_d * T^3
#! CALCULATED PARAMETER: 
#! cv_T returns heat capacity
#! VALIDITY: 
#! NOTES:
#! SDEVICE: HeatCapacity(TempDep)
#! REFERENCE:
#! Sentaurus Device User Guide 

namespace eval GaAs::LatticeHeatCapacity {
  proc init {} {
      variable cv 1.6 
      variable cv_b 0.0
      variable cv_c 0.0
      variable cv_d 0.0 
      variable cv_T
      set cv_T [expr {$cv + $cv_b * $::temp + $cv_c * $::temp * $::temp + $cv_d * pow($::temp,3) }]
  }
  proc print {} {printPar::LatticeHeatCapacitySection}  
}
GaAs::LatticeHeatCapacity::init

