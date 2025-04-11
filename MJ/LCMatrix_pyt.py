#!/usr/bin/python
#setdep @node|MatPar@

if "@LC@" == "on":

	import os, sys

	### path to custom python files
	## use these paths for running outside of Sentuarus
	#sys.path.append(os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', 'Python'))
	#sys.path.append(os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', 'Python', 'tmm'))
	## use these paths for running inside Sentaurus
	sys.path.append(os.path.join('@pwd@', '..', 'Python'))#### alter if running outside of Sentaurus
	sys.path.append(os.path.join('@pwd@', '..', 'Python', 'tmm')) #### alter if running outside of Sentaurus
	#sys.path.append("raidC/$USER/STDB/AIIR-POWER/1550nm_PPC_Sentaurus/Python/tmm")
	import tdr
	import h5py
	import pyximport; pyximport.install()
	import epi_cmd_LC
	from scipy.integrate import trapz
	import numpy as np
	import csv
	import datetime
	import math
	import tmm.tmm_core_mw as tmm
	import matrix_plotter as mplt
	import matplotlib.pyplot as plt

	from multiprocessing import Pool, Lock, Queue

	##suppress print statements
#sys.stdout = open(os.devnull, 'w')

	# these variables are substituted by the sentaurus preprocessor when the script is run through Sentaurus Workbench.
	LC_node = @node|LCMatrix@#### alter if running outside of Sentaurus
	epi_node = @node|epi@ #27
	sde_node = @node|sde@ #31
	MatPar_node = @node|MatPar@ #38
	wtot = float(@wtot@) #1.0
	substrate_t = @substrate_t@
	num_segs = int(@numSegments@)

	#specify the name of the file and path to be written
	LC_filepath = '@pwd@/results/nodes/@node|LCMatrix@/' + 'LC.csv'

	#back_mat = "back_mat"
	if substrate_t == 0.0: # when substrate_t is set to 0 the model assumes a flat gold backreflector 
		back_mat = ["Gold"]
		back_mat_thickness = [1] # last layer thickness will be set to inf
	else:
		back_mat = ["InP"]
		back_mat_thickness = [1] # last layer thickness will be set to inf
	material_files = {'Gold': 'Gold.par', 'InP': 'InP.tcl', 'Air': None}
	material_files_list = [material_files[x] for x in back_mat]
		
	# This functions does coupling calculation for emissions from a single layer.Multiple
	# threads are spawned, each processing one layer.%
