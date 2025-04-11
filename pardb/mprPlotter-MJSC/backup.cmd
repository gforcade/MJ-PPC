#-----------------------------------------------------------------------------------------------------------#
# Plot absorption coefficient spectra of AlInP, GaInP, AlGaAs, GaAs and InGaAs 
#-----------------------------------------------------------------------------------------------------------#

#--------------------------------------------------------
# 1) Plot GaInP alpha Vs energy for xMole=0.5
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
set ::model Schubert
set ::propertyVariable klist

# 1.3) Define X-axis variable
set ::XdataVar llist   

# 1.4) Define parameters
set ::xMole 0.5

# 1.5) Get X (wavelength) and Y (extinction coefficient) data from the model.tcl file
set Xdata [getXdataFromTable]
set Ydata [getYdataFromTable]

# Calculate Energy from wavelength 
set energy [list]
foreach lambda $Xdata {
	set en [expr {1.23984/$lambda}]
	lappend energy $en
}

# Calculate absorption coefficient from extinction coefficient 
set alpha [list]
foreach lambda $Xdata k $Ydata {
	set abs [expr {4*$::pi*$k/($lambda*1e-4)}]
	lappend alpha $abs
}	
	
# 1.6) Plot alpha Vs lambda curve	
set curveName ${::material}_${::parSection}_${::model}_${::xMole}
cv_createFromScript $curveName $energy $alpha
cv_display $curveName y
lappend CURVES $curveName



#--------------------------------------------------------------------------------------------------
# 2) Plot GaAs alpha Vs energy for doping of 1e18 cm^-3
#--------------------------------------------------------------------------------------------------
set ::material GaAs
set ::propertyGroup Optics
set ::parSection TableODB
set ::model Levinshtein
set ::doping 1e18

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
	set abs [expr {4*$::pi*$k/($lambda*1e-4)}]
	lappend alpha $abs
}	
	
	
set curveName ${::material}_${::parSection}_${::model}_${::doping}
cv_createFromScript $curveName $energy $alpha
cv_display $curveName y
lappend CURVES $curveName

#--------------------------------------------------------------------------------------------------
# 3) Plot AlInP alpha Vs energy for xMole=0.5 
#--------------------------------------------------------------------------------------------------
set ::material AlInP
set ::propertyGroup Optics
set ::parSection TableODB
set ::model Breselge
set ::xMole 0.5

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
	set abs [expr {4*$::pi*$k/($lambda*1e-4)}]
	lappend alpha $abs
}	
	
	
set curveName ${::material}_${::parSection}_${::model}_${::xMole}
cv_createFromScript $curveName $energy $alpha
cv_display $curveName y
lappend CURVES $curveName
#--------------------------------------------------------------------------------------------------
# 4) Plot AlInP alpha Vs energy 
#--------------------------------------------------------------------------------------------------
set ::material InGaAs
set ::model Bhattacharya
set ::xMole 0.7

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
	set abs [expr {4*$::pi*$k/($lambda*1e-4)}]
	lappend alpha $abs
}	
	
	
set curveName ${::material}_${::parSection}_${::model}_${::xMole}
cv_createFromScript $curveName $energy $alpha
cv_display $curveName y
lappend CURVES $curveName

#--------------------------------------------------------------------------------------------------
# 5) Plot AlGaAs alpha Vs energy 
#--------------------------------------------------------------------------------------------------
set ::material AlGaAs
set ::model djurisic
set ::xMole 0.3

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
	set abs [expr {4*$::pi*$k/($lambda*1e-4)}]
	lappend alpha $abs
}	
	
	
set curveName ${::material}_${::parSection}_${::model}_${::xMole}
cv_createFromScript $curveName $energy $alpha
cv_display $curveName y
lappend CURVES $curveName


#----------------------------------------------------------------------------
# 6) Set curve and axes attributes
#----------------------------------------------------------------------------
setAllCurveAttr $CURVES
set XaxisTitle Energy\[eV\]
set XaxisScale 0
set YaxisTitle alpha\[cm^(-1)\]
set YaxisScale 1
gr_setAxisAttr X $XaxisTitle {helvetica 16} {} {} black 1 {helvetica 14} 0 10 $XaxisScale black
gr_setAxisAttr Y $YaxisTitle {helvetica 16} {1e-1} {} black 1 {helvetica 14} 0 10 $YaxisScale black











