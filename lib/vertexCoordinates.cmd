;;; Copy this file to .cmd of the structure editor tool.
;; It Writes the x,y, z coordinates in the tdr file as PMIUserField names. 

(display "Define definitions that will write coordinates of vertices in .tdr file that is generated from meshing") (newline) 
(sdedr:define-analytical-profile "XPosition" "PMIUserField0" "" "x" 0 "General" )
(sdedr:define-analytical-profile "YPosition" "PMIUserField1" "" "y" 0 "General" )
(sdedr:define-analytical-profile "ZPosition" "PMIUserField2" "" "z" 0 "General" )


!(

proc printPositions {region} {
# function that writes all three positions
 	puts "(sdedr:define-analytical-profile-placement (string-append \"$region\" \"_XPosition\") \"XPosition\" \"$region\" \"Positive\" \"NoReplace\" \"Eval\" \"$region\" 0 \"region\" )"
	puts "(sdedr:define-analytical-profile-placement (string-append \"$region\" \"_YPosition\") \"YPosition\" \"$region\" \"Positive\" \"NoReplace\" \"Eval\" \"$region\" 0 \"region\" )"
	puts "(sdedr:define-analytical-profile-placement (string-append \"$region\" \"_ZPosition\") \"ZPosition\" \"$region\" \"Positive\" \"NoReplace\" \"Eval\" \"$region\" 0 \"region\" )"
}



#if @cap_t@ > 0.0
	printPositions "cap"
#endif
#if @ARC2_t@ > 0.0
	printPositions "ARC1"
#endif
#if @ARC1_t@ > 0.0
	printPositions "ARC2"
#endif
#if @substrate_t@ > 0.0
	printPositions "substrate"
#endif
for {set i 1} {$i < @numSegments@+1} {incr i} {
	printPositions "sc${i}_fsf"
	printPositions "sc${i}_em"
	printPositions "sc${i}_base"
	if {$i > 1} {
		set j [expr $i - 1]
		printPositions "td${j}_pplus"
		printPositions "td${j}_nplus"
	}
}




if {1 == 0} {
#  Slurp up the data file
set fp [open "./results/nodes/@node|epi@/n@node|epi@_epi.out" r]
set file_data [read $fp]
close $fp
#  Process data file
set data [split $file_data "\n"]
foreach line $data {
	set eqSplit [split $line "="]
	if {[lindex $eqSplit 0] == "region"} {
		set spaceSplit [split [lindex $eqSplit 1] { }]
		set region [lindex $spaceSplit 0]
		puts "(sdedr:define-analytical-profile-placement (string-append $region \"_XPosition\") \"XPosition\" $region \"Positive\" \"NoReplace\" \"Eval\" $region 0 \"region\" )"
		puts "(sdedr:define-analytical-profile-placement (string-append $region \"_YPosition\") \"YPosition\" $region \"Positive\" \"NoReplace\" \"Eval\" $region 0 \"region\" )"
		puts "(sdedr:define-analytical-profile-placement (string-append $region \"_ZPosition\") \"ZPosition\" $region \"Positive\" \"NoReplace\" \"Eval\" $region 0 \"region\" )"

	} 
}
}
)!