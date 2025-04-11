"""
For grabbing layer details of the device.
Will grab it from the mpr tool, looking into the par files.
"""
import numpy as np
import subprocess
import uuid
import os
import feather
import pandas as pd


def isfloat(num):
	try:
		float(num)
		return True
	except ValueError:
		return False

def isfloat_v2(line):
	## checks if it is empty as well as a float
	if line:
		return isfloat(line[0])
	else:
		return False


def GrabMatPars(fNameGrab):
	"""
	INPUT: 
		fNameGrab: String
			Name + directory of mpr.par file within the mpr tool.

	OUTPUT: 
		layer: dictionnary
			provides layer names, file locations, layer thicknesses, layer materials.
			Material names are repeated if nk data is the same. Else, using increasing numbering to desifer them
		
		wnk: dictionnary
			layer wavelength (um), n, and k data. keys are the layer names.

	"""
	#fNameGrab = '../MJ/results/nodes/1949/n1949_mpr.par'

	layer = {}
	layer['Names'] = []
	layer['Files'] = []
	layer['Thicknesses'] = []
	layer['Materials'] = []

	#grab layer names, file locations, layer thicknesses, layer materials
	with open(fNameGrab) as fid:
		lines = fid.readlines()
		for line in lines:	
			if "Region" in line:
				layer['Names'].append(line.split('=')[1].split('{')[0].strip().replace('\"',""))
				layer['Files'].append(line.split('=')[2].split('}')[0].strip().replace('\"',""))
				try: 		# for normal layers
					layer['Thicknesses'].append(float(layer['Files'][-1].split('/')[-1].split('_')[2]))
				except: 	# for layers that only have thickness dependence (no doping or mole fractions)
					layer['Thicknesses'].append(float(layer['Files'][-1].split('/')[-1].split('_')[2][:-4]))
				count = 0
				while True:
					if (layer['Files'][-1].split('/')[-1].split('_')[1] + str(count)) not in layer['Materials']:
						break
					count += 1
				layer['Materials'].append(layer['Files'][-1].split('/')[-1].split('_')[1] + str(count))
	
	#grab gold layer if no substrate present
	if 'substrate' not in layer['Names']:	
		with open(fNameGrab) as fid: 
			lines = fid.readlines()
			for line in lines:	
				if "Gold" in line:
					layer['Names'].append(line.split('=')[1].split('{')[0].strip().replace('\"',""))
					layer['Files'].append(line.split('=')[2].split('}')[0].strip().replace('\"',""))
					layer['Thicknesses'].append(1.0)
					layer['Materials'].append(layer['Files'][-1].split('/')[-1].split('_')[1] + str(count))	
	layer['Thicknesses'] = np.array(layer['Thicknesses'])


	wnk = {} #dictionnary of nk data vs wavelength for every layer. Gives key of nk data that is identical given layer.
	layerMat_gather = []
	for lidx in range(len(layer['Files'])):
		wnk_gather = []
		# grab nk data from files, returns list of strings with w(um),n,k 
		with open(layer['Files'][lidx]) as fid:
			while True: 	#run through file until just before the nk data
				if "NumericalTable" in fid.readline():
					break
			while True: 	#grab the nk data
				line = fid.readline()
				line = line.replace(';',"").replace('\\n',"").strip()
				if ')' in line and wnk_gather:
					break
				if isfloat_v2(line):
					wnk_gather.append(np.fromstring(line,sep=' '))
		for i in range(len(layerMat_gather)): 	# mark non-unique nk dataset 
			if  ''.join([n for n in layer['Materials'][lidx] if not n.isdigit()]) == ''.join([n for n in layerMat_gather[i] if not n.isdigit()]) and np.array_equal(np.transpose(np.array(wnk_gather)), wnk[layer['Names'][i]]):
				layerMat_gather.append(layer['Materials'][lidx])
				layer['Materials'][lidx] = layer['Materials'][i]		#change material name to first repeat layer	
				wnk[layer['Names'][lidx]] = layer['Names'][i]
				break
		if layer['Names'][lidx] not in wnk.keys(): # save nk data if it is unique
			layerMat_gather.append(layer['Materials'][lidx])
			wnk[layer['Names'][lidx]] = np.transpose(np.array(wnk_gather))

		if not layerMat_gather: # save nk data always for first file
			layerMat_gather.append(layer['Materials'][lidx])
			wnk[layer['Names'][lidx]] = np.transpose(np.array(wnk_gather))

	
	return layer,wnk











