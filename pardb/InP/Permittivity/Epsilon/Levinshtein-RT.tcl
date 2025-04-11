#----------------------------------------------------------------------#
# $Id: Levinshtein-RT.tcl,v 1.1 2008/07/07 12:25:56 sameers Exp $
#----------------------------------------------------------------------#
#! MODEL: Room temperature model from sdevice
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
#! "Handbook series on Semiconductor Parameters, Vol I"
#! M. Levenshtein, S. Rumyantsev, M. Shur, World Scientific, 1996
#! HISTORY:
#! Created on 2008/07/07 by Sameer Shah

namespace eval InP::Epsilon {
  proc init {} {
    variable epsilon 12.5
  }
  proc print {} {printPar::EpsilonSection}  
}
InP::Epsilon::init

