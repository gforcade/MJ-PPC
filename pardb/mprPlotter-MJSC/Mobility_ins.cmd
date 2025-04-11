#------------------------------------------------------------------------------------------------------------------#
# Plotting electron mobility as a function of doping concentration in GaAs, Ga(0.5)In(0.5)P and 
# In(0.3)Ga(0.7)As
#------------------------------------------------------------------------------------------------------------------#
#----------------------------------------------------------------------------------
# 1) GaAs:Electron Mobility Vs doping
#----------------------------------------------------------------------------------

# 1.1) Specify path of pardb and source files
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

# 1.4) Specify variables for creating list of Xdata values
# a) N should be greater than 1 b)min != max c) min < max
# for logspace: min > 0 and max > 0
set N 100			
set min 1e15
set max 1e20

set ::xvar doping
set Xdata [logspace $min $max $N]


# 1.2) Define variables
set ::material GaAs
set ::model Sotoodeh-Masetti_4CPV

set Ydata [getDataFromEqn $Xdata]
set curveName ${::material}_${::model}
cv_createFromScript $curveName $Xdata $Ydata
cv_display $curveName

# Add the curvename to a list of curves. Useful for manipulating curve attributes
lappend CURVES $curveName
cv_write csv "${::filename}_${curveName}.csv" $curveName

#----------------------------------------------------------------------------------
# GaInP
#----------------------------------------------------------------------------------

set ::material GaInP
set ::model Sotoodeh_4CPV

set Ydata1 [getDataFromEqn $Xdata]

set curveName ${::material}_${::model}
cv_createFromScript $curveName $Xdata $Ydata1
cv_display $curveName

lappend CURVES $curveName
cv_write csv "${::filename}_${curveName}.csv" $curveName

#----------------------------------------------------------------------------------
# InGaAsN
#----------------------------------------------------------------------------------

set ::material InGaAsN
set ::model MW

set Ydata2 [getDataFromEqn $Xdata]

set curveName ${::material}_${::model}
cv_createFromScript $curveName $Xdata $Ydata2
cv_display $curveName

lappend CURVES $curveName
cv_write csv "${::filename}_${curveName}.csv" $curveName

#----------------------------------------------------------------------------------
#  AlInP
#----------------------------------------------------------------------------------
namespace eval :: { source ../AlInP/Mobility/ConstantMobility/Default.tcl }
set ::material AlInP
set ::model Default_4CPV

set Ydata2 [getDataFromEqn $Xdata]

set curveName ${::material}_${::model}
cv_createFromScript $curveName $Xdata $Ydata2
cv_display $curveName

lappend CURVES $curveName
cv_write csv "${::filename}_${curveName}.csv" $curveName

#----------------------------------------------------------------------------------
#  AlGaAs
#----------------------------------------------------------------------------------

set ::material AlGaAs
set ::model Sotoodeh_4CPV
set ::xMole 0.05

set Ydata2 [getDataFromEqn $Xdata]

set curveName ${::material}_${::model}_${::xMole}
cv_createFromScript $curveName $Xdata $Ydata2
cv_display $curveName

lappend CURVES $curveName
cv_write csv "${::filename}_${curveName}.csv" $curveName

#----------------------------------------------------------------------------------
#  Germanium
#----------------------------------------------------------------------------------

set ::material Ge
set ::model Palankovski_4CPV

set Ydata2 [getDataFromEqn $Xdata]

set curveName ${::material}_${::model}
cv_createFromScript $curveName $Xdata $Ydata2
cv_display $curveName

lappend CURVES $curveName
cv_write csv "${::filename}_${curveName}.csv" $curveName

#----------------------------------------------------------------------------
# Set curve and axes attributes
#----------------------------------------------------------------------------
setAllCurveAttr $CURVES
set XaxisTitle Doping\[cm^-3\]
set XaxisScale 1
set YaxisTitle {Electron Mobility [cm2/V-s]}
set YaxisScale 1
gr_setAxisAttr X $XaxisTitle {helvetica 16} {} {} black 1 {helvetica 14} 0 10 $XaxisScale black
gr_setAxisAttr Y $YaxisTitle {helvetica 16} {} {} black 1 {helvetica 14} 0 10 $YaxisScale black



