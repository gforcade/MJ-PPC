#-----------------------------------------------------------------------#
# $Id: EbgnVsN_ins.cmd,v 1.3 2007/08/20 07:32:32 sameers Exp $
#-----------------------------------------------------------------------#
# Plotting multiple curves with mprPlotter for table based models:
# Plot bandgap narrowing of n-GaAs as a function of doping concentration
#-----------------------------------------------------------------------#

#--------------------------------------------------------------------------------------------------
# 1) Plot a single curve: bandgap narrowing Vs doping using the table based model from JainRoulston 
#--------------------------------------------------------------------------------------------------

source computematpar.tcl

# 1.1) Specify path of epi and pardb directories
set ::pardb ../../pardb
set ::epi ../../epi
source $::epi/lib/helper.tcl
source $::epi/lib/compound_lib.tcl


# 1.2) Define variables
set ::material GaInP
set ::propertyGroup BandStructure
set ::parSection TableBGN
set ::model Piprek
set ::propertyVariable deltaEg_n

# 1.3) Define X-axis variable
set ::XdataVar Nd   
set ::temp 300
set ::xMole 0.51
# 1.4) Get X and Y data from the model.tcl file
set Xdata [getXdataFromTable]
set Ydata [getYdataFromTable]

# 1.5) Plot curve
set curveName ${::material}_${::parSection}_${::model}_${::propertyVariable}
cv_createFromScript $curveName $Xdata $Ydata
cv_display $curveName

# 1.6) Add the curvename to a list of curves. Useful for manipulating curve attributes
lappend CURVES $curveName

set ::model Levinshtein

set Xdata [getXdataFromTable]
set Ydata [getYdataFromTable]

# 1.5) Plot curve
set curveName ${::material}_${::parSection}_${::model}_${::propertyVariable}
cv_createFromScript $curveName $Xdata $Ydata
cv_display $curveName

# 1.6) Add the curvename to a list of curves. Useful for manipulating curve attributes
lappend CURVES $curveName

set ::propertyVariable deltaEg_p

set Xdata [getXdataFromTable]
set Ydata [getYdataFromTable]

# 1.5) Plot curve
set curveName ${::material}_${::parSection}_${::model}_${::propertyVariable}
cv_createFromScript $curveName $Xdata $Ydata
cv_display $curveName

# 1.6) Add the curvename to a list of curves. Useful for manipulating curve attributes
lappend CURVES $curveName

#===============
set ::parSection JainRoulston
set ::model Levinshtein
set ::propertyVariable deltaEg
set ::xvar doping

set N 50			
set min 1e14
set max 1e21

# 1.5) Generate list of X-axis variable
set Xdata [logspace $min $max $N]
set Ydata [getDataFromEqn $Xdata]

# 1.7) Plot curve
set curveName ${::material}_${::parSection}_${::model}_${::propertyVariable}
cv_createFromScript $curveName $Xdata $Ydata
cv_display $curveName

# 1.8) Add the curvename to a list of curves. Useful for manipulating curve attributes
lappend CURVES $curveName
#if 0
set N 50			
set min 1e14
set max 1e21

# 1.5) Generate list of X-axis variable
set Xdata [logspace $min $max $N]
set Ydata [getDataFromEqn $Xdata]

# 1.7) Plot curve
set curveName ${::material}_${::parSection}_${::model}_${::propertyVariable}
cv_createFromScript $curveName $Xdata $Ydata
cv_display $curveName

# 1.8) Add the curvename to a list of curves. Useful for manipulating curve attributes
lappend CURVES $curveName


set ::material GaP
set Xdata [getXdataFromTable]
set Ydata [getYdataFromTable]

# 1.5) Plot curve
set curveName ${::material}_${::parSection}_${::model}_${::propertyVariable}
cv_createFromScript $curveName $Xdata $Ydata
cv_display $curveName

# 1.6) Add the curvename to a list of curves. Useful for manipulating curve attributes
lappend CURVES $curveName

set ::xMole 0.5
set ::material GaInP
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

#endif
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








