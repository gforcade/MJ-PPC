#----------------------------------------------------------------#
# $Id: EgVsT_ins.cmd,v 1.4 2007/08/20 07:32:32 sameers Exp $
#----------------------------------------------------------------#
# Plotting multiple curves with mprPlotter for analytical models:
# Plot Bandgap of GaAs as a function of temperature 
#----------------------------------------------------------------#

#-----------------------------------------------------------------------
# 1) Plot a single curve: Bandgap Vs temperature using the default model from sdevice 
#-----------------------------------------------------------------------

source computematpar.tcl

# 1.1) Specify path of epi and pardb directories
set ::pardb ../../pardb
set ::epi ../../epi
source $::epi/lib/helper.tcl

# 1.2) Define variables
set ::material GaP
set ::propertyGroup BandStructure
set ::parSection Bandgap
set ::model Default
set ::propertyVariable Eg

# 1.3) Choose X-axis variable (temp, lambda, xMole, yMole, doping)
set ::xvar temp

# 1.4) Specify variables for creating list of Xdata values
# a) N should be greater than 1 b)min != max c) min < max
# for logspace: min > 0 and max > 0
set N 50			
set min 10
set max 300

# 1.5) Generate list of X-axis variable
set Xdata [linspace $min $max $N]

# 1.6) Calculate propertyValue
set Ydata [getDataFromEqn $Xdata]

# 1.7) Plot curve
set curveName ${::material}_${::parSection}_${::model}_${::propertyVariable}
cv_createFromScript $curveName $Xdata $Ydata
cv_display $curveName

# 1.8) Add the curvename to a list of curves. Useful for manipulating curve attributes
lappend CURVES $curveName

#----------------------------------------------------------------------------------
# 2) Plot additional curve: Bandgap Vs temperature using model from Levinshtein-RT
#----------------------------------------------------------------------------------

# 2.1) Redefine variables
set ::material InP

# 2.2) Calculate  propertyValue
set Ydata1 [getDataFromEqn $Xdata]

# 2.3) Plot curve
set curveName ${::material}_${::parSection}_${::model}_${::propertyVariable}
cv_createFromScript $curveName $Xdata $Ydata1
cv_display $curveName
lappend CURVES $curveName




#----------------------------------------------------------------------------
# Set curve and axes attributes
#----------------------------------------------------------------------------
setAllCurveAttr $CURVES
set XaxisTitle temperature\[K\]
set XaxisScale 0
set YaxisTitle Bandgap\[eV\]
set YaxisScale 0
gr_setAxisAttr X $XaxisTitle {helvetica 16} {} {} black 1 {helvetica 14} 0 10 $XaxisScale black
gr_setAxisAttr Y $YaxisTitle {helvetica 16} {} {} black 1 {helvetica 14} 0 10 $YaxisScale black


