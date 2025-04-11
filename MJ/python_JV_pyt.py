#setdep @node|JV@


# provides the Jsc, Voc, FF, Eff, Jph,...

sys.path.append(os.path.abspath(os.path.join('..','..','..','..','Python')))
import dfise
import Curve_compare as cc
from scipy import interpolate, optimize
import csv
import numpy as np

vString	=	'anode OuterVoltage'
jString	=	'cathode TotalCurrent'

def optGenToJ(optGen):
	#converts opticalgeneration density subl to current density
	#sentaurus output: [cm-3 s-1 um]
	#function ouput: [A cm-2]
	return optGen*1e-4*1.6e-19



### initiates variables to make sentaurs preprocess correctly
#set Jsc 0.0
#set Voc 0.0
#set FF 0.0
#set Eff 0.0
#set Pm 0.0
#set QE 0.0


#constants
wtoeV = 1.24		#[eV um]

#if "@eSim_type@" == "Jph"
### optical simulatin only run. So grab Jph data for optimization
#create an instance of class dfise from the given file.
d = dfise.dfise("../"+"@node|optics@"+'/pv1_PV_n@node|optics@_des.plt')
dKeys = d.data.keys()
Jph = []
for i in range(int(@numSegments@),0,-1):
	for key in dKeys:
		if ('Integrsc'+str(i)+'_em' in key) and ('OpticalGeneration' in key):
			Jph_name = key
			Jph.append(optGenToJ(d.data[Jph_name][0]) * wtoeV / @spectrum@ * @numSegments@ / 1.0 )
	print("DOE: Jph" + str(i) +"_norm " + str(Jph[-1]))
##print the limiting current	
print("DOE: Jph_norm " + str(min(Jph)))
 
#else
### electrical simulation run.
#include "../Python/python_JV_JVran.py"

#endif




#####################################################################

### compare current-voltage measurementes to simulation
#RMSD, RMSRE, MD (mean difference), MRD (mean relative difference). (data1 - data2)

######################################################################

#if "@sim_type@" == "fitOptimize"

#plotting details
plotDet = {}
plotDet['plotName'] = 'IV_curve'
plotDet['xlabel'] = 'Voltage (V)'
plotDet['ylabel'] = 'J (A/cm$^2$)'
plotDet['yscale'] = 'log'
plotDet['plt'] = False



#model details
Details = {}
Details['swap'] = False
Details['log'] =False

##details on how to grab data from files. Don't skiprows, do it automatically
#skiprows, delimiter, ycolumn(0,1,2,...), um (unit multiplier)
#simDetails = cc.dataDetails(0,'\t', 1,1.0)
targDetails = cc.dataDetails(0,',', 1, 1.0)



##grab data (Filename, dataDetails) + calculate error
simData =  np.array([d.data[vString],abs(d.data[jString])])#cc.grabData("../"+"@node|python_JV@"+'/data.csv',simDetails)
targetData =cc.grabData("@pwd@/../Measurements/@measIVData@",targDetails)
if True:#simData[0,0]< targetData[0,0]: 
	#map target data to sim data as it has a smaller range
	plotDet['dataSwap'] = False
	Data = cc.interp(targetData,simData,plotDet) #data2 -> data1
else:
	plotDet['dataSwap'] = True
	Data = cc.interp(simData,targetData,plotDet) #data2 -> data1
error = cc.RMSREM(Data,Details) 



if @Pin@ > 0.0:
	#get measured Jsc,Voc,FF,Pmax as a class and compare to simulated values
	error = cc.RMSD(Data,Details) 
	measIVParams = cc.grabIVParams("@pwd@/../Measurements/@measIVData@")
	print(f"DOE: error_Jsc {(Jsc - measIVParams.Jsc)/measIVParams.Jsc}")
	print(f"DOE: error_Voc {(Voc - measIVParams.Voc)/measIVParams.Voc}")
	print(f"DOE: error_FF {(FF - measIVParams.FF)/measIVParams.FF}")
	print(f"DOE: error_Pmax {(Pm - measIVParams.Pmax)/measIVParams.Pmax}")
else:
	print(f"DOE: error_Jsc 0.0")
	print(f"DOE: error_Voc 0.0")
	print(f"DOE: error_FF 0.0")
	print(f"DOE: error_Pmax 0.0")


#print the error in the workbench
print(f"DOE: error_IV {error}")

#endif







