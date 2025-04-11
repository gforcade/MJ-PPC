#----------------------------------------------------------------------#
# $Id: Default.tcl,v 1.1 2007/08/29 15:19:01 sameers Exp $
#----------------------------------------------------------------------#
#! MODEL: Room temperature model from Levinshtein
#! MATERIAL: AlGaAs
#! PROPERTY: Static dielectric permittivity
#! EXPRESSION: 
#! Static dielectric permittivity is given by linear interpolation of corresponding values for GaAs and AlAs
#! CALCULATED PARAMETER: 
#! epsilon returns static dielectric permittivity
#! VALIDITY: This model is valid only for T=300K
#! NOTES:
#! SDEVICE:
#! REFERENCE: 
#! Sentaurus Device User Guide 
#! HISTORY:
#! Created on 2007/08/29 by Sameer Shah

namespace eval AlGaAs::Epsilon {
    proc init {} {
        variable epsilon 
        set epsilon_AlAs 10.06
        set epsilon_GaAs 13.18
        set epsilon [expr {[::compute_ternary $::xMole $epsilon_AlAs $epsilon_GaAs]}]
    }
    proc print {} {printPar::EpsilonSection}  
}
AlGaAs::Epsilon::init

