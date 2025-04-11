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


set ::material GaInP
set ::propertyGroup BandStructure
set ::parSection JainRoulston
set ::model Levinshtein
set ::propertyVariable deltaEg
set ::xvar doping
set ::xMole 0.1

set N 60			
set min 1e15
set max 1e20
# 1.5) Generate list of X-axis variable
set Xdata [logspace $min $max $N]

# 1.6) Calculate propertyValue
set Ydata [getDataFromEqn $Xdata]

# 1.7) Plot curve
set curveName ${::material}_${::parSection}_${::model}_${::propertyVariable}
cv_createFromScript $curveName $Xdata $Ydata
cv_display $curveName

# 1.8) Add the curvename to a list of curves. Useful for manipulating curve attributes
lappend CURVES $curveName


#----------------------------------------------------------------------------------
# 2) Plot additional curve: bandgap narrowing Vs doping using the table based model from Schubert
#----------------------------------------------------------------------------------
set ::material InP

set Xdata [logspace $min $max $N]
set Ydata [getDataFromEqn $Xdata]

set curveName ${::material}_${::parSection}_${::model}_${::propertyVariable}
cv_createFromScript $curveName $Xdata $Ydata
cv_display $curveName
lappend CURVES $curveName
#----------------------------------------------------------------------------------
# 3) Plot additional curve: bandgap narrowing Vs doping using the table based model from Marti
#----------------------------------------------------------------------------------

set ::material GaP

set Xdata [logspace $min $max $N]
set Ydata [getDataFromEqn $Xdata]

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









