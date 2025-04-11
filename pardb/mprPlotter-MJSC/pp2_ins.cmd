
set ::pardb ../../pardb
source ../../lib/helper.tcl
source computematpar.tcl
source ../../lib/PhysicalConstants.tcl
source ../../lib/compound_lib.tcl

set ::temp 300
set ::propertyVariable mu_dop_p
set ::filename hMobility
set ::parSection DopingDependence
set ::propertyGroup Mobility

set N 100			
set min 1e15
set max 1e20

set ::xvar doping
set Xdata [logspace $min $max $N]


set ::material GaAs
set ::model Sotoodeh-Masetti_4CPV

set Ydata [getDataFromEqn $Xdata]
set curveName ${::material}_${::model}
cv_createFromScript $curveName $Xdata $Ydata
cv_display $curveName

lappend CURVES $curveName
cv_write csv "${::filename}_${curveName}.csv" $curveName


set ::material GaInP
set ::model Sotoodeh_4CPV

set Ydata1 [getDataFromEqn $Xdata]

set curveName ${::material}_${::model}
cv_createFromScript $curveName $Xdata $Ydata1
cv_display $curveName

lappend CURVES $curveName
cv_write csv "${::filename}_${curveName}.csv" $curveName


set ::material InGaAsN
set ::model MW

set Ydata2 [getDataFromEqn $Xdata]

set curveName ${::material}_${::model}
cv_createFromScript $curveName $Xdata $Ydata2
cv_display $curveName

lappend CURVES $curveName
cv_write csv "${::filename}_${curveName}.csv" $curveName

namespace eval :: { source ../AlInP/Mobility/ConstantMobility/Default.tcl }
set ::material AlInP
set ::model Default_4CPV

set Ydata2 [getDataFromEqn $Xdata]

set curveName ${::material}_${::model}
cv_createFromScript $curveName $Xdata $Ydata2
cv_display $curveName

lappend CURVES $curveName
cv_write csv "${::filename}_${curveName}.csv" $curveName


set ::material AlGaAs
set ::model Sotoodeh_4CPV
set ::xMole 0.05

set Ydata2 [getDataFromEqn $Xdata]

set curveName ${::material}_${::model}_${::xMole}
cv_createFromScript $curveName $Xdata $Ydata2
cv_display $curveName

lappend CURVES $curveName
cv_write csv "${::filename}_${curveName}.csv" $curveName


set ::material Ge
set ::model Palankovski_4CPV

set Ydata2 [getDataFromEqn $Xdata]

set curveName ${::material}_${::model}
cv_createFromScript $curveName $Xdata $Ydata2
cv_display $curveName

lappend CURVES $curveName
cv_write csv "${::filename}_${curveName}.csv" $curveName

setAllCurveAttr $CURVES
set XaxisTitle Doping\[cm^-3\]
set XaxisScale 1
set YaxisTitle {Electron Mobility [cm2/V-s]}
set YaxisScale 1
gr_setAxisAttr X $XaxisTitle {helvetica 16} {} {} black 1 {helvetica 14} 0 10 $XaxisScale black
gr_setAxisAttr Y $YaxisTitle {helvetica 16} {} {} black 1 {helvetica 14} 0 10 $YaxisScale black




