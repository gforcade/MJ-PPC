"""
Compare QE measurement to simulation 

Extract Eg from QE simulation
 
"""

#setdep @node|EQE@


##compare QE measurementes to simulation

import sys
import os
import numpy as np
import matplotlib.pyplot as plt
from scipy.optimize import minimize
import math

sys.path.append(os.path.abspath(os.path.join('..','..','..','..','Python')))

import dfise
import Curve_compare as cc
#RMSD, RMSRE, MD (mean difference), MRD (mean relative difference). (data1 - data2)

# Physcial constants
qe = 1.602e-19 # C
h = 6.626e-34 # J.s
c0 = 299792458 # m/s


# Eg fitting details
satRange = 1.2  # QE data to keep, below the peak
edError = 2e-2    #minimum uncertainty allowed for edge fit
edMinQE = 8e-2   # minimum QE for starting point choice (if measured QE is noisy below a threshold)
Eg = 1.353*@em_xMole@ + 0.737 * (1.0 - @em_xMole@) - 0.13*@em_xMole@*(1.0 - @em_xMole@)  #expected bandgap of material (for starting point)



#plotting details
plotDet = {}
plotDet['plt'] = False
plotDet['xlabel'] = 'Wavelength (um)'


#model details
Details = {}
Details['swap'] = False
Details['log'] =False


!( global wstart, wend, wsteps, intensity )!

# Load simulated data. create an instance of class dfise from the given file.
d = dfise.dfise("@pwd@/results/nodes/@node|EQE@/n@node|EQE@_des.plt")


#global variables
wlname =  "Device=,File=CommandFile/Physics,DefaultRegionPhysics,ModelParameter=Optics/Excitation/Wavelength"
iname = "Device=,File=CommandFile/Physics,DefaultRegionPhysics,ModelParameter=Optics/Excitation/Intensity"


#if @wfrontc@ == 0.0
# Assume front contacts are perfectly reflective
FT = 1.0
#else
FT = @<(wtot-wfrontc)/wtot>@
#endif



## EQE compare
plotDet['plotName'] = 'EQE_compare'
plotDet['ylabel'] = 'EQE' 
##details on how to grab data from files
#skiprows, delimiter, ycolumn, um (units)
simDetails = cc.dataDetails(0,',', 1,1.0)
targDetails = cc.dataDetails(0,',', 6, 1.0)
##grab data (simFilename, skiprows, target file name, skiprows) + \calculate error
##simData = cc.grabData("../"+"@node|svisual_EQE@"+'/EQE.csv',simDetails)
EQE = d.data["cathode TotalCurrent"]*(h*c0/qe)/(d.data[wlname]*1e-6*@intensity@)*@numSegments@*(1.0+@Rfactor@)
simData = np.array([d.data[wlname],EQE])
targetData =cc.grabData("@pwd@/../Measurements/@measQEData@",targDetails)
Data = cc.interp(targetData, simData,plotDet)
error_EQE = cc.RMSD(Data,Details)



## RS compare
plotDet['plotName'] = 'RS_compare'
plotDet['ylabel'] = 'R'
##details on how to grab data from files
#skiprows, delimiter, ycolumn, um (units)
simDetails = cc.dataDetails(0,',', 1,1.0)
targDetails = cc.dataDetails(0,',', 8, 1.0)
##grab data (simFilename, skiprows, target file name, skiprows) + \calculate error
R = FT*d.data["LayerStack(W1) R_Total"]*(1.0+@Rfactor@)+(1.0-FT)
##simData = cc.grabData("../"+"@node|svisual_EQE@"+'/RS.csv',simDetails)
simData = np.array([d.data[wlname],R])
targetData =cc.grabData("@pwd@/../Measurements/@measQEData@",targDetails)
Data = cc.interp(targetData, simData,plotDet)
error_RS = cc.RMSRE(Data,Details)


