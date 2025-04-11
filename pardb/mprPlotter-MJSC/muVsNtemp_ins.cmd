#------------------------------------------------------------------------------------------------------------------#
# $Id: muVsNtemp_ins.cmd,v 1.5 2007/08/21 03:30:01 sameers Exp $
#------------------------------------------------------------------------------------------------------------------#
# Plotting multiple curves with mprPlotter for analytical models:
# For a single model, plot electron mobility of GaAs as a function of doping concentration at different temperatures
#------------------------------------------------------------------------------------------------------------------#

#----------------------------------------------------------------------------------------------------------
# 1) Plot a single curve: electron mobility Vs doping at T=400 K, using the default model from sdevice 
#----------------------------------------------------------------------------------------------------------

source computematpar.tcl

# 1.1) Specify path of epi and pardb directories
set ::pardb ../../pardb
set ::epi ../../epi
source $::epi/lib/helper.tcl

# 1.2) Define variables
set ::material GaAs
set ::propertyGroup Mobility
set ::parSection DopingDependence
set ::model Default-Arora
set ::propertyVariable mu_dop_n

# 1.3) Choose X-axis variable (temp, lambda, xMole, yMole, doping)
set ::xvar doping

# 1.4) Define parameters
set ::temp 400

# 1.4) Specify variables for creating list of Xdata values
# a) N should be greater than 1 b)min != max c) min < max
# for logspace: min > 0 and max > 0
set N 100			
set min 1e14
set max 1e20

# 1.5) Generate list of X-axis variable
set Xdata [logspace $min $max $N]

# 1.6) Calculate propertyValue
set Ydata [getDataFromEqn $Xdata]

# 1.7) Plot curve
set curveName ${::material}_${::parSection}_${::model}_${::propertyVariable}_${::temp}
cv_createFromScript $curveName $Xdata $Ydata
cv_display $curveName

# 1.8) Add the curvename to a list of curves. Useful for manipulating curve attributes
lappend CURVES $curveName


#----------------------------------------------------------------------------------
# 2) Plot additional curve: Room temperature electron mobility Vs doping using model from sdevice 
#----------------------------------------------------------------------------------

# 2.1) Redefine variables
set ::temp 300

# 2.2) Calculate  propertyValue
set Ydata1 [getDataFromEqn $Xdata]

# 2.3) Plot curve
set curveName ${::material}_${::parSection}_${::model}_${::propertyVariable}_$::temp
cv_createFromScript $curveName $Xdata $Ydata1
cv_display $curveName
lappend CURVES $curveName

#----------------------------------------------------------------------------
# Set curve and axes attributes
#----------------------------------------------------------------------------
setAllCurveAttr $CURVES
set XaxisTitle Doping\[cm^-3\]
set XaxisScale 1
set YaxisTitle ElectronMobility\[cm^2/(V-s)\]
set YaxisScale 0
gr_setAxisAttr X $XaxisTitle {helvetica 16} {} {} black 1 {helvetica 14} 0 10 $XaxisScale black
gr_setAxisAttr Y $YaxisTitle {helvetica 16} {} {} black 1 {helvetica 14} 0 10 $YaxisScale black