####%%%%%%
"""
Write python file for S4 to run.

"""

def writeAndRunS4(layer,wnk,spectrum,stepSize,thinLs,optRun):
	"""
	Writes python file that is written to run S4.

	INPUT:
		layer, [dictionnary]
			see GrabMaterialPars for keys and there definitions.
		spectrum, [float or string]
			wavelength at which we shall simulate or spectrum file to use for multiple wavelengths
		wnk, [dictionnary]
			nk data for the various layers. it also includes strings that point to a wavelength set that is identical
		stepSize, [float]
			the smallest sublayer thickness to target when creating sub-layers.
		thinLs, [float]
			True if you want 1 nm sublayers at extremities of each layer
		optRun, [boolean]
			True, so that pandas is included

	OUTPUT:
		S, [dict]
			S4 stuff is returned
		kZero, [boolean list]
			list of 1s== layer name absorbs, 0s layer name does not absorb
	"""	
	# creates random filename for the S4 compatible py file.
	S4fname = str(uuid.uuid4()) + '.py'


	for key in wnk.keys():
		if not isinstance(wnk[key],str):
			eps = (wnk[key][1] + 1j * wnk[key][2])**2
			wnk[key][1] = eps.real
			wnk[key][2] = eps.imag
	
	if isfloat(spectrum):
		wl = float(spectrum)

	with open(S4fname,"w") as fid:	
		fid.write('import S4\n')
		fid.write('import numpy as np\n')
		#fid.write('import matplotlib.pyplot as plt\n')
		fid.write("\n\n\n")
		fid.write("S = S4.New(Lattice=((1.0,0.0),(0.0,1.0)),NumBasis=2)\n\n")
	
		if optRun:
			fid.write("import pandas as pd\n")

		# add materials and layers
		numL,kZero = setMaterialsS4(layer,wnk,fid,wl,stepSize)
		addLayersS4(layer,wnk,fid,wl, numL,thinLs)
	
		# set simulation properties
		fid.write("\n\n # Set simulation properties \n")
		fid.write("S.SetExcitationPlanewave(IncidenceAngles=(0,0),sAmplitude=1,pAmplitude=0)\n")
		fid.write("S.SetFrequency(1.0/"+str(wl)+")\n")
		
		# write into S4 file to say what layers calcualte absorption
		getSimulationOutput(layer,fid, wl,numL,thinLs,False,'',kZero,"0")

	d = locals()

	# run written python file, save variables in d environment
	exec(open(S4fname).read(),d)
	

	# remove S4 file as it is not needed anymore
	#os.remove(S4fname)

	return d['S'],kZero







