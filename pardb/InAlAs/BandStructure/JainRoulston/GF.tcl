#----------------------------------------------------------------------#
# $Id: Levinshtein.tcl,v 1.3 2021/01/04 06:58:20 Gavin Forcade Exp $
#----------------------------------------------------------------------#
#! MODEL: Doping dependent model, xMole is ___In__ mole fraction!!!
#! MATERIAL: InAlAs
#! PROPERTY: Bandgap narrowing (BGN)
#! Bandgap narrowing  is calculated using 
#! deltaEg = A_i N^(1/3) + B_i N^(1/4) + C_i N^(1/2) + D_i N^(1/2)
#! where i is n for n-type or p for p-type
#! CALCULATED PARAMETER:
#! A_i, B_i, C_i, D_i, deltaEg
#! VALIDITY: 
#! This model is valid for p-InAlAs
#! SDEVICE: EffectiveIntrinsicDensity(JainRoulston)
#! REFERENCE: 
#! "Handbook series on Semiconductor Parameters, Vol II"
#! M. Levinshtein, S. Rumyantsev, M. Shur, World Scientific, 1999
#! HISTORY
#! Created on 2022/01/04 by Gavin Forcade - SUNLAB

namespace eval InAlAs::JainRoulston {
    proc init {} {
	#Jain parameters from original article
	#InAs
	set A_p_InAs 8.34e-9
	set B_p_InAs 2.91e-7
	set C_p_InAs 4.53e-12
	set D_p_InAs 0.0
	#AlAs
	set A_p_AlAs 10.6e-9
	set B_p_AlAs 5.47e-7
	set C_p_AlAs 3.01e-12
	set D_p_AlAs 0.0

	set xMole_r [expr 1.0 - $::xMole]

        variable A_n 9.0e-9            ;# [eV cm]
        variable A_p [expr {$A_p_InAs*$::xMole + $A_p_AlAs*$xMole_r}]            ;# [eV cm]
        variable B_n 2.62e-7            ;# [eV cm^(3/4)]
        variable B_p [expr {$B_p_InAs*$::xMole + $B_p_AlAs*$xMole_r}]         	;# [eV cm^(3/4)]
        variable C_n 98.4e-12         	;# [eV cm^(3/2)]	        
        variable C_p [expr {$C_p_InAs*$::xMole + $C_p_AlAs*$xMole_r}]         	;# [eV cm^(3/2)]
        variable D_n 0.0            	;# [eV cm^(3/2)]				
    	variable D_p 0.0	    	;# [eV cm^(3/2)]			 	            
        
    	if { $::doping > 0.0 } {
	    variable deltaEg [expr {$A_n*pow($::doping,1.0/3.0) + $B_n*pow($::doping,1.0/4.0) + $C_n*pow($::doping,1.0/2.0) + $D_n*pow($::doping,1.0/2.0)}]
    	} elseif { $::doping < 0.0 } {
            variable deltaEg [expr {$A_p*pow(abs($::doping),1.0/3.0) + $B_p*pow(abs($::doping),1.0/4.0) + $C_p*pow(abs($::doping),1.0/2.0) + $D_p*pow(abs($::doping),1.0/2.0)}]
	}
    }
    proc print {} {printPar::JainRoulstonSection}
}
InAlAs::JainRoulston::init
