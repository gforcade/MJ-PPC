#folder for child process
opt_folder = "@pwd@/../"

# list of folders of the parent project to copy to child project
#folders_to_copy =  ["@pwd@/../optsMJ/layerCSVs","@pwd@/../optsMJ/lib","@pwd@/../optsMJ/par","@pwd@/../optsMJ/pardb"]

# list of files to copy from parent to child
files_to_copy = ["datexcodes.txt"] 

#list of tools to be sent to child process   ## order is important !!!!
opt_tools = ["epi","sde","MatPar","RCWA"]
if 'v1' not in "@OptiToSentaurus@": #include tdx if v2 or v3 are used
	opt_tools += ["tdx"]
##if "on" in "@LC@": 	#include LC if being used
opt_tools += ["LCMatrix"]
if ("@sim_type@" == "fitOptimize") and (@Pin@ == 0.0): 	#include EQE sims 
	opt_tools += ["EQE","QE_Compare"]
opt_tools += ["optics"]
##if "Jph" not in "@eSim_type@": 	#include JV sims
#	opt_tools += ["JV","svisual_JV"]
#opt_tools += ["python_JV"]
#opt_tools += ["pyCollector"]



#list of parameters to update in parent project. empty param means nothing gets updated
if "@sim_type@" == "exploreOptimize":
	opt_params = []


#boolean specifying to restart last run child project
restart = False
