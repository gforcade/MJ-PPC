Physics {
  Temperature = @temp@
  AreaFactor = @< 1e8/wtot >@ * to get current in A/cm^2

  * Use Fermi-Dirac (rather than Maxwell-Boltzmann) statistics
  Fermi

  * Allow thermionic emission across (and tunneling through) small potential barriers, and
  * create double mesh vertices at material interfaces to model abrupt band offsets.
  Thermionic
  HeteroInterface

  EffectiveIntrinsicDensity(NoFermi 
#if "@BGN@" == "JR"
 	BandGapNarrowing(JainRoulston)
#else
	NoBandgapNarrowing
#endif

)  

  Recombination(
    SRH*( DopingDep)
    Radiative
    Auger
  #if [lsearch [list @tool_label|all@] LCMatrix] >=0
    #if "@LC@" == "on"
       OpticalCoupling_Recombination(MatrixFile="@pwd@/results/nodes/@node|LCMatrix@/LC.csv")
    #endif
 #endif
  )

  Mobility(DopingDependence)


} 

#if 1 == 1
Physics (RegionInterface = "sc1_em/sc1_em2") {
	Recombination(surfaceSRH)
}
#endif


#if @sideS@ > 0.0
** sidewall recombination
Physics (RegionInterface = "Side_Air/sc1_em") {
	Recombination(surfaceSRH)
}
#endif


** Barrier tunneling at BSF/substrate interface
#if @substrate_t@ > 0.0
Physics (RegionInterface = "sc1_base/substrate") {
Recombination(hBarrierTunneling  eBarrierTunneling)
}
#endif


** Barrier tunneling at FSF/absorber interface
!(
for { set i 1 } { $i <= @<numSegments>@ } { incr i } {
puts "Physics (RegionInterface = \"sc${i}_fsf/sc${i}_em\") \{"
puts "Recombination(hBarrierTunneling  eBarrierTunneling)" 
puts "\}"
}
)!



** Barrier tunneling at absorber/BSF interface
!(
for { set i 1 } { $i <= @<numSegments>@ } { incr i } {
if {(@seg1_em2_t@ > 0.0) && $i == 1 || (@seg2_em2_t@ > 0.0) && $i == 2} { 
puts "Physics (RegionInterface = \"sc${i}_em2/sc${i}_base\") \{"
puts "Recombination(surfaceSRH)"
} else {
puts "Physics (RegionInterface = \"sc${i}_em/sc${i}_base\") \{"
}
puts "Recombination(hBarrierTunneling eBarrierTunneling)" 
puts "\}"
}
)!




#if 1 == 0
** B2B in absorber layers
!(
### 0  means not present
set B2B 0
set trapSRH 0
for { set i 1 } { $i <= @<numSegments>@ } { incr i } {
puts "Physics (Region = \"sc${i}_em\") \{"
puts "Recombination("
if {$trapSRH} {
puts "SRH( NonlocalPath ( Lifetime = Schenk Fermi TwoBand))" 
}
if {$B2B} {
puts "Band2Band( Model=NonlocalPath FranzDispersion )"
}
puts ")\}"
}

#if @seg1_em2_t@ > 0.0
puts "Physics (Region = \"sc1_em2\") \{"
puts "Recombination("
if {$trapSRH} {
puts "SRH( NonlocalPath ( Lifetime = Schenk Fermi TwoBand))" 
}
if {$B2B} {
puts "Band2Band( Model=NonlocalPath FranzDispersion )"
}
puts ")\}"
#endif
)!
#endif
* B2B end




** tunnel diodes
!(
for { set i 1 } { $i <= @<numSegments-1>@ } { incr i } {
##puts "Physics (Region = \"td${i}_pplus\") \{"
##puts "EffectiveIntrinsicDensity( BandGapNarrowing(JainRoulston) )  "
##puts "Recombination("
##puts "*Band2Band( Model=NonlocalPath FranzDispersion)"
##puts "SRH(NonlocalPath ( Lifetime = Schenk Fermi TwoBand))"
##puts ") \}"
puts " "
puts "Physics (RegionInterface = \"td${i}_pplus/td${i}_nplus\") \{"
puts "Recombination("
puts "eBarrierTunneling ( Band2Band=Full TwoBand )"
puts "hBarrierTunneling ( Band2Band=Full TwoBand )"
puts ") \}"
puts " "
##puts "Physics (Region = \"td${i}_nplus\") \{"
##puts "EffectiveIntrinsicDensity( BandGapNarrowing(JainRoulston) )  "
##puts "Recombination("
##puts "*Band2Band( Model=NonlocalPath FranzDispersion)"
##puts "SRH(NonlocalPath ( Lifetime = Schenk Fermi TwoBand))"
##puts ") \}"
}
)!
