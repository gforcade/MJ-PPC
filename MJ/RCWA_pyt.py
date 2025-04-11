"""
## Runs RCWA

#### Code should only be changed where there is 4 hashtags.

"""



#setdep @node|MatPar@

import sys
import os
import numpy as np
from scipy.optimize import minimize
import time
import cProfile

sys.path.append(os.path.abspath(os.path.join('..','..','..','..','Python')))

from S4_RCWA import *


start = time.time()



######### Inputs ############

maxTh = 7.0 #max total summed absorber thicknesses [um]
maxSegTh = 4.0  #max single absorber thickness [um]
method = 'Nelder-Mead' #scipy optimization method: use Nelder-mead for unconstrained or SLSQP for constrained problems
Contrained = False  	#include contrained optimization, constraining the layer thicknesses


##################




# grab optical parameters and layer structure. Input ..._mpr.par file from matpar tool.
layer,wnk = GrabMatPars('../@node|MatPar@/n@node|MatPar@_mpr.par')



#if "@OptiToSentaurus@" == "v3"
"""
## run optical sims for optoelectronic simulations
"""

# write python file for S4. layer, wnk, wavelength, minimum step size (um) for optical mesh, True adds 1nm sublayers for each layer (slower sim), False means dont optimize
writeAndRunS4(layer,wnk,@spectrum@,0.01,True,False)



#elif "@OptiToSentaurus@" == "v3.1"
"""
## only run optical simulations, for internal optimization
"""

#wavelength we are investigating
wl = @spectrum@


# initialize S4 simulation + get pre-optimization absorption per junction
# write python file for S4. layer, wnk, wavelength, minimum step size (um) for optical mesh (keep larger than thicknest layer to maximize speed), True adds 1nm sublayers for each layer (False  for speed), True = optimization run
S,kZero = writeAndRunS4(layer,wnk,wl,10.0,False,True)


#### Choose which region thicknesses you want to optimize. Create a mask where True means optimize layer
# thicknesses are ordered from the top to the bottom of the cell.
layerMask = [False for name in layer['Names']] #start with no layer thickness optimizations.
# add layers to be optimized

s4OptType = '@s4OptType@'
if s4OptType not in ['absAndArcTh', 'absThOnly', 'arcThOnly', 'absThNoBottom',  'absAndArcThNoBottom']:
	print(f's4OptType "{s4OptType}" not recognized. Using "absAndArcTh".')
	s4OptType = 'absAndArcTh'

for idx in range(len(layer['Names'])):
	# emitter layers 
	if s4OptType != 'arcThOnly':
		if 'em' in layer['Names'][idx]:
			layerMask[idx] = True
	
	if s4OptType != 'absThOnly' or s4OptType != 'absThNoBottom':
		#ARC layers
		if idx == 0 or idx == 1:
			layerMask[idx] = True

	if  s4OptType == 'absThNoBottom' or s4OptType == 'absAndArcThNoBottom': 
		#exclude the bottom junction
		if 'sc1_' in layer['Names'][idx]:
			layerMask[idx] = False



cons = {}
if Contrained:
	cons = ({'type': 'ineq', 'fun': lambda x: maxTh - sum(abs(x[2:]))}, {'type': 'ineq', 'fun': lambda x: maxSegTh - max(abs(x[2:]))})

# run optimization
x_opt = layer['Thicknesses'][layerMask]
print("\nInitial thicknesses: ")
print(x_opt)



optProgDF = pd.DataFrame(columns=["OptFOM"]+list(np.array(layer['Names'])[layerMask]))



for i in range(int(@num_s4opts@)):
	if i == 0:
		res = minimize(fOpt,x_opt,method=method,args=(layer,wnk,wl,S,kZero,layerMask,optProgDF),bounds=[(0.001,9.9)] * len(x_opt),options={'adaptive':True, 'maxfev':100000},constraints=cons)
		res.x = abs(res.x)
	else:
		res = minimize(fOpt,abs(res.x),method=method,args=(layer,wnk,wl,S,kZero,layerMask,optProgDF),bounds=[(0.001,9.9)] * len(x_opt),options={'adaptive':True, 'maxfev':100000},constraints=cons)
		res.x = abs(res.x)
	

print("\nFinal thicknesses: ")
print(res.x)
printVars(res.x,layerMask,layer)
print("\n")
print(res)
print("DOE: " + "s4opt_success " + str(res.success))
print("DOE: " + "s4opt_nfev " + str(res.nfev))


	
with open(os.path.abspath(os.path.join(os.getcwd(), "n@node@_s4OptProg.csv")), 'w') as file:
	file.write(f"S4 Optimization\nProject Folder,{os.path.abspath('@pwd@')}\nOpt completion datetime,{time.strftime('%y%m%d_%H%M%S')}\nOPT RESULT\n{res}\nOPT DATAFRAME\n")
	optProgDF.to_csv(file)


# calculate the absorptions of all cells for optimized parameters
layer['Thicknesses'][layerMask] = res.x
# update and run python file for S4. layer, wnk, wavelength, minimum step size (um) for optical mesh, True adds 1nm sublayers for each layer (False for speed), -string- output file name of absorption used for optimization,True = optimization run, S, kZero
updateAndRunS4(layer,wnk,wl,10.0,False,'',False,S,kZero)


#endif

#print total runtime
print("\n\nRun Time = " + str(time.time() - start) + "s.")













