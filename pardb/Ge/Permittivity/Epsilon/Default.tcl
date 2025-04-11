#----------------------------------------------------------------------#
# $Id: Default.tcl,v 1.1 2007/09/10 13:01:10 sameers Exp $
#----------------------------------------------------------------------#
#! MODEL: Room temperature model from sdevice
#! MATERIAL: Ge
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

namespace eval Ge::Epsilon {
  proc init {} {
    variable epsilon 15.8
  }
  proc print {} {printPar::EpsilonSection}  
}
Ge::Epsilon::init

