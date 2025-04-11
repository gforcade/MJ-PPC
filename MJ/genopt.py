optimizing = True

#cannot preprocess in this file

if optimizing == True:
	## device details
	lowerAR = 0.5
	upperAR = 3.0
	init = [0.1,0.1]
	ARC2_t = TOptParam("ARC2_t", init[1],init[1]*lowerAR,init[1]*upperAR,transform=(Normalize))
	ARC1_t = TOptParam("ARC1_t", init[0],init[0]*lowerAR,init[0]*upperAR,transform=(Normalize))
	ARC = [ARC1_t, ARC2_t]


	lower = 0.7
	upper = 1.3
	# init = [ bottom to top junction ]	
	#fsf thicknesses
	init = [ 0.2, 0.2, 0.2, 0.2, 0.2, 0.2, 0.2, 0.2, 0.2, 0.2 ]
	seg10_fsf_t = TOptParam("seg10_fsf_t", init[9],0.03,3.0,transform=(Normalize))
	seg9_fsf_t = TOptParam("seg9_fsf_t", init[8],0.03,3.0,transform=(Normalize))
	seg8_fsf_t = TOptParam("seg8_fsf_t", init[7],0.03,3.0,transform=(Normalize))
	seg7_fsf_t = TOptParam("seg7_fsf_t", init[6],0.03,3.0,transform=(Normalize))
	seg6_fsf_t = TOptParam("seg6_fsf_t", init[5],0.03,3.0,transform=(Normalize))
	seg5_fsf_t = TOptParam("seg5_fsf_t", init[4],0.03,3.0,transform=(Normalize))
	seg4_fsf_t = TOptParam("seg4_fsf_t", init[3],0.03,3.0,transform=(Normalize))
	seg3_fsf_t = TOptParam("seg3_fsf_t", init[2],0.03,3.0,transform=(Normalize))
	seg2_fsf_t = TOptParam("seg2_fsf_t", init[1],0.03,3.0,transform=(Normalize))
	seg1_fsf_t = TOptParam("seg1_fsf_t", init[0],0.03,3.0,transform=(Normalize))


	#fsf doping
	init = [5e18, 5e18, 5e18, 5e18, 5e18, 5e18, 5e18, 5e18, 5e18, 5e18]
	seg10_fsf_dop = TOptParam("seg10_fsf_dop", init[9],1e16,5e19,transform=(Normalize,Log10))
	seg9_fsf_dop = TOptParam("seg9_fsf_dop", init[8],1e16,5e19,transform=(Normalize,Log10))
	seg8_fsf_dop = TOptParam("seg8_fsf_dop", init[7],1e16,5e19,transform=(Normalize,Log10))
	seg7_fsf_dop = TOptParam("seg7_fsf_dop", init[6],1e16,5e19,transform=(Normalize,Log10))
	seg6_fsf_dop = TOptParam("seg6_fsf_dop", init[5],1e16,5e19,transform=(Normalize,Log10))
	seg5_fsf_dop = TOptParam("seg5_fsf_dop", init[4],1e16,5e19,transform=(Normalize,Log10))
	seg4_fsf_dop = TOptParam("seg4_fsf_dop", init[3],1e16,5e19,transform=(Normalize,Log10))
	seg3_fsf_dop = TOptParam("seg3_fsf_dop", init[2],1e16,5e19,transform=(Normalize,Log10))
	seg2_fsf_dop = TOptParam("seg2_fsf_dop",init[1],1e16,5e19,transform=(Normalize,Log10))
	seg1_fsf_dop = TOptParam("seg1_fsf_dop", init[0],1e16,5e19,transform=(Normalize,Log10))


	#emitter thicknesses
	#init = [1.7, 0.3, 0.9, 0.6, 0.4, 0.3, 0.25, 0.2, 0.19, 0.16, 0.15] #bottom is a homojnc
	init = [0.479,0.436,0.375,0.318,0.271,0.234,0.203,0.181,0.162,0.146] #all hetero
	seg10_em_t = TOptParam("seg10_em_t", init[9],init[9]*lower,init[9]*upper,transform=(Normalize))
	seg9_em_t = TOptParam("seg9_em_t", init[8],init[8]*lower,init[8]*upper,transform=(Normalize))
	seg8_em_t = TOptParam("seg8_em_t", init[7],init[7]*lower,init[7]*upper,transform=(Normalize))
	seg7_em_t = TOptParam("seg7_em_t", init[6],init[6]*lower,init[6]*upper,transform=(Normalize))
	seg6_em_t = TOptParam("seg6_em_t", init[5],init[5]*lower,init[5]*upper,transform=(Normalize))
	seg5_em_t = TOptParam("seg5_em_t", init[4],init[4]*lower,init[4]*upper,transform=(Normalize))
	seg4_em_t = TOptParam("seg4_em_t", init[3],init[3]*lower,init[3]*upper,transform=(Normalize))
	seg3_em_t = TOptParam("seg3_em_t", init[2],init[2]*lower,init[2]*upper,transform=(Normalize))
	seg2_em_t = TOptParam("seg2_em_t", init[1],init[1]*lower,init[1]*upper,transform=(Normalize))
	seg1_em_t = TOptParam("seg1_em_t", init[0],init[0]*lower,init[0]*upper,transform=(Normalize))
	#segment 1 homojunction base thickness
	seg1_em2_t = TOptParam("seg1_em2_t", init[0], 0.03, 10.0, transform=(Normalize))


	#emitter doping
	init = [ 5e16, 5e16, 5e16, 5e16, 5e16, 5e16, 5e16, 5e16, 5e16, 5e16 ]
	seg10_em_dop = TOptParam("seg10_em_dop", init[9],1e14,1.5e19,transform=(Normalize,Log10))
	seg9_em_dop = TOptParam("seg9_em_dop", init[8],1e14,1.5e19,transform=(Normalize,Log10))
	seg8_em_dop = TOptParam("seg8_em_dop", init[7],1e14,1.5e19,transform=(Normalize,Log10))
	seg7_em_dop = TOptParam("seg7_em_dop", init[6],1e14,1.5e19,transform=(Normalize,Log10))
	seg6_em_dop = TOptParam("seg6_em_dop", init[5],1e14,1.5e19,transform=(Normalize,Log10))
	seg5_em_dop = TOptParam("seg5_em_dop", init[4],1e14,1.5e19,transform=(Normalize,Log10))
	seg4_em_dop = TOptParam("seg4_em_dop", init[3],1e14,1.5e19,transform=(Normalize,Log10))
	seg3_em_dop = TOptParam("seg3_em_dop", init[2],1e14,1.5e19,transform=(Normalize,Log10))
	seg2_em_dop = TOptParam("seg2_em_dop", init[1],1e14,1.5e19,transform=(Normalize,Log10))
	seg1_em_dop = TOptParam("seg1_em_dop", init[0],1e14,1.5e19,transform=(Normalize,Log10))
	

	#base thicknesses
	init = [ 0.2, 0.2, 0.2, 0.2, 0.2, 0.2, 0.2, 0.2, 0.2, 0.2 ] 
	seg10_ba_t = TOptParam("seg10_ba_t", init[9],0.03,3.0,transform=(Normalize))
	seg9_ba_t = TOptParam("seg9_ba_t", init[8],0.03,3.0,transform=(Normalize))
	seg8_ba_t = TOptParam("seg8_ba_t", init[7],0.03,3.0,transform=(Normalize))
	seg7_ba_t = TOptParam("seg7_ba_t", init[6],0.03,3.0,transform=(Normalize))
	seg6_ba_t = TOptParam("seg6_ba_t", init[5],0.03,3.0,transform=(Normalize))
	seg5_ba_t = TOptParam("seg5_ba_t", init[4],0.03,3.0,transform=(Normalize))
	seg4_ba_t = TOptParam("seg4_ba_t", init[3],0.03,3.0,transform=(Normalize))
	seg3_ba_t = TOptParam("seg3_ba_t", init[2],0.03,3.0,transform=(Normalize))
	seg2_ba_t = TOptParam("seg2_ba_t", init[1],0.03,3.0,transform=(Normalize))
	seg1_ba_t = TOptParam("seg1_ba_t", init[0],0.03,3.0,transform=(Normalize))
	


	#base doping
	pdopTransform = Normalize(14,19)*Log10()*Linear(-1.0)
	init = [ -8e17, -8e17, -8e17, -8e17, -8e17, -8e17, -8e17, -8e17, -8e17, -8e17 ]
	seg10_ba_dop = TOptParam("seg10_ba_dop", init[9],-1e19,-1e16,transform=pdopTransform)
	seg9_ba_dop = TOptParam("seg9_ba_dop", init[8],-1e19,-1e16,transform=pdopTransform)
	seg8_ba_dop = TOptParam("seg8_ba_dop", init[7],-1e19,-1e16,transform=pdopTransform)
	seg7_ba_dop = TOptParam("seg7_ba_dop", init[6],-1e19,-1e16,transform=pdopTransform)
	seg6_ba_dop = TOptParam("seg6_ba_dop", init[5],-1e19,-1e16,transform=pdopTransform)
	seg5_ba_dop = TOptParam("seg5_ba_dop", init[4],-1e19,-1e16,transform=pdopTransform)
	seg4_ba_dop = TOptParam("seg4_ba_dop", init[3],-1e19,-1e16,transform=pdopTransform)
	seg3_ba_dop = TOptParam("seg3_ba_dop", init[2],-1e19,-1e16,transform=pdopTransform)
	seg2_ba_dop = TOptParam("seg2_ba_dop", init[1],-1e19,-1e16,transform=pdopTransform)
	seg1_ba_dop = TOptParam("seg1_ba_dop", init[0],-1e19,-1e16,transform=pdopTransform)
	
	
	wtot = TOptParam("wtot", 0.2, minval=0.05, maxval=0.8,transform=Log10)
	simMethod = DOptParam("simMethod","together",choices=["together","speedUp"],sorted=True)
	
	
	#only optimize over 1 subcell
	#p = [ seg1_ba_dop, seg1_ba_t, seg1_em_dop, seg1_em_t, seg1_fsf_dop, seg1_fsf_t ] 
	
	#thicknesses only, last jnc homo
	#p = [ seg10_em_t, seg9_em_t, seg8_em_t, seg7_em_t, seg6_em_t, seg5_em_t, seg4_em_t, seg3_em_t, seg2_em_t, seg1_em_t, seg1_em2_t ] 
	
	#thicknesses only, last jnc hetero
	p = [ seg10_em_t, seg9_em_t, seg8_em_t, seg7_em_t, seg6_em_t, seg5_em_t, seg4_em_t, seg3_em_t, seg2_em_t, seg1_em_t] 

	#compare sim methods 3 junctions
	#p = [ seg3_em_t, seg2_em_t, seg1_em_t]

	#include ARC 
	p = p + ARC

	
	#target 
	t_Eff = OptTarget("Eff", target=100.0, scale=100.0)
	t_Jsc = OptTarget("Jsc", target=1000, scale=1)
	t_JscNormMin = OptTarget("Jsc_norm_min", target = 0, scale=1) #(1 - Jsc_norm)
	t_JscNormMatch = OptTarget("Jsc_norm_match", target=0, scale=1) 
	t_JscNormMatch20 = OptTarget("Jsc_norm_match_20", target=0, scale=1)	
	t_JscNormMatch45 = OptTarget("Jsc_norm_match_45", target=0, scale=1)	
	t = [ t_JscNormMin ]
	
	### grid search. random to least random
	# "random" : purely random, Ns: number of samples
	# "latin": near-random only 1 point per hyperplane, Ns: number of samples
	# "sobol": quasi-random which covers sample space more evenly. skip: omit intial experiments,  Ns: number of experiments
	# "grid":  location: random or equidist, Ns: number of samples per dimension
	optimizer.search( p, t, method="random", options={"Ns": 10})

else:
	## validate model by fitting with parameters
	
	#parameters varied
	p1 = OptParam("seg1_em_t", 0.54,minval=0.5, maxval=0.6, scale=0.54)
	p2 = OptParam("seg1_fsf_t", 0.3,minval=0.27, maxval=0.33, scale=0.3)
	p3 = OptParam("Rfactor", -0.03, minval=-0.1, maxval=0.1,scale=0.1)
	p4 = OptParam("seg1_ba_t",0.255,minval=0.23,maxval=0.27, scale=0.255)
	
	p = [p1,p2,p3,p4]
	
	#error targets
	t1 = OptTarget("error_IQE", target=0.0)
	t2 = OptTarget("error_RS", target=0.0)
	
	t = [ t2, t2,t2,t2]
	optimizer.backend.set_method("shgo")#"n": 5**len(p),
	optimizer.backend.set_optimization_parameters(method='L-BFGS-B',options={"n": 3**len(p),"gtol": 1e-5,"ftol": 2.2e-9})
	
	optimizer.optimize( p, t )

