#----------------------------------------------------------------------#
# $Id: Default.tcl,v 1.2 2013/03/12 13:12:08 mwilkins Exp $
#----------------------------------------------------------------------#
#! MODEL: Hurkx TAT tunneling parameters from sdevice
#! MATERIAL: GaAs
#! PROPERTY: Hurkx TAT
#! EXPRESSION: 
#! 
#! CALCULATED PARAMETER: 
#! 
#! VALIDITY: 
#! NOTES: 
#! 
#! REFERENCE: 
#! Sentaurus Device User Guide 
#! HISTORY:
#! Created by M Wilkins

namespace eval GaAs::HurkxTrapAssistedTunneling {
    proc init {} {

	variable me_tun $::GaAs::eDOSMass::mm
	variable mh_tun $::GaAs::hDOSMass::mlp

    }
    proc print {} {printPar::HurkxTrapAssistedTunnelingSection}    
}
GaAs::HurkxTrapAssistedTunneling::init