#%%
	def process_layer(li):
			# Calculate coupling for emission layer li
			print( "* Processing layer {0}. {1} y-values.".format(e.layers[li].name, len(e.layers[li].yvalues)))
			# due to the threading, always flush after printing to ensure output appears in correct sequence.
			sys.stdout.flush()
	
			if e.layers[li].material_type == 'Semiconductor':
				yi_list = e.layers[li].yvalues
				E_list = e.layers[li].E_list


				# P_list will contain a list of tuples (yA, yB, P) for emission from li at yA and
				# absorption in each layer lk at yB
				# Pint_list contains only the P values for integration.
				P_list = []
				Pint_list = []
				for lk in range(len(e.layers)):
					P_list.append([])
					Pint_list.append([])

				P_arr = np.zeros((len(e.layers), len(yi_list)) )
				Ps = np.zeros(len(e.layers))
				new_n_list = n_list.copy()

				# set up storage to solutions to TMM calculations.
				for z in range(len(yi_list)):
					yA = yi_list[z]
					data_list_TE = []
					data_list_TM = []
					for a in E_list:
						data_list_TE.append([tmm.Tmm_data_internalsource()]*(len(th_list)-1))
						data_list_TM.append([tmm.Tmm_data_internalsource()]*(len(th_list)-1))

					yA0 = yA - e.layers[li].ytop

					# Build TMM solutions at yA
					layer_flags = np.zeros(len(e.layers), dtype=int)
					# iterate over energy values near the emitting layer band gap
					for E_i in range(len(E_list)):
						E = E_list[E_i]
						wl = e.layers[li].wl_list[E_i] # in um
						for i in range(len(e.layers)):
							new_n_list[i+1] = e.layers[i].nk(wl)
						# set semi-infinite layer at theof the stack same as last finite layer.
				 		# set the semi-infinite layer at the bottom of the stack to be the same as the substrate pwils
						for i in range(len(e.backlayers)):
							if e.backlayers[i].material != 'Air':
								new_n_list[len(e.layers) + 1 + i] = e.backlayers[i].nk(wl) #e.bottom_mat.nk(wl)
							else:
								new_n_list[len(e.layers) + 1 + i] = 1. + 0j # nk for Air/Vacuum
						#print('##############new_n_list:', new_n_list, '@ wl = ', wl)
						# iterate over polar emission angles
						for th_i in range(len(th_list)-1):
							th = th_list[th_i]
							# print(th)
							# generate TMM solutions for TE and TM polarizations
							data_list_TE[E_i][th_i] = tmm.coh_tmm_internalsource(tmm.TE, new_n_list.copy(), d_list, li, yA0, th, wl)
							data_list_TM[E_i][th_i] = tmm.coh_tmm_internalsource(tmm.TM, new_n_list.copy(), d_list, li, yA0, th, wl)
							# flag layers with non-negligible power entering from the source.
							for i in range(len(e.layers)):
								layer_flags[i] = 1
								# if tmm.check_layer(i, data_list_TE[E_i][th_i], data_list_TM[E_i][th_i]): # turn this back on in an attempt to correct fields blowing up -pwils
								#	layer_flags[i] = 1
								# else:
								#	print('/n***Layer flag not set - calculation will be skipped') # if True, consider this layer; if False, fields entering the layer are small enough to be ignored and P is set to 0 in the block below this

					# now use TMM solutions to find absorption at specific locations yB.
					# iterate over absorption layer lk
					for lk in range(len(e.layers)): #[0] #!!!
						if e.layers[lk].material_type == 'Semiconductor':
							yk_list = e.layers[lk].yvalues
							Pint_list = np.zeros(len(yk_list))
							for k in range(len(yk_list)):
							 yB = yk_list[k]
							 if layer_flags[lk] == 1:
								 yB0 = yB - e.layers[lk].ytop
								 P = epi_cmd_LC.calc_a(li, lk, yA, yB, data_list_TE, data_list_TM, e)/ (2.0*wtot)
								 if P < -1e-10:
										print('Negative Coupling value, li=', li, ' lk=', lk)
										print( data_list_TE )
										print( data_list_TM)
										raise ValueError
								 P_list[lk].append((yA, yB, P))
								 Pint_list[k] = P
							 else:
								 P_list[lk].append((yA, yB, 0.))
								 Pint_list[k] = 0.
							P = trapz(Pint_list, x=yk_list)
							P_arr[lk,z] = P*wtot

					print(' {0: <10} {1: 3d}/{2: 3d}	 yA={3} Eff={4:.4f}'.format(e.layers[li].name, z+1, len(yi_list), yA, sum(P_arr[:,z])))
					sys.stdout.flush()


				# integrated coupling between 2 layers
				print( '.')
				for lk in range(len(e.layers)):
					 Ps[lk] = trapz(P_arr[lk,:], x=yi_list)/e.layers[li].thickness
				print('.')
				sys.stdout.flush()
				# after completing all calculations for emission from layer li, we acquire the file lock
				# and write to the output file.
				print('* Writing Output from {0}.Total coupling efficiency: {1:.4f}'.format(e.layers[li].name, sum(Ps)))
				sys.stdout.flush()
				fileLock.acquire()
				for lk in range(len(e.layers)):
						outwriter.writerow(['**', li, e.layers[li].name, lk, e.layers[lk].name, Ps[lk] ])
						for i in range(len(P_list[lk])):
							tu = P_list[lk][i]
							outwriter.writerow([tu[0], tu[1], tu[2]])
						outfile.flush()
				fileLock.release()
			return True
