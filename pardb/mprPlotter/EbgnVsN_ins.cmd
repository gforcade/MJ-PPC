#-----------------------------------------------------------------------#
# $Id: EbgnVsN_ins.cmd,v 1.3 2007/08/20 07:32:32 sameers Exp $
#-----------------------------------------------------------------------#
# Plotting multiple curves with mprPlotter for table based models:
# Plot bandgap narrowing of n-GaAs as a function of doping concentration
#-----------------------------------------------------------------------#

#--------------------------------------------------------------------------------------------------
# 1) Plot a single curve: bandgap narrowing Vs doping using the table based model from JainRoulston 
#--------------------------------------------------------------------------------------------------

# 1.1) Specify path of pardb and source files
set ::pardb ../../pardb
source ../../lib/helper.tcl
source computematpar.tcl

# 1.2) Define variables
set ::material GaAs
set ::propertyGroup BandStructure
set ::parSection TableBGN
set ::model JainRoulston-Default
set ::propertyVariable deltaEg_n

# 1.3) Define X-axis variable
set ::XdataVar Nd   

# 1.4) Get X and Y data from the model.tcl file
set Xdata [getXdataFromTable]
set Ydata [getYdataFromTable]

# 1.5) Plot curve
set curveName ${::material}_${::parSection}_${::model}_${::propertyVariable}
cv_createFromScript $curveName $Xdata $Ydata
cv_display $curveName

# 1.6) Add the curvename to a list of curves. Useful for manipulating curve attributes
lappend CURVES $curveName

#----------------------------------------------------------------------------------
# 2) Plot additional curve: bandgap narrowing Vs doping using the table based model from Schubert
#----------------------------------------------------------------------------------

# 2.1) Redefine variables
set ::model Schubert

# 2.2) Get X and Y data from the model.tcl file
set Xdata [getXdataFromTable]
set Ydata [getYdataFromTable]

# 2.3) Plot curve
set curveName ${::material}_${::parSection}_${::model}_${::propertyVariable}
cv_createFromScript $curveName $Xdata $Ydata
cv_display $curveName
lappend CURVES $curveName
#----------------------------------------------------------------------------------
# 3) Plot additional curve: bandgap narrowing Vs doping using the table based model from Marti
#----------------------------------------------------------------------------------

# 3.1) Redefine variables
set ::model Blieske

# 3.2) Get X and Y data from the model.tcl file
set Xdata [getXdataFromTable]
set Ydata [getYdataFromTable]

# 3.3) Plot curve
set curveName ${::material}_${::parSection}_${::model}_${::propertyVariable}
cv_createFromScript $curveName $Xdata $Ydata
cv_display $curveName
lappend CURVES $curveName


#----------------------------------------------------------------------------
# Set curve and axes attributes
#----------------------------------------------------------------------------
setAllCurveAttr $CURVES
set XaxisTitle Doping\[cm^-3\]
set XaxisScale 1
set YaxisTitle Ebgn\[eV\]
set YaxisScale 0
gr_setAxisAttr X $XaxisTitle {helvetica 16} {} {} black 1 {helvetica 14} 0 10 $XaxisScale black
gr_setAxisAttr Y $YaxisTitle {helvetica 16} {} {} black 1 {helvetica 14} 0 10 $YaxisScale black








