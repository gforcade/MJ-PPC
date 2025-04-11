#----------------------------------------------------------------------#
# $Id: Default-TEM2.tcl,v 1.2 2007/08/10 12:17:04 sameers Exp $
#----------------------------------------------------------------------#
#! MODEL: High field mobility model with default Transferred Electron model parameters from sdevice
#! MATERIAL: GaAs
#! PROPERTY: Mobility
#! EXPRESSION: 
#! High field mobility is calculated using 
#! mu_highfield = (mu_lowfield+(vsat/E)*(E/E0_TrEf)^4)/(1+(E/E0_TrEf)^4)
#! The saturation velocity, vsat is calculated using
#! vsat = A_vsat - B_vsat*(T/T0)
#! CALCULATED PARAMETER: 
#! Transferred electron model parameters and model 2 parameters for velocity saturation model
#! VALIDITY: This model is valid at high electric fields
#! NOTES: 
#! To use this model, activate Transferred Electron model in sdevice command file
#! SDEVICE: Mobility(HighFieldDependence(eHighFieldSaturation(TransferredElectronEffect)))
#! REFERENCE: 
#! Sentaurus Device User Guide

namespace eval GaAs::HighFieldDependence {
    proc init {} {
# sdevice default parameters for Extended Canali model. Used only for the sake of printing the complete HighFieldDependence section
	variable beta0_n 2
	variable beta0_p 2
	variable betaexp_n 0.0
	variable betaexp_p 0.0
	variable alpha_n 0.0
	variable alpha_p 0.0

# Smoothing parameter for HydroHighField Caughey-Thomas model. Used only for the sake of printing the complete HighFieldDependence section
	variable K_dT_n 0.2
	variable K_dT_p 0.2

# Transferred-Electron model parameters
	variable E0_TrEf_n 4.0000e+03
	variable E0_TrEf_p 4.0000e+03  	
	variable Ksmooth_TrEf_n 1
	variable Ksmooth_TrEf_p 1

# Velocity Saturation model parameters
	variable Vsat_Formula_n 2
	variable Vsat_Formula_p 2
	variable A_vsat_n 1.1300e+07
	variable A_vsat_p 1.1300e+07
	variable B_vsat_n 3.6000e+06
	variable B_vsat_p 3.6000e+06
	variable vsat_min_n 5.0000e+05
	variable vsat_min_p 5.0000e+05
    }
    proc print {} {printPar::HighFieldDependenceTEM2Section}    
}
GaAs::HighFieldDependence::init
