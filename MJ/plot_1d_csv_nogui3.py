# hint:  python plot_1d_csv_nogui.py n1270_1ddata.csv n1246_1ddata.csv pp119_epi.cmd

import h5py
import numpy as np
import matplotlib
import math
import sys
import matplotlib.pyplot as plt
import string
import brewer2mpl

# custom modules
from epi_cmd import epifile
import svisual_1d_csv
import csv

matplotlib.rcParams['figure.facecolor'] = 'white'
colours = matplotlib.rcParams['axes.color_cycle']
print colours
# Nature's max font size = 7 pt.
matplotlib.rcParams['font.size'] = 7.0
#matplotlib.rcParams['text.usetex'] = False
# matplotlib.rcParams['mathtext.default'] = 'regular'

matplotlib.rcParams['axes.linewidth'] = 0.25
matplotlib.rcParams['lines.linewidth'] = 0.5
if 'xtick.major.width' in matplotlib.rcParams.keys():
	matplotlib.rcParams['xtick.major.width'] = 0.25
	matplotlib.rcParams['ytick.major.width'] = 0.25
	matplotlib.rcParams['xtick.minor.width'] = 0.25
	matplotlib.rcParams['ytick.minor.width'] = 0.25
#	matplotlib.rcParams['ytick.color'] = '0.25'
#	matplotlib.rcParams['xtick.color'] = '0.25'
#	matplotlib.rcParams['grid.color'] = '0.5'
	

# Nature single column figure width = 89 mm (3.5 inches),  double column = 183 mm.
matplotlib.rcParams['figure.figsize'] = [183./25.4,14]
matplotlib.rcParams['figure.dpi'] = 150

matplotlib.rcParams['figure.subplot.left'] = 0.09
matplotlib.rcParams['figure.subplot.right'] = 0.85
matplotlib.rcParams['figure.subplot.top'] = 0.99
matplotlib.rcParams['figure.subplot.bottom'] = 0.09
matplotlib.rcParams['figure.subplot.hspace'] = 0.18
matplotlib.rcParams['savefig.dpi'] = 150

# associate colours with materials
matcolordict = {'GaAs' : 0, 'AlGaAs': 1, 'GaInP': 2, 'InGaAsN':3, 'Germanium':4, 'Gold': 5, 'TiOx':6, 'MgF':6, 'InGaAsN': 8, 'AlInP':3, 'AlOx':6, 'AlGaInP':6, 'MQW_eff': 6}


def plot_from_csv( ax, csv, key, color='k', linestyle='-', dashes=(None,None),yscale=1.0, label=''):
        x = csv.x_plot.y
        y = csv.plots[key].y*yscale
       
        if len(label) == 0:
            self.label = key      
	ax.plot(x,y, color=color, linestyle=linestyle, dashes=dashes, label=label)

def plot_netgen(ax, csv, color='k', linestyle='-', dashes=(None,None),yscale=1.0, label=''):
        x = csv.x_plot.y
        y1 = csv.plots['RadiativeRecombination'].y*yscale
        y2 = csv.plots['PMIeNonLocalRecombination'].y*yscale
       
        if len(label) == 0:
            self.label = key      
	ax.plot(x-1.0,-y1-y2, color=color, linestyle=linestyle, dashes=dashes, label=label)



# load data from epi and tdr files
epi = epifile(sys.argv[2], layers='layers.csv')

svis = svisual_1d_csv.svis_1d_csv(sys.argv[1])


print 'Fields in CSV file:'
for i in svis.plots.keys():
    print i
svis.set_x_variable('Y')


