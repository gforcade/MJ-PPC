#----------------------------------------------------------------#
# $Id: EgVsxMole_ins.cmd,v 1.5 2007/08/23 03:21:12 sameers Exp $
#----------------------------------------------------------------#
# Plot room temperature Bandgaps of AlGaAs as a function of xMole
#----------------------------------------------------------------#

# 1.1) Specify path of pardb and source files
set ::pardb ../../pardb
source ../../lib/helper.tcl
source computematpar.tcl

# Define variables
set ::material AlGaAs
set ::propertyGroup BandStructure
set ::parSection Bandgap
set ::model Levinshtein

# Define X-axis variable (temp, lambda, xMole, yMole, doping)
set ::xvar xMole

# Define parameters
set ::temp 300

# Specify variables for creating list of Xdata values
# a) N should be greater than 1 b)min != max c) min < max
# for logspace: min > 0 and max > 0
set N 100			
set min 0
set max 1

# Generate list of X-axis variable
set Xdata [linspace $min $max $N]

# Plot curves
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


#----------------------------------------------------------------------------
# Set curve and axes attributes
#----------------------------------------------------------------------------
setAllCurveAttr $CURVES
set XaxisTitle xMole\[1\]
set XaxisScale 0
set YaxisTitle Bandgap\[eV\]
set YaxisScale 0
gr_setAxisAttr X $XaxisTitle {helvetica 16} {} {} black 1 {helvetica 14} 0 10 $XaxisScale black
gr_setAxisAttr Y $YaxisTitle {helvetica 16} {} {} black 1 {helvetica 14} 0 10 $YaxisScale black


