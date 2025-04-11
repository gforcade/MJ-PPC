#----------------------------------------------------------------------#
# $Id: Piprek.tcl,v 1.2 2008/07/07 12:24:01 sameers Exp $
#----------------------------------------------------------------------#
#! MODEL: Room temperature model from Piprek
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
#! "Semiconductor Optoelectronic Devices: Introduction to Physics and Simulation", J. Piprek, Elsevier Science(USA), 2003
#! HISTORY:
#! Created on 2007/08/29 by Sameer Shah
#! Minor correction in MODEL on 2008/07/07

namespace eval AlGaAs::Epsilon {
    proc init {} {
        variable epsilon 
        set epsilon_AlAs 10.06
        set epsilon_GaAs 12.91
        set epsilon [expr {[::compute_ternary $::xMole $epsilon_AlAs $epsilon_GaAs]}]
    }
    proc print {} {printPar::EpsilonSection}  
}
AlGaAs::Epsilon::init

