#----------------------------------------------------------------------#
# $Id: Default.tcl,v 1.1 2007/08/10 12:17:07 sameers Exp $
#----------------------------------------------------------------------#
#! MODEL: model from sdevice
#! MATERIAL: GaAs
#! PROPERTY: Free Carrier Absorption
#! EXPRESSION: 
#! FCA = (alpha_n * n + alpha_p * p) * Light Intensity
#! CALCULATED PARAMETER: 
#! alpha_n and alpha_p return coefficients for free carrier absorption
#! VALIDITY: 
#! NOTES:
#! SDEVICE:
#! REFERENCE:
#! Sentaurus Device User Guide 

namespace eval GaAs::FreeCarrierAbsorption {
  proc init {} {
      variable alpha_n 4.0000e-18
      variable alpha_p 8.0000e-18
  }
  proc print {} {printPar::FreeCarrierAbsorptionSection}  
}
GaAs::FreeCarrierAbsorption::init
