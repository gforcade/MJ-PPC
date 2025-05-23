#-----------------------------------------------------------------------------------------------------------#
# $Id: nkVslambda_ins.cmd,v 1.3 2007/08/21 03:30:01 sameers Exp $
#-----------------------------------------------------------------------------------------------------------#
# Plotting multiple curves with mprPlotter for table based models:
# For a single model, plot n and k for n-GaAs as a function of wavelength at different doping concentrations
#-----------------------------------------------------------------------------------------------------------#

#--------------------------------------------------------
# 1) Plot n and k Vs wavelength for doping of 1e17 cm^-3
#--------------------------------------------------------

# 1.1) Specify path of pardb and source files
set ::pardb ../../pardb
source ../../lib/helper.tcl
source computematpar.tcl
source ../../lib/compound_lib.tcl

# 1.2) Define variables
set ::temp 300

set ::propertyGroup Optics
set ::parSection TableODB



# 1.3) Define X-axis variable
set ::XdataVar llist   

#--------------------------------------------------------------------------------------------------
# 2) Plot n and k Vs wavelength for doping of 1e18 cm^-3
#-------------- 

set ::material AlInP
set ::xMole 0.5
set ::model Default_4CPV

puts "n,k plotter"

set ::propertyVariable nlist
set Xdata [getXdataFromTable]
set Ydata [getYdataFromTable]
set curveName ${::material}_${::parSection}_${::model}_${::propertyVariable}
cv_createFromScript $curveName $Xdata $Ydata
cv_display $curveName y
lappend CURVES $curveName

set ::propertyVariable klist
set Xdata [getXdataFromTable]
set Ydata [getYdataFromTable]
set curveName ${::material}_${::parSection}_${::model}_${::propertyVariable}
cv_createFromScript $curveName $Xdata $Ydata
cv_display $curveName y
lappend CURVES $curveName


set ::material GaInP
set ::xMole 0.5
set ::model Default_4CPV

puts "n,k plotter"

set ::propertyVariable nlist
set Xdata [getXdataFromTable]
set Ydata [getYdataFromTable]
set curveName ${::material}_${::parSection}_${::model}_${::propertyVariable}
cv_createFromScript $curveName $Xdata $Ydata
cv_display $curveName y
lappend CURVES $curveName

set ::propertyVariable klist
set Xdata [getXdataFromTable]
set Ydata [getYdataFromTable]
set curveName ${::material}_${::parSection}_${::model}_${::propertyVariable}
cv_createFromScript $curveName $Xdata $Ydata
cv_display $curveName y
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
gr_setAxisAttr X $XaxisTitle {helvetica 16} 1 6 black 1 {helvetica 14} 0 10 $XaxisScale black
gr_setAxisAttr Y $YaxisTitle {helvetica 16} -10 20 black 1 {helvetica 14} 0 10 $YaxisScale black
gr_setAxisAttr Y2 $Y2axisTitle {helvetica 16} {} {} black 1 {helvetica 14} 0 10 $Y2axisScale black








