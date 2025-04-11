#setdep @node|-1@


##Runs a local gradient optimization starting from the initial experiment




## parameters that will be swept
# scaling parameter by itself
wtot = TOptParam("wtot", @wtot@,5.0,1e4,transform=(Normalize,Log10))

#fsf thicknesses
"""
seg10_fsf_t = TOptParam("seg10_fsf_t", @seg10_fsf_t@,0.03,3.0,transform=(Normalize,Log10))
seg9_fsf_t = TOptParam("seg9_fsf_t", @seg9_fsf_t@,0.03,3.0,transform=(Normalize,Log10))
seg8_fsf_t = TOptParam("seg8_fsf_t", @seg8_fsf_t@,0.03,3.0,transform=(Normalize,Log10))
seg7_fsf_t = TOptParam("seg7_fsf_t", @seg7_fsf_t@,0.03,3.0,transform=(Normalize,Log10))
seg6_fsf_t = TOptParam("seg6_fsf_t", @seg6_fsf_t@,0.03,3.0,transform=(Normalize,Log10))
seg5_fsf_t = TOptParam("seg5_fsf_t", @seg5_fsf_t@,0.03,3.0,transform=(Normalize,Log10))
seg4_fsf_t = TOptParam("seg4_fsf_t", @seg4_fsf_t@,0.03,3.0,transform=(Normalize,Log10))
seg3_fsf_t = TOptParam("seg3_fsf_t", @seg3_fsf_t@,0.03,3.0,transform=(Normalize,Log10))
seg2_fsf_t = TOptParam("seg2_fsf_t", @seg2_fsf_t@,0.03,3.0,transform=(Normalize,Log10))
seg1_fsf_t = TOptParam("seg1_fsf_t", @seg1_fsf_t@,0.03,3.0,transform=(Normalize,Log10))
"""

!(
## write parameters in list only up to # of specified junctions
set varLump "fsf_t = \[ "
set init { @seg1_fsf_t@, @seg2_fsf_t@, @seg3_fsf_t@, @seg4_fsf_t@, @seg5_fsf_t@, @seg6_fsf_t@, @seg7_fsf_t@, @seg8_fsf_t@, @seg9_fsf_t@, @seg10_fsf_t@ }
for { set i 1 } { $i <= @numSegments@ } { incr i } {
	append varLump "seg${i}_fsf_t "
	if {$i < @numSegments@} {
		append varLump ","
	}
	puts "seg${i}_fsf_t = TOptParam(\"seg${i}_fsf_t\", [lindex $init $i-1],0.03,3.0,transform=(Normalize,Log10))"
}
append varLump "\]"
puts $varLump
)!

#fsf doping
"""
seg10_fsf_dop = TOptParam("seg10_fsf_dop", @seg10_fsf_dop@,1e14,1.5e19,transform=(Normalize,Log10))
seg9_fsf_dop = TOptParam("seg9_fsf_dop", @seg9_fsf_dop@,1e14,1.5e19,transform=(Normalize,Log10))
seg8_fsf_dop = TOptParam("seg8_fsf_dop", @seg8_fsf_dop@,1e14,1.5e19,transform=(Normalize,Log10))
seg7_fsf_dop = TOptParam("seg7_fsf_dop", @seg7_fsf_dop@,1e14,1.5e19,transform=(Normalize,Log10))
seg6_fsf_dop = TOptParam("seg6_fsf_dop", @seg6_fsf_dop@,1e14,1.5e19,transform=(Normalize,Log10))
seg5_fsf_dop = TOptParam("seg5_fsf_dop", @seg5_fsf_dop@,1e14,1.5e19,transform=(Normalize,Log10))
seg4_fsf_dop = TOptParam("seg4_fsf_dop", @seg4_fsf_dop@,1e14,1.5e19,transform=(Normalize,Log10))
seg3_fsf_dop = TOptParam("seg3_fsf_dop", @seg3_fsf_dop@,1e14,1.5e19,transform=(Normalize,Log10))
seg2_fsf_dop = TOptParam("seg2_fsf_dop", @seg2_fsf_dop@,1e14,1.5e19,transform=(Normalize,Log10))
seg1_fsf_dop = TOptParam("seg1_fsf_dop", @seg1_fsf_dop@,1e14,1.5e19,transform=(Normalize,Log10))
"""
!(
## write parameters in list only up to # of specified junctions
set varLump "fsf_dop = \[ "
set init { @seg1_fsf_dop@, @seg2_fsf_dop@, @seg3_fsf_dop@, @seg4_fsf_dop@, @seg5_fsf_dop@, @seg6_fsf_dop@, @seg7_fsf_dop@, @seg8_fsf_dop@, @seg9_fsf_dop@, @seg10_fsf_dop@ }
for { set i 1 } { $i <= @numSegments@ } { incr i } {
	append varLump "seg${i}_fsf_dop "
	if {$i < @numSegments@} {
		append varLump ","
	}
	puts "seg${i}_fsf_dop = TOptParam(\"seg${i}_fsf_dop\", [lindex $init $i-1],1e14,1.5e19,transform=(Normalize,Log10))"
}
append varLump "\]"
puts $varLump
)!

