#----------------------------------------------------------------------#
# $Id: Default.tcl,v 1.2 2013/03/12 13:12:08 mwilkins Exp $
#----------------------------------------------------------------------#
#! MODEL: Band2Band tunneling parameters from sdevice
#! MATERIAL: GaAs
#! PROPERTY: Band to Band tunneling
#! EXPRESSION: 
#! Band to band tunnleing
#! CALCULATED PARAMETER: 
#! 
#! VALIDITY: 
#! NOTES: 
#! 
#! REFERENCE: 
#! Sentaurus Device User Guide 
#! HISTORY:
#! Created by M Wilkins

namespace eval GaAs::Band2BandTunneling {
    proc init {} {

	puts "GaAs Band2BandTunneling parameters"
	set Eg $::GaAs::Bandgap::Eg
	# adjusted to fit Franz dispersion curve to complex bandstructure
	set me 0.08
	# GaAs light-hole mass in [100] direction
	set mh 0.0901
#	if { namespace eval GaAs { namespace exists TableBGN } } { 
	set dEg $::GaAs::TableBGN::dEg
#	    } else { set dEg 0.0 }
		
	puts "Eg $Eg, me $me, mh $mh, m0 $::m0, Chi $::GaAs::Bandgap::Chi, dEg $dEg"

	# defines max tunnel length for Dynamic Nonlocal Path Band2Band and TAT models.
	variable MaxTunnelLength 20e-7 #! cm 

	# helper variables for calculating A and B
	set mr [expr 1.0/(1.0/$me + 1.0/$mh)]
	puts "GaAs mr $mr"
	# Use path1 for direct tunneling process.  A, B from manual, (421), (422)
	set Anum [expr $::g_b2b*$::pi*sqrt($mr*$::m0)*pow($::q*100,2.0) ]
	set Aden [expr 9.0*pow($::h,2.0)*sqrt($::q*($Eg - $dEg)) ]
	variable Apath1 [expr 1e-6*$Anum/$Aden]

	set Bnum [expr pow($::pi,2.0)*sqrt($mr*$::m0)*pow($::q*($Eg - $dEg) ,3.0/2.0) ]
	variable Bpath1 [expr 1e-2*$Bnum/($::q*$::h)]

	variable Dpath1 0   #! deltaC - conduction band offset
	variable Ppath1 0   #! 0 - direct process
	variable Rpath1 [expr $mh/$me]   #! mv/mc

	puts "GaAs Apath1 $Apath1, Bpath1 $Bpath1"

	# use path2 for indirect (phonon-assisted) process.
    	variable Apath2 0
	variable Bpath2 0
	variable Dpath2 0   #! deltaC - conduction band offset
	variable Ppath2 0   #! 0 - direct process
	variable Rpath2 0   #! mv/mc

    	variable Apath3 0
	variable Bpath3 0
	variable Dpath3 0   #! deltaC - conduction band offset
	variable Ppath3 0   #! 0 - direct process
	variable Rpath3 0   #! mv/mc
    }
    proc print {} {printPar::Band2BandTunnelingSection}    
}
GaAs::Band2BandTunneling::init
