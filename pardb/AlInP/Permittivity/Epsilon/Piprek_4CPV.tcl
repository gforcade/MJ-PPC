#----------------------------------------------------------------------#
# $Id: Piprek.tcl,v 1.1 2008/07/14 11:32:08 sameers Exp $
#----------------------------------------------------------------------#
#! MODEL: Room temperature model from Piprek
#! MATERIAL: AlInP
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
#! "Semiconductor Optoelectronic Devices: Introduction to Physics and Simulation", J. Piprek, Elsevier Science(USA), 2003
#! HISTORY:  
#! Created on 2008/07/14 by Sameer Shah

namespace eval AlInP::Epsilon {
  proc init {} {
    variable epsilon [expr {12.91- 3.11*$::xMole}]
  }
  proc print {} {printPar::EpsilonSection}  
}
AlInP::Epsilon::init

