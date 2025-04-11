##compare QE measurementes to simulation

#setdep @node|svisual_EQE@

import sys 
import os

sys.path.append(os.path.abspath(os.path.join('..','..','..','..','Python')))

import Curve_compare as cc


#plotting details
plotDet = {}
plotDet['xlabel'] = 'Wavelength (um)'




#model details
Details = {}
Details['swap'] = False
Details['log'] =False


## EQE compare
plotDet['plotName'] = 'EQE_compare'
plotDet['ylabel'] = 'EQE' 
##details on how to grab data from files
#skiprows, delimiter, ycolumn, um (units)
simDetails = cc.dataDetails(1,',', 1,1.0)
targDetails = cc.dataDetails(1,',', 6, 1.0)
##grab data (simFilename, skiprows, target file name, skiprows) + \calculate error
simData = cc.grabData("../"+"@node|svisual_EQE@"+'/EQE.csv',simDetails)
targetData =cc.grabData("@pwd@/../Measurements/@measData@",targDetails)
Data = cc.interp(targetData, simData,plotDet)
error_EQE = cc.RMSD(Data,Details)



## IQE compare
plotDet['plotName'] = 'IQE_compare'
plotDet['ylabel'] = 'IQE' 
##details on how to grab data from files
#skiprows, delimiter, ycolumn, um (units)
simDetails = cc.dataDetails(1,',', 1,1.0)
targDetails = cc.dataDetails(1,',', 7, 1.0)
##grab data (simFilename, skiprows, target file name, skiprows) + \calculate error
simData = cc.grabData("../"+"@node|svisual_EQE@"+'/IQE.csv',simDetails)
targetData =cc.grabData("@pwd@/../Measurements/@measData@",targDetails)
Data = cc.interp(targetData, simData,plotDet)
error_IQE = cc.RMSD(Data,Details)



## RS compare
plotDet['plotName'] = 'RS_compare'
plotDet['ylabel'] = 'R'
##details on how to grab data from files
#skiprows, delimiter, ycolumn, um (units)
simDetails = cc.dataDetails(1,',', 1,1.0)
targDetails = cc.dataDetails(1,',', 8, 1.0)
##grab data (simFilename, skiprows, target file name, skiprows) + \calculate error
simData = cc.grabData("../"+"@node|svisual_EQE@"+'/RS.csv',simDetails)
targetData =cc.grabData("@pwd@/../Measurements/@measData@",targDetails)
Data = cc.interp(targetData, simData,plotDet)
error_RS = cc.RMSD(Data,Details)

#print the error in the workbench
print(f"DOE: error_EQE {error_EQE}")
print(f"DOE: error_IQE {error_IQE}")
print(f"DOE: error_RS {error_RS}")
