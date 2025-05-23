


set ::pardb ../../pardb
source ../../lib/helper.tcl
source computematpar.tcl
source ../../lib/PhysicalConstants.tcl
source ../../lib/compound_lib.tcl




set ::material GaAs
set ::propertyGroup Recombination
set ::parSection RadiativeRecombination
set ::model GF_v3

set ::xvar thickness

set ::doping 1e15
set ::xMole 0.47
set ::temp 300.0


set N 100			
set min 0.001
set max 100.0

set Xdata [logspace $min $max $N]



set ::propertyVariable C
set Ydata [getDataFromEqn $Xdata]




set curveName ${::material}_${::parSection}_${::model}_${::propertyVariable}_${::doping}
cv_createFromScript $curveName $Xdata $Ydata
cv_display $curveName
lappend CURVES $curveName




setAllCurveAttr $CURVES
set XaxisTitle $::xvar
set XaxisScale 1
set YaxisTitle Variable
set YaxisScale 0
gr_setAxisAttr X $XaxisTitle {helvetica 25} {} {} black 1 {helvetica 23} 0 10 $XaxisScale black
gr_setAxisAttr Y $YaxisTitle {helvetica 25} {} {} black 1 {helvetica 23} 0 10 $YaxisScale black

cv_write csv SimData.csv "${::material}_${::parSection}_${::model}_${::propertyVariable}_${::doping}"

