#----------------------------------------------------------------------#
#! MODEL: Room temperature 
#! MATERIAL: (InGaAs)x (InAlAs)(1-x). MoleFraction xMole is ____InGaAs____!!!
#! PROPERTY: Complex Refractive Index 
#! EXPRESSION: 
#! Room temperature values of wavelength, refractive index and extinction coefficient are created
#! n: NRC data + shifted ISE data to follow NRC 
#! k: Anderson model that captures n-doping dependence + k data from Meghan for short wavelengths as anderson model only works well at band edge.
#! CALCULATED PARAMETER:
#! llist, nlist and klist return wavelength [um], absorption coefficient [cm^-1], refractive index and extinction coefficient respectively. 
#! VALIDITY: this model is valid only for T=300K, and all doping concentrations and types.
#! REFERENCE: 
#! HISTORY:
#! Gavin Forcade: adapted to output ComplexRefractiveIndex and NumericalTable format 2022-Oct-5

namespace eval InGaAs_InAlAs::ComplexRefractiveIndex {
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



	proc shiftData { x y x_shift y_fillValue } {
		#function to shift y data to x_shift. Fills the rest of the values with y_fillValue
		set i 0
		set y_new [lrepeat [llength $y] $y_fillValue]
		while {$x_shift > [lindex $x $i]} {
			incr i
		   }
		set j 0
		for {set j 0} {$i + $j < [llength $y]} {incr j} {
			lset y_new $j [lindex $y [expr $i + $j]]
		   }
		return $y_new
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
            set dataFile $folderName/In53GaAs.dat
	    puts $dataFile
	#-----------------------------------------------------------------------------------------------------
 
	set tableType TableODB
	set lnklist [readTable $dataFile $tableType]
	set llist [lindex $lnklist 0]
	set nlist [lindex $lnklist 1]
	set klist_meas [lindex $lnklist 2]

	#--------------------------------------------------------------------------------------------
	# Calculate k data based on doping concentration
	#---------------------------------------------------------------------------------------------------

	# data from vurgaftmann, and Piprek (P from lower limit). Provided best fit with the measured n-InGaAs Hahn 1995 data.
	#energies in eV, eps in eps0, masses in m0, P in eV cm, N in cm-3	

	set Eg [func_Q1 $::xMole 0.73 1.45]
	set delt [func_Q1 $::xMole [func_Q1 0.53 0.39 0.34] [func_Q1 0.52 0.39 0.28]]
	set eps_inf [func_Q1 $::xMole [func_Q1 0.53 12.25 10.9] [func_Q1 0.52 12.25 8.16]]
	set P [func_Q1 $::xMole [func_Q1 0.53 9.05e-8 10.47e-8] [func_Q1 0.52 9.05e-8 8.9e-8]]
	set mhh [expr [func_Q1 $::xMole [func_Q1 0.53 0.57 0.52] [func_Q1 0.52 0.57 0.76]]]
	set mlh [expr [func_Q1 $::xMole [func_Q1 0.53 0.026 0.083] [func_Q1 0.52 0.026 0.15]]]
	
	# get eDOSMass from file
	set Nc [evalVar "${::material}::eDOSMass::Nc"]
	set me [expr pow($Nc/2.54e19,2.0/3.0)]
  

	# klist_meas < anderson cutoff <  anderson model. [um]. Using up to the midpoint between bandgap and the splitoff absorption.
	set anderson_cutoff [expr 1.24/($Eg + $delt/2.0)]

	# shift k list measured data to smaller wavelengths.
	###set nlist [shiftData $llist $nlist_meas $anderson_cutoff [lindex $nlist_meas end]]
	set klist_meas [shiftData $llist $klist_meas $anderson_cutoff 0.0]

	set klist [k_python $klist_meas $anderson_cutoff $llist $Eg $delt $eps_inf $P $Nc $::doping $me $mhh $mlh $::temp ]
	

	set Formula 1

    }
    proc print {} {printPar::ComplexRefractiveIndexSection} 
}
InGaAs_InAlAs::ComplexRefractiveIndex::init
