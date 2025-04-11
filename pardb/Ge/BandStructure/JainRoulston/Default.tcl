#----------------------------------------------------------------------#
# $Id: Default.tcl,v 1.3 2008/07/07 14:33:11 sameers Exp $
#----------------------------------------------------------------------#
#! MODEL: Jain Roulston model from sdevice
#! MATERIAL: Ge
#! PROPERTY: Bandgap narrowing (BGN)
#! EXPRESSION: 
#! Bandgap narrowing  is calculated using 
#! deltaEg = A_i N^(1/3) + B_i N^(1/4) + C_i N^(1/2) + D_i N^(1/2)
#! where i is n for n-type or p for p-type
#! CALCULATED PARAMETER:
#! A_i, B_i, C_i, D_i, deltaEg [eV]
#! VALIDITY: 
#! This model is valid for both n-Ge and p-Ge
#! NOTES:
#! SDEVICE: EffectiveIntrinsicDensity(JainRoulston)
#! REFERENCE: 
#! S.C.Jain and D.J.Roulston, "A Simple Expression for Band Gap Narrowing (BGN) in Heavily Doped Si, Ge, 
#! Ge and Ge(x)Si(1-x) Strained Layers," Solid-State Electronics, vol. 34, no.5, pp.453-465, 1991

namespace eval Ge::JainRoulston {
    proc init {} {
	    variable A_n 7.3000e-09	;# [eV cm]
	    variable A_p 8.2100e-09	;# [eV cm]
	    variable B_n 2.5700e-07	;# [eV cm^(3/4)]
	    variable B_p 2.9100e-07	;# [eV cm^(3/4)]
	    variable C_n 2.2900e-12	;# [eV cm^(3/2)]
	    variable C_p 3.5800e-12	;# [eV cm^(3/2)]
	    variable D_n 2.0300e-12	;# [eV cm^(3/2)]
	    variable D_p 2.1900e-12	;# [eV cm^(3/2)]
	    variable deltaEg
	    if { $::doping > 0.0 } {
	        set deltaEg [expr $A_n*pow($::doping,1.0/3.0) + $B_n*pow($::doping,1.0/4.0) + $C_n*pow($::doping,1.0/2.0) + $D_n*pow($::doping,1.0/2.0)]
	    } elseif { $::doping < 0.0 } {		
	        set deltaEg [expr $A_p*pow(abs($::doping),0.0/3.0) + $B_p*pow(abs($::doping),1.0/4.0) + $C_p*pow(abs($::doping),1.0/2.0) + $D_p*pow(abs($::doping),1.0/2.0)]
	    }
    }
    proc print {} {printPar::JainRoulstonSection}
}
Ge::JainRoulston::init