#emitter thicknesses
"""
seg10_em_t = TOptParam("seg10_em_t", @seg10_em_t@,0.03,1.0,transform=(Normalize,Log10))
seg9_em_t = TOptParam("seg9_em_t", @seg9_em_t@,0.03,1.0,transform=(Normalize,Log10))
seg8_em_t = TOptParam("seg8_em_t", @seg8_em_t@,0.03,1.0,transform=(Normalize,Log10))
seg7_em_t = TOptParam("seg7_em_t", @seg7_em_t@,0.03,1.0,transform=(Normalize,Log10))
seg6_em_t = TOptParam("seg6_em_t", @seg6_em_t@,0.03,1.0,transform=(Normalize,Log10))
seg5_em_t = TOptParam("seg5_em_t", @seg5_em_t@,0.03,1.0,transform=(Normalize,Log10))
seg4_em_t = TOptParam("seg4_em_t", @seg4_em_t@,0.03,2.0,transform=(Normalize,Log10))
seg3_em_t = TOptParam("seg3_em_t", @seg3_em_t@,0.03,2.0,transform=(Normalize,Log10))
seg2_em_t = TOptParam("seg2_em_t", @seg2_em_t@,0.03,3.0,transform=(Normalize,Log10))
seg1_em_t = TOptParam("seg1_em_t", @seg1_em_t@,0.03,4.0,transform=(Normalize,Log10))
"""
!(
## write parameters in list only up to # of specified junctions
set varLump "em_t = \[ "
set init { @seg1_em_t@, @seg2_em_t@, @seg3_em_t@, @seg4_em_t@, @seg5_em_t@, @seg6_em_t@, @seg7_em_t@, @seg8_em_t@, @seg9_em_t@, @seg10_em_t@ }
for { set i 1 } { $i <= @numSegments@ } { incr i } {
	append varLump "seg${i}_em_t "
	if {$i < @numSegments@} {
		append varLump ","
	}
	puts "seg${i}_em_t = TOptParam(\"seg${i}_em_t\", [lindex $init $i-1],0.03,4.0,transform=(Normalize,Log10))"
}
append varLump "\]"
puts $varLump
)!

#emitter doping
"""
seg10_em_dop = TOptParam("seg10_em_dop", @seg10_em_dop@,1e14,1.5e19,transform=(Normalize,Log10))
seg9_em_dop = TOptParam("seg9_em_dop", @seg9_em_dop@,1e14,1.5e19,transform=(Normalize,Log10))
seg8_em_dop = TOptParam("seg8_em_dop", @seg8_em_dop@,1e14,1.5e19,transform=(Normalize,Log10))
seg7_em_dop = TOptParam("seg7_em_dop", @seg7_em_dop@,1e14,1.5e19,transform=(Normalize,Log10))
seg6_em_dop = TOptParam("seg6_em_dop", @seg6_em_dop@,1e14,1.5e19,transform=(Normalize,Log10))
seg5_em_dop = TOptParam("seg5_em_dop", @seg5_em_dop@,1e14,1.5e19,transform=(Normalize,Log10))
seg4_em_dop = TOptParam("seg4_em_dop", @seg4_em_dop@,1e14,1.5e19,transform=(Normalize,Log10))
seg3_em_dop = TOptParam("seg3_em_dop", @seg3_em_dop@,1e14,1.5e19,transform=(Normalize,Log10))
seg2_em_dop = TOptParam("seg2_em_dop", @seg2_em_dop@,1e14,1.5e19,transform=(Normalize,Log10))
seg1_em_dop = TOptParam("seg1_em_dop", @seg1_em_dop@,1e14,1.5e19,transform=(Normalize,Log10))
"""
!(
## write parameters in list only up to # of specified junctions
set varLump "em_dop = \[ "
set init { @seg1_em_dop@ @seg2_em_dop@ @seg3_em_dop@ @seg4_em_dop@ @seg5_em_dop@ @seg6_em_dop@ @seg7_em_dop@ @seg8_em_dop@ @seg9_em_dop@ @seg10_em_dop@ }
for { set i 1 } { $i <= @numSegments@ } { incr i } {
	append varLump "seg${i}_em_dop "
	if {$i < @numSegments@} {
		append varLump ","
	}
	puts "seg${i}_em_dop = TOptParam(\"seg${i}_em_dop\", [lindex $init $i-1],1e14,1.5e19,transform=(Normalize,Log10))"
}
append varLump "\]"
puts $varLump
)!

