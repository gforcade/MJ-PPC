#----------------------------------------------------------------------#
# $Id: Levinshtein.tcl,v 1.2 2007/09/10 13:01:10 sameers Exp $
#----------------------------------------------------------------------#
#! MODEL: Room temperature model from Levinshtein
#! MATERIAL: GaAs
#! PROPERTY: Static dielectric permittivity
#! EXPRESSION: 
#! Static dielectric permittivity is given by
#!     epsilon = 12.9
#! CALCULATED PARAMETER: 
#! epsilon returns static dielectric permittivity
#! VALIDITY: This model is valid only for T=300K
#! NOTES:
#! SDEVICE:
#! REFERENCE: 
#! "Handbook series on Semiconductor Parameters, Vol I"
#! M. Levenshtein, S. Rumyantsev, M. Shur, World Scientific, 1996
#! HISTORY:
#! Created by Sameer Shah

namespace eval GaAs::Epsilon {
  proc init {} {
    variable epsilon 12.9
  }
  proc print {} {printPar::EpsilonSection}  
}
GaAs::Epsilon::init

