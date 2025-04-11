#----------------------------------------------------------------------#
# $Id: Default.tcl,v 1.1 2007/08/10 12:17:11 sameers Exp $
#----------------------------------------------------------------------#
#! MODEL: Temperature dependent model from sdevice
#! MATERIAL: GaAs
#! PROPERTY: Thermal conductivity
#! EXPRESSION: 
#! kappa(T) = kappa + kappa_b * T + kappa_c * T^2 
#! CALCULATED PARAMETER: 
#! kappa_T returns thermal conductivity
#! VALIDITY: 
#! NOTES:
#! SDEVICE: ThermalConductivity
#! REFERENCE:
#! Sentaurus Device User Guide 

namespace eval GaAs::Kappa {
  proc init {} {
      variable kappa 0.46 
      variable kappa_b 0.01
      variable kappa_c 0.01
      variable kappa_T
      set kappa_T [expr {$kappa + $kappa_b * $::temp + $kappa_c * $::temp * $::temp }]
  }
  proc print {} {printPar::Kappa1Section}  
}
GaAs::Kappa::init

