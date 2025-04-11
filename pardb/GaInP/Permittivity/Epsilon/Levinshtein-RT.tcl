#----------------------------------------------------------------------#
# $Id: Levinshtein-RT.tcl,v 1.1 2008/07/07 12:25:56 sameers Exp $
#----------------------------------------------------------------------#
#! MODEL: Room temperature model from Levinshtein
#! MATERIAL: GaInP
#! PROPERTY: Static dielectric permittivity
#! EXPRESSION: 
#! Static dielectric permittivity is given by
#!     epsilon = 12.5-1.4x
#! CALCULATED PARAMETER: 
#! epsilon returns static dielectric permittivity
#! VALIDITY: This model is valid only for T=300K
#! NOTES:
#! SDEVICE:
#! REFERENCE: 
#! "Handbook series on Semiconductor Parameters, Vol II"
#! M. Levenshtein, S. Rumyantsev, M. Shur, World Scientific, 1999
#! HISTORY:
#! Created on 2008/07/07 by Sameer Shah

namespace eval GaInP::Epsilon {
  proc init {} {
    variable epsilon [expr {12.5 - 1.4*$::xMole}]
  }
  proc print {} {printPar::EpsilonSection}  
}
GaInP::Epsilon::init

