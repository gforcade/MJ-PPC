
*------------------------------------------------------------
* Simulate J-V characteristics 
* ------------------------------------------------------------


#setdep @node|optics@

#if "@eSim_type@" != "Jph"

File{
*-Input
   PMIpath = "@pwd@/../pmi"
   Grid    = "@tdr@"
   Parameters ="@pwd@/results/nodes/@node|MatPar@/@mprpar@"
#if "@OptiToSentaurus@" == "v3"
OpticalGenerationInput = "@pwd@/results/nodes/@node|tdx@/optGen.tdr"  
#else
 OpticalGenerationInput = "@[relpath pv1_PV_n@node|optics@_OptGen_des.tdr]@"  
#endif


*-Output
   Plot    = "@tdrdat@"
   Current = "@plot@"
   Output  = "@log@"
}


Electrode{
  { Name="cathode"  Voltage=0.0 }
{ Name="anode"  Voltage=0.0 }

#if "@eSim_type@" == "Jsc"
!(
	puts "*TCL code block to print tunnel contacts in electrodes section "
	for { set i 1 } { $i < @numSegments@ } { incr i } {
		puts "  {Name =\"td${i}_VContact1\" Voltage=0} "
		puts "  {Name =\"td${i}_VContact2\" Voltage=0} "
	}
)!
#endif

}  

*--------------------------------------
**** Physics section




* include general physics stuff (for both JV and EQE sdevice)
#include "@pwd@/../lib/sdevicePhysics.cmd" 



Physics {

#if @Pin@ > 0
  Optics (
    OpticalGeneration( 
	ReadFromFile( DatasetName = OpticalGeneration Scaling = @Pin@)
	#if "@LC@" == "on"  
		#if @Pin@ > 0.01
		TimeDependence ( WaveTime = (1.0, 3.0) WaveTSlope = 0.9999 Scaling = @Pin@ ) 
		#else
		TimeDependence ( WaveTime = (1.0, 3.0) WaveTSlope = 0.009999 Scaling = @Pin@ ) 
		#endif
	#else
	TimeDependence ( WaveTime = (1.0, 3.0) WaveTExp = 0.05 Scaling = @Pin@ -OpticalTurningPoints )  *using a gaussian scaling ramp, better convergence
	#endif
    ) *end of OpticalGeneration
  ) * Optics
#endif

} 







*----------------------------------------------------

Plot {
  xMoleFraction Doping DonorConcentration AcceptorConcentration 
  eEffectiveStateDensity hEffectiveStateDensity EffectiveIntrinsicDensity IntrinsicDensity
  eDensity hDensity SpaceCharge DielectricConstant 
  eQuasiFermiPotential hQuasiFermiPotential BandGap EffectiveBandGap ConductionBandEnergy ValenceBandEnergy ElectronAffinity
  eQuasiFermiEnergy hQuasiFermiEnergy
  ElectricField ElectricField/vector ElectrostaticPotential
  eLifetime hLifetime SRH Auger SurfaceRecombination RadiativeRecombination tSRHRecombination Band2BandGeneration TotalRecombination
  eCurrent/Vector hCurrent/Vector current/vector
  eMobility hMobility eVelocity hVelocity
  PMIeNonLocalRecombination
  eBarrierTunneling hBarrierTunneling
  OpticalGeneration OpticalIntensity AbsorbedPhotonDensity

}

