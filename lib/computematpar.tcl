#----------------------------------------------------------------------------------------
# New procedures

proc cv_display_all {material propertyGroup parSection model propertyVariable {Xdata 1} } {
# display curves. 
# Default value of Xdata is set to 1. For tabular data, it is generated within this procedure. For analytical models, Xdata is calculated in the inspect command file and passed to this procedure.
        
    foreach mat $material { 
        foreach m $model {                   
	        foreach pV $propertyVariable {                
                if {[info exists ::parType]} {
                    foreach parValue $::parameter {
                        switch -exact $::parType {
	                        temp { set ::temp $parValue }
                            lambda { set ::lambda $parValue }
                            doping { set ::doping $parValue }
                            xMole { set ::xMole $parValue }
                            yMole { set ::yMole $parValue }
                        }
                        set modelFile "$::pardb/$mat/$propertyGroup/$parSection/$m.tcl"
                        if {[file exists $modelFile]} {
                            set curve [getCurve $mat $propertyGroup $parSection $m $pV $Xdata]
                            cv_display $curve 
                            lappend ::CURVES $curve
                        } else {
                            puts stderr "$modelFile does not exist"
                        }
                    }
                } else {
                        set modelFile "$::pardb/$mat/$propertyGroup/$parSection/$m.tcl"
                        if {[file exists $modelFile]} {                    
                            set curve [getCurve $mat $propertyGroup $parSection $m $pV $Xdata]
                            cv_display $curve   
                            lappend ::CURVES $curve
                        } else {
                            puts stderr "$modelFile does not exist"
                        }
                }                                    
		    }
        } 
    }

}


proc getCurve {material propertyGroup parSection model propertyVariable Xdata {curve ""}} {
# Create curves
	if {[string trim $curve] == ""} {
        if [info exists ::parameter] {
            switch -exact $::parType {
                temp {set curve "curve($material,$parSection,$model,$propertyVariable,$::temp)"}
                lambda {set curve "curve($material,$parSection,$model,$propertyVariable,$::lambda)"}
                doping {set curve "curve($material,$parSection,$model,$propertyVariable,$::doping)"}
                xMole {set curve "curve($material,$parSection,$model,$propertyVariable,$::xMole)"}
                yMole {set curve "curve($material,$parSection,$model,$propertyVariable,$::yMole)"}
            }
        } else {
		    set curve "curve($material,$parSection,$model,$propertyVariable)"
        }
	}

    if {$::modelType == "equation"} {
         set Ydata [getDataFromEqn $material $propertyGroup $parSection $model $propertyVariable $Xdata]
    } elseif {$::modelType == "table"} {
        set Xdata [getXdataFromTable $material $propertyGroup $parSection $model $::XdataVar]        
        set Ydata [getYdataFromTable $material $propertyGroup $parSection $model $propertyVariable]
    } 
     
    cv_createFromScript $curve $Xdata $Ydata
	return $curve	
	#	cv_display curve($model)
}


proc getDataFromEqn {material propertyGroup parSection model propertyVariable Xdata} {
# Calculates a list of Y values from analytical models in the material parameter database    
    set Xdata_length [llength $Xdata]
    set Ydata [list]
    foreach xdata $Xdata { 
# Set x axis variable to either temp, doping, x or y              
        switch -exact $::xvar {
	        temp { set ::temp $xdata }
            lambda { set ::lambda $xdata }
            doping { set ::doping $xdata }
            xMole { set ::xMole $xdata }
            yMole { set ::yMole $xdata }
         }
         initProperty $material $propertyGroup $parSection $model
         lappend Ydata [evalVar "${material}::${parSection}::${propertyVariable}"] 
    }
    return $Ydata
}

proc getXdataFromTable {material propertyGroup parSection model XdataVar} {
      initProperty $material $propertyGroup $parSection $model
      set Xdata [evalVar2 "\$${material}::${parSection}::${XdataVar}"] 
      return $Xdata
  }

proc getYdataFromTable {material propertyGroup parSection model propertyVariable} {
      initProperty $material $propertyGroup $parSection $model
      set Ydata [evalVar2 "\$${material}::${parSection}::${propertyVariable}"] 
      return $Ydata
  }

proc setAllCurveAttr {CURVES} {
    set COLORS [list red blue green orange magenta purple black maroon brown tomato violet turquoise pink yellow khaki azure]
    set NCOLORS [llength $COLORS]
    set index 0
    foreach curve $CURVES {
	    set color [lindex $COLORS $index]
	    incr index
	    cv_setCurveAttr $curve "$curve" $color solid 1 circle 3 defcolor 1 defcolor
	    if { $index == $NCOLORS } {set index 0}
    } 
}


# Old procedures
proc getData {material propertyGroup parSection model propertyVariable range} {
	dbputs "material: $material propertyGroup: $propertyGroup parSection: $parSection model: $model value: $propertyVariable range: $range" 5
	# returns X-Y data for a given material, propertyGroup, parSection, model, propertyVariable
	set xvar [lindex $range 0]
	set min [lindex $range 1]
	set max [lindex $range 2]
	set step [lindex $range 3]
	dbputs "xvar: $xvar min:$min max: $max step: $step" 5
	# Create lists for storing propertyVariables corresponding to a single model
	set Xs [list]
	set Ys [list]
	set xvalue $min
	while { $xvalue <= $max } {
		lappend Xs $xvalue
		# Set x axis variable to either temp, doping, x or y
    set cmdline "set ::$xvar $xvalue"
    dbputs "cmdline: $cmdline" 5
    if {[catch "eval $cmdline"]} {
			puts stderr "error in getData: \"$cmdline\" is not a variable"
    }
    dbputs "xvar: $xvar=[evalVar "::$xvar"]" 5
		initProperty $material $propertyGroup $parSection $model
		lappend Ys [evalVar "${material}::${parSection}::${propertyVariable}"]
		set xvalue [expr {$xvalue+$step}]
	}
	set XYdata [list $Xs $Ys ]
	return $XYdata
}

proc getCurve1 {material propertyGroup parSection model propertyVariable range {curve ""}} {
	if {[string trim $curve] == ""} {
		set curve "curve($material,$parSection,$model,$propertyVariable)"
	}
	set XYdata [getData $material $propertyGroup $parSection $model $propertyVariable $range]
	cv_createFromScript $curve [lindex $XYdata 0] [lindex $XYdata 1]
	return $curve	
	#	cv_display curve($model)
}

proc cv_display_all1 {material propertyGroup parSection model propertyVariable range } {
   foreach m $model {
	foreach pV $propertyVariable {
		set curve [getCurve $material $propertyGroup $parSection $m $pV $range]
		cv_display $curve
		}
    }  
}