def updateAndRunS4(layer,wnk,spectrum,stepSize,thinLs,outfname,optRun,S,kZero):
	"""
	Writes python file that is written to rerun S4, for optimizer. Sets layer thicknesses only, thus need S4 structure input, so needs have writeAndRunS4 run already.

	INPUT:
		layer, [dictionnary]
			see GrabMaterialPars for keys and there definitions.
		spectrum, [float or string]
			wavelength at which we shall simulate or spectrum file to use for multiple wavelengths
		wnk, [dictionnary]
			nk data for the various layers. it also includes strings that point to a wavelength set that is identical
		stepSize, [float]
			the smallest sublayer thickness to target when creating sub-layers.
		thinLs, [float]
			True if you want 1 nm sublayers at extremities of each layer
		outfname, [string]
			File name where we output layer resolved absorption
		optRun, [boolean]
			True: run as optimizer. False: print out Jph_norm for all layers.
		S, [dict]
			S4 structure dictionnary
		kZero, [boolean list]
			list of 1s== layer name absorbs, 0s layer name does not absorb
	"""	
	# creates random filename for the S4 compatible py file.
	S4fname = str(uuid.uuid4()) + '.py'


	for key in wnk.keys():
		if not isinstance(wnk[key],str):
			eps = (wnk[key][1] + 1j * wnk[key][2])**2
			wnk[key][1] = eps.real
			wnk[key][2] = eps.imag
	
	if isfloat(spectrum):
		wl = float(spectrum)

	with open(S4fname,"w") as fid:	
		

		# add materials and layers
		numL = [1] * len(layer['Names'])
		updateLayersS4(layer,wnk,fid,wl, numL,thinLs)
		
		# write into S4 file to say what layers calcualte absorption
		getSimulationOutput(layer,fid, wl,numL,thinLs,optRun,outfname,kZero,"1")


	# run written python file
	exec(open(S4fname).read())


	# remove S4 file as it is not needed anymore
	os.remove(S4fname)






def getSimulationOutput(layer,fid, wl,numL,thinLs,optRun,outfname,kZero,initOrFin):
	"""
	Set what RCWA will calculate as output.

	INPUT:
		layer, [dictionnary]
			see GrabMaterialPars for keys and there definitions.
		fid, [file ]
			file that we write to
		wl, [float]
			wavelength at which we shall simulate
		numL, [list]
			says how many sublayers to add for each layer.
		thinLs, [boolean]
			True, have 1 nm sublayers at extremities of layer.
		optRun, [boolean]
			True: run as optimizer. False: print out Jph_norm for all layers.
		outfname, [string]
			File name where we output layer resolved absorption. Only useful when optRun=True
		kZero, [boolean list]
			list of 1s== layer name absorbs, 0s layer name does not absorb
		initOrFin, [str]
			string either 0 or 1 to differentiate between the initial and final results
	"""
	# get simulation output 
	fid.write("\n\n ### Get simulation output. \n")
	Gen = []
	t_abs = []
	A = []
	for lay in range(len(layer['Names'])):
		if not optRun or kZero[lay]: 	# only get absorption if it is a non-opt run or if it has an extinction coefficient !~ 0.
			if lay == len(layer['Names'])-1:
				G,t,a = sumLayerP(layer,fid,wl,layer['Names'][lay],layer['Names'][lay],numL,thinLs)
			else:
				G,t,a = sumLayerP(layer,fid,wl,layer['Names'][lay],layer['Names'][lay+1],numL,thinLs)
			Gen.append(G)
			t_abs.append(t)
			A.append(a)
	

	# Save Generation rate as file, and print R,A,T values in sentaurus output file
	Ais = []
	for n in range(1,len(A)):
		Ai = '+'.join([x for x in A if ("sc"+str(n)+"_") in x])
		if Ai:
			Ais.append(Ai)
	if optRun:
		fid.write("df = pd.DataFrame({'Ai': [" + ','.join(Ais) + "]})\n")
		fid.write("df.to_feather('" + outfname + "')\n")
	else:
		fid.write("A =  [" + ','.join(Ais) + "]\n")
		fid.write("for Aidx in range(len(A)):\n")
		fid.write("	print('DOE: Jph' + str(Aidx+1) + '_norm" + initOrFin +" ' + str(A[Aidx]*len(A)))\n")
		fid.write("print('DOE: Jph_norm" + initOrFin +" ' + str(min(A)*len(A)))\n\n")

		# Save Generation rate as file, and print R,A,T values in sentaurus output file
		fid.write("Pair = S.GetPowerFlux(Layer='AirAbove',zOffset=0.0)\n")
		SaveGenRate(layer,fid,Gen,t_abs)
		fid.write("\n\n # Print important parameters \n")
		fid.write("print(\"R = \" + str(abs(Pair[1].real)))\n")
		fid.write("print(\"T = \" + str(P" + layer['Names'][-1] + "_" + str(numL[-1]-1) + "[0].real))\n")
		fid.write("print('DOE: A" + initOrFin + " ' + str(" + '+'.join(A) + ") )\n")
		fid.write("print(\"R + T + A = \" + str(" + '+'.join(A) + " + abs(Pair[1].real) + P" + layer['Names'][-1] + "_" + str(numL[-1]-1) + "[0].real) + \"\\n\" )\n")





