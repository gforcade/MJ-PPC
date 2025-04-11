#----------------------------------------------------------------------#
# $Id: Default.tcl,v 1.1 2019/08/13 M Beattie $ 
#----------------------------------------------------------------------#
#! MODEL: Auger Recombination model parameters from sdevice
#! MATERIAL: InGaAs
#! PROPERTY: Auger Recombination
#! EXPRESSION: 
#! Auger recombination rate is calculated using
#! R_Auger = ( C_n n + C_p p ) ( n p - ni_eff^2)
#! with C_n,p = (A + B (T/T0) + C (T/T0)^2) (1 + H exp(-{n,p}/N0))
#! CALCULATED PARAMETER: 
#! A_n, A_p, B_n, B_p, C_n, C_p, H_n, H_p, N0_n, N0_p
#! VALIDITY: 
#! NOTES: 
#! SDEVICE: Recombination(Auger)
#! REFERENCE: 
#! "Handbook series on Semiconductor Parameters, Vol II"
#! M. Levenshtein, S. Rumyantsev, M. Shur, World Scientific, 1999 
#! HISTORY:
#! Created on 2022/12/13 by Gavin Forcade - SUNLAB

namespace eval InGaAs_InAlAs::Band2BandTunneling {
    proc init {} {
	# effective masses of electrons and holes.
	    variable mc
	    variable mv
	# degeneracy of tunneling (4 as we have 2 x 2 bands for tunneling)
	    variable g 4.0
	# phonon assisted tunneling, only useful for Si
	    variable Cp 8.3e-11
	    variable Pp 0.0
	# max tunnel length
	    variable mtl 100e-7   

	set mc [expr 0.041*$::xMole + 0.069*(1.0 - $::xMole)]
	set mv [expr 0.0528*$::xMole + 0.093*(1.0 - $::xMole)]

    }
    proc print {} {printPar::Band2BandTunnelingSection}    
}
InGaAs_InAlAs::Band2BandTunneling::init
