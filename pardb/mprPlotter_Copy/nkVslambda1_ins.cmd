#-----------------------------------------------------------------------------------------------------------#
# $Id: nkVslambda_ins.cmd,v 1.3 2007/08/21 03:30:01 sameers Exp $
#-----------------------------------------------------------------------------------------------------------#
# Plotting multiple curves with mprPlotter for table based models:
# For a single model, plot n and k for n-GaAs as a function of wavelength at different doping concentrations
#-----------------------------------------------------------------------------------------------------------#

#--------------------------------------------------------
# 1) Plot alpha and k Vs wavelength for GaInP
#--------------------------------------------------------

# 1.1) Specify path of pardb and source files
set ::pardb ../../pardb
source ../../lib/helper.tcl
source computematpar.tcl
source ../../lib/PhysicalConstants.tcl

# 1.2) Define variables
set ::material GaInP
set ::propertyGroup Optics
set ::parSection TableODB
set ::model Schubert-new


# 1.3) Define X-axis variable
set ::XdataVar llist   

# 1.4) Define parameters
set ::doping 1e18



# Plot k Vs lambda
set ::propertyVariable klist

set Xdata [getXdataFromTable]
set Ydata [getYdataFromTable]


set energy [list]
foreach lambda $Xdata {
	set en [expr {1.23984/$lambda}]
	lappend energy $en
}
	
set alpha [list]
foreach lambda $Xdata k $Ydata {
	set abs [expr {4*$::pi*$k/($lambda)}]
	lappend alpha $abs
}	
	
	
set curveName ${::material}_${::parSection}_${::model}_alpha
cv_createFromScript $curveName $energy $alpha
cv_display $curveName y
lappend CURVES $curveName

set curveName ${::material}_${::parSection}_${::model}_${::propertyVariable}
cv_createFromScript $curveName $energy $Ydata
cv_display $curveName y2
lappend CURVES $curveName

#--------------------------------------------------------
# 1) Plot alpha and k Vs wavelength for GaInP
#--------------------------------------------------------

set ::material AlInP
set ::propertyGroup Optics
set ::parSection TableODB
set ::model Ioffe

set ::propertyVariable klist
set Xdata [getXdataFromTable]
set Ydata [getYdataFromTable]

set energy [list]
foreach lambda $Xdata {
	set en [expr {1.23984/$lambda}]
	lappend energy $en
}
	
set alpha [list]
foreach lambda $Xdata k $Ydata {
	set abs [expr {4*$::pi*$k/($lambda)}]
	lappend alpha $abs
}	
	
	
set curveName ${::material}_${::parSection}_${::model}_alpha
cv_createFromScript $curveName $energy $alpha
cv_display $curveName y
lappend CURVES $curveName

set curveName ${::material}_${::parSection}_${::model}_${::propertyVariable}
cv_createFromScript $curveName $energy $Ydata
cv_display $curveName y2
lappend CURVES $curveName
#----------------------------------------------------------------------------
# 3) Set curve and axes attributes
#----------------------------------------------------------------------------
setAllCurveAttr $CURVES
set XaxisTitle Energy\[eV\]
set XaxisScale 0
set YaxisTitle alpha\[um^(-1)\]
set YaxisScale 1
# set Y2axisTitle k\[1\]
# set Y2axisScale 0
gr_setAxisAttr X $XaxisTitle {helvetica 16} {} {} black 1 {helvetica 14} 0 10 $XaxisScale black
gr_setAxisAttr Y $YaxisTitle {helvetica 16} {} {} black 1 {helvetica 14} 0 10 $YaxisScale black
# gr_setAxisAttr Y2 $Y2axisTitle {helvetica 16} {} {} black 1 {helvetica 14} 0 10 $Y2axisScale black








