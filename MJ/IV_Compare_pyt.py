##compare current-voltage measurementes to simulation

#setdep @node|python_JV@


sys.path.append(os.path.abspath(os.path.join('..','..','..','..','Python')))

import Curve_compare as cc
#RMSD, RMSRE, MD (mean difference), MRD (mean relative difference). (data1 - data2)

#if "@sim_type@" == "fitOptimize"

#plotting details
plotDet = {}
plotDet['plotName'] = 'IV_curve'
plotDet['xlabel'] = 'Voltage (V)'
plotDet['ylabel'] = 'J (A/cm$^2$'
plotDet['plt'] = False



#model details
Details = {}
Details['swap'] = False
Details['log'] =False

##details on how to grab data from files. Don't skiprows, do it automatically
#skiprows, delimiter, ycolumn(0,1,2,...), um (unit multiplier)
simDetails = cc.dataDetails(0,'\t', 1,1.0)
targDetails = cc.dataDetails(0,',', 1, 1.0)



##grab data (Filename, dataDetails) + calculate error
simData = cc.grabData("../"+"@node|python_JV@"+'/data.csv',simDetails)
targetData =cc.grabData("@pwd@/../Measurements/@measIVData@",targDetails)
Data = cc.interp(targetData, simData,plotDet) #data2 -> data1
error = cc.RMSRE(Data,Details) 

if @Pin@ > 0.0:
	#get measured Jsc,Voc,FF,Pmax as a class and compare to simulated values
	error = cc.RMSD(Data,Details) 
	measIVParams = cc.grabIVParams("@pwd@/../Measurements/@measIVData@")
	print(f"DOE: error_Jsc {(measIVParams.Jsc-@Jsc@)/measIVParams.Jsc}")
	print(f"DOE: error_Voc {(measIVParams.Voc-@Voc@)/measIVParams.Voc}")
	print(f"DOE: error_FF {(measIVParams.FF-@FF@/100.0)/measIVParams.FF}")
	print(f"DOE: error_Pmax {(measIVParams.Pmax-@Pm@)/measIVParams.Pmax}")


#print the error in the workbench
print(f"DOE: error_IV {error}")

#endif



