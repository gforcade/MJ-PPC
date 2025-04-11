#setdep @node|LCMatrix@

import os, sys
sys.path.append(os.path.join('@pwd@', '..', 'Python', 'tmm')) 
sys.path.append(os.path.join('@pwd@', '..', 'Python'))

import pyximport; pyximport.install()
import matrix_plotter as mplt
import matplotlib.pyplot as plt
import epi_cmd_LC

LC_node = @node|LCMatrix@
epi_node = @node|epi@ 
MatPar_node = @node|MatPar@ 
wtot = float(@wtot@) 
num_segs = int(@numSegments@)


#%%
#Plot LC matrix
mplt.plot_LCMatrix('@pwd@/results/nodes/' + str(LC_node) + '/' , 'LC',num_segs,wtot)
plt.tight_layout()
plt.savefig('LC_fig.png')


## plot nk data
e = epi_cmd_LC.epifile('@pwd@' + '/results/nodes/' + str(epi_node) + '/pp'+ str(epi_node) + '_epi.cmd')
e.read_parfiles('@pwd@' +'/results/nodes/' + str(MatPar_node) + '/n' + str(MatPar_node) + '_mpr.par') 
mplt.plot_nkData(e)
plt.savefig('LC_nk.png')
