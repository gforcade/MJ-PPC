#----------------------------------------------------------------------#
# $Id:$
#----------------------------------------------------------------------#
#! MODEL: Room temperature model from Adachi
#! MATERIAL: GaAs
#! PROPERTY: Complex Refractive Index 
#! EXPRESSION: 
#! Temperature dependent values of wavelength, refractive index and extinction coefficient are created using GaAs.dat in Adachi folder
#! CALCULATED PARAMETER:
#! llist, nlist and klist return wavelength [um], absorption coefficient [cm^-1], refractive index and extinction coefficient respectively. 
#! VALIDITY:
#! 
#! NOTES:
#! REFERENCE:
#  The n and k values of GaAs have been set from Adachi's book on optical constants of crystalline and amorphous semiconductors - numerical data and graphical information (1999).
#! HISTORY:
#! Created by Alex Walker

namespace eval GaAs::TableODB {                
	proc init {} {
#		source ../../lib/helper.tcl
		variable Eg 1.519
		variable deltaEg
# Compute the bandgap narrowing due to temperature using the Varshni model
		variable alpha 5.405e-4
		variable beta 204
		set deltaEg [expr {-$alpha*$::temp*$::temp/($::temp+$beta)}]
		puts stderr "The change in bandgap for GaAs according to temperature $::temp is $deltaEg"
		variable Egeff [expr {$Eg+$deltaEg}]

# Read in the TableODB values for wavelength, n, k and alpha
		variable llist
		variable nlist
		variable klist
		variable alist
		variable alphalist
		variable energy
		set scriptName [info script]
		set folderName [file rootname $scriptName]
		set dataFile $folderName/GaAs.dat
#		set dataFile $folderName/GaAs_test.dat
		puts $folderName
		puts $dataFile
		set tableType TableODB
		set FID [open $dataFile r]
		set i 0
		set llist [list]
		set nlist [list]
		set klist [list]
		set alphalist [list]
		set energy [list]
		while {[gets $FID line] >= 0} {
			if {[scan $line "%f,%f,%f" l n k] == 3 } {
				lappend llist [expr $l*1.0]
				lappend nlist $n
				lappend klist $k
				lappend alphalist [expr 4*3.14159*$k/($l*pow(10,-4))]
				lappend energy [expr 1.240/$l]
				puts [format "%f %f %f" $l $n $k]
				incr i
				}
		}

# Compute the maximum derivative of the absorption coefficient in log space as the bandgap energy
		variable deriv [expr {abs((log([lindex $alphalist 0])-log([lindex $alphalist 1]))/([lindex $energy 0]-[lindex $energy 1]))}]		
		variable nextderiv
		variable deltaY
		variable deltaX
		variable index
		set i 0
		set m 1
		variable max [expr {[llength $alphalist]-1}]
		while {$m <= $max} {
			if {[lindex $alphalist $i] == 0 || [lindex $alphalist $m] == 0} {break}
			set deltaY [expr {log([lindex $alphalist $i])-log([lindex $alphalist $m])}]
			set deltaX [expr {[lindex $energy $i]-[lindex $energy $m]}]
			set nextderiv [expr {abs($deltaY/$deltaX)}]
			if {$nextderiv > $deriv} {
				set deriv $nextderiv
				set index [expr $i-1]
			}
			incr i
			incr m
		}
		variable new [lindex $energy $index]
		
# Translate the energy column such that the max slope is at the energy corresponding to Eg(T)
		variable energydiff [expr {$Egeff-$new}]
		variable newenergy
		variable newlist
		set newlist [list]
		set newenergy [list]
		set i 0
		while {$i <= $max} {
			variable translation [expr {[lindex $energy $i]+$energydiff}]
			lappend newenergy $translation
			if {$translation == 0} {
				lappend newlist [expr {1.24/[lindex $energy $i]}]
			} else {
				lappend newlist [expr {1.24/$translation}]
			}
			incr i
		}
		variable testlist
		set testlist [list]
		set testlist $llist
		set llist $newlist
		close $FID
	}
# Print out the results in the parameter file
	proc print {} {printPar::TableODBSection}
}
GaAs::TableODB::init
