#----------------------------------------------------------------------#
# $Id:$
#----------------------------------------------------------------------#
#! MODEL: Room temperature model from Sopra (Kato et al)
#! MATERIAL: AlGaInP
#! PROPERTY: Complex Refractive Index 
#! EXPRESSION: 
#! Room temperature values of wavelength, refractive index and extinction coefficient are created using 
#! Sopra database for (AlxGa1-x)50In50P
#! CALCULATED PARAMETER:
#! llist, nlist and klist return wavelength [um], absorption coefficient [cm^-1], refractive index and extinction coefficient respectively. 
#! VALIDITY:
#!     For (AlxGa1-x)50In50P with x values of 0 (GaInP), 0.1, 0.3, 0.6, 0.7, 1.0 (AlInP)
#! NOTES:
#!  Data obtained from RefractiveIndex.Info which obtained the data from SOPRA N&K Database. 
#   Publication cited by SOPRA: 
#! REFERENCE: H.KATO,S. ADACHI, H.NAKANISHI, K. OHTSUKA. 
#!            Optical Properties of (AlxGa1-x)0.5In0.5P Quaternary alloys
#!            Japan J. Appl. Phys. Vol 33 (1994) pp. 186-192.
#! HISTORY:
#! Created by Gilbert Arbez, March, 2012

namespace eval AlGaInP::TableODB {                
	proc init {} {
                variable llist
		variable nlist
		variable klist
                # Check that mole fraction exists
		if {![info exists ::xMole]} {
			puts stderr "AlGaInP TableODB Sopra: xmole fraction not defined"
			exit 1
		}
		# Some warnings for mole fractions 0 and 1 - error if outside valid range
                set scriptName [info script]
                set folderName [file rootname $scriptName]
                set dataFile $folderName/Ga51In49P.dat
		# Only certain mole fractions available for (AlxGa1-x)50In50P: 0 (GaInP), 0.1, 0.3, 0.6, 0.7, 1.0 (AlInP)
		if {$::xMole == 0.0} {
                   puts "AlGaInP TableODB Sopra: mole fraction = 0.0 TableODB is for GaInP"
                   set dataFile $folderName/GaInP.dat
		} elseif {$::xMole == 1.0} {
	           puts "AlGaInP TableODB Sopra: mole fraction = 1.0 TableODB is for AlInP"
                   set dataFile $folderName/AlInP.dat
		} elseif {$::xMole == 0.1} {
                   set dataFile $folderName/Al10GaInP.dat
		} elseif {$::xMole == 0.3} {
                   set dataFile $folderName/Al30GaInP.dat
		} elseif {$::xMole == 0.6} {
                   set dataFile $folderName/Al60GaInP.dat
		} elseif {$::xMole == 0.7} {
                   set dataFile $folderName/Al70GaInP.dat
		} elseif {$::xMole < 0.0||$::xMole> 1.0} {
		   puts stderr "AlGaInP TableODB Sopra: xmole fraction \"$::xMole\" unphysical."
		   exit 1
		} else {
		   puts stderr "AlGaInP TableODB Sopra: do not have data for xmole fraction \"$::xMole\"."
		   exit 1
		}
                puts $folderName
                puts $dataFile
		# Setup the table ODB for the parameter file
                set tableType TableODB
		set FID [open $dataFile r]
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
		close $FID
		proc print {} {printPar::TableODBSection} 
	}
}
AlnGaInP::TableODB::init
