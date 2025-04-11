import h5py
import numpy as np
import matplotlib
import math
import sys
from PySide import QtGui, QtCore
from matplotlib.backends.backend_qt4agg import FigureCanvasQTAgg as FigureCanvas
from matplotlib.figure import Figure
import string

# custom modules
from epi_cmd import epifile
import svisual_1d_csv
import plot_manager
import csv

colours = matplotlib.rcParams['axes.color_cycle']
matplotlib.rcParams['font.size'] = 14.0

# associate colours with materials
matcolordict = {'GaAs' : 0, 'AlGaAs': 1, 'GaInP': 2, 'InGaAsN':3, 'Germanium':4, 'Gold': 5, 'TiOx':6, 'MgF':7, 'InGaAsN': 8, 'AlInP':9}


class plot_def_csv:
    def __init__(self, csv, key, color='', linestyle='-', show=True, yscale=1.0, label=''):
        self.csv = csv
        self.key = key
        self.show = show
        self.unit = ''
        self.color = color
        self.yscale = yscale
        self.linestyle = linestyle
        if key in svis.plots:
            self.valid = True
            self.x = csv.x_plot.y
            self.y = csv.plots[key].y
            self.miny = np.min(self.y)
            self.maxy = np.max(self.y)
        else:
            self.valid = False
       
        if len(label) > 0:
            self.label = label
        else:
            self.label = key

    def set_show(self, show):
        self.show = show

# load data from epi and tdr files
epi = epifile(sys.argv[2], layers='layers.csv')
svis = svisual_1d_csv.svis_1d_csv(sys.argv[1])

print 'Fields in CSV file:'
for i in svis.plots.keys():
    print i
svis.set_x_variable('Y')


eV_plots = [
    plot_def_csv(svis, 'ConductionBandEnergy', 'k', '-', label='$\mathit{E_C}$'),
    plot_def_csv(svis, 'eQuasiFermiPotential', 'r', '--',  label='$\mathit{E_{Fn}}$', yscale=-1.),
    plot_def_csv(svis, 'hQuasiFermiPotential', 'b', '--',  label='$\mathit{E_{Fp}}$', yscale=-1.),
    plot_def_csv(svis, 'ValenceBandEnergy', 'k', '-', label='$\mathit{E_V}$') ,
    plot_def_csv(svis, 'ElectrostaticPotential', 'k', '--', show=False, label='$\mathit{-\Phi}$', yscale=-1.) ]

                
conc_plots = [
    plot_def_csv(svis, 'AcceptorConcentration','0.75','--', label='$\mathit{N_A}$'),
    plot_def_csv(svis, 'DonorConcentration','0.75','--', label='$\mathit{N_D}$'),
    plot_def_csv(svis, 'hDensity',  label='$\mathit{p}$'),
    plot_def_csv(svis, 'eDensity', label='$\mathit{n}$'),
    plot_def_csv(svis, 'hEffectiveStateDensity', show=False, label='$\mathit{N_{V,eff}}$'),
    plot_def_csv(svis, 'eEffectiveStateDensity', show=False, label='$\mathit{N_{C,eff}}$') ]

rate_plots = [
    plot_def_csv(svis, 'srhRecombination', label='SRH Rec.'),
    plot_def_csv(svis, 'RadiativeRecombination', label='Radiative Rec.'),
    plot_def_csv(svis, 'PMIeNonLocalRecombination', label='Coupled Gen.', yscale=-1.),
    plot_def_csv(svis, 'AugerRecombination',  label='Auger Rec.'),
    plot_def_csv(svis, 'OpticalGeneration', label='Optical Gen.'),
    plot_def_csv(svis, 'tSRHRecombination', label='TAT SRH'),
    plot_def_csv(svis, 'eBand2BandGeneration', label='eB2B Gen.'),
    plot_def_csv(svis, 'hBand2BandGeneration', label='hB2B Gen.') ]



class ControlPanel(QtGui.QWidget):
    def __init__(self):
        super(ControlPanel, self).__init__()
        self.initUI()

    def reset_hscale(self):
        self.hscale_min_box.setText(str(xmin))
        self.hscale_max_box.setText(str(xmax))
        self.set_hscale()

    def set_hscale(self):
        self.min_x = float(self.hscale_min_box.text())
        self.max_x = float(self.hscale_max_box.text())
        self.ax0.set_xlim((self.min_x, self.max_x))
        self.ax1_mgr.ax.set_xlim((self.min_x, self.max_x))
        self.ax2_mgr.ax.set_xlim((self.min_x, self.max_x))
        self.ax3_mgr.ax.set_xlim((self.min_x, self.max_x))
        
        #redraw layer stack
        self.ax0.clear()
        for i in epi.layers:
            pat1 = matplotlib.patches.Rectangle((i.ytop,0),i.ybot-i.ytop,1, color=colours[matcolordict[i.material]], alpha=0.3)
            self.ax0.add_patch(pat1)
            t = matplotlib.textpath.TextPath((0,0),i.material,rotation='vertical', va='bottom', ha='center',size=9)
            bb2 = t.get_extents()
            if i.doping < 0:
                    dsign = '$p$ '
            else:
                    dsign = '$n$ '