#%%
	### first check if an LCMatrix is already available
	if os.path.isfile(LC_filepath):
		#pass
		print("*** LCMatrix file already exists, skipping calculation ***")

	else:
		starttime = datetime.datetime.now()
		print('***')
		print('*** LCMatrix - Compute optical coupling between layers in a multilayer stack ')
		print('*** started at ', starttime)
		print('***' )

		# Open an epi file and read the layer stack - materials, thicknesses etc.
	 # e = epi_cmd_LC.epifile('results/nodes/' + str(epi_node) + '/pp'+ str(epi_node) + '_epi.cmd') #### alter if running outside of Sentaurus
		e = epi_cmd_LC.epifile('@pwd@' + '/results/nodes/' + str(epi_node) + '/pp'+ str(epi_node) + '_epi.cmd') #### alter if running outside of Sentaurus
		#e.bottom_material(back_mat[0], material_files[back_mat[0]], 0.555) # takes material, material file, thickness, and optional doping and molefraction; re-added this function -pwils
		e.bottom_material(back_mat, material_files_list, back_mat_thickness)
				# Add MatPar data to each layer
		# including n,k vs. wavelength and B_rad
		#e.read_parfiles('results/nodes/' + str(MatPar_node) + '/n' + str(MatPar_node) + '_mpr.par') #### alter if running outside of Sentaurus
		e.read_parfiles('@pwd@' +'/results/nodes/' + str(MatPar_node) + '/n' + str(MatPar_node) + '_mpr.par') #### alter if running outside of Sentaurus

		# creates e.layer.yvalues, a dict indexed by yposition of vertices, by reading the mesh file.
		#e.get_layer_vertices('results/nodes/' + str(sde_node) + '/n' + str(sde_node) + '_msh.tdr') #### alter if running outside of Sentaurus
		e.get_layer_vertices('@pwd@' + '/results/nodes/' + str(sde_node) + '/n' + str(sde_node) + '_msh.tdr') #### alter if running outside of Sentaurus
		sys.stdout.flush()

		print('')


		# Open output file for writing.
		#withopen('@pwd@' + '/results/nodes/' + str(JV_node) + '/n' + str(JV_node) + '_LC.csv', 'w') as outfile: #altered to write as text for the time being pwils
		with open(LC_filepath, 'w') as outfile:
				outwriter = csv.writer(outfile, delimiter=',', quotechar='"', quoting=csv.QUOTE_MINIMAL)

				# write the header
				outwriter.writerow(['#'])
				outwriter.writerow(['# Output from LCMatrix ' + datetime.datetime.now().strftime("%B %d, %Y at %I:%M%p")] )
				outwriter.writerow(['# device width = ' + str(wtot) + ' um'])
				outwriter.writerow(['#'])

				# Write Radiative Recombination coeffcients to the output file.
				if __name__ == '__main__':
						for lk in range(len(e.layers)):
								outwriter.writerow(['Brad', e.layers[lk].name, e.layers[lk].material, e.layers[lk].Brad, e.layers[lk].thickness ])

				print('\n*** Computing Optical Coupling:')

				# set up lists for TMM calc.n_list will be calculated per E value.The lists include the semi-infinite media
				# on either side of the layer stack.Air on top, same material as last layer on the bottom.
				n_list = np.zeros((len(e.layers)+1+len(back_mat)), dtype=complex) # +1 semi-inf front layer, + number of back layers (most bottom one will be semi-inf)
				d_list = np.zeros((len(e.layers)+1+len(back_mat)), dtype=np.float64)
				n_list[0] = 1.0+0j
				d_list[0] = tmm.inf
				for i in range(len(e.layers)):
					d_list[i+1] = e.layers[i].thickness
				for i in range(len(e.backlayers)):
					d_list[len(e.layers) +1 + i] = e.backlayers[i].thickness # changes to backmt -pwils
				d_list[-1] = tmm.inf #whatever last backlayer thickness is will be overwritten
				n_list[-1] = 1.0+0j # this will be adjusted later in new_n_list

				th_list = e.theta_list
				sin_th_list = np.sin(th_list)

				# Now set up for multiprocessing and execute the parallel calculation.
				# Make a lock for the output file so only one process can work on it at a time.

				# flush write buffer to file _before_ forking -- otherwise we fork the buffer contents and get repeated lines in the file.
				outfile.flush()

				# sub-processes must acquire the lock before writing to the output file, then release it.This way only one sub-process writes
				# to file at any time.
				fileLock =Lock()

				# Define a pool of processes for parallel processing of the LCMatrix calculation.This will create as many
				# worker processes as there are processors in the machine.
				# For debugging, it could be useful to use Pool(1).Then only one worker process is created
				# and the calculation is done sequentially.The main process forks at this point, so all sub-processes start
				# with the same state as the main process at this point.
				numPool = int((os.cpu_count() - os.getloadavg()[0])/@experiments:last@) #uses every cpu that is available (since the last minute)
				if numPool <= 0:
					numPool = 1
				pool = Pool(numPool)

				res = []
				# submit jobs to the process pool.Each job calculates luminescent coupling of emissions from
				# one layer in the stack into all other layers and writes the results to file.Results for job i will be avaialble
				# in res[i] once the job is finished.

				# we sort the jobs before submiting them to the queue so that layers with the most y-values are processed first.This should lead
				# to more even distribution of work across the processors and shorter overall run time. (i.e. we avoid a situation where all processes have finished
				# except one thread which processes all y-values in a thick substrate.)

				# sort jobs by number of y-values
				job_list = []
				print( len(e.layers))
				for m in range(len(e.layers)):
						job_list.append( (m, len(e.layers[m].yvalues)))
				job_list.sort(key=lambda tup: tup[1], reverse=True)

				# submit jobs to queue
				for tup in job_list:
						# queue up calls to the process_layer() function, one for each layer.
						res.append( pool.apply_async(process_layer, [tup[0]]) )

				# Wait until all jobs have finished, then close the pool so no new jobs can be submitted, and stop all sub-processes.
				for r in res:
						r.wait()
						try:
								r.get()
						except IndexError:
								print('IndexError')
				pool.close()
				pool.join()

				# ... and we're done.
				endtime = datetime.datetime.now()
				print( '\n***')
				print( '*** LCMatrix Finshed at', endtime)
				print( '*** Runtime: ', (endtime-starttime))
				print( '***')