CurrentPlot {
  SRH(Integrate( Semiconductor))
  tSRHRecombination(Integrate( Semiconductor))
  RadiativeRecombination(Integrate(Semiconductor))
  AugerRecombination(Integrate(Semiconductor))
   TotalRecombination(Integrate(Semiconductor))
 OpticalGeneration(Integrate(Semiconductor))
 Band2BandGeneration(Integrate (Semiconductor))
 SurfaceRecombination(Integrate (Everywhere))

!(
for { set i 1 } { $i < @<numSegments+1>@ } { incr i } {
if { (@seg1_em2_t@ > 0.0 && $i == 1) || (@seg2_em2_t@ > 0.0 && $i == 2) } {
puts "OpticalGeneration(Integrate(Region=\"sc${i}_em\" Region=\"sc${i}_em2\" ))"
puts "SRH(Integrate(Region=\"sc${i}_em\" Region=\"sc${i}_em2\" ))"
puts "AugerRecombination(Integrate(Region=\"sc${i}_em\" Region=\"sc${i}_em2\" ))"
puts "RadiativeRecombination(Integrate(Region=\"sc${i}_em\" Region=\"sc${i}_em2\" ))"
} else {
puts "OpticalGeneration(Integrate(Region=\"sc${i}_em\" ))"
puts "SRH(Integrate(Region=\"sc${i}_em\" ))"
puts "AugerRecombination(Integrate(Region=\"sc${i}_em\" ))"
puts "RadiativeRecombination(Integrate(Region=\"sc${i}_em\" ))"
}
}
)!

#if "@LC@" == "on"
!(
for { set i 1 } { $i < @<numSegments+1>@ } { incr i } {
if { (@seg1_em2_t@ > 0.0 && $i == 1) || (@seg2_em2_t@ > 0.0 && $i == 2) } {
puts "PMIeNonLocalRecombination(Integrate(Region=\"sc${i}_em\" Region=\"sc${i}_em2\" ))"
} else {
puts "PMIeNonLocalRecombination(Integrate(Region=\"sc${i}_em\" ))"
}
}
)!
#endif





}






Math{
  NumberOfThreads = 12
  Wallclock
  CheckRhsAfterUpdate
 * RhsAndUpdateConvergence
 Extrapolate*(NumberOfFailures=2) *always use this when Pin > 0.0
  Derivatives 			*default
*  Smooth   			*keep mobility and recombination rates from previous step for better intial conditions (bad for transient ramp convergence)
  RelErrControl 
 * IncompleteNewton	*reuse jacobian if certain contraints are met. Not good for us. Only good for Id-Vg ramps
  NotDamped=1000
  Method=ParDiSo
*ExtendedPrecision up to 10^(-Digits) precision
#if @numSegments@ < 10
  ExtendedPrecision *(128) *ExtendedPrecision(Digits=63)      ** is good enough for 1J and 2J devices
#else
   ExtendedPrecision*(128)
#endif
#if "@LC@" == "on"
  Digits=7
  Iterations = 100
#else
  Digits=7
  Iterations = 10
  Extrapolate
#endif




*   CheckTransientError
  Transient=BE
  TransientDigits=7
  ErrRef(electron) = 1E0
  ErrRef(hole) = 1E0          
  TransientErrRef(electron) = 1E0
  TransientErrRef(hole) = 1E0

  -MetalConductivity
  ExitOnFailure
  RhsFactor = 1e20 
  #if @3D@ == 0.0
	  #if @Pin@ > 1.0
	  	RhsMin = @<1e-2*Pin>@ *RhsMin=1e-1*
	  #else
		#if @numSegments@ == 2
	  		RhsMin = 1.0e-1
		#else
			RhsMin = 1.0e-3
		#endif
	  #endif
  #else
	RhsMin = 1.0
  #endif
  *CNormPrint
*  NewtonPlot ( Error Residual )


* For the FSF/absorber interface tunneling
!(
for { set i 1 } { $i <= @<numSegments>@ } { incr i } {
puts "NonLocal("
puts "RegionInterface = \"sc${i}_fsf/sc${i}_em\""
# [cm] distance to anchor point
puts "Length=5e-7"
# [cm] length by which nonlocal mesh lines are extended across the interface or contact
puts "Permeation = 5e-7"
puts ")"
} 
)!


* For the absorber/BSF interface tunneling
!(
for { set i 1 } { $i <= @<numSegments>@ } { incr i } {
puts "NonLocal("
if {(@seg1_em2_t@ > 0.0) && $i == 1 || (@seg2_em2_t@ > 0.0) && $i == 2} { 
puts "RegionInterface = \"sc${i}_em2/sc${i}_base\""
} else {
puts "RegionInterface = \"sc${i}_em/sc${i}_base\""
}
# [cm] distance to anchor point
puts "Length=5e-7"
# [cm] length by which nonlocal mesh lines are extended across the interface or contact
puts "Permeation = 5e-7"
puts ")"
} 
)!


#if @substrate_t@ > 0.0
* For the BSF/substrate interface tunneling
NonLocal(
RegionInterface = "sc1_base/substrate"
Length=5e-7
Permeation=5e-7
)
#endif


* For the tunnel diode
!(
for { set i 1 } { $i <= @<numSegments-1>@ } { incr i } {
puts "NonLocal("
puts "RegionInterface = \"td${i}_pplus/td${i}_nplus\""
# [cm] distance to anchor point
puts "Length=5e-7"
# [cm] length by which nonlocal mesh lines are extended across the interface or contact
puts "Permeation = 5e-7"
puts ")"
} 
)!



}