def setMaterialsS4(layer,wnk,fid,wl,stepSize):
	"""
	Writes material properties to S4 file for 1 wavelength.
	Does not create sublayers for layers with k < 1e-3

	INPUT:
		layer, [dictionnary]
			see GrabMaterialPars for keys and there definitions.
		fid, [file ]
			file that we write to
		wl, [float]
			wavelength at which we shall simulate
		wnk, [dictionnary]
			nk data for the various layers. it also includes strings that point to a wavelength set that is identical
		stepSize, [float]
			the smallest sublayer thicknes to target when creating sub-layers.

	OUTPUT:
		numL, [list int]		
			number of sub-layers per device layer (meshing)
	"""
	numL = [1] * len(layer['Names'])
	kZero = [0] * len(layer['Names'])

	#Material definitions
	fid.write("\n\n # Material parameters for given frequency. \n")
	fid.write("S.SetMaterial(Name='Vacuum',Epsilon=1.0 + 0j)\n")
	for idx in range(len(wnk.keys())):
		if not isinstance(wnk[layer['Names'][idx]],str): 	# continues if nk data is unique/first
			if np.interp(wl,wnk[layer['Names'][idx]][0],wnk[layer['Names'][idx]][2]) > 1e-3:
				numL[idx] = int(np.ceil(layer['Thicknesses'][idx]/stepSize))
				kZero[idx] = 1
			fid.write("S.SetMaterial(Name='" + str(layer['Materials'][idx]) + "',Epsilon=" + str(np.interp(wl,wnk[layer['Names'][idx]][0],wnk[layer['Names'][idx]][1])) + "+ 1j * " + str(np.interp(wl,wnk[layer['Names'][idx]][0],wnk[layer['Names'][idx]][2]))  + ")\n")
		else: 									# uses numL !=0 if its extinction coefficient was nonZero.
			if kZero[layer['Names'].index(wnk[layer['Names'][idx]])]:
				numL[idx] = int(np.ceil(layer['Thicknesses'][idx]/stepSize))
				kZero[idx] = 1
	return numL,kZero





