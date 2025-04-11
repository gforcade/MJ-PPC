#setdep @previous@


##Runs a local optimization starting from the initial experiment given. 

## parameters that will be swept. Includes bounds (make realistic) for the parameters.
## EX: var1 = TOptParam("name of variable", initial value, minimum value, maximum value, transformation to domain)  


#bounds [fraction of the init value]
!(
set fsf_t_lb 0.95
set fsf_t_ub 1.05
set em_t_lb 0.95
set em_t_ub 1.05
set arc_t_lb 0.95
set arc_t_ub 1.05
)!


## parameters that will be swept. Includes bounds (make realistic) for the parameters.
## EX: var1 = TOptParam("name of variable", initial value, minimum value, maximum value, transformation to domain)  
# scaling parameter by itself
wtot = TOptParam("wtot", @wtot@,@wfrontc@,1e4,transform=(Normalize,Log10))



#arc thicknesses
!(
set varLump "ARC = \[ "
set init { @ARC1_t@ @ARC2_t@ }
for { set i 1 } { $i <= 2 } { incr i } {
	append varLump "ARC${i}_t "
	if { $i == 1 } {
		append varLump ","
	}
	puts "ARC${i}_t = OptParam(\"ARC${i}_t\",[lindex $init $i-1],$arc_t_lb*[lindex $init $i-1],$arc_t_ub*[lindex $init $i-1],[lindex $init $i-1])"
}
append varLump "\]"
puts $varLump
)!


#fsf thicknesses
!(
set varLump "fsf_t = \[ "
set init { @seg1_fsf_t@ @seg2_fsf_t@ @seg3_fsf_t@ @seg4_fsf_t@ @seg5_fsf_t@ @seg6_fsf_t@ @seg7_fsf_t@ @seg8_fsf_t@ @seg9_fsf_t@ @seg10_fsf_t@ }
for { set i 1 } { $i <= @numSegments@ } { incr i } {
	append varLump "seg${i}_fsf_t "
	if {$i < @numSegments@} {
		append varLump ","
	}
	puts "seg${i}_fsf_t = OptParam(\"seg${i}_fsf_t\", [lindex $init $i-1],[lindex $init $i-1]*$fsf_t_lb,[lindex $init $i-1]*$fsf_t_ub,[lindex $init $i-1])"
}
append varLump "\]"
puts $varLump
)!


#fsf doping
!(
set varLump "fsf_dop = \[ "
set init { @seg1_fsf_dop@ @seg2_fsf_dop@ @seg3_fsf_dop@ @seg4_fsf_dop@ @seg5_fsf_dop@ @seg6_fsf_dop@ @seg7_fsf_dop@ @seg8_fsf_dop@ @seg9_fsf_dop@ @seg10_fsf_dop@ }
for { set i 1 } { $i <= @numSegments@ } { incr i } {
	append varLump "seg${i}_fsf_dop "
	if {$i < @numSegments@} {
		append varLump ","	
	}
	puts "seg${i}_fsf_dop = TOptParam(\"seg${i}_fsf_dop\", [lindex $init $i-1],1e14,5e19,transform=(Normalize,Log10))"
}
append varLump "\]"
puts $varLump
)!

#emitter thicknesses
!(
set varLump " "
set init { @seg1_em_t@ @seg2_em_t@ @seg3_em_t@ @seg4_em_t@ @seg5_em_t@ @seg6_em_t@ @seg7_em_t@ @seg8_em_t@ @seg9_em_t@ @seg10_em_t@ }
if {@seg1_em2_t@ > 0.0 } {
	set varLump ", seg1_em2_t ${varLump}"
	puts "seg1_em2_t = TOptParam(\"seg1_em2_t\", @seg1_em2_t@, $em_t_lb*@seg1_em2_t@, $em_t_ub*@seg1_em2_t@, transform=(Normalize))"
}
if {@seg2_em2_t@ > 0.0 } {
	set varLump ", seg2_em2_t ${varLump}"
	puts "seg2_em2_t = TOptParam(\"seg2_em2_t\", @seg2_em2_t@, $em_t_lb*@seg2_em2_t@, $em_t_ub*@seg2_em2_t@, transform=(Normalize))"
}
for { set i 1 } { $i <= @numSegments@ } { incr i } {
	set varLump "seg${i}_em_t ${varLump}"
	if {$i < @numSegments@} {
		set varLump ",${varLump}"
	}
	puts "seg${i}_em_t = OptParam(\"seg${i}_em_t\", [lindex $init $i-1],$em_t_lb*[lindex $init $i-1],$em_t_ub*[lindex $init $i-1],[lindex $init $i-1])"
}
set varLump "em_t = \[ ${varLump}"
append varLump "\]"
puts $varLump
)!

