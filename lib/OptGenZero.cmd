;;; Copy this file to .cmd of the structure editor tool.
;; It Writes OpticalGeneration into the tdr file, as 0.0 

(display "Define definitions that will write coordinates of vertices in .tdr file that is generated from meshing") (newline) 
(sdedr:define-analytical-profile "optGen" "OpticalGeneration" "" "0.0" 0 "General" )


!(

proc printPositions {region} {
# function that writes 
 	puts "(sdedr:define-analytical-profile-placement (string-append \"$region\" \"_optGen\") \"optGen\" \"$region\" \"Positive\" \"NoReplace\" \"Eval\" \"$region\" 0 \"region\" )"
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




)!