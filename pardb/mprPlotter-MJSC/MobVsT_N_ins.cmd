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
set ::xvar temp

# Define parameters
set ::doping 1e14

# Specify variables for creating list of Xdata values
# a) N should be greater than 1 b)min != max c) min < max
# for logspace: min > 0 and max > 0
set N 20			
set min 200
set max 1000

# Generate list of X-axis variable
set Xdata [logspace $min $max $N]

# Plot curves
set ::propertyVariable mu_dop_n
set Ydata [getDataFromEqn $Xdata]
set curveName ${::material}_${::parSection}_${::model}_${::propertyVariable}_${::doping}
cv_createFromScript $curveName $Xdata $Ydata
cv_display $curveName
lappend CURVES $curveName

set ::doping 1e17
set Ydata [getDataFromEqn $Xdata]
set curveName ${::material}_${::parSection}_${::model}_${::propertyVariable}_${::doping}
cv_createFromScript $curveName $Xdata $Ydata
cv_display $curveName
lappend CURVES $curveName
 
set ::doping 1e19
set Ydata [getDataFromEqn $Xdata]
set curveName ${::material}_${::parSection}_${::model}_${::propertyVariable}_${::doping}
cv_createFromScript $curveName $Xdata $Ydata
cv_display $curveName
lappend CURVES $curveName 
#----------------------------------------------------------------------------
# Set curve and axes attributes
#----------------------------------------------------------------------------
setAllCurveAttr $CURVES
set XaxisTitle temp\[1\]
set XaxisScale 1
set YaxisTitle ElectronMobility\[cm^2/(V-s)\]
set YaxisScale 1
gr_setAxisAttr X $XaxisTitle {helvetica 16} 200 1000 black 1 {helvetica 14} 1 10 $XaxisScale black
gr_setAxisAttr Y $YaxisTitle {helvetica 16} {} {} black 1 {helvetica 14} 1 10 $YaxisScale black









