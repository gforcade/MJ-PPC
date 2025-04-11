#----------------------------------------------------------------------#
# $Id: Piprek.tcl,v 1.2 2008/07/14 11:32:09 sameers Exp $
#----------------------------------------------------------------------#
#! MODEL: Room temperature model from Adachi
#! MATERIAL: InP
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
#! Adachi, "III-V ternary and quaternary compounds", 2017
#! HISTORY:  
#! Created on 2022/04/03 by Gavin Forcade

namespace eval InP::Epsilon {
  proc init {} {
    variable epsilon 12.9
  }
  proc print {} {printPar::EpsilonSection}  
}
InP::Epsilon::init

