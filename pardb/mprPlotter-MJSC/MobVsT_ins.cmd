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
set ::material AlInP
set ::propertyGroup Mobility
set ::parSection ConstantMobility
set ::model Default

# Define X-axis variable (temp, lambda, xMole, yMole, doping)
set ::xvar temp

# Define parameters
# set ::doping 1e14


# Specify variables for creating list of Xdata values
# a) N should be greater than 1 b)min != max c) min < max
# for logspace: min > 0 and max > 0
set N 4			
set min 200
set max 500

# Generate list of X-axis variable
set Xdata [linspace $min $max $N]

# Plot curves
set ::propertyVariable mu_const_n
set Ydata [getDataFromEqn $Xdata]
set curveName ${::material}_${::parSection}_${::model}_${::propertyVariable}
cv_createFromScript $curveName $Xdata $Ydata
cv_display $curveName
lappend CURVES $curveName

set ::propertyVariable mu_const_p
set Ydata [getDataFromEqn $Xdata]
set curveName ${::material}_${::parSection}_${::model}_${::propertyVariable}
cv_createFromScript $curveName $Xdata $Ydata
cv_display $curveName
lappend CURVES $curveName


#----------------------------------------------------------------------------
# Set curve and axes attributes
#----------------------------------------------------------------------------
setAllCurveAttr $CURVES
set XaxisTitle Temperature\[1\]
set XaxisScale 0
set YaxisTitle ElectronMobility\[cm^2/(V-s)\]
set YaxisScale 0
gr_setAxisAttr X $XaxisTitle {helvetica 16} 200 500 black 1 {helvetica 14} 1 10 $XaxisScale black
# gr_setAxisAttr Y $YaxisTitle {helvetica 16} 0 9000 black 1 {helvetica 14} 1 10 $YaxisScale black







