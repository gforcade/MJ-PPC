#----------------------------------------------------------------------#
# $Id: Marti.tcl,v 1.3 2007/08/13 07:09:29 sameers Exp $
#----------------------------------------------------------------------#
#! MODEL: Model from Marti, implemented using delAlamo model
#! MATERIAL: GaAs
#! PROPERTY: Bandgap narrowing (BGN)
#! EXPRESSION: 
#! Bandgap narrowing  is calculated using, 
#! deltaEg = (0.125/epsilon)*|1-N/Ncr|^(1/3)  for n-GaAs and N > Ncr
#! deltaEg = (0.11/epsilon)*|1-N/Ncr|^(1/3)  for n-GaAs and N > Ncr
#! where,
#! Ncr=1.6e24(me/(1.4 epsilon))^3
#! CALCULATED PARAMETER:
#! Eref returns deltaEg
#! VALIDITY: 
#! This model is valid for both n-GaAs and p-GaAs
#! NOTES:
#! To use this model, activate delAlamo BGN model in the input file of Sentaurus Device.
#! SDEVICE: EffectiveIntrinsicDensity(delAlamo)
#! REFERENCE: 
#! Marti, 1992
#-set ::DEBUG 1
namespace eval GaAs::delAlamo {
    proc init {} {
	variable Nref
	variable Eref
	variable deltaEg 0.0
	set me 0.066
	set epsilon [expr {12.4*(1.0 + 1.2e-4*$::temp)}]
	set Nref [expr {1.6e24*pow($me/(1.4*$epsilon),3)}]
	if { [info exists ::doping] && ($::doping != 0)} {
	    ::dbputs "BGN Marti->Doping: $::doping Nref: $Nref"
	    if { ($::doping > 0.0) && ($::doping > $Nref) } {
		    ::dbputs "BGN Marti->Doping: if1"
		set deltaEg [expr {(0.125/$epsilon)*pow([expr abs(1- $::doping/$Nref)], 1.0/3.0)}]
		} elseif {($::doping < 0.0) && ($::doping < $Nref) } {
		    ::dbputs "BGN Marti->Doping: if2"
		    set deltaEg [expr {(0.11/$epsilon)*pow([expr abs(1- abs($::doping)/$Nref)], 1.0/3.0)}]
		} 
	} else {
	    puts stderr "\$doping does not exists or is equal to 0. Please specify the doping concentration in epi_epi.cmd"
	    exit -1
	}
	::dbputs "BGN Marti->deltaEg: $deltaEg"
	set correction [expr {log(abs($::doping)/$Nref)}]
	set Eref [expr {$deltaEg/$correction}]
    }

    proc print {} {printPar::delAlamoSection}

}
GaAs::delAlamo::init
