

set ::pardb ../../pardb
source ../../lib/helper.tcl
source computematpar.tcl
source ../../lib/PhysicalConstants.tcl

set ::material GaInP
set ::propertyGroup Optics
set ::parSection TableODB
set ::model Schubert


set ::XdataVar llist   

set ::doping 1e18



set ::propertyVariable klist

set Xdata [getXdataFromTable]
set Ydata [getYdataFromTable]


set energy [list]
foreach lambda $Xdata {
	set en [expr {1.23984/$lambda}]
	lappend energy $en
}
	
set alpha [list]
foreach lambda $Xdata k $Ydata {
	set abs [expr {4*$::pi*$k/($lambda*1e-4)}]
	lappend alpha $abs
}	
	
	
set curveName ${::material}_${::parSection}_${::model}
cv_createFromScript $curveName $energy $alpha
cv_display $curveName y
lappend CURVES $curveName



set ::material GaAs
set ::propertyGroup Optics
set ::parSection TableODB
set ::model Levinshtein

set ::propertyVariable klist
set Xdata [getXdataFromTable]
set Ydata [getYdataFromTable]

set energy [list]
foreach lambda $Xdata {
	set en [expr {1.23984/$lambda}]
	lappend energy $en
}
	
set alpha [list]
foreach lambda $Xdata k $Ydata {
	set abs [expr {4*$::pi*$k/($lambda*1e-4)}]
	lappend alpha $abs
}	
	
	
set curveName ${::material}_${::parSection}_${::model}
cv_createFromScript $curveName $energy $alpha
cv_display $curveName y
lappend CURVES $curveName

set ::material AlInP
set ::propertyGroup Optics
set ::parSection TableODB
set ::model Breselge

set ::propertyVariable klist
set Xdata [getXdataFromTable]
set Ydata [getYdataFromTable]

set energy [list]
foreach lambda $Xdata {
	set en [expr {1.23984/$lambda}]
	lappend energy $en
}
	
set alpha [list]
foreach lambda $Xdata k $Ydata {
	set abs [expr {4*$::pi*$k/($lambda*1e-4)}]
	lappend alpha $abs
}	
	
	
set curveName ${::material}_${::parSection}_${::model}
cv_createFromScript $curveName $energy $alpha
cv_display $curveName y
lappend CURVES $curveName

set ::model Default_4CPV

set ::propertyVariable klist
set Xdata [getXdataFromTable]
set Ydata [getYdataFromTable]

set energy [list]
foreach lambda $Xdata {
	set en [expr {1.23984/$lambda}]
	lappend energy $en
}
	
set alpha [list]
foreach lambda $Xdata k $Ydata {
	set abs [expr {4*$::pi*$k/($lambda*1e-4)}]
	lappend alpha $abs
}	
	
	
set curveName ${::material}_${::parSection}_${::model}
cv_createFromScript $curveName $energy $alpha
cv_display $curveName y
lappend CURVES $curveName

set ::material InGaAs
set ::propertyGroup Optics
set ::parSection TableODB
set ::model Bhattacharya

set ::propertyVariable klist
set Xdata [getXdataFromTable]
set Ydata [getYdataFromTable]

set energy [list]
foreach lambda $Xdata {
	set en [expr {1.23984/$lambda}]
	lappend energy $en
}
	
set alpha [list]
foreach lambda $Xdata k $Ydata {
	set abs [expr {4*$::pi*$k/($lambda*1e-4)}]
	lappend alpha $abs
}	
	
	
set curveName ${::material}_${::parSection}_${::model}
cv_createFromScript $curveName $energy $alpha
cv_display $curveName y
lappend CURVES $curveName

set ::material AlGaAs
set ::propertyGroup Optics
set ::parSection TableODB
set ::model djurisic

set ::propertyVariable klist
set Xdata [getXdataFromTable]
set Ydata [getYdataFromTable]

set energy [list]
foreach lambda $Xdata {
	set en [expr {1.23984/$lambda}]
	lappend energy $en
}
	
set alpha [list]
foreach lambda $Xdata k $Ydata {
	set abs [expr {4*$::pi*$k/($lambda*1e-4)}]
	lappend alpha $abs
}	
	
	
set curveName ${::material}_${::parSection}_${::model}
cv_createFromScript $curveName $energy $alpha
cv_display $curveName y
lappend CURVES $curveName


setAllCurveAttr $CURVES
set XaxisTitle Energy\[eV\]
set XaxisScale 0
set YaxisTitle alpha\[cm^(-1)\]
set YaxisScale 1
gr_setAxisAttr X $XaxisTitle {helvetica 16} {} {} black 1 {helvetica 14} 0 10 $XaxisScale black
gr_setAxisAttr Y $YaxisTitle {helvetica 16} {1e-1} {} black 1 {helvetica 14} 0 10 $YaxisScale black











