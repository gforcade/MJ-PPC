#----------------------------------------------------------------------#
# $Id: Default.tcl,v 1.1 2008/07/07 12:53:27 sameers Exp $
#----------------------------------------------------------------------#
#! MODEL: Room temperature model from Levinshtein
#! MATERIAL: AlGaInP
#! PROPERTY: Static dielectric permittivity
#! EXPRESSION: 
#! Static dielectric permittivity is given by
#!     epsilon = 12.05
#! CALCULATED PARAMETER: 
#! epsilon returns static dielectric permittivity
#! VALIDITY: This model is valid only for T=300K (MODEL NEEDS JUSTIFICATION FROM RELIABLE SOURCE)
#! NOTES:
#! SDEVICE:
#! REFERENCE: 
#! Sentaurus Device User Guide
#! HISTORY:
#! Created on 2008/07/07 by Sameer Shah

namespace eval AlGaInP::Epsilon {
  proc init {} {
#!    variable epsilon [expr {12.4- 2.2*$::xMole}]
	variable epsilon 11.84 ;# Cyrium value
  }
  proc print {} {printPar::EpsilonSection}  
}
AlGaInP::Epsilon::init

