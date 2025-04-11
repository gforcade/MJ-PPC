*------------------------------------------------------------
* Simulate Optical Generation Profile
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



File{
*-Input
   PMIPath = "../pmi"
   Grid    = "@tdr@"
   Parameters ="@mprpar@"
   OpticalSolverInput = "@pwd@/Illumination.plx"
 #if "@OptiToSentaurus@" == "v3"
   OpticalGenerationInput = "@pwd@/results/nodes/@node|tdx@/optGen.tdr"
 #endif


* These spectra are based on data from ASTM G173 and are scaled such that
* they integrate to 1000 W/m2 when integrated from 0 to 4000 nm.  However,
* data from 2000 to 4000 nm has been omitted from the Sentaurus input files.
#if "@spectrum@"  == "am1.5g"   
   IlluminationSpectrum = "@pwd@/../spectra/am15gWm2-long.txt"
#elif "@spectrum@"  == "am1.5d"
   IlluminationSpectrum = "@pwd@/../spectra/am15dWm2-long.txt"
#elif "@spectrum@"  == "am0"
   IlluminationSpectrum = "@pwd@/../spectra/am0Wm2-long.txt"  
#elif "@spectrum@"  == "Dilas"
   IlluminationSpectrum = "@pwd@/../spectra/Dilas_1319.txt"  
#elif "@spectrum@" < 2.0
  *wavelength should be in um
#else
    IlluminationSpectrum = "@pwd@/../spectra/gaussian_@spectrum@.txt"
#endif



*-Output
   Plot    = "@tdrdat@"
   SpectralPlot = "n@node@_spec_des.tdr"
   Current = "@plot@"
   Output  = "@log@"
   OpticalGenerationOutput = "n@node@_OptGen_des.tdr"
}

***** Device
Device PV {


*** Device physics
Physics {
Optics(
	OpticalGeneration()
		OpticalSolver ( Composite )
	) *endOptics
}


***
Plot {
  xMoleFraction Doping DonorConcentration AcceptorConcentration 
  EffectiveIntrinsicDensity IntrinsicDensity
  BandGap ElectronAffinity
  eLifetime hLifetime 
  eMobility hMobility eVelocity hVelocity
  
  OpticalIntensity
  OpticalGeneration
  AbsorbedPhotonDensity
}


***
CurrentPlot {
 OpticalGeneration(Integrate(Semiconductor))
!(
for { set i 1 } { $i <= @<numSegments>@ } { incr i } {
if {$i == 1 && @seg1_em2_t@ > 0.0} {
puts "OpticalGeneration(Integrate(Region=\"sc${i}_em\" Region=\"sc${i}_em2\" Region=\"sc${i}_base\"))"
} else {
puts "OpticalGeneration(Integrate(Region=\"sc${i}_em\" Region=\"sc${i}_base\"))"
} }
)!
}

} * endDevice


