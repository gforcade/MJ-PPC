#Sentaurus pyCollector cmd file
#The tool collects input parameters and node information for each experiment
#It creates or overwrites results/nodes/#/n#_swbVars.csv files when run

#File autocreated by pyPrepper.py script
#Command file creation time:20230605_151458

import time
import csv
import os

now = time.strftime('%Y%m%d_%H%M%S')

#For all expts; write project info, headers and then extract data and print to line
expts = '@experiments@'
exptStr = expts.replace(' ', '-')
with open(f'@pwd@/results/nodes/@node@/n@node@_swbVars.csv', 'w', newline='', encoding='UTF8') as file:
	file.write(f'@pwd@\npreprocessing time:,{now}')
	file.write(f'\n\nsimulation flow:\n@tool_label|all@\n\n')
	writer = csv.writer(file)
	writer.writerow(['expt_num','sim_type','measQEData','measIVData','simMethod','BGN','3D','wtot','ARC2_t','ARC1_t','cap_t','cap_dop','seg10_fsf_t','seg10_fsf_dop','seg10_em_t','seg10_em_dop','seg10_ba_t','seg10_ba_dop','seg9_fsf_t','seg9_fsf_dop','seg9_em_t','seg9_em_dop','seg9_ba_t','seg9_ba_dop','seg8_fsf_t','seg8_fsf_dop','seg8_em_t','seg8_em_dop','seg8_ba_t','seg8_ba_dop','seg7_fsf_t','seg7_fsf_dop','seg7_em_t','seg7_em_dop','seg7_ba_t','seg7_ba_dop','seg6_fsf_t','seg6_fsf_dop','seg6_em_t','seg6_em_dop','seg6_ba_t','seg6_ba_dop','seg5_fsf_t','seg5_fsf_dop','seg5_em_t','seg5_em_dop','seg5_ba_t','seg5_ba_dop','seg4_fsf_t','seg4_fsf_dop','seg4_em_t','seg4_em_dop','seg4_ba_t','seg4_ba_dop','seg3_fsf_t','seg3_fsf_dop','seg3_em_t','seg3_em_dop','seg3_ba_t','seg3_ba_dop','seg2_fsf_t','seg2_fsf_dop','seg2_em_t','seg2_em_dop','seg2_em2_t','seg2_em2_dop','seg2_ba_t','seg2_ba_dop','seg1_fsf_t','seg1_fsf_dop','seg1_em_t','seg1_em_dop','seg1_em2_t','seg1_em2_dop','seg1_ba_t','seg1_ba_dop','substrate_t','numSegments','EmBaGrad_t','Mat9_Base','em_xMole','delEgMax','delThickMax','eSim_type','wfrontc','sideS','InAlAs_SymPos','InAlAs_StdDev','InGaAs_nk','del_k','InGaAs_tauSRH','InGaAs_S','InGaAs_Bfactor','Rfactor','temp','PR','OptiToSentaurus','s4OptType','num_s4opts','spectrum','LC','Pin','Rshunt','Rseries','optimizer','expt nodes'])

	writer.writerow([@experiment@,'@sim_type@','@measQEData@','@measIVData@','@simMethod@','@BGN@',@3D@,@wtot@,@ARC2_t@,@ARC1_t@,@cap_t@,@cap_dop@,@seg10_fsf_t@,@seg10_fsf_dop@,@seg10_em_t@,@seg10_em_dop@,@seg10_ba_t@,@seg10_ba_dop@,@seg9_fsf_t@,@seg9_fsf_dop@,@seg9_em_t@,@seg9_em_dop@,@seg9_ba_t@,@seg9_ba_dop@,@seg8_fsf_t@,@seg8_fsf_dop@,@seg8_em_t@,@seg8_em_dop@,@seg8_ba_t@,@seg8_ba_dop@,@seg7_fsf_t@,@seg7_fsf_dop@,@seg7_em_t@,@seg7_em_dop@,@seg7_ba_t@,@seg7_ba_dop@,@seg6_fsf_t@,@seg6_fsf_dop@,@seg6_em_t@,@seg6_em_dop@,@seg6_ba_t@,@seg6_ba_dop@,@seg5_fsf_t@,@seg5_fsf_dop@,@seg5_em_t@,@seg5_em_dop@,@seg5_ba_t@,@seg5_ba_dop@,@seg4_fsf_t@,@seg4_fsf_dop@,@seg4_em_t@,@seg4_em_dop@,@seg4_ba_t@,@seg4_ba_dop@,@seg3_fsf_t@,@seg3_fsf_dop@,@seg3_em_t@,@seg3_em_dop@,@seg3_ba_t@,@seg3_ba_dop@,@seg2_fsf_t@,@seg2_fsf_dop@,@seg2_em_t@,@seg2_em_dop@,@seg2_em2_t@,@seg2_em2_dop@,@seg2_ba_t@,@seg2_ba_dop@,@seg1_fsf_t@,@seg1_fsf_dop@,@seg1_em_t@,@seg1_em_dop@,@seg1_em2_t@,@seg1_em2_dop@,@seg1_ba_t@,@seg1_ba_dop@,@substrate_t@,@numSegments@,@EmBaGrad_t@,'@Mat9_Base@',@em_xMole@,@delEgMax@,@delThickMax@,'@eSim_type@',@wfrontc@,@sideS@,@InAlAs_SymPos@,@InAlAs_StdDev@,'@InGaAs_nk@',@del_k@,@InGaAs_tauSRH@,@InGaAs_S@,@InGaAs_Bfactor@,@Rfactor@,@temp@,'@PR@','@OptiToSentaurus@','@s4OptType@',@num_s4opts@,@spectrum@,'@LC@',@Pin@,@Rshunt@,@Rseries@,'@optimizer@','@node|all@'])