#emitter doping
!(
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
!(
set varLump "ba_t = \[ "
set init { @seg1_ba_t@ @seg2_ba_t@ @seg3_ba_t@ @seg4_ba_t@ @seg5_ba_t@ @seg6_ba_t@ @seg7_ba_t@ @seg8_ba_t@ @seg9_ba_t@ @seg10_ba_t@ }
for { set i 1 } { $i <= @numSegments@ } { incr i } {
	append varLump "seg${i}_ba_t "
	if {$i < @numSegments@} {
		append varLump ","
	}
	puts "seg${i}_ba_t = OptParam(\"seg${i}_ba_t\", [lindex $init $i-1],0.02,3.0,[lindex $init $i-1])"
}
append varLump "\]"
puts $varLump
)!


#base doping
pdopTransform = Normalize(14,19)*Log10()*Linear(-1.0)
!(
set varLump "ba_dop = \[ "
set init { @seg1_ba_dop@ @seg2_ba_dop@ @seg3_ba_dop@ @seg4_ba_dop@ @seg5_ba_dop@ @seg6_ba_dop@ @seg7_ba_dop@ @seg8_ba_dop@ @seg9_ba_dop@ @seg10_ba_dop@ }
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

#jsc#_norm target
!(
set varLump "t_jscNumNorm = \[ "
for { set i 1 } { $i <= @numSegments@ } { incr i } {
	append varLump "Jsc${i}_norm "
	if {$i < @numSegments@} {
		append varLump ","
	}
	puts "Jsc${i}_norm = OptTarget(\"Jsc${i}_norm\", target=0.99)"
}
append varLump "\]"
puts $varLump
)!



t_errorRS = OptTarget("error_RS",target=0.0,scale=0.03)
t_errorEQE = OptTarget("error_EQE",target=0.0,scale=0.1)
t_eff = OptTarget("Eff", target=100.0,scale=100.0)
t_errorIV = OptTarget("error_IV",target=0.0,scale=0.3)
t_jscError = OptTarget("error_Jsc", target=0.0)
t_jscNorm = OptTarget("Jsc_norm", target=1.0)
t_JscNormMin = OptTarget("Jsc_norm_min", target = 0, scale=1) #(1 - Jsc_norm)
t_JscNormMatch = OptTarget("Jsc_norm_match", target = 0, scale=1)
t_JscNormMatch20 = OptTarget("Jsc_norm_match_20", target=0, scale=1)	
t_JscNormMatch45 = OptTarget("Jsc_norm_match_45", target=0, scale=1)
if "@eSim_type@" == "Jph":
	t_jscNorm = OptTarget("Jph_norm", target=1.0)



seq = 1

if "@sim_type@" == "exploreOptimize": 
	if @wfrontc@ == 0.0:	#1D simulation
		p = em_t + ARC + [Pin] #fsf_t + fsf_dop + em_t + em_dop + ba_t + ba_dop + ARC
	else:	#2D simulation
		p = [wtot] + fsf_t + fsf_dop + em_t + em_dop + ba_t + ba_dop

	if "@simMethod@" == "together":
		p = ARC + p + [Pin]
	if "@simMethod@" == "speedUp":
		#optimize for active layers then for ARC layers, sequentially
		seq = 2	
	
	## target of optimization
	target =  t_eff#t_jscNorm#[t_jscNorm]

	
	## run local optimizer, via gradient method. 
	# eps: step size, gtol: gradient norm stopping criteria, maxiter: max # of iterations
	# L-BFGS-B: Default. CG: . Nelder-Mead: runs in serial, non-gradient method.
	optimizer.backend.set_method("minimize")
	#optimizer.backend.set_optimization_parameters(method="Nelder-Mead",options={"fatol": 1e-4,"xatol":1e-4}) 
	optimizer.backend.set_optimization_parameters(method="@optimizer@",options={"ftol":1e-5,"gtol":1e-5,"fatol": 1e-4,"xatol":1e-4},kwargs={"eps": 1.e-2, "step_type": "rel"})
	optimizer.optimize(p, target,print_sensitivity=True)
	#optimizer.backend.set_optimization_parameters(method="SLSQP",options={"ftol": 1e-5}) 
	#optimizer.backend.set_optimization_parameters(method="Powell",options={"ftol": 1e-4,"xtol":1e-4}) 
	#optimizer.backend.set_optimization_parameters(method="CG",options={"gtol": 1e-5},kwargs={"eps": 1.e-4, "step_type": "rel"})  #bad
	#optimizer.backend.set_optimization_parameters(method="COBYLA") 
	#optimizer.backend.set_optimization_parameters(method="TNC") 
	for i in range(seq):
		optimizer.optimize(p, target,print_sensitivity=True)
		dataFrame = optimizer.get_last_optimal()
		print(dataFrame)
		#optimizer.backend.set_optimization_parameters(maxiter=None)
		#optimizer.optimize(p, target,print_sensitivity=True)
		p = ARC

elif "@sim_type@" == "fitOptimize":
	

	## various parameters for sweeping ("name", start value, minvalue, maxvalue, linear scaling)
	seg_fsf_t = OptParam("seg1_fsf_t", @seg1_fsf_t@,@seg1_fsf_t@*0.9,@seg1_fsf_t@*1.1,@seg1_fsf_t@)
	seg_em_t = OptParam("seg1_em_t", @seg1_em_t@,@seg1_em_t@*0.9,@seg1_em_t@*1.1,@seg1_em_t@)
	#seg_em_dop = OptParam("seg1_em_dop", @seg1_em_dop@,@seg1_em_dop@*0.8,@seg1_em_dop@*1.2,@seg1_em_dop@)
	seg_ba_t = OptParam("seg1_ba_t", @seg1_ba_t@,@seg1_ba_t@*0.9,@seg1_ba_t@*1.1,@seg1_ba_t@)	
	seg_ba_dop = OptParam("seg1_ba_dop", @seg1_ba_dop@,@seg1_ba_dop@*2.0,@seg1_ba_dop@*0.1,@<-1.0*seg1_ba_dop>@)	
	Rfactor = OptParam("Rfactor", @Rfactor@, minval=-0.08, maxval=0.0,scale=0.03)
	InGaAs_S = OptParam("InGaAs_S", @InGaAs_S@,2.0,20.0,scale=@InGaAs_S@)
	InGaAs_tauSRH = TOptParam("InGaAs_tauSRH", @InGaAs_tauSRH@,5e-8,5e-5,transform=(Normalize,Log10))
	SymPos = OptParam("InAlAs_SymPos",@InAlAs_SymPos@,0.0,0.06,scale=0.01)
	StdDev = OptParam("InAlAs_StdDev",@InAlAs_StdDev@,0.0,0.02,scale=0.005)
	Rseries = OptParam("Rseries",@Rseries@,0.005,0.5,scale=@Rseries@)
	Rshunt = TOptParam("Rshunt",@Rshunt@,1e2,1e6,transform=(Normalize,Log10))
	
	if @Pin@ > 0.0:
		# fit Jsc when illuminated (assumes un-calibrated measurements)
		Pin = OptParam("Pin", @Pin@,1e-2,@<20.0*numSegments>@,scale=@Pin@)
		t_errorFF = OptTarget("error_FF",target=0.0)
		optimizer.backend.set_method("minimize")
		optimizer.backend.set_optimization_parameters(options={"ftol":1e-5,"gtol":1e-5})
		optimizer.optimize(Pin,t_jscError)
		#optimizer.optimize(Rseries,t_errorFF)
		
	else:
		#p = [InGaAs_S,InGaAs_tauSRH,Rseries,seg_em_t,seg_fsf_t,seg_ba_dop,seg_em_dop]
		#p = [InGaAs_S,InGaAs_tauSRH,Rseries,SymPos,StdDev]
		p = ARC + em_t +fsf_t 
		target = [t_errorRS]#[t_errorIV,t_errorRS,t_errorEQE]

		#optimizer.backend.set_optimization_parameters(options={"n":250,"maxfev":350}) 
		optimizer.backend.set_method("shgo") 
		optimizer.optimize(p, target,print_sensitivity=True)
		


	