***** Optical device with name optdevice. Solve TMM within sentaurus
OpticalDevice sentaurusTMM {

***
Physics {
  Optics (
	OpticalGeneration(
	    QuantumYield = 1 
            * In 1D simulations, reduce intensity by gridline shading factor.
	    *ComputeFromSpectrum(KeepSpectralData Scaling = @<(wtot-wfrontc)/wtot>@)
	#if "@spectrum@" < 2.0
  		ComputeFromMonochromaticSource( )
	#else
	    	ComputeFromSpectrum(KeepSpectralData )
	#endif

	) * end OpticalGeneration

        Excitation (
	#if @3D@ > 0.0
	   Theta =90
	   Phi = 90
	#else
	  Theta = 0
	#endif
           Polarization = 0.5
	#if "@spectrum@" < 2.0
		*wavelength in [um]
		Wavelength = @spectrum@
	#endif
	   Intensity = 1.0	*[W/cm2] **I multiply this by Pin in electrical sim. Thus, Pin is total illumination power in [W/cm2] over the area of illumination

	   Window("W1") (          
	      Origin = (0.0, 0.0, 0.0)
		* 1D vs 2D simulation
		#if @wfrontc@ == 0.0
			#if @3D@ > 0.0
				YDirection = (0.0, 0.0, -1.0)
				Rectangle (
					corner1 = ( 0.0, 0.0)
					corner2 = ( @wtot@, -@3D@ )
						)
			#else
	      			Line (X1=0.0 X2=@wtot@)
			#endif
		#else
			#if @3D@ > 0.0
				YDirection = (0.0, 0.0, -1.0)
				Rectangle (
					corner1 = (0.0, 0.0)
					corner2 = ( @<(wtot - wfrontc)>@, -@3D@ )
						)
			#else
				Line (X1 = 0.0 X2 = @<(wtot-wfrontc)>@)
			#endif
		#endif
	      
                       
	   )
        ) * end Excitation

	ComplexRefractiveIndex( WavelengthDep )
	OpticalSolver(
*                OptBeam(LayerStackExtraction(WindowName="W1" WindowPosition=Center) )
#if 1
	        TMM (
        		NodesPerWavelength = 50
			LayerStackExtraction(
		        	WindowName="W1"
				WindowPosition = Center
				* Define the material below the layer stack to be gold. (provides a back reflection)
				#if @substrate_t@ == 0.0
					Medium( Location=bottom Material=Gold) 
				#else
					Medium( Location=bottom Material=InP)
				#endif 
			)	
	            )  *end TMM
#endif
	) *end OpticalSolver
    ) * end Optics  
} *Physics
} *end sentaurusTMM



***** Optical device with name optdevice. Use version 1 of optiwave import within sentaurus
OpticalDevice optiwave {

***
Physics {

 Optics( 
  OpticalGeneration(
      ComputeFromMonochromaticSource ()
       TimeDependence ( WaveTime = (1.0, 2.0) WaveTExp = 0.3 Scaling = 1.0 ) *using a gaussian scaling ramp, better convergence
	Scaling = 1.0
        )
	OpticalSolver (
		FromFile (				
		DatasetName = OpticalGeneration 				*data in illumination file, if photon density use AbsorbedPhotonDensity 
		IdentifyingParameter = ("wavelength","phi")
	)
     )
    ) *end optics
     
  } *Physics
}*end optiwave





***** Optical device with name optdevice. Use version 2 of optiwave import within sentaurus
OpticalDevice optiwave_v2 {

***
Physics {
  Optics (
	OpticalGeneration(
		ReadFromFile (
			DatasetName = OpticalGeneration
		)
	)
    ) *end optics
     
  } *Physics
}*end optiwave_v2





***** system to solve
System {



* illumination using the optdevice basis
!(
set varLump "OpticalDevice = \["
#if "@OptiToSentaurus@" == "v2" || "@OptiToSentaurus@" == "v3" || "@OptiToSentaurus@" == "v3.1"
	puts "optiwave_v2 optiwavev2 () \{ \}"
	append varLump " optiwavev2 "
#elif "@OptiToSentaurus@" == "v1"
	puts "sentaurusTMM tmm1 () \{ Physics \{Optics ( Excitation (Wavelength = @spectrum@ ) ) \} \}"
	append varLump " tmm1 "
#else
	for { set i 1 } { $i <= @OptiToSentaurus@ } { incr i } {
	puts "optiwave opt${i} () \{ Physics \{  Optics ( "
	puts "Excitation("
	puts "wavelength=1.0"
	puts "phi=0.0"
	puts "Window("
	puts "Origin=(0 0 0)				*shifting to avoid cap layer"
	set x1 [expr @<(wtot - wfrontc)>@/@OptiToSentaurus@*($i-1)]
	set x2 [expr @<(wtot - wfrontc)>@/@OptiToSentaurus@*$i]
	puts "Line(x1=$x1 x2=$x2)"
	puts "))) *end optical generation"
	puts "\} \} *opt${i}"
	puts " "
	append varLump " opt${i}"
	} 
#endif

puts "* PV device itself, which composes opt illuminations"
puts "PV pv1 ( "
append varLump " \]"
puts $varLump
puts " ) "
)!



} *end system



***** Global Math
Math{
  NumberOfThreads = 10
  Method=Blocked
  SubMethod=Pardiso
  ExitOnFailure
}

Solve{
  Optics
}
