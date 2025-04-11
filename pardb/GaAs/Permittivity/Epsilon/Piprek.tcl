#----------------------------------------------------------------------#
# $Id: Piprek.tcl,v 1.1 2007/08/10 12:17:09 sameers Exp $
#----------------------------------------------------------------------#
#! MODEL: Room temperature model from Piprek
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
#! "Semiconductor Optoelectronic Devices: Introduction to Physics and Simulation", J. Piprek, Elsevier Science(USA), 2003
#! HISTORY:  
#! Created on 11/06/2007 by Sameer Shah

namespace eval GaAs::Epsilon {
  proc init {} {
    variable epsilon 12.91
  }
  proc print {} {printPar::EpsilonSection}  
}
GaAs::Epsilon::init

