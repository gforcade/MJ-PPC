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
import tdr
import plot_manager

colours = matplotlib.rcParams['axes.color_cycle']

# associate colours with materials
matcolordict = {'GaAs' : 0, 'AlGaAs': 1, 'GaInP': 2, 'InGaAsN':3, 'Germanium':4, 'Gold': 5, 'TiOx':6, 'MgF':7, 'InGaAsN': 8, 'AlInP':9}


class plot_def_tdr:
    def __init__(self, tdr, key, color='', linestyle='-', show=True, yscale=1.0, label=''):
        self.tdr = tdr
        self.key = key
        self.show = show
        self.unit = ''
        self.color = color
        self.yscale = yscale
        self.linestyle = linestyle
        if key in tdr.plots:
            self.valid = True
            self.x = tdr.plots[key].x
            self.y = tdr.plots[key].y
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
epi = epifile(sys.argv[2])
tdr = tdr.tdr(sys.argv[1])

print 'Fields in TDR file:'
for i in tdr.plots.keys():
    print i


eV_plots = [
    plot_def_tdr(tdr, 'eQuasiFermiPotential', 'r', '--',  label='$E_{Fn}$'),
    plot_def_tdr(tdr, 'hQuasiFermiPotential', 'b', '--',  label='$E_{Fp}$'),
    plot_def_tdr(tdr, 'ElectrostaticPotential', 'k', '--', show=False, label='$\Phi$'),
    plot_def_tdr(tdr, 'ConductionBandEnergy', 'k', '-', label='$E_C$'),
    plot_def_tdr(tdr, 'ValenceBandEnergy', 'k', '-', label='$E_V$') ]
                
conc_plots = [
    plot_def_tdr(tdr, 'AcceptorConcentration','0.75','--', label='$N_a$'),
    plot_def_tdr(tdr, 'DonorConcentration','0.75','--', label='$N_d$'),
    plot_def_tdr(tdr, 'hDensity',  label='$p$'),
    plot_def_tdr(tdr, 'eDensity', label='$n$'),
    plot_def_tdr(tdr, 'hEffectiveStateDensity', show=False, label='$N_{V,eff}$'),
    plot_def_tdr(tdr, 'eEffectiveStateDensity', show=False, label='$N_{C,eff}$') ]

rate_plots = [
    plot_def_tdr(tdr, 'srhRecombination', label='SRH Rate'),
    plot_def_tdr(tdr, 'RadiativeRecombination', label='Radiative Rate'),
    plot_def_tdr(tdr, 'ePMINonLocalRcombination', label='Luminescent Coupling Rec'),
    plot_def_tdr(tdr, 'AugerRecombination',  label='Auger Rate'),
    plot_def_tdr(tdr, 'OpticalGeneration', label='Optical Generation'),
    plot_def_tdr(tdr, 'tSRHRecombination', label='TAT SRH'),
    plot_def_tdr(tdr, 'eBand2BandGeneration', label='eB2B Generation'),
    plot_def_tdr(tdr, 'hBand2BandGeneration', label='hB2B Generation') ]



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
            bb1 = pat1.get_extents()
            bb2 = t.get_extents()
#            print bb1.width, bb2.height
            if bb2.height*6.0 < bb1.width-2:
                if i.doping < 0:
                    dsign = '$p$ '
                else:
                    dsign = '$n$ '
                self.ax0.text((i.ytop+i.ybot)/2,0.05,i.material + '\n' + dsign +str(abs(i.doping)),rotation='vertical', va='bottom', ha='center', multialignment='left',size=9, clip_on=True)
            elif bb2.height*1.2 < bb1.width-2:
                self.ax0.text((i.ytop+i.ybot)/2,0.05,i.material,rotation='vertical', va='bottom', ha='center',multialignment='left',size=9, clip_on=True)
        self.canvas.draw()

    def initUI(self):

        # Figure and Axes
        self.p1 = Figure(dpi=100)
        gs = matplotlib.gridspec.GridSpec(4,1,height_ratios=[1.75,4,4,4], hspace=0.1)
        self.ax0 = self.p1.add_subplot(gs[0,0])
        self.ax0.xaxis.set_visible(False)
        self.ax0.yaxis.set_visible(False)

        self.ax1 = self.p1.add_subplot(gs[1,0])
        self.ax2 = self.p1.add_subplot(gs[2,0])
        self.ax3 = self.p1.add_subplot(gs[3,0])
        self.canvas = FigureCanvas(self.p1)
        data_vbox = QtGui.QVBoxLayout()


        self.ax1_mgr = plot_manager.plot_manager(data_vbox, self, self.ax1, eV_plots, 'Band Diagram', '', 'Energy [eV]', False, False)
        self.ax2_mgr = plot_manager.plot_manager(data_vbox, self, self.ax2, rate_plots, 'Rate', '', 'Rate [cm$^{-3}$s$^{-1}$]', True, False)
        self.ax3_mgr = plot_manager.plot_manager(data_vbox, self, self.ax3, conc_plots, 'Density', 'Y Position [$\mu$m]', 'Density [cm$^{-3}$]', True, True)
        data_vbox.addStretch(0)
        data_vbox.addWidget(self.init_hscale())
        
        # Canvas and main Hbox

        hbox = QtGui.QHBoxLayout()
        hbox.addLayout(data_vbox)
        hbox.addWidget(self.canvas,100)
        self.setLayout(hbox)    
        self.set_hscale()        
        self.setGeometry(100, 100, 1000, 700)
        self.setWindowTitle('TDR Plot - ' + sys.argv[1])
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
