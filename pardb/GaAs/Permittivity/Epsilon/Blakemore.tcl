#----------------------------------------------------------------------#
# $Id: Blakemore.tcl,v 1.1 2007/08/10 12:17:09 sameers Exp $
#----------------------------------------------------------------------#
#! MODEL: Temperature dependent model from Blakemore
#! MATERIAL: GaAs
#! PROPERTY: Static dielectric permittivity
#! EXPRESSION: 
#! Static dielectric permittivity is calculated using
#!     epsilon(T) = epsilon(Tpar)*(1+lambda*T)/(1+lambda*Tpar) 
#! CALCULATED PARAMETER: 
#! epsilon returns static dielectric permittivity
#! VALIDITY: This model is valid from 100 - 600 K
#! NOTES:
#! SDEVICE:
#! REFERENCE: 
#! J.S.Blakemore, "Semiconducting and other major properties of GaAs", J. Appl. Phys., Vol. 53, No. 10,pp. R123-181, 1982

namespace eval GaAs::Epsilon {
  proc init {} {
      set Tpar 0
      set epsilon_Tpar 12.4
      set lambda 1.20e-4
      variable epsilon
      set epsilon [expr {$epsilon_Tpar*(1.0+$lambda*$::temp)/(1+$lambda*$Tpar)}]
}
  proc print {} {printPar::EpsilonSection}  
}
GaAs::Epsilon::init

 