#            self.ax0.text((i.ytop+i.ybot)/2,0.05,i.material + '\n' + dsign +str(abs(i.doping)),rotation='vertical', va='bottom', ha='center', multialignment='left',size=9, clip_on=True)
            self.ax0.annotate(i.label, ((i.ytop+i.ybot)/2, 1), xytext=(i.offset, 10), ha='center', va='bottom', textcoords='offset points',
            arrowprops=dict(arrowstyle='-'), rotation='vertical', fontsize=10.0)
        self.canvas.draw()

    def initUI(self):

        # Figure and Axes
        self.p1 = Figure(dpi=100)
        gs = matplotlib.gridspec.GridSpec(4,1,height_ratios=[0.75,4,4,4], hspace=0.1, left=0.07, right = 0.85 , top=0.92, bottom=0.07)
        self.ax0 = self.p1.add_subplot(gs[0,0])
        self.ax0.xaxis.set_visible(False)
        self.ax0.yaxis.set_visible(False)

        from matplotlib.transforms import Bbox
        box = self.ax0.get_position().get_points()
        print box
        self.ax0.set_position(Bbox(box+ np.array([[0, -0.1/3.], [0,-0.1/3.]] )))
        self.ax1 = self.p1.add_subplot(gs[1,0])
        self.ax2 = self.p1.add_subplot(gs[2,0])
        self.ax3 = self.p1.add_subplot(gs[3,0])
        self.canvas = FigureCanvas(self.p1)
        data_vbox = QtGui.QVBoxLayout()
        from matplotlib.patheffects import Stroke
        for s in self.ax1.spines:
            self.ax0.spines[s].set_path_effects([Stroke(capstyle='round')])
            self.ax1.spines[s].set_path_effects([Stroke(capstyle='round')])
            self.ax2.spines[s].set_path_effects([Stroke(capstyle='round')])
            self.ax3.spines[s].set_path_effects([Stroke(capstyle='round')])


        self.ax1_mgr = plot_manager.plot_manager(data_vbox, self, self.ax1, eV_plots, 'Band Diagram', '', 'Energy [$\mathrm{eV}$]', False, False)
        self.ax2_mgr = plot_manager.plot_manager(data_vbox, self, self.ax2, rate_plots, 'Rate', '', 'Rate [$\mathrm{cm^{-3}s^{-1}}$]', True, False)
        self.ax3_mgr = plot_manager.plot_manager(data_vbox, self, self.ax3, conc_plots, 'Density', 'Y Position [$\mathrm{\mu m}$]', 'Density [$\mathrm{cm^{-3}}$]', True, True)
        data_vbox.addStretch(0)
        data_vbox.addWidget(self.init_hscale())
        
        # Canvas and main Hbox

        hbox = QtGui.QHBoxLayout()
        hbox.addLayout(data_vbox)
        hbox.addWidget(self.canvas,100)
        self.setLayout(hbox)    
        self.set_hscale()        
        self.setGeometry(100, 100, 1000, 700)
        self.setWindowTitle('Svisual 1D Plot - ' + sys.argv[1])
        self.show()

    def init_hscale(self):
        # H Scale Settings
        box = QtGui.QGroupBox()
        vbox = QtGui.QVBoxLayout(box)
        box.setTitle('Horizontal Scale')
        box.setFlat(True)
        hscale_layout = QtGui.QHBoxLayout()
        hscale_layout.addWidget(QtGui.QLabel('Min'))
        self.hscale_min_box = QtGui.QLineEdit()
        self.hscale_min_box.setFixedWidth(70)
        hscale_layout.addWidget(self.hscale_min_box)
        hscale_layout.addWidget(QtGui.QLabel('Max'))
        self.hscale_max_box = QtGui.QLineEdit()
        hscale_layout.addWidget(self.hscale_max_box)
        self.hscale_max_box.setFixedWidth(70)   
        vbox.addLayout(hscale_layout)
        self.hscale_apply_button = QtGui.QPushButton('Apply')
        self.hscale_reset_button = QtGui.QPushButton('Zoom Full')
        vbox.addWidget(self.hscale_apply_button)
        vbox.addWidget(self.hscale_reset_button)
        (self.xmin, self.xmax) = self.ax1.get_xlim()
        self.hscale_max_box.setText(str(self.xmax))
        self.hscale_min_box.setText(str(self.xmin))
        self.hscale_min_box.returnPressed.connect(self.hscale_max_box.setFocus)
        self.hscale_max_box.returnPressed.connect(self.hscale_apply_button.clicked)
        self.hscale_apply_button.clicked.connect(self.set_hscale)
        self.hscale_reset_button.clicked.connect(self.reset_hscale)
        return box


def main():
    app = QtGui.QApplication(sys.argv)

    ex = ControlPanel()
    sys.exit(app.exec_())

if __name__ == '__main__':
    main()
