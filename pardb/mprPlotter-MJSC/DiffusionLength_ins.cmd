#------------------------------------------------------------------------------------------------------------------#
# Plotting electron diffusion length as a function of doping concentration in GaAs, Ga(0.5)In(0.5)P and 
# In(0.3)Ga(0.7)As
#------------------------------------------------------------------------------------------------------------------#
#----------------------------------------------------------------------------------
# 1) GaAs:Electron Diffusion Length Vs doping
#----------------------------------------------------------------------------------

# 1.1) Specify path of pardb and source files
set ::pardb ../../pardb
source ../../lib/helper.tcl
source computematpar.tcl
source ../../lib/PhysicalConstants.tcl


# 1.2) Define variables
set ::material GaAs
set ::propertyGroup Mobility
set ::parSection DopingDependence
set ::model Sotoodeh-Masetti
set ::propertyVariable mu_dop_n

# 1.3) Choose X-axis variable (temp, lambda, xMole, yMole, doping)
set ::xvar doping

# 1.4) Define parameters
set ::temp 300

# 1.4) Specify variables for creating list of Xdata values
# a) N should be greater than 1 b)min != max c) min < max
# for logspace: min > 0 and max > 0
set N 100			
set min 1e15
set max 1e20

# 1.5) Generate list of X-axis variable
set Xdata [logspace $min $max $N]

# 1.6) Calculate propertyValue
set Ydata [getDataFromEqn $Xdata]

# Calculate radiative recombination lifetime as a function of doping
set tauN_s [list]
foreach dop $Xdata {
	set tauN [expr {1./(2e-10*$dop)}]
	lappend tauN_s $tauN
}

set Vth [expr {$::kB*$::temp/$::q}]

set Ln [list]
foreach mob $Ydata tau_n $tauN_s {
	set LN [expr {1e4*sqrt($Vth*$mob*$tau_n)}]; #Diffusion Length in um
	lappend Ln $LN
}

		
# 1.7) Plot curve
set curveName ${::material}_${::model}
cv_createFromScript $curveName $Xdata $Ln
cv_display $curveName

# 1.8) Add the curvename to a list of curves. Useful for manipulating curve attributes
lappend CURVES $curveName


#----------------------------------------------------------------------------------
# 2) GaInP:Electron Diffusion Length Vs doping
#----------------------------------------------------------------------------------

set ::material GaInP
set ::model Sotoodeh

set Ydata1 [getDataFromEqn $Xdata]

# Calculate radiative recombination lifetime as a function of doping
set tauN_s [list]
foreach dop $Xdata {
	set tauN [expr {1./(2e-10*$dop)}]
	lappend tauN_s $tauN
}

set Ln [list]
foreach mob $Ydata1 tau_n $tauN_s {
	set LN [expr {1e4*sqrt($Vth*$mob*$tau_n)}]; #Diffusion Length in um
	lappend Ln $LN
}

set curveName ${::material}_${::model}
cv_createFromScript $curveName $Xdata $Ln
cv_display $curveName

lappend CURVES $curveName

#----------------------------------------------------------------------------------
# 3) InGaAs:Electron Diffusion Length Vs doping
#----------------------------------------------------------------------------------

set ::material InGaAs
set ::model Sotoodeh

set Ydata2 [getDataFromEqn $Xdata]

# Calculate radiative recombination lifetime as a function of doping
set tauN_s [list]
foreach dop $Xdata {
	set tauN [expr {1./(1e-8*$dop)}]
	lappend tauN_s $tauN
}

set Ln [list]
foreach mob $Ydata2 tau_n $tauN_s {
	set LN [expr {1e4*sqrt($Vth*$mob*$tau_n)}]; #Diffusion Length in um
	lappend Ln $LN
}

set curveName ${::material}_${::model}
cv_createFromScript $curveName $Xdata $Ln
cv_display $curveName

lappend CURVES $curveName

#----------------------------------------------------------------------------
# Set curve and axes attributes
#----------------------------------------------------------------------------
setAllCurveAttr $CURVES
set XaxisTitle Doping\[cm^-3\]
set XaxisScale 1
set YaxisTitle {Electron Diffusion Length [um]}
set YaxisScale 1
gr_setAxisAttr X $XaxisTitle {helvetica 16} {} {} black 1 {helvetica 14} 0 10 $XaxisScale black
gr_setAxisAttr Y $YaxisTitle {helvetica 16} {} {} black 1 {helvetica 14} 0 10 $YaxisScale black


