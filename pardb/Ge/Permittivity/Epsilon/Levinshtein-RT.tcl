#----------------------------------------------------------------------#
# $Id: Levinshtein-RT.tcl,v 1.1 2008/07/07 12:39:41 sameers Exp $
#----------------------------------------------------------------------#
#! MODEL: room temperature model from Levinshtein
#! MATERIAL: Ge
#! PROPERTY: Epsilon
#! EXPRESSION: 
#! Dielectric constant is given by
#!     epsilon = 16.2
#! CALCULATED PARAMETER: 
#! epsilon returns dielectric constant, epsilon [1]
#! VALIDITY: this model is valid only for T=300K
#! NOTES:
#! SDEVICE:
#! REFERENCE: 
#! "Handbook series on Semiconductor Parameters, Vol I"
#! M. Levenshtein, S. Rumyantsev, M. Shur, World Scientific, 1996
#! HISTORY
#! Created on 2008/07/07 by Sameer Shah

namespace eval Ge::Epsilon {
    proc init {} {
      variable epsilon 16.2
   }
  proc print {} {printPar::EpsilonSection}  
}
Ge::Epsilon::init
