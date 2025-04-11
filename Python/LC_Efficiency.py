#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Tue Feb 28 16:02:47 2023

@author: pwilson3
"""

import numpy as np
import matplotlib
import matplotlib.pyplot as plt
import csv
import numpy as np
import sys
import pandas as pd
import seaborn as sns
import os
# from scipy import interp1d

import matrix_plotter as mplt
import matrix_handler as mh

def get_rad_data(folder, prefix, wl_vals):
    file_list = sorted([file for file in os.listdir(folder) 
                        if file[:len(prefix)] == prefix])
    all_data = pd.DataFrame()
    for (file, wl) in zip(file_list, wl_vals):
        data =  pd.read_csv(os.path.join(folder, file), skiprows = [1])
        data = data.rename(columns = {'Y': 'z (um) (wl = ' + str(wl) + ')',
                               'RadiativeRecombination': 'Radiative Recombination (1/cm^3) (wl = ' + str(wl) + ')'})
        all_data = pd.concat([all_data, data], axis = 1)
    return all_data

def setup_simple_line(fig_num, second_y = True):
    sns.set_theme(style = 'white',font_scale = 1.5, 
                  rc = {"font.size": 20, "lines.linewidth": 2})
    p1 = plt.figure(fig_num)
    ax1 = p1.subplots(1, 1)
    ax1.set_xlabel('Emission location $\mathit{z_A}$ ($\mu$m)')
    ax1.set_ylabel('Efficiency')
    if second_y == True:
        ax2 = ax1.twinx()
        ax2.set_ylabel('Radiative Recombination (cm$^{-3}$)') #TODO: check units
        ax2.set_yscale('log')
        return p1, ax1, ax2
    else:
        return p1, ax1
        
def plot_data(ax1, yA, eff, ax2 = None, z_RadRec = None, RadRec = None):
    colours = sns.color_palette('Set1')
    ax1.plot(yA, eff, c = colours[0] , ls = '-')
    ax1.set_ylim(0.3, 1)
    ax1.set_xlim(0, yA[-1]+0.1)
    if ax2 != None:
        ax2.plot(z_RadRec, abs(RadRec), #TODO: why does this come out negative from Sentaurus sometimes
                 c = colours[1] , ls = '-')
        ax2.set_ylim(10, 5e18)
    
def add_labels(ax1, labels, matrix_class):
    mplt.create_labels(ax1, labels, 
                        [x.lstrip('\t').lstrip(' ') 
                         for x in matrix_class.materials],
                        matrix_class.thicknesses,
                        xbar = True, ybar = False,
                        xbar_anchor = 1.01, ybar_anchor = 0.1, 
                        bar_thickness = 0.01)
    ax1.vlines([sum(matrix_class.thicknesses[:i + 1]) 
                for i in range(len(matrix_class.thicknesses))],
               0.3, 1, colors = 'darkgrey', linestyles = ':')
    
# def data_cleanup(data_set): #TODO: might be more useful to organize dataset by wavelength
#     data_dict = {}
    


# PULL EFFICIENCY DATA FROM LOGFILE -------------------------------------------

folder = '/raidB/pwilson3/STDB/AIIR-Power/1550nm_PPC_Sentaurus/11-2J_Compare_with_Experiment'
LC_filename = '/results/11-2J_comparison_with_experiment_C5246'
LC_logfile = '/LCMatrix_C5246_comparison'

m1 = mh.matrix_handler(folder + LC_filename + '.csv')
eff_vals = m1.yA_efficiency(folder + LC_logfile + '.txt')
yA, eff = zip(*sorted(zip(eff_vals['yA (Emission)'], eff_vals['Efficiency'])))

# PULL RADIATIVE RECOMBINATION DATA FROM SENTAURUS RESULTS FILES---------------

node = 500
Sentaurus_results = os.path.join(folder, 'results', 'nodes', str(node))
wavelengths = np.linspace(1, 1.8, 31)
RadRec_data = get_rad_data(Sentaurus_results, 
                           'n' + str(node) + '_RadiativeRecombination_',
                           wavelengths)

# PLOT EFFICIENCY -------------------------------------------------------------
# TODO: create a plotting file to organize these commands

num_segs = 2
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
colours = sns.color_palette('Set1')

p1, ax1, ax2 = setup_simple_line(1)
plot_data(ax1, yA, eff, ax2, 
          RadRec_data[RadRec_data.columns[0]], 
          RadRec_data[RadRec_data.columns[1]])
add_labels(ax1, custom_labels, m1)




# p1, ax1 = plt.subplots(1, 1)
# ax2 = ax1.twinx()
# ax1.plot(yA, eff, c = colours[0] , ls = '-')
# ax2.plot(RadRec_data[RadRec_data.columns[0]][1:], 
#          abs(RadRec_data[RadRec_data.columns[1]][1:]), #TODO: why does this come out negative from Sentaurus sometimes
#          c = colours[1] , ls = '-')
# mplt.create_labels(ax1, custom_labels, 
#                     [x.lstrip('\t').lstrip(' ') for x in m1.materials],
#                     m1.thicknesses,
#                     xbar = True, ybar = False,
#                     xbar_anchor = 1.01, ybar_anchor = 0.1, 
#                     bar_thickness = 0.01)
# ax1.vlines([sum(m1.thicknesses[:i + 1]) for i in range(len(m1.thicknesses))],
#            0.3, 1, colors = 'darkgrey', linestyles = ':')
# ax1.set_xlabel('Emission location $\mathit{z_A}$ ($\mu$m)')
# ax1.set_ylabel('Efficiency')
# ax2.set_ylabel('Radiative Recombination (cm$^{-3}$)') #TODO: check units
# ax2.set_yscale('log')
# ax1.set_ylim(0.3, 1)
# ax1.set_xlim(0, yA[-1]+0.1)