def addLayersS4(layer,wnk,fid,wl,numL,thinLs):
	"""
	Write layers and sublayers to S4 file.

	INPUT:
		layer, [dictionnary]
			see GrabMaterialPars for keys and there definitions.
		fid, [file ]
			file that we write to
		wl, [float]
			wavelength at which we shall simulate
		wnk, [dictionnary]
			nk data for the various layers. it also includes strings that point to a wavelength set that is identical
		numL, [list]
			says how many sublayers to add for each layer.
		thinLs, [boolean]
			True, have 1 nm sublayers at extremities of layer.
	
	"""
	fid.write("\n\n # Add all layer representing device. Will subdivide layers if input was as such. Copying as much as possible as it runs faster. \n")	

	# add air layers above
	fid.write("S.AddLayer(Name='Incoming',Thickness=0.0,Material='Vacuum' )\n")
	fid.write("S.AddLayer(Name='AirAbove',Thickness=1.0,Material='Vacuum' )\n")
	
	# add all other layers below
	for lay in range(len(layer['Names'])):
		discr = numL[lay]
		if thinLs:
			discr += 2
		for i in range(discr):
			if i == 0: # special for first layer
				if thinLs:
					fid.write("S.AddLayer(Name='" + layer['Names'][lay] + "_" + str(i) + "',Thickness=" + str(0.001) + ",Material='" +  layer['Materials'][lay] + "')\n")
					thick = (layer['Thicknesses'][lay]-0.002)/(discr - 2)
				else:
					thick = layer['Thicknesses'][lay]/discr
					if not isinstance(wnk[layer['Names'][lay]],str):  	# add layer if layer with same material has not been added yet.
						fid.write("S.AddLayer(Name='" + layer['Names'][lay] + "_" + str(i) + "',Thickness=" + str(thick) + ",Material='" +  layer['Materials'][lay] + "')\n")
					else: 		# add layer copy for layers with materials that have already been added.
						fid.write("S.AddLayerCopy(Name='" + layer['Names'][lay] + "_" + str(i) + "',Thickness=" + str(thick) + ",Layer='" +  wnk[layer['Names'][lay]] + "_" + str(0) + "')\n")
			elif thinLs and i == discr-1:
				fid.write("S.AddLayerCopy(Name='" + layer['Names'][lay] + "_" + str(i) + "',Thickness=" + str(0.001) + ",Layer='" +  layer['Names'][lay] + "_" + str(0) + "')\n")
			else:
				fid.write("S.AddLayerCopy(Name='" + layer['Names'][lay] + "_" + str(i) + "',Thickness=" + str(thick) + ",Layer='" +  layer['Names'][lay] + "_" + str(0) + "')\n")




def updateLayersS4(layer,wnk,fid,wl,numL,thinLs):
	"""
	Update layer thicknesses.

	INPUT:
		layer, [dictionnary]
			see GrabMaterialPars for keys and there definitions.
		fid, [file ]
			file that we write to
		wl, [float]
			wavelength at which we shall simulate
		wnk, [dictionnary]
			nk data for the various layers. it also includes strings that point to a wavelength set that is identical
		numL, [list]
			says how many sublayers to add for each layer.
		thinLs, [boolean]
			True, have 1 nm sublayers at extremities of layer.
	
	"""
	fid.write("\n\n # Add all layer representing device. Will subdivide layers if input was as such. Copying as much as possible as it runs faster. \n")	

	
	# add all other layers below
	for lay in range(len(layer['Names'])):
		discr = numL[lay]
		if thinLs:
			discr += 2
		for i in range(discr):
			if i == 0:
				if thinLs:
					fid.write("S.SetLayerThickness(Layer='" + layer['Names'][lay] + "_" + str(i) + "',Thickness=" + str(0.001) + ")\n")
					thick = (layer['Thicknesses'][lay]-0.002)/(discr - 2)
				else:
					thick = layer['Thicknesses'][lay]/discr
					fid.write("S.SetLayerThickness(Layer='" + layer['Names'][lay] + "_" + str(i) + "',Thickness=" + str(thick) + ")\n")
			elif thinLs and i == discr-1:
				fid.write("S.SetLayerThickness(Layer='" + layer['Names'][lay] + "_" + str(i) + "',Thickness=" + str(0.001) + ")\n")
			else:
				fid.write("S.SetLayerThickness(Layer='" + layer['Names'][lay] + "_" + str(i) + "',Thickness=" + str(thick) + ")\n")



