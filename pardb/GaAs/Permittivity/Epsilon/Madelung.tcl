#----------------------------------------------------------------------#
# $Id: Madelung.tcl,v 1.1 2007/08/10 12:17:09 sameers Exp $
#----------------------------------------------------------------------#
#! MODEL: Temperature dependent model from Madelung
#! MATERIAL: GaAs
#! PROPERTY: Static dielectric permittivity
#! EXPRESSION: 
#! Static dielectric permittivity is calculated using
#!     epsilon(T) = epsilon(Tpar)*(1+lambda*T)/(1+lambda*Tpar) 
#! CALCULATED PARAMETER: 
#! epsilon returns static dielectric permittivity
#! VALIDITY: 
#! NOTES:
#! SDEVICE:
#! REFERENCE: 
#! "Semiconductors: Data Handbook", O. Madelung, Springer-Verlag, 2004

namespace eval GaAs::Epsilon {
  proc init {} {
      set Tpar 300
      set epsilon_Tpar 12.80
      set lambda 2.04e-4
      variable epsilon
      set epsilon [expr {$epsilon_Tpar*(1.0+$lambda*$::temp)/(1+$lambda*$Tpar)}]
}
  proc print {} {printPar::EpsilonSection}  
}
GaAs::Epsilon::init

 
