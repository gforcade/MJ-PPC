#----------------------------------------------------------------#
# $Id: EgVsxMole_ins.cmd,v 1.5 2007/08/23 03:21:12 sameers Exp $
#----------------------------------------------------------------#
# Plot room temperature Bandgaps of AlGaAs as a function of xMole
#----------------------------------------------------------------#



# 1.1) Specify path of pardb and source files
set ::pardb ../../pardb
source ../../lib/helper.tcl
source computematpar.tcl
source ../../lib/PhysicalConstants.tcl
source ../../lib/compound_lib.tcl




# Define variables
set ::material GaAs
set ::propertyGroup Recombination
set ::parSection RadiativeRecombination
set ::model GF_v3

# Define X-axis variable (temp, lambda, xMole, yMole, doping, thickness)
set ::xvar thickness

# Define parameters
set ::doping 1e15
set ::xMole 0.47
set ::temp 300.0


# Specify variables for creating list of Xdata values
# a) N should be greater than 1 b)min != max c) min < max
# for logspace: min > 0 and max > 0
set N 100			
set min 0.001
set max 100.0

# Generate list of X-axis variable
##set Xdata [linspace $min $max $N]
set Xdata [logspace $min $max $N]



set ::propertyVariable C
set Ydata [getDataFromEqn $Xdata]




set curveName ${::material}_${::parSection}_${::model}_${::propertyVariable}_${::doping}
cv_createFromScript $curveName $Xdata $Ydata
cv_display $curveName
lappend CURVES $curveName




#----------------------------------------------------------------------------
# Set curve and axes attributes
#----------------------------------------------------------------------------
setAllCurveAttr $CURVES
set XaxisTitle $::xvar
set XaxisScale 1
set YaxisTitle Variable
set YaxisScale 0
gr_setAxisAttr X $XaxisTitle {helvetica 25} {} {} black 1 {helvetica 23} 0 10 $XaxisScale black
gr_setAxisAttr Y $YaxisTitle {helvetica 25} {} {} black 1 {helvetica 23} 0 10 $YaxisScale black

cv_write csv SimData.csv "${::material}_${::parSection}_${::model}_${::propertyVariable}_${::doping}"