Solve{



		* Solve poisson equation to a high precision
		NewCurrentPrefix = "tmp_"
		Coupled(Digits=15 RhsMin=1e-10 Iterations=50 RhsAndUpdateConvergence){Poisson}
                Plot( FilePrefix = "n@node@BnddgmPoisson" )
		NewCurrentPrefix = "" 


	
#if @Pin@ > 0.0
	
		
		** pre-voltage sweep ramps
		*initial ramp that provides a good intial converged solution set
		  Transient (
		    InitialStep = 1e-10 MinStep = 1e-20 MaxStep = 1e-2 Increment = 1.1 Decrement = 3.0
		    InitialTime = 0.0 FinalTime = 1.0  
		  )
		#if @numSegments@ > 2
		  {Coupled ( RhsMin=1.0e-5 ) {Poisson Electron Hole}  CurrentPlot ( Time = (-1) ) }
		#else
		  {Coupled ( RhsAndUpdateConvergence RhsMin=1e-1 ) {Poisson Electron Hole}  CurrentPlot ( Time = (-1) ) }
		#endif
		Plot( FilePrefix = "n@node@BnddgmJsc")  
		

		#if "@eSim_type@" == "Jsc"
			* current at 0 voltage
			Coupled { Poisson Electron Hole }  
			Plot( FilePrefix = "n@node@BnddgmJsc"  )		


		#else


			Coupled (Iterations=100) {Poisson Electron Hole}
			*first quick voltage ramp up to a little less than MPP
			Transient ( 
			  InitialStep=0.001 MaxStep =0.01 MinStep = 1e-10 Increment=2.0 Decrement=2.0
			  InitialTime = 1.0 FinalTime = 2.0 
			  Goal { voltage = @<0.3*numSegments>@ Name="anode" }
			){ Coupled (Iterations=10) {Poisson Electron Hole  }  } 
			Plot( FilePrefix = "n@node@BnddgmMidV")

			*slow voltage ramp at MPP
			Transient ( 
			  InitialStep=0.001 MaxStep =0.001 MinStep = 1e-10 Increment=2.0 Decrement=2.0
			  InitialTime = 1.0 FinalTime = 2.0 
			  Goal { voltage = @<1.0*numSegments>@ Name="anode" } 
			 BreakCriteria {    Current (Contact = "cathode" minval = 0.0) }
			){ Coupled (Iterations=10) {Poisson Electron Hole  } }
			Plot( FilePrefix = "n@node@BnddgmVoc"  )


		#endif
#else

			!(
			## get the voltage data to know measured range
			source @pwd@/../lib/getMinAndMax.tcl
			set V [xData @pwd@/../Measurements/@measIVData@]
			)!

#if "a"  == "a"
			*ramp from 0V to minV voltage
			Quasistationary ( 
			  InitialStep=1e-7 MaxStep =0.03 MinStep = 1e-8 Increment=2 
			  Goal { voltage = -1.0 Name="anode" }
*			  Goal { voltage = !(puts -nonewline [min $V])! Name="anode" }
			){ Coupled  {Poisson Electron Hole  }  CurrentPlot ( Time = (-1) )}
			* dark current-voltage ramp intial
			Plot( FilePrefix = "n@node@BnddgmNegV"  )
			Quasistationary ( 
			  InitialStep=0.1 MaxStep =0.03 MinStep = 1e-8 Increment=2 
			  Goal { voltage = 0.001 Name="anode" }
			){ Coupled  {Poisson Electron Hole  } }
			Plot( FilePrefix = "n@node@BnddgmZeroV"  )
#endif


			* dark current-voltage ramp final
			Quasistationary ( 
			  InitialStep=0.03 MaxStep =0.03 MinStep = 1e-20 Increment=2 
			  Goal { voltage = !(puts -nonewline [max $V] )! Name="anode" }
			){ Coupled {Poisson Electron Hole  } }
			Plot( FilePrefix = "n@node@BnddgmMaxV"  )


#endif

  System("rm -f tmp*") *remove the plot we dont need anymore. 

}

#endif