class Plots:
    def __init__(self):
        # Figure and Axes
        self.p1 = plt.figure(figsize=(7,3.5))
        gs = matplotlib.gridspec.GridSpec(3,1,height_ratios=[0.25,5,5])
        self.ax0 = self.p1.add_subplot(gs[0,0])

        from matplotlib.transforms import Bbox
        box = self.ax0.get_position().get_points()
        self.ax0.set_position(Bbox(box+ np.array([[0, -0.2/3.], [0,-0.2/3.]] )))
        self.ax1 = self.p1.add_subplot(gs[1,0])
        self.ax2 = self.p1.add_subplot(gs[2,0])


        self.ax0.xaxis.set_visible(False)
        self.ax0.yaxis.set_visible(False)
     #   self.ax1.set_xticklabels([])

        from matplotlib.patheffects import Stroke
        for s in self.ax1.spines:
            self.ax0.spines[s].set_path_effects([Stroke(capstyle='round')])
            self.ax1.spines[s].set_path_effects([Stroke(capstyle='round')])

	self.min_x = 0.
	self.max_x = 8.

    def set_hscale(self):

        layers = ['bs1_em', 'bs2_em', 'bs3_em', 'bs4_em', 'bs5_em']
        labels = ['J1', 'J2', 'J3', 'J4', 'J5']
        self.ax0.set_xlim((self.min_x, self.max_x))
        self.ax1.set_xlim((self.min_x, self.max_x))
        self.ax2.set_xlim((self.min_x, self.max_x))

        ylim1 = self.ax1.get_ylim()

        
        #redraw layer stack
        self.ax0.clear()
#        self.ax1.clear()
#        self.ax2.clear()
        for i in epi.layers:
            pat0 = matplotlib.patches.Rectangle((i.ytop,0),i.ybot-i.ytop,1, color=colours[matcolordict[i.material]], alpha=0.6)
            pat1 = matplotlib.patches.Rectangle((i.ytop,ylim1[0]),i.ybot-i.ytop,ylim1[1]-ylim1[0], color=colours[matcolordict[i.material]], alpha=0.1)
            
            self.ax0.add_patch(pat0)
            self.ax1.add_patch(pat1)
            
            if i.name in layers:
                    index = layers.index(i.name)
                    l = labels[index]
                    #self.ax0.annotate(l, (i.ybot -1., 1), xytext=(i.offset, 10), ha='center', va='bottom', textcoords='offset points',
                    #arrowprops=dict(arrowstyle='-'), rotation='vertical')
                    self.ax0.text(i.ybot -1., 1.05, l, ha='center', va='bottom')

def main():
	plots = Plots()
	plots.min_x = 0
	plots.max_x = 3.25

	plots.ax1.set_xlabel(r'position Z (\textmu m)')

        rec_color = 'b'

	plot_from_csv(plots.ax1, svis, 'ConductionBandEnergy', 'k', '-', label='$\mathit{E_\mathrm{C}}$')
	plot_from_csv(plots.ax1, svis, 'eQuasiFermiPotential', 'r', dashes=(5,2),  label='$\mathit{E_\mathrm{Fn}}$', yscale=-1.)
	plot_from_csv(plots.ax1, svis, 'hQuasiFermiPotential', 'b', dashes=(5,2),  label='$\mathit{E_\mathrm{Fp}}$', yscale=-1.)
	plot_from_csv(plots.ax1, svis, 'ValenceBandEnergy', 'k', '-', label='$\mathit{E_\mathrm{V}}$') 

	plot_from_csv(plots.ax2, svis, 'srhRecombination', color=rec_color, dashes=(5,2), label='SRH Rec.')
	plot_from_csv(plots.ax2, svis, 'RadiativeRecombination', color=rec_color,  label='Radiative Rec.')
	plot_from_csv(plots.ax2, svis, 'AugerRecombination',  color=rec_color, dashes=(1,1), label='Auger Rec.')
	plot_from_csv(plots.ax2, svis, 'OpticalGeneration',  color='k', label='External Gen.')


	if 'PMIeNonLocalRecombination' in svis.plots.keys():
		plot_from_csv(plots.ax2, svis, 'PMIeNonLocalRecombination', color='k', dashes=(2,2), label='Coupled Gen.', yscale=-1.)

	plots.ax1.legend(bbox_to_anchor=(1,0.9), loc='upper left', frameon=False)
	plots.ax2.legend(bbox_to_anchor=(1,0.9), loc='upper left', frameon=False)
	
	plots.set_hscale()

	plots.ax1.set_ylabel(r'\centering Energy\\(eV)\\')

	ticks = plots.ax1.yaxis.get_ticklines()
        ticks[0].set_visible(False)
        ticks[-1].set_visible(False)

	ticks = plots.ax1.xaxis.get_ticklines()
        ticks[0].set_visible(False)
        ticks[-1].set_visible(False)
   
	plt.show()

if __name__ == '__main__':
    main()