## IQE compare
plotDet['plotName'] = 'IQE_compare'
plotDet['ylabel'] = 'IQE' 
##details on how to grab data from files
#skiprows, delimiter, ycolumn, um (units)
simDetails = cc.dataDetails(0,',', 1,1.0)
targDetails = cc.dataDetails(0,',', 7, 1.0)
##grab data (simFilename, skiprows, target file name, skiprows) + \calculate error
IQE = EQE/(1.0-R)
##simData = cc.grabData("../"+"@node|svisual_EQE@"+'/IQE.csv',simDetails)
simData = np.array([d.data[wlname],np.abs(IQE)])
targetData =cc.grabData("@pwd@/../Measurements/@measQEData@",targDetails)
Data = cc.interp(targetData, simData,plotDet)
error_IQE = cc.RMSD(Data,Details)


# copy and convert QE to log for Eg extraction
QE = np.copy([1.24/np.flip(simData[0]),np.flip(np.log(simData[1]))])



#print the error in the workbench
print(f"DOE: error_EQE {error_EQE}")
print(f"DOE: error_IQE {error_IQE}")
print(f"DOE: error_RS {error_RS}")



##%% extract the bandgap assuming method from Helmers, "Bandgap determination basd onelectrical quantum efficiency,"  2013



def fitLin(idxWL,QE):
	mask = np.where((QE[0] >= QE[0,idxWL[0]]) & (QE[0] <= QE[0,idxWL[1]]),True,False) 
	edCoefs = np.polyfit(QE[0,mask],QE[1,mask], deg=1,cov=True)
	return max(abs(np.diag(edCoefs[1])/edCoefs[0])),QE[0,mask]

def find_nearest(array,value):
	array =  np.asarray(array)    
	idx = (np.abs(array - value)).argmin()
	return idx


## fit saturation part of QE

# find peak QE
peak = np.nanmax(QE,axis=1)[1]
#gather points that have similar QE values
mask = np.where(QE[1] > peak * satRange,True,False)
satCoefs = np.polyfit(QE[0,mask],QE[1,mask], deg=1,cov=True)
satP = np.poly1d(satCoefs[0])


# fit edge part of QE
idxWL = [find_nearest(np.exp(QE[1]),edMinQE),find_nearest(QE[0],Eg)]
while True:
	idxWL = [idxWL[0],idxWL[1]-1] #step upper bound down
	x1,points = fitLin(idxWL,QE)
	print(x1)
	if len(points) == 3: # step lowerbound up 
		idxWL = [idxWL[0]+1,find_nearest(QE[0],Eg)]
	if x1 < edError:
		break


mask = np.where((QE[0] >= QE[0,idxWL[0]]) & (QE[0] <= QE[0,idxWL[1]]),True,False) 
edCoefs = np.polyfit(QE[0,mask],QE[1,mask], deg=1,cov=True)
edP = np.poly1d(edCoefs[0])
print('\n\nData used for edge fit:')
print(QE[0,mask])


def P(x):
	# funciton to find intersection between curves
	return abs(edP(x)-satP(x)) 

# provide bandgap 
res = minimize(P,Eg) 
print('\n\nDOE: Eg ' + str(res.x[0]))


#calculate bandgap uncertainty
unEd = np.sqrt(np.diag(edCoefs[1]))
unSat = np.sqrt(np.diag(satCoefs[1]))
unEg = res.x[0]*np.sqrt((unSat[1]**2 + unEd[1]**2)/(satCoefs[0][1] - edCoefs[0][1])**2 + (unSat[0]**2 + unEd[0]**2)/(satCoefs[0][0] - edCoefs[0][0])**2)
print('DOE: uncert_Eg ' + str(unEg))

## plot results
#if 1 == 0
plt.figure()
plt.rcParams.update({'font.size':20})
plt.plot(QE[0],np.exp(QE[1]),label='QE',linewidth=3)
plt.plot(QE[0],np.exp(satP(QE[0])),label='Saturation',linewidth=3)
plt.plot(QE[0],np.exp(edP(QE[0])),label='Edge',linewidth=3)
plt.scatter(res.x[0],np.exp(edP(res.x[0])),color='k',label='Eg')
plt.yscale('log')
plt.legend()
plt.ylim((1e-2,1.1))
plt.xlabel('Energy (eV)')
plt.ylabel('QE')
plt.tight_layout()

plt.savefig("EgExtract.png",transparent=True)

#endif






