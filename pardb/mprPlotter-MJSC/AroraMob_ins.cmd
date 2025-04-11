#----------------------------------------------------------------#
# $Id: $
#----------------------------------------------------------------#
#----------------------------------------------------------------#
# Plot Electron mobility of AlGaAs as a function of xMole
# Fig. 4 Sotoodeh
#----------------------------------------------------------------#
# Created on 2007/12/04 by Sameer Shah

# setdep @previous@


source computematpar.tcl
# Specify path of epi and pardb directories
set ::pardb ../../pardb
set ::epi ../../epi
source $::epi/lib/helper.tcl
source $::epi/lib/compound_lib.tcl
source $::epi/lib/PhysicalConstants.tcl

# Define variables
set ::material GaAs
set ::propertyGroup Mobility
set ::parSection DopingDependence
set ::model Palankovski

# Define X-axis variable (temp, lambda, xMole, yMole, doping)
set ::xvar doping

# Define parameters
set ::temp 200


# Specify variables for creating list of Xdata values
# a) N should be greater than 1 b)min != max c) min < max
# for logspace: min > 0 and max > 0
set N 20			
set min 1e14
set max 1e19

# Generate list of X-axis variable
set Xdata [logspace $min $max $N]

# Plot curves
set ::propertyVariable mu_dop_n
set Ydata [getDataFromEqn $Xdata]
set curveName ${::material}_${::parSection}_${::model}_${::propertyVariable}_${::temp}
cv_createFromScript $curveName $Xdata $Ydata
cv_display $curveName
lappend CURVES $curveName

set ::temp 300
set Ydata [getDataFromEqn $Xdata]
set curveName ${::material}_${::parSection}_${::model}_${::propertyVariable}_${::temp}
cv_createFromScript $curveName $Xdata $Ydata
cv_display $curveName
lappend CURVES $curveName
 
set ::temp 400
set Ydata [getDataFromEqn $Xdata]
set curveName ${::material}_${::parSection}_${::model}_${::propertyVariable}_${::temp}
cv_createFromScript $curveName $Xdata $Ydata
cv_display $curveName
lappend CURVES $curveName 
#----------------------------------------------------------------------------
# Set curve and axes attributes
#----------------------------------------------------------------------------
setAllCurveAttr $CURVES
set XaxisTitle doping\[1\]
set XaxisScale 1
set YaxisTitle ElectronMobility\[cm^2/(V-s)\]
set YaxisScale 0
gr_setAxisAttr X $XaxisTitle {helvetica 16} 1e14 1e19 black 1 {helvetica 14} 1 10 $XaxisScale black
# gr_setAxisAttr Y $YaxisTitle {helvetica 16} 0 9000 black 1 {helvetica 14} 1 10 $YaxisScale black






