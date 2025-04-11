#----------------------------------------------------------------------#
# $Id: Default.tcl,v 1.1 2007/08/10 12:17:09 sameers Exp $
#----------------------------------------------------------------------#
#! MODEL: Room temperature model from sdevice
#! MATERIAL: GaAs
#! PROPERTY: Static dielectric permittivity
#! EXPRESSION: 
#! Static dielectric permittivity is given by
#!     epsilon = constant
#! CALCULATED PARAMETER: 
#! epsilon returns static dielectric permittivity
#! VALIDITY: This model is valid only for T=300K
#! NOTES:
#! SDEVICE:
#! REFERENCE:
#! Sentaurus Device User Guide 

namespace eval GaAs::Epsilon {
  proc init {} {
    variable epsilon 13.18
  }
  proc print {} {printPar::EpsilonSection}  
}
GaAs::Epsilon::init

