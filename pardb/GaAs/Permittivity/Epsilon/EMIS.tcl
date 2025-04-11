#----------------------------------------------------------------------#
# $Id: EMIS.tcl,v 1.1 2007/08/10 12:17:09 sameers Exp $
#----------------------------------------------------------------------#
#! MODEL: Temperature dependent model from EMIS
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
#! "Properties of GaAs: 3rd Edition", M R Brozel and G E Stillman (Eds.), IEE/Inspec EM-016, 1996

namespace eval GaAs::Epsilon {
  proc init {} {
      set Tpar 0
      set epsilon_Tpar 12.79
      set lambda 1.0e-4
      variable epsilon
      set epsilon [expr {$epsilon_Tpar*(1.0+$lambda*$::temp)/(1+$lambda*$Tpar)}]
}
  proc print {} {printPar::EpsilonSection}  
}
GaAs::Epsilon::init

 
