#----------------------------------------------------------------------#
# $Id: Levinshtein.tcl,v 1.1 2007/08/29 15:19:01 sameers Exp $
#----------------------------------------------------------------------#
#! MODEL: Room temperature model from Levinshtein
#! MATERIAL: AlGaAs
#! PROPERTY: Static dielectric permittivity
#! EXPRESSION: 
#! Static dielectric permittivity is given by
#!     epsilon = 12.9-2.84x
#! CALCULATED PARAMETER: 
#! epsilon returns static dielectric permittivity
#! VALIDITY: This model is valid only for T=300K
#! NOTES:
#! SDEVICE:
#! REFERENCE: 
#! "Handbook series on Semiconductor Parameters, Vol II"
#! M. Levenshtein, S. Rumyantsev, M. Shur, World Scientific, 1999
#! HISTORY:
#! Created on 2007/08/29 by Sameer Shah

namespace eval AlGaAs::Epsilon {
  proc init {} {
    variable epsilon [expr {12.9 - 2.84*$::xMole}]
  }
  proc print {} {printPar::EpsilonSection}  
}
AlGaAs::Epsilon::init

