#----------------------------------------------------------------------#
# $Id: Piprek.tcl,v 1.1 2008/07/14 11:32:09 sameers Exp $
#----------------------------------------------------------------------#
#! MODEL: Room temperature model from Piprek
#! MATERIAL: GaInP
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

namespace eval GaInP::Epsilon {
  proc init {} {
    variable epsilon 11.88
  }
  proc print {} {printPar::EpsilonSection}  
}
GaInP::Epsilon::init