def sumLayerP(layer,fid,wl,name,backName,numL,thinLs):
	
	"""
	Write to file, so that we get the powerflux absorbed in every sublayer

	INPUT: 
		layer, [dictionnary]
			see GrabMaterialPars for keys and there definitions.
		fid, [file ]
			file that we write to
		wl, [float]
			wavelength at which we shall simulate
		name, [string]
			name of the layer we shall analyze
		backName, [string]
			name of the layer just below layer 'name'
		numL, [list int]
			number of sublayers for layers 
		thinLs, [boolean]
			True, have 1 nm sublayers at extremities of layer.
	OUTPUT:
		3 strings
			generation, depth, Absortion names of the variables that were written to the S4 file.

	"""

	lIdx = layer['Names'].index(name)
	discr = numL[lIdx]
	if thinLs:
		discr += 2
	
	fid.write("\n# Layer " + name + " is being processed \n")
	# Get power flux for layers and back layer
	fid.write("P" + backName + " = S.GetPowerFlux(Layer='" + backName + "_" + str(0) + "',zOffset=0.0)\n")
	for i in range(discr):
		fid.write("P" + name + "_" + str(i) + " = S.GetPowerFlux(Layer='" + name + "_" + str(i) + "',zOffset=0.0)\n")
		#fid.write("print('P" + name + str(i) + " = '+ str(P" + name + str(i) + "))\n")
	
	# Calculate absorption within each layer
	addStr = ""
	for i in range(discr):

		if i < discr-1:
			fid.write("A" + name + "_" + str(i) + "= P" + name + "_" + str(i) + "[0].real   - P" + name + "_" + str(i+1) + "[0].real + P" + name + "_" + str(i) + "[1].real   - P" + name + "_" + str(i+1) + "[1].real\n")

		else:
			if name == backName:
				fid.write("if P" + name + "_" + str(i) + "[1].real == 0.0: \n")
				# says last layer has no absorption if there is no reflection (so no back-reflector)
				fid.write("	A" + name + "_" + str(i) + "=0.0\n")
				#fid.write("A" + name + str(i) + "= P" + name + str(i-1) + "[0].real + P" + name + str(i-1) + "[1].real  - P" + name + str(i) + "[0].real - P" + name + str(i) + "[1].real \n")
			else:
				fid.write("A" + name + "_" + str(i) + "= P" + name + "_" + str(i) + "[0].real + P" + name + "_" + str(i) + "[1].real  - P" + backName + "[0].real - P" + backName + "[1].real \n")
			

		addStr += "A" + name + "_" + str(i) + " + "
	
	# Amass absorption into 1 total value for layer
	fid.write("A" + name + " =" + addStr[0:-2] + "\n")
	
	fid.write("Pabs = np.array([" + addStr[0:-2].replace('+',',') + "])\n")
	#fid.write("print('A__" + name + " = ' + str(A" + name + "))\n")
	
	# Calculate and save the generation rate profile
	if thinLs:
		fid.write("Gen" + name + " = np.abs(Pabs)*(" + str(wl/(1.2398*1.602e-19)) + ")/(" + str((layer['Thicknesses'][ lIdx ]-0.002)/(discr-2)) + "*1e-4)\n")
		fid.write("for i in [0,-1]:\n")
		fid.write("	Gen" + name + "[i] = Gen" + name + "[i]*" + str((layer['Thicknesses'][ lIdx ]-0.002)/(discr-2)) + "/0.001\n")
		fid.write("t_abs" + name + " = np.array([0.001/2.0 if x == 0 else " + str(layer['Thicknesses'][ lIdx ]) + "-0.001/2.0 if x == " + str(discr) +"-1 else 0.001 + (x - 0.5)/(" + str(discr) +"-2)*(" + str(layer['Thicknesses'][ lIdx ]) + "-0.002) for x in range(" + str(discr) +")])\n")
		fid.write("t_abs"+ name + " += " + str(sum( [ layer['Thicknesses'][i] for i in range(lIdx) ])) + "\n") 
	else:
		fid.write("Gen" + name + " = np.abs(Pabs)*(" + str(wl/(1.2398*1.602e-19)) + ")/(" + str(layer['Thicknesses'][ lIdx ]/discr) + "*1e-4)\n")
		fid.write("t_abs" + name + " = [(x + 0.5)/" + str(discr) +"*" + str(layer['Thicknesses'][ lIdx ]) + " + " + str(sum( [ layer['Thicknesses'][i] for i in range(lIdx) ])) + " for x in range(" + str(discr) +")]\n") 


	return ("Gen"+name),("t_abs"+name),("A"+name)





