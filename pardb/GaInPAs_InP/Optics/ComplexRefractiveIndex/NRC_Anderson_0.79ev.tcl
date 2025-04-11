#----------------------------------------------------------------------#
#! MODEL: Room temperature 
#! MATERIAL: InGaAs
#! PROPERTY: Complex Refractive Index 
#! EXPRESSION: 
#! Room temperature values of wavelength, refractive index and extinction coefficient are created
#! n: NRC data + shifted ISE data to follow NRC 
#! k: Anderson model that captures n-doping dependence + k data from QE measurement from ISE for 1J InGaAsP device
#! CALCULATED PARAMETER:
#! version 3 assumes morphed data with mid-point from Carmine's GaInAsP device. 20230801_doubleMorph_full.
#! llist, nlist and klist return wavelength [um], absorption coefficient [cm^-1], refractive index and extinction coefficient respectively. 
#! VALIDITY: this model is valid only for T=300K, and all doping concentrations and types.
#! REFERENCE: 
#! HISTORY:
#! Gavin Forcade: adapted to output ComplexRefractiveIndex and NumericalTable format 2022-Oct-5

namespace eval GaInPAs_InP::ComplexRefractiveIndex {
    proc init {} {
	proc readTable {file tableType} {
	    set FID [open $file r]
	    set i 0
	    set llist [list]
	    set nlist [list]
	    set klist [list]
	    while {[gets $FID line] >= 0} {
		    if {[scan $line "%e,%e,%e" l n k] == 3 } {
		        lappend llist $l
		        lappend nlist $n
		        lappend klist $k
		        incr i
	    	}
	    }
	    set lnklist [list $llist $nlist $klist]
	    return $lnklist
        close $FID
	}


	proc manip_wl {wl Ex} {
		## stretch/compress wl axis. Convert to Energy, then compress/stretch by Ex, then convert back to wl.
		for {set i 0} {$i < [llength $wl]} {incr i} {
			lset wl $i [expr {[lindex $wl $i] * $Ex }]
		}
		return $wl
		}

	proc mltp {x a} {
		## multiply the list x by the value a
		set y [list ]
		foreach i $x {
			 lappend y [expr $i*$a]
		}
		return $y
		}


	#function to interface with python
	proc k_python { klist anderson_cutoff llist Eg delt eps_inf P Nc doping me mhh mlh temp } {
		#INPUT: wavelength data, bandgap, split-off band, optical dieletric constant, band matrix element, conduction band DOS, Doping concentration, electron, heavy-hole, and light hole effective masses, temperature
		set output [exec python ../../../../Python/k_ndoping_dependent.py $klist $anderson_cutoff $llist $Eg $delt $eps_inf $P $Nc $doping $me $mhh $mlh $temp]
		#convert from string to list
		set output [regexp -all -inline {\S+} $output]
	}



	proc func_Q1 { x ac bc } {
		#function to interpolate between parameters
		return [expr ($x*$ac + (1.0 - $x)*$bc)]
	}


	variable llist
	variable nlist
	variable klist
	variable Formula

	# Format doping value so that it is consistent with data file names in Levinshtein folder
	set doping [format %1.2e $::doping]

    #---------------------------------------------------------------------------------------------------
	# Grab data for wavelength and n
    #---------------------------------------------------------------------------------------------------

            set scriptName [info script]
            set folderName [file rootname $scriptName]
            set yMole [expr {0.47*(1.0 - $::xMole)}] 
            set yMole_round [format "%.2f" $yMole] 
            set xMole_round [expr {1.0 - $yMole_round/0.47}]
            set dataFile ${folderName}/NRC_InGaAsP_0.79eV.dat
	    puts $dataFile
	#-----------------------------------------------------------------------------------------------------
 
	# get the bandgaps of the actual composition and the rounded composition. Using GF_RT formula.
	set Eg [expr {1.353 * $::xMole + 0.737 * (1.0 - $::xMole) - 0.13*(1.0 - $::xMole)*$::xMole}]
	set Eg_round [expr {1.353 * $xMole_round + 0.737 * (1.0 - $xMole_round) - 0.13*(1.0 - $xMole_round)*$xMole_round}]


	set tableType TableODB
	set lnklist [readTable $dataFile $tableType]
	set llist [lindex $lnklist 0]

	# compress/stretch wl axis in energy space
	##set llist [manip_wl $llist [expr {$Eg_round/$Eg}]]

	set nlist [lindex $lnklist 1]
	set klist [lindex $lnklist 2]


	#--------------------------------------------------------------------------------------------
	# Calculate k data based on doping concentration
	#---------------------------------------------------------------------------------------------------

	### || ($::temp != 298.0)
	if {($::doping > 1.0e17)} {
	set klist_meas [lindex $lnklist 2]

	# data from vurgaftmann, and Piprek (P from lower limit). Provided best fit with the measured n-InGaAs Hahn 1995 data.
	#energies in eV, eps in eps0, masses in m0, P in eV cm, N in cm-3	. Using Piprek and/or Vurgaftman parameters

 

	set delt [func_Q1 [expr {1.0-$::xMole}] [func_Q1 0.53 0.39 0.34] [func_Q1 0.52 0.39 0.28]]  
	set eps_inf [func_Q1 [expr {1.0-$::xMole}] [func_Q1 0.53 12.25 10.9] 9.61]
	set P [func_Q1 [expr {1.0-$::xMole}] [func_Q1 0.53 9.05e-8 10.47e-8] 8.87e-8]
	set mhh [expr [func_Q1 [expr {1.0-$::xMole}] [func_Q1 0.53 0.57 0.52] 0.6]]
	set mlh [expr {0.0528 + 0.0386*$::xMole + 0.0302*$::xMole*$::xMole}]

	set Eg [evalVar "${::material}::Bandgap::Eg"]	

	# get eDOSMass from file
	set Nc [evalVar "${::material}::eDOSMass::Nc"]
	set me [expr pow($Nc/2.54e19,2.0/3.0)]

	# klist_meas < anderson cutoff <  anderson model. [um] Starts at 1.4um for InGaAs and shifts in energy space with bandgap.
	set anderson_cutoff [expr 1.24/($Eg + $delt/2.0)]

	set klist [k_python $klist_meas $anderson_cutoff $llist $Eg $delt $eps_inf $P $Nc $::doping $me $mhh $mlh $::temp ]
	}

	
	#-----------------------------------------------------------------------------------------------------
	# shift k data
	set klist [mltp $klist [expr $::del_k + 1.0]]
	
	#------------------------------------------------------------------------------------------------------

	set Formula 1

    }
    proc print {} {printPar::ComplexRefractiveIndexSection} 
}
GaInPAs_InP::ComplexRefractiveIndex::init
