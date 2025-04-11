#----------------------------------------------------------------------#
#! MODEL: Room temperature results
#! MATERIAL: GaInAsP, xMole is ___InP__ mole fraction!!!
#! PROPERTY: Complex Refractive Index 
#! EXPRESSION: 
#! Room temperature values of wavelength, refractive index and extinction coefficient are created
#! n: InGaAs = NRC data + shifted ISE data to follow NRC, InP = Palik-Aspens
#! k: InGaAs = MegC5034_3B data, InP = Palik-Aspens
#! CALCULATED PARAMETER:
#! llist, nlist and klist return wavelength [um], absorption coefficient [cm^-1], refractive index and extinction coefficient respectively. 
#! VALIDITY: this model is valid only for T=300K
#! - stretches/compresses wl axis in energy space to make nk data continuous vs xMole
#! - InGaAs and InP data were morphed using model: Determination of the Complex Refractive Index of Compound Semiconductor Alloys for Optical Device Modelling 2020, Schygulla et al.
#! REFERENCE: 
#! HISTORY:
#! Gavin Forcade: adapted to output ComplexRefractiveIndex and NumericalTable format 2023-Feb-8

namespace eval GaInPAs_InP::ComplexRefractiveIndex {
    proc init {} {
	proc readTable {file tableType} {
	    set FID [open $file r]
	    set i 0
	    set llist [list]
	    set nlist [list]
	    set klist [list]
	    while {[gets $FID line] >= 0} {
		    if {[scan $line "%e %e %e" l n k] == 3 } {
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
            set yMole [expr {0.47*(1.0 - $::xMole)}] 
            set yMole_round [format "%.2f" $yMole] 
            set xMole_round [expr {1.0 - $yMole_round/0.47}]
            set dataFile ${folderName}/GaInAsP_x${yMole_round}_nk.txt
	    puts $dataFile
#-----------------------------------------------------------------------------------------------------
 
	# get the bandgaps of the actual composition and the rounded composition. Using GF_RT formula.
	set Eg [expr {1.353 * $::xMole + 0.737 * (1.0 - $::xMole) - 0.13*(1.0 - $::xMole)*$::xMole}]
	set Eg_round [expr {1.353 * $xMole_round + 0.737 * (1.0 - $xMole_round) - 0.13*(1.0 - $xMole_round)*$xMole_round}]


	set tableType TableODB
	set lnklist [readTable $dataFile $tableType]
	set llist [lindex $lnklist 0]

	# compress/stretch wl axis in energy space
	set llist [manip_wl $llist [expr {$Eg_round/$Eg}]]



	set nlist [lindex $lnklist 1]
	set klist [lindex $lnklist 2]
	set Formula 1
    }
    proc print {} {printPar::ComplexRefractiveIndexSection} 
}
GaInPAs_InP::ComplexRefractiveIndex::init