#base thicknesses
"""
seg10_ba_t = TOptParam("seg10_ba_t", @seg10_ba_t@,0.03,3.0,transform=(Normalize,Log10))
seg9_ba_t = TOptParam("seg9_ba_t", @seg9_ba_t@,0.03,3.0,transform=(Normalize,Log10))
seg8_ba_t = TOptParam("seg8_ba_t", @seg8_ba_t@,0.03,3.0,transform=(Normalize,Log10))
seg7_ba_t = TOptParam("seg7_ba_t", @seg7_ba_t@,0.03,3.0,transform=(Normalize,Log10))
seg6_ba_t = TOptParam("seg6_ba_t", @seg6_ba_t@,0.03,3.0,transform=(Normalize,Log10))
seg5_ba_t = TOptParam("seg5_ba_t", @seg5_ba_t@,0.03,3.0,transform=(Normalize,Log10))
seg4_ba_t = TOptParam("seg4_ba_t", @seg4_ba_t@,0.03,3.0,transform=(Normalize,Log10))
seg3_ba_t = TOptParam("seg3_ba_t", @seg3_ba_t@,0.03,3.0,transform=(Normalize,Log10))
seg2_ba_t = TOptParam("seg2_ba_t", @seg2_ba_t@,0.03,3.0,transform=(Normalize,Log10))
seg1_ba_t = TOptParam("seg1_ba_t", @seg1_ba_t@,0.03,3.0,transform=(Normalize,Log10))
"""
!(
## write parameters in list only up to # of specified junctions
set varLump "ba_t = \[ "
set init { @seg1_ba_t@ @seg2_ba_t@ @seg3_ba_t@ @seg4_ba_t@ @seg5_ba_t@ @seg6_ba_t@ @seg7_ba_t@ @seg8_ba_t@ @seg9_ba_t@ @seg10_ba_t@ }
for { set i 1 } { $i <= @numSegments@ } { incr i } {
	append varLump "seg${i}_ba_t "
	if {$i < @numSegments@} {
		append varLump ","
	}
	puts "seg${i}_ba_t = TOptParam(\"seg${i}_ba_t\", [lindex $init $i-1],0.03,4.0,transform=(Normalize,Log10))"
}
append varLump "\]"
puts $varLump
)!


#base doping
pdopTransform = Normalize(14,19)*Log10()*Linear(-1.0)
"""
seg10_ba_dop = TOptParam("seg10_ba_dop", @seg10_ba_dop@,-1e19,-1e14,transform=pdopTransform)
seg9_ba_dop = TOptParam("seg9_ba_dop", @seg9_ba_dop@,-1e19,-1e14,transform=pdopTransform)
seg8_ba_dop = TOptParam("seg8_ba_dop", @seg8_ba_dop@,-1e19,-1e14,transform=pdopTransform)
seg7_ba_dop = TOptParam("seg7_ba_dop", @seg7_ba_dop@,-1e19,-1e14,transform=pdopTransform)
seg6_ba_dop = TOptParam("seg6_ba_dop", @seg6_ba_dop@,-1e19,-1e14,transform=pdopTransform)
seg5_ba_dop = TOptParam("seg5_ba_dop", @seg5_ba_dop@,-1e19,-1e14,transform=pdopTransform)
seg4_ba_dop = TOptParam("seg4_ba_dop", @seg4_ba_dop@,-1e19,-1e14,transform=pdopTransform)
seg3_ba_dop = TOptParam("seg3_ba_dop", @seg3_ba_dop@,-1e19,-1e14,transform=pdopTransform)
seg2_ba_dop = TOptParam("seg2_ba_dop", @seg2_ba_dop@,-1e19,-1e14,transform=pdopTransform)
seg1_ba_dop = TOptParam("seg1_ba_dop", @seg1_ba_dop@,-1e19,-1e14,transform=pdopTransform)
"""
!(
## write parameters in list only up to # of specified junctions
set varLump "ba_dop = \[ "
set init { @seg1_ba_dop@, @seg2_ba_dop@, @seg3_ba_dop@, @seg4_ba_dop@, @seg5_ba_dop@, @seg6_ba_dop@, @seg7_ba_dop@, @seg8_ba_dop@, @seg9_ba_dop@, @seg10_ba_dop@ }
for { set i 1 } { $i <= @numSegments@ } { incr i } {
	append varLump "seg${i}_ba_dop "
	if {$i < @numSegments@} {
		append varLump ","
	}
	puts "seg${i}_ba_dop = TOptParam(\"seg${i}_ba_dop\", [lindex $init $i-1],-1e19,-1e14,transform=pdopTransform)"
}
append varLump "\]"
puts $varLump
)!



p = fsf_t + fsf_dop + em_t + em_dop + ba_t + ba_dop


## target of optimization
t = OptTarget("Eff", target=100.0,scale=100.0)

target =  [t]



## run local optimizer, via gradient method. (1 + n experiments per iteration, n-parameters)
# eps: step size, gtol: gradient norm stopping criteria, maxiter: max # of iterations
# BGFS: bad as our minima does not cross 0. CG: Seems slow+gradient. Nelder-Mead: runs in serial, non-gradient method.
optimizer.backend.set_method("minimize")
optimizer.backend.set_optimization_parameters(method="Nelder-Mead",options={"fatol": 5e-3,"xatol":1e-3})


optimizer.optimize(p, t)
