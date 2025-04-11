#----------------------------------------------------------------------#
# $Id: Piprek.tcl,v 1.1 2007/08/10 12:17:11 sameers Exp $
#----------------------------------------------------------------------#
#! MODEL: Temperature dependent model from Piprek
#! MATERIAL: GaAs
#! PROPERTY: Thermal conductivity
#! EXPRESSION: 
#! kappa(T) = kappa300*(T/300)^deltak
#! CALCULATED PARAMETER: 
#! kappa_T returns thermal conductivity
#! VALIDITY: This model is valid only for temperatures near room temperature
#! NOTES:
#! SDEVICE: ThermalConductivity
#! REFERENCE:
#! "Semiconductor Optoelectronic Devices: Introduction to Physics and Simulation", J. Piprek, Elsevier Science(USA), 2003

namespace eval GaAs::Kappa {
  proc init {} {
# parameters from Piprek
      set kappa300 0.44 
      set deltak -1.25

# sdevice parameters
      variable kappa
      variable kappa_b 0.0
      variable kappa_c 0.0

# calculation of temperature dependent thermal conductivity
      variable kappa_T
      set kappa_T [expr {$kappa300 * pow($::temp/300.0, $deltak) }]
      set kappa $kappa_T
  }
  proc print {} {printPar::Kappa1Section}  
}
GaAs::Kappa::init

