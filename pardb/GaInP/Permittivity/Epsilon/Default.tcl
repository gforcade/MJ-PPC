#----------------------------------------------------------------------#
# $Id: Default.tcl,v 1.1 2008/07/07 12:53:27 sameers Exp $
#----------------------------------------------------------------------#
#! MODEL: Room temperature model from Levinshtein
#! MATERIAL: GaInP
#! PROPERTY: Static dielectric permittivity
#! EXPRESSION: 
#! Static dielectric permittivity is given by
#!     epsilon = 12.4-2.2x
#! CALCULATED PARAMETER: 
#! epsilon returns static dielectric permittivity
#! VALIDITY: This model is valid only for T=300K
#! NOTES:
#! SDEVICE:
#! REFERENCE: 
#! Sentaurus Device User Guide
#! HISTORY:
#! Created on 2008/07/07 by Sameer Shah

namespace eval GaInP::Epsilon {
  proc init {} {
    variable epsilon [expr {12.4- 2.2*$::xMole}]
  }
  proc print {} {printPar::EpsilonSection}  
}
GaInP::Epsilon::init

