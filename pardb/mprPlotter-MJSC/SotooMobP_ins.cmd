#----------------------------------------------------------------#
# $Id: SotooMobP_ins.cmd,v 1.2 2007/12/05 16:31:37 sameers Exp $
#----------------------------------------------------------------#
# Created on 2007/12/04 by Sameer Shah

# setdep @previous@

#----------------------------------------------------------------#
# Plot Hole mobility of AlGaAs as a function of xMole
#----------------------------------------------------------------#
source computematpar.tcl
# Specify path of epi and pardb directories
set ::pardb ../../pardb
set ::epi ../../epi
source $::epi/lib/helper.tcl
source $::epi/lib/compound_lib.tcl
source $::epi/lib/PhysicalConstants.tcl

# Define variables
set ::material Ge
set ::propertyGroup Mobility
set ::parSection DopingDependence
set ::model Default

# Define X-axis variable (temp, lambda, xMole, yMole, doping)
set ::xvar doping

# Define parameters
set ::temp 300
#set ::doping 2e17

# Specify variables for creating list of Xdata values
# a) N should be greater than 1 b)min != max c) min < max
# for logspace: min > 0 and max > 0
set N 100			
set min 1e14
set max 1e18

# Generate list of X-axis variable
set Xdata [linspace $min $max $N]

# Plot curves
set ::propertyVariable mu_dop_p
set Ydata [getDataFromEqn $Xdata]
set curveName ${::material}_${::parSection}_${::model}_${::propertyVariable}_${::doping}
cv_createFromScript $curveName $Xdata $Ydata
cv_display $curveName
lappend CURVES $curveName

if 0 {
set ::propertyVariable mu_dop_p
set Xdata [linspace $min $max $N]
set Ydata [getDataFromEqn $Xdata]
set curveName ${::material}_${::parSection}_${::model}_${::propertyVariable}_${::doping}
cv_createFromScript $curveName $Xdata $Ydata
cv_display $curveName
lappend CURVES $curveName

#----------------------------------------------------------------------------
# Set curve and axes attributes
#----------------------------------------------------------------------------
setAllCurveAttr $CURVES
set XaxisTitle xMole\[1\]
set XaxisScale 0
set YaxisTitle HoleMobility\[cm^2/(V-s)\]
set YaxisScale 0
gr_setAxisAttr X $XaxisTitle {helvetica 16} 0 1 black 1 {helvetica 14} 0 10 $XaxisScale black
gr_setAxisAttr Y $YaxisTitle {helvetica 16} 0 250 black 1 {helvetica 14} 0 10 $YaxisScale black
}






