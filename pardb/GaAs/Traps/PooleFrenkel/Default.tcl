#----------------------------------------------------------------------#
# $Id: Default.tcl,v 1.2 2007/08/10 12:17:12 sameers Exp $
#----------------------------------------------------------------------#
#! MODEL: Poole Frenkel model from sdevice
#! MATERIAL: GaAs
#! PROPERTY: Trap Cross Section
#! EXPRESSION: 
#! CALCULATED PARAMETER: 
#! epsPF
#! VALIDITY: 
#! NOTES:
#! SDEVICE: 
#! REFERENCE:
#! Sentaurus Device User Guide 

namespace eval GaAs::PooleFrenkel {
  proc init {} {
    variable epsPF_n 13.18
    variable epsPF_p 13.18

  }
  proc print {} {printPar::PooleFrenkelSection}  
}
GaAs::PooleFrenkel::init

