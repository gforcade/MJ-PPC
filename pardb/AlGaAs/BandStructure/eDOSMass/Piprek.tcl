#----------------------------------------------------------------------#
# $Id: Piprek.tcl,v 1.4 2008/07/23 06:48:12 sameers Exp $
#----------------------------------------------------------------------#
#! MODEL: model from Piprek
#! MATERIAL: AlGaAs
#! PROPERTY: electron Density of States (DOS) and DOS effective mass
#! EXPRESSION:
#! For conduction band with spherical isoenergy surface, electron DOS effective mass is given by
#! mn/m0 = me
#! For conduction band with ellipsoidal isoenergy surfaces, electron DOS effective mass is given by
#! mn/m0 = M^(2/3)*(mll*mt^2)^(1/3)
#! where mll = longitudinal effective mass, mt = transversal effective mass
#! and M = Number of equivalent conduction band minima
#! The electron DOS is calculated using
#! Nc = 2*(2*pi*kB*T*mn*m0/h^2)^(3/2)   
#! CALCULATED PARAMETER:
#! mm returns me/m0 [1]
#! VALIDITY: This model is valid at all temperatures assuming temperature independent DOS effective mass
#! NOTES:
#! Low temperature electron DOS effective mass is used to calculate temperature dependent electron DOS.
#! The electron DOS effective mass and DOS are calculated for the conduction band (Gamma, X or L) corresponding to the semiconductor bandgap.
#! Formula 1 is used to calculate the electron DOS and DOS mass. 
#! SDEVICE:
#! REFERENCE: 
#! "Semiconductor Optoelectronic Devices: Introduction to Physics and Simulation", J. Piprek, Elsevier Science(USA), 2003
#! HISTORY:
#! Created on 2007/09/06 by Sameer Shah
#! 2008/07/23: Changed Notation and documentation

namespace eval AlGaAs::eDOSMass {
    proc init {} {
# Low temprature electron effective masses from Piprek (Table 2.1, page 18)
        set mn_Gamma_GaAs 0.067
        set mn_Gamma_AlAs 0.15
        set mt_X_GaAs 0.23
        set ml_X_GaAs 1.3
        set mt_X_AlAs 0.22
        set ml_X_AlAs 0.97
        set M_GaAs 4.0
        set M_AlAs 3.0

# Parameters from sdevice           
	variable Formula 1
    	variable a 0.0
	variable ml 0.0
    	variable mm
        
# Calculate electron DOS effective mass        
        if {$::xMole < 0.41} {
            set mn_Gamma [expr {[::compute_ternary $::xMole $mn_Gamma_AlAs $mn_Gamma_GaAs]}]
            set mm $mn_Gamma
        } elseif {$::xMole > 0.45} {
            set mn_X_GaAs [expr {(pow($M_GaAs, 2.0/3.0))*(pow($ml_X_GaAs*$mt_X_GaAs*$mt_X_GaAs,1.0/3.0))}]
            set mn_X_AlAs [expr {(pow($M_AlAs, 2.0/3.0))*(pow($ml_X_AlAs*$mt_X_AlAs*$mt_X_AlAs,1.0/3.0))}]
            set mn_X [expr {[::compute_ternary $::xMole $mn_X_AlAs $mn_X_GaAs]}]
            set mm $mn_X
        } else { 
            puts stderr "AlGaAs/BandStructure/eDOSMass/Piprek: Electron DOS mass is not defined for xMole=(0.41,0.45)"
            exit -1
        }

# Calculate conduction band DOS        
	variable Nc [expr {2.0*pow(2.0*$::pi*$::m0*$mm*$::kB*$::temp/($::h*$::h*1.0e4),3.0/2.0)}]
    }
    proc print {} {printPar::eDOSMass1Section}    
}
AlGaAs::eDOSMass::init
