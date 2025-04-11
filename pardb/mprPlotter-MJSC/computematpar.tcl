#-------------------------------------------------------#
# $Id: computematpar.tcl,v 1.5 2007/12/05 16:31:37 sameers Exp $
#-------------------------------------------------------#
set tcl_precision 17

proc getDataFromEqn {Xdata} {
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
         initProperty $::material $::propertyGroup $::parSection $::model
         lappend Ydata [evalVar "${::material}::${::parSection}::${::propertyVariable}"] 
    }
    return $Ydata
}

proc getXdataFromTable {} {
      initProperty $::material $::propertyGroup $::parSection $::model
      set Xdata [evalVar2 "\$${::material}::${::parSection}::${::XdataVar}"] 
      return $Xdata
  }

proc getYdataFromTable {} {
      initProperty $::material $::propertyGroup $::parSection $::model
      set Ydata [evalVar2 "\$${::material}::${::parSection}::${::propertyVariable}"] 
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

