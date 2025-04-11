#----------------------------------------------------------------------#
#! MODEL: Room temperature results from ISE Fraunhoffer
#! MATERIAL: InGaAs
#! PROPERTY: Complex Refractive Index 
#! EXPRESSION: 
#! Room temperature values of wavelength, refractive index and extinction coefficient are created
#! n: NRC data + shifted ISE data to follow NRC 
#! k: MegC5035_3B data + MegC5034_3B data for p- and n-type InGaAs at 5e-16 cm-3 doping
#! CALCULATED PARAMETER:
#! llist, nlist and klist return wavelength [um], absorption coefficient [cm^-1], refractive index and extinction coefficient respectively. 
#! VALIDITY: this model is valid only for T=300K
#! REFERENCE: 
#! HISTORY:
#! Gavin Forcade: adapted to output ComplexRefractiveIndex and NumericalTable format 2022-Feb-14

namespace eval InGaAs::ComplexRefractiveIndex {
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
	# Choose data file based on doping concentration and dopant type
    #---------------------------------------------------------------------------------------------------

            set scriptName [info script]
            set folderName [file rootname $scriptName]
	if {$::doping > 0.0} {
	    ## use n-type measured results
            set dataFile $folderName/NRC_MegC5034_3B.dat
	} else {
	    ## use p-type measured results
	    set dataFile $folderName/NRC_MegC5035_3B.dat
	}

	    puts $dataFile
#-----------------------------------------------------------------------------------------------------
 
	set tableType TableODB
	set lnklist [readTable $dataFile $tableType]
	set llist [lindex $lnklist 0]
	set nlist [lindex $lnklist 1]
	set klist [lindex $lnklist 2]

	if {$::doping > 1.0e17} {
	set klist_meas [lindex $lnklist 2]

	#--------------------------------------------------------------------------------------------
	# Calculate k data based on doping concentration
	#---------------------------------------------------------------------------------------------------

	# data from vurgaftmann, and Piprek (P from lower limit). Provided best fit with the measured n-InGaAs Hahn 1995 data.
	#energies in eV, eps in eps0, masses in m0, P in eV cm, N in cm-3	

	set Eg 0.73
	set delt [func_Q1 $::xMole 0.39 0.34]
	set eps_inf [func_Q1 $::xMole 12.25 10.9]
	set P [func_Q1 $::xMole 8.5e-8 9.9e-8]
	set mhh [expr [func_Q1 $::xMole 0.57 0.52]]
	set mlh [expr [func_Q1 $::xMole 0.026 0.083]]
	
	# get eDOSMass from file
	set Nc [evalVar "${::material}::eDOSMass::Nc"]
	set me [expr pow($Nc/2.54e19,2.0/3.0)]

	# klist_meas < anderson cutoff <  anderson model. [um]
	set anderson_cutoff 1.4
	

	set klist [k_python $klist_meas $anderson_cutoff $llist $Eg $delt $eps_inf $P $Nc $::doping $me $mhh $mlh $::temp ]

	}

	set Formula 1
    }
    proc print {} {printPar::ComplexRefractiveIndexSection} 
}
InGaAs::ComplexRefractiveIndex::init
