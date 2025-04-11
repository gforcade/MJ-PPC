# -*- coding: utf-8 -*-
"""
Created on Tue Nov 15 16:20:54 2022

@author: pwilson3
"""

import numpy as np
import matplotlib
import matplotlib.pyplot as plt
import matplotlib.tri as tri
import csv
import numpy as np
import sys
import pandas as pd
import seaborn as sns

import matrix_plotter as mplt
import matrix_handler


# location of matrix file
# folder = 'C:/Users/pwilson3/Documents/AIIR-Power/LC_proj/Sentaurus_LC_files/2JDevices/'
# filename = 'n109_2J_Devices_C5247_prelim_LC'
# folder = 'C:/Users/pwilson3/OneDrive - University of Ottawa/PC_Documents_Backup/AIIR-Power/Matrix_Tests/Preliminary/'
# filename = '5J_LC_Nov4'
# folder = 'C:/Users/pwilson3/OneDrive - University of Ottawa/PC_Documents_Backup/AIIR-Power/LC_proj/Sentaurus_LC_Files/10j_moonshot/'
# filename = '10J_moonshot'
# folder = 'C:/Users/pwilson3/OneDrive - University of Ottawa/PC_Documents_Backup/AIIR-Power/Matrix_Tests/Stability/'
# filename = '5J_LC_Nov23_angle_cutoff_77'
#folder = 'C:/Users/pwilson3/OneDrive - University of Ottawa/PC_Documents_Backup/AIIR-Power/Matrix_Tests/Stability/More_5J_Tests/'
# filename = '5J_Device_test1'
#filename = '5J_Device_test5_removed_large_vw'
folder = '/raidC/gforc034/STDB/AirPower/1550_PPC/MJ_Elec/results/nodes/104/'
filename = 'LC'

# parameters for scaling the data
wtot = 1
num_segs = 10

print('Reading in Matrix...')
# import the matrix with the matrix handler
m1 = matrix_handler.matrix_handler(folder + filename + '.csv')
print('Finished reading in Matrix.')

# fill this in to get custom label names
custom_labels = []
for x in m1.layers:
    if x[-2:] == 'em':
        custom_labels.append('sc' + str(num_segs))
        num_segs -= 1
    # if x[-5:] == 'nplus':
    #     custom_labels.append('td' + str(num_segs))
    #     num_segs -= 1
    # elif x[-5:] == 'pplus':
    #     custom_labels.append('')
    elif x == 'cap':
        custom_labels.append(x)
    elif x =='substrate':
        custom_labels.append('buffer')
    elif x == 'ARC1':
        custom_labels.append('ARC')
    else:
        custom_labels.append(' ')

sns.set_theme(font_scale = 1.5, style = 'white')

#plot data
print("Plotting data")
p1, ax1, ax2 = mplt.setup_simple_plot(1)
mplt.simple_matrix_plot(p1, ax1, ax2,
                        m1.xs + m1.xs2, 
                        m1.ys + m1.ys2, 
                        np.abs(m1.zs*wtot + m1.zs2*wtot)) # multiply by wtot to get reabsorption density (instead of coupling coefficient)
mplt.create_labels(ax1, custom_labels, 
                    [x.lstrip('\t').lstrip(' ') for x in m1.materials],
                    m1.thicknesses)
mplt.create_legend(p1, [x.lstrip('\t').lstrip(' ') for x in m1.materials])

# compare upper and lower halves of the matrix
# create a list of values which compares upper half of matrix to lower half
# sorted_lower = sorted(zip(m1.xs,m1.ys, m1.zs))
# sorted_upper = sorted(zip(m1.ys2, m1.xs2, m1.zs2))
# compare_z = np.array(sorted_lower) - np.array(sorted_upper)

# p2, ax3, ax4 = mplt.setup_simple_plot(2)
# mplt.simple_matrix_plot(p2, ax3, ax4,
#                         m1.xs2,
#                         m1. ys2,
#                         compare_z[:,2],
#                         tick_points = np.linspace(-10, 10, 5))

# mplt.create_labels(ax3, m1.layers, 
#                     [x.lstrip('\t').lstrip(' ') for x in m1.materials],
#                     m1.thicknesses)
# mplt.create_legend(p2, [x.lstrip('\t').lstrip(' ') for x in m1.materials])


plt.show()