def SaveGenRate(layer,fid,Gen,t_abs):
	"""
	Writes to the fid file, so that the file saves the generation and related depth into a file.

	INPUT: 
		Gen, [list of strings]
			 list of names of the generation rate variables for each layer
		t_abs, [list of strings]
			list of names of the depth that is related to the generation rate
		fid, [file ]
			file that we write to
		layer, [dictionnary]
			see GrabMaterialPars for keys and there definitions.
	"""		
	
	fid.write("\n\n # Write to file \n") 
	fid.write("head = 'Depth(um),GenRate(cm-3s-1)' \n")
	if len(Gen) > 1:
		fid.write("np.savetxt('GenRate.csv',np.transpose([np.concatenate((" + ','.join(t_abs) + ")),np.concatenate((" + ','.join(Gen) + "))]),header=head,delimiter=',',comments='')\n")
	else:
		fid.write("np.savetxt('GenRate.csv',np.transpose([" + t_abs[0] + "," + Gen[0] + "]),header=head,delimiter=',',comments='')\n")
	
	








####%%%%%%
"""
optimize using S4.

"""



def fOpt(thicknesses,layer,wnk,wl,S,kZero,layersToOpt,optProgDF):
	"""
	Optimization function, give a mask to say which layer thickness to optimize (True). Optimizes Jph_min.
	"""

	layer['Thicknesses'][layersToOpt] = abs(thicknesses)

	outfname = str(uuid.uuid4()) + '.feather'
	updateAndRunS4(layer,wnk,wl,10.0,False,outfname,True,S,kZero)
	
	df = feather.read_dataframe(outfname)
	os.remove(outfname)

	optVal = 0.98 - df['Ai'].min()*len(df['Ai'])

	optProgDF.loc[len(optProgDF)] = [optVal] + list(layer['Thicknesses'][layersToOpt])


	return abs(optVal)



def fOptA(thicknesses,layer,wnk,wl,S,kZero,layersToOpt,optProgDF):
	"""
	Optimization function, give a mask to say which layer thickness to optimize (True). Optimizes absorption.
	"""

	layer['Thicknesses'][layersToOpt] = abs(thicknesses)

	outfname = str(uuid.uuid4()) + '.feather'
	updateAndRunS4(layer,wnk,wl,10.0,False,outfname,True,S,kZero)
	
	df = feather.read_dataframe(outfname)
	os.remove(outfname)

	optVal = 1.0 - df['Ai'].sum()


	optProgDF.loc[len(optProgDF)] = [optVal] + list(layer['Thicknesses'][layersToOpt])


	return optVal


def fOptSteps(thicknesses,layer,wnk,wl,S,kZero,layersToOpt,optProgDF,fitTo):
	"""
	Optimization function, give a mask to say which layer thickness to optimize (True).
	"""

	Pin = thicknesses[-1]
	thicknesses = thicknesses[:-1]
	for i in range(len(thicknesses[:-1])):
		j=i+1
		for n in range(len(layersToOpt)):
			if f"sc{j}_" in layer['Names'][n]:
				layer['Thicknesses'][layersToOpt[n]] = abs(thicknesses)

	outfname = str(uuid.uuid4()) + '.feather'
	updateAndRunS4(layer,wnk,wl,10.0,False,outfname,True,S,kZero)
	
	df = feather.read_dataframe(outfname)
	os.remove(outfname)

	RMSRE = 0
	for num in range(len(fitTo)):
		RMSRE += ((fitTo[num] - df['Ai'][num]*Pin)/(fitTo[num] + df['Ai'][num]*Pin))**2
		

	return RMSRE**(1/2)



def printVars(x,layerMask,layer):

	printLayers = np.array(layer['Names'],dtype=str)[layerMask]



	for idx in range(len(x)):
		print("DOE: " + printLayers[idx] + "_d " + str(x[idx]))










