#----------------------------------------------------------------------#
# $Id: Strzalkowski.tcl,v 1.1 2007/08/10 12:17:09 sameers Exp $
#----------------------------------------------------------------------#
#! MODEL: Temperature dependent model from Strzalkowski
#! MATERIAL: GaAs
#! PROPERTY: Static dielectric permittivity
#! EXPRESSION: 
#! Static dielectric permittivity is calculated using
#!     epsilon(T) = epsilon(Tpar)*(1+lambda*T)/(1+lambda*Tpar) 
#! CALCULATED PARAMETER: 
#! epsilon returns static dielectric permittivity
#! VALIDITY: This model is valid from 100 - 300 K
#! NOTES:
#! SDEVICE:
#! REFERENCE: 
#! I.Strzalkowski, S.Joshi, C.R.Crowell, "Dielectric constant and its temperature dependence for GaAs, 
#! CdTe, and ZnSe", Appl. Phys. Lett., vol. 28, no. 6, pp. 350-352, 1976

namespace eval GaAs::Epsilon {
  proc init {} {
      set Tpar 0
      set epsilon_Tpar 12.35
      set lambda 2.01e-4
      variable epsilon
      set epsilon [expr {$epsilon_Tpar*(1.0+$lambda*$::temp)/(1+$lambda*$Tpar)}]
}
  proc print {} {printPar::EpsilonSection}  
}
GaAs::Epsilon::init

 
