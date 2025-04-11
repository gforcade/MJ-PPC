*------------------------------------------------------------
* Simulate EQE of GaAs/GaAs p-n junction solar cell
* ------------------------------------------------------------

## setting dependencies 
#if [lsearch [list @tool_label|all@] LCMatrix] >=0
	#if [lsearch [list @tool_label|all@] tdx] >=0
		#setdep @node|tdx@ @node|LCMatrix@ 
	#else 
		#setdep @node|LCMatrix@ 
	#endif
#else 
	#setdep @node|MatPar@
#endif

#seth wstart 1.0 
#seth wend 1.8 
#seth wsteps 200

#seth intensity 1.0e-5


File{
*-Input
   PMIpath = "@pwd@/../pmi"
   Grid    = "@tdr@"
   Parameters ="@pwd@/results/nodes/@node|MatPar@/@mprpar@"
*-Output
   Plot    = "@tdrdat@"
   Current = "@plot@"
   Output  = "@log@"
}

Electrode{
  { Name="cathode"  Voltage=0 }
  { Name="anode"  Voltage=0 }
}

*Physics (Region = "sc1_em") {
*Recombination(
*SRH( NonlocalPath ( Lifetime = Schenk Fermi TwoBand)) 
*)}


*-------------------------------------------------------
**** Physics Section


* include general physics stuff (for both JV and EQE sdevice)
#include "@pwd@/../lib/sdevicePhysics.cmd" 


Physics {

  Optics (
    OpticalGeneration(
      QuantumYield = 1 * generated carriers/photon, default: 1, for lambda < 450, > 1
      ComputeFromMonochromaticSource 
    )

    Excitation (
      Theta = 0
      Polarization = 0.5
      Wavelength = @wstart@  *[um]
      Intensity = @intensity@  *[W/cm2]

      Window("W1") (
	Origin = (0.0, -1.0)
	* 1D vs 2D simulation
	#if @wfrontc@ == 0.0
      		Line (Dx = @wtot@)
	#else
		Line (Dx = @<wtot - wfrontc>@)
	#endif
      OriginAnchor=West                  
      )
    ) *end of Excitation

    ComplexRefractiveIndex (
      WavelengthDep
    ) *end of ComplexRefractiveIndex

    OpticalSolver (
      TMM (
        NodesPerWavelength = 100
	LayerStackExtraction (
	  WindowName="W1"
	  WindowPosition = Center
		* Define the material below the layer stack to be gold. (provides a back reflection)
		#if @substrate_t@ == 0.0
			Medium( Location=bottom Material=Gold) 
		#else
			Medium( Location=bottom Material=InP)
		#endif 
        ) *end LayerStackExtraction
      ) *end TMM
    ) *end OpticalSolver
  ) *end Optics

}  






*----------------------------------------------------

Plot {
  *Mole Fractions and Doping Concentrations
  xMoleFraction Doping DonorConcentration AcceptorConcentration

  *Band Structure
  eQuasiFermiPotential hQuasiFermiPotential eQuasiFermiEnergy hQuasiFermiEnergy EffectiveBandGap ConductionBandEnergy ValenceBandEnergy ElectronAffinity
      
  *Densities of States  
  eEffectiveStateDensity hEffectiveStateDensity
  
  *Carrier Densities
  EffectiveIntrinsicDensity IntrinsicDensity eDensity hDensity
  
  *Space Charge
  SpaceCharge
  
  *Carrier Mobility and Velocity
  eMobility hMobility eVelocity hVelocity
  
  *Recombination
  SRH Auger TotalRecombination RadiativeRecombination eLifetime hLifetime

  *Electric Field
  ElectricField ElectricField/vector ElectrostaticPotential

  *Currents
  eCurrent/Vector hCurrent/Vector current/vector

  OpticalGeneration

  ComplexRefractiveIndex
  
  PMIeNonLocalRecombination


}

CurrentPlot {
  ModelParameter = "Optics/Excitation/Wavelength"   * includes reflectance, transmittance and wavelength data		
  OpticalGeneration(Integrate(Semiconductor)) *Calculates Integrated Optical generation rate for each wavelength
  SRH(Integrate( Semiconductor))
  RadiativeRecombination(Integrate(Semiconductor))
  AugerRecombination(Integrate(Semiconductor))
*  OpticalGeneration(Integrate(Material="InAlGaAs_InP"))
  OpticalGeneration(Integrate(Region="sc1_em" Region="sc1_base"))

* hQuasiFermiPotential(Average(RegionInterface="sc1_bsf/buffer"))
*  hQuasiFermiPotential(Average(RegionInterface="buffer/substrate"))

  SurfaceRecombination( 
		       Integrate(RegionInterface = "sc1_fsf/sc1_em")

	)
}


Math{
  NumberOfThreads = 6
  Transient=BE
  CheckRhsAfterUpdate
  Derivatives   
  RelErrControl 
  Notdamped=50 
  Method=ParDiSo
  ExtendedPrecision*(128)
#if "@LC@" == "on"
  Digits=5
  Iterations=100
#else
  Digits=10
  Iterations=10
#endif
  RhsMin=1e-5
  ErrRef(electron) = 1E0
  ErrRef(hole) = 1E0
  TransientDigits=7            
  TransientErrRef(electron) = 1E0
  TransientErrRef(hole) = 1E0
  -MetalConductivity
  ExitOnFailure
  RhsFactor = 1e20 
*  CNormPrint
  BreakCriteria {
    Current (Contact = "cathode" minval = -1)
   
  }


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

Solve {
  # solve Poisson equation to a high precision
  NewCurrentPrefix = "tmp_"
  Coupled(Digits = 7) {Poisson} 
  NewCurrentPrefix = "" 
  # solve Poisson electron-hole equations
  Transient (
    InitialStep = 1e-10 MinStep = 1e-20 MaxStep = 0.2 Increment = 1.1 Decrement = 5
    InitialTime = 0 FinalTime = 1.0
    Extrapolate
  )
*  {Coupled ( Digits=3 RhsAndUpdateConvergence ) {Poisson Electron Hole} CurrentPlot ( Time = (-1) ) }
  {Coupled (Iterations=10) {Poisson Electron Hole} CurrentPlot ( Time = (-1) ) }

  # perform wavelength ramp
  Quasistationary ( DoZero
    InitialStep = @<1./wsteps>@ MaxStep = @<1./wsteps>@ MinStep = 1e-20 Decrement = 2.0 Increment = 3.0 Extrapolate(NumberOfFailures=1)
    Goal{ModelParameter = "Optics/Excitation/Wavelength" Value = @wend@}
  )
  {Coupled {Poisson Electron Hole}}

  System("rm -f tmp*") *remove the plot we dont need anymore. 

}

