#-----------------------------------------------------------------------------------------------------------#
# $Id: nkVslambda_ins.cmd,v 1.3 2007/08/21 03:30:01 sameers Exp $
#-----------------------------------------------------------------------------------------------------------#
# Plotting multiple curves with mprPlotter for table based models:
# For a single model, plot n and k for n-GaAs as a function of wavelength at different doping concentrations
#-----------------------------------------------------------------------------------------------------------#

#--------------------------------------------------------
# 1) Plot n and k Vs wavelength for doping of 1e17 cm^-3
#--------------------------------------------------------

source computematpar.tcl

# 1.1) Specify path of epi and pardb directories
set ::pardb ../../pardb
set ::epi ../../epi
source $::epi/lib/helper.tcl

# 1.2) Define variables
set ::material GaAs
set ::propertyGroup Optics
set ::parSection TableODB
set ::model Levinshtein
set ::propertyVariable nlist

# 1.3) Define X-axis variable
set ::XdataVar llist   

# 1.4) Define parameters
set ::doping 1e17

# 1.5) Get X and Y data from the model.tcl file
set Xdata [getXdataFromTable]
set Ydata [getYdataFromTable]

# 1.6) Plot curve
set curveName ${::material}_${::parSection}_${::model}_${::propertyVariable}_${::doping}
cv_createFromScript $curveName $Xdata $Ydata
cv_display $curveName y

# 1.7) Add the curvename to a list of curves. Useful for manipulating curve attributes
lappend CURVES $curveName

# Plot k Vs lambda
set ::propertyVariable klist

set Xdata [getXdataFromTable]
set Ydata [getYdataFromTable]

set curveName ${::material}_${::parSection}_${::model}_${::propertyVariable}_${::doping}
cv_createFromScript $curveName $Xdata $Ydata
cv_display $curveName y2
lappend CURVES $curveName


#--------------------------------------------------------------------------------------------------
# 2) Plot n and k Vs wavelength for doping of 1e18 cm^-3
#--------------------------------------------------------------------------------------------------
set ::doping 1e18

set ::propertyVariable nlist
set Xdata [getXdataFromTable]
set Ydata [getYdataFromTable]
set curveName ${::material}_${::parSection}_${::model}_${::propertyVariable}_${::doping}
cv_createFromScript $curveName $Xdata $Ydata
cv_display $curveName y
lappend CURVES $curveName

set ::propertyVariable klist
set Xdata [getXdataFromTable]
set Ydata [getYdataFromTable]
set curveName ${::material}_${::parSection}_${::model}_${::propertyVariable}_${::doping}
cv_createFromScript $curveName $Xdata $Ydata
cv_display $curveName y2
lappend CURVES $curveName


#----------------------------------------------------------------------------
# 3) Set curve and axes attributes
#----------------------------------------------------------------------------
setAllCurveAttr $CURVES
set XaxisTitle wavelength\[um\]
set XaxisScale 0
set YaxisTitle n\[1\]
set YaxisScale 0
set Y2axisTitle k\[1\]
set Y2axisScale 0
gr_setAxisAttr X $XaxisTitle {helvetica 16} {} {} black 1 {helvetica 14} 0 10 $XaxisScale black
gr_setAxisAttr Y $YaxisTitle {helvetica 16} {} {} black 1 {helvetica 14} 0 10 $YaxisScale black
gr_setAxisAttr Y2 $Y2axisTitle {helvetica 16} {} {} black 1 {helvetica 14} 0 10 $Y2axisScale black








