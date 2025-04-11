

set ::pardb ../../pardb
source ../../lib/helper.tcl
source computematpar.tcl
source ../../lib/compound_lib.tcl

set ::material InGaAsN
set ::propertyGroup Mobility
set ::parSection DopingDependence
set ::model Sotoodeh
set ::propertyVariable mu_dop_n

set ::xvar doping

set ::temp 400
set ::xMole 0.9115
set ::yMole 0.0312


set N 100			
set min 1e14
set max 1e20

set Xdata [logspace $min $max $N]

set Ydata [getDataFromEqn $Xdata]

set curveName ${::material}_${::parSection}_${::model}_${::propertyVariable}_${::temp}
cv_createFromScript $curveName $Xdata $Ydata
cv_display $curveName

lappend CURVES $curveName



set ::temp 300

set Ydata1 [getDataFromEqn $Xdata]

set curveName ${::material}_${::parSection}_${::model}_${::propertyVariable}_$::temp
cv_createFromScript $curveName $Xdata $Ydata1
cv_display $curveName
lappend CURVES $curveName

setAllCurveAttr $CURVES
set XaxisTitle Doping\[cm^-3\]
set XaxisScale 1
set YaxisTitle ElectronMobility\[cm^2/(V-s)\]
set YaxisScale 0
gr_setAxisAttr X $XaxisTitle {helvetica 16} {} {} black 1 {helvetica 14} 0 10 $XaxisScale black
gr_setAxisAttr Y $YaxisTitle {helvetica 16} {} {} black 1 {helvetica 14} 0 10 $YaxisScale black


