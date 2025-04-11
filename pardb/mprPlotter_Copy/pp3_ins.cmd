
set ::pardb ../../pardb
source ../../lib/helper.tcl
source computematpar.tcl

set ::material AlGaAs
set ::propertyGroup BandStructure
set ::parSection Bandgap
set ::model Levinshtein

set ::xvar xMole

set ::temp 300

set N 100			
set min 0
set max 1

set Xdata [linspace $min $max $N]

set ::propertyVariable Eg0_Gamma
set Ydata [getDataFromEqn $Xdata]
set curveName ${::material}_${::parSection}_${::model}_${::propertyVariable}
cv_createFromScript $curveName $Xdata $Ydata
cv_display $curveName
lappend CURVES $curveName

set ::propertyVariable Eg0_L
set Ydata [getDataFromEqn $Xdata]
set curveName ${::material}_${::parSection}_${::model}_${::propertyVariable}
cv_createFromScript $curveName $Xdata $Ydata
cv_display $curveName
lappend CURVES $curveName

set ::propertyVariable Eg0_X
set Ydata [getDataFromEqn $Xdata]
set curveName ${::material}_${::parSection}_${::model}_${::propertyVariable}
cv_createFromScript $curveName $Xdata $Ydata
cv_display $curveName
lappend CURVES $curveName

set ::propertyVariable Eg0
set Ydata [getDataFromEqn $Xdata]
set curveName ${::material}_${::parSection}_${::model}_${::propertyVariable}
cv_createFromScript $curveName $Xdata $Ydata
cv_display $curveName
lappend CURVES $curveName


setAllCurveAttr $CURVES
set XaxisTitle xMole\[1\]
set XaxisScale 0
set YaxisTitle Bandgap\[eV\]
set YaxisScale 0
gr_setAxisAttr X $XaxisTitle {helvetica 16} {} {} black 1 {helvetica 14} 0 10 $XaxisScale black
gr_setAxisAttr Y $YaxisTitle {helvetica 16} {} {} black 1 {helvetica 14} 0 10 $YaxisScale black



