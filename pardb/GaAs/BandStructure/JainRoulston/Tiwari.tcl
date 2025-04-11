#----------------------------------------------------------------------#
# $Id: Tiwari.tcl,v 1.1 2008/03/28 12:13:52 sameers Exp $
#----------------------------------------------------------------------#
#! MODEL: Doping dependent model
#! MATERIAL: GaAs
#! PROPERTY: Bandgap narrowing (BGN)
#! EXPRESSION: 
#! Bandgap narrowing  is calculated using 
#! deltaEg =C_p*N^(1/2) 
#! CALCULATED PARAMETER:
#! C_p
#! VALIDITY: 
#! This model is valid only for p-GaAs
#! NOTES:
#! SDEVICE: EffectiveIntrinsicDensity(JainRoulston)
#! REFERENCE: 
#! S.C.Jain and D.J.Roulston, "A Simple Expression for Band Gap Narrowing (BGN) in Heavily Doped Si, Ge, 
#! GaAs and Ge(x)Si(1-x) Strained Layers," Solid-State Electronics, vol. 34, no.5, pp.453-465, 1991

namespace eval GaAs::JainRoulston {
    proc init {} {
	variable A_n 0.0				;# [eV cm]
    	variable A_p 0.0				;# [eV cm]
	variable B_n 0.0				;# [eV cm^(3/4)]
    	variable B_p 0.0				;# [eV cm^(3/4)]
	variable C_n 0.0        		        ;# [eV cm^(3/2)]
    	variable C_p 2.0000e-11                         ;# [eV cm^(3/2)]
	variable D_n 0.0				;# [eV cm^(3/2)]
    	variable D_p 0.0				;# [eV cm^(3/2)]
	variable deltaEg
    	if { $::doping > 0.0 } {
	    puts stderr "GaAs:JainRoulston:Tiwari: The BGN model from Tiwari is valid only for p-GaAs. Please use another BGN model!"
            exit -1	    	   
    	} elseif { $::doping < 0.0 } {
	    set deltaEg [expr {$A_p*pow(abs($::doping),1.0/3.0) + $B_p*pow(abs($::doping),1.0/4.0) + $C_p*pow(abs($::doping),1.0/2.0) + $D_p*pow(abs($::doping),1.0/2.0)}]
	}
    }
    proc print {} {printPar::JainRoulstonSection}
}
GaAs::JainRoulston::init
