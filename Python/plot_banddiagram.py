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
import dfise
import plot_manager

colours = matplotlib.rcParams['axes.color_cycle']

# associate colours with materials
matcolordict = {'GaAs' : 0, 'AlGaAs': 1, 'GaInP': 2, 'InGaAsN':3, 'Germanium':4, 'Gold': 5, 'pSilicon': 6, 'Silicon': 7, 'AlInP': 8, 'Aluminum': 9, 'TiOx': 0, 'MgF': 1}


def me(n, sigfigs = 1): 
    s = ('%.'+'%ie' % sigfigs) % n # check docs for a better way? 
    if 'e' in s:
        m, e = s.split('e') 
    return m, e.lstrip('+') 

class plot_def_dfise:
    def __init__(self, dfise, key, color='', linestyle='-', show=True, yscale=1.0, label=''):
        self.dfise = dfise
        self.key = key
        self.show = show
        self.unit = ''
        self.color = color
        self.yscale = yscale
        self.linestyle = linestyle
        self.x_key = 'Default Y [um]'
        
        if key in self.dfise.data:        
            self.valid = True
            self.x = self.dfise.data[self.x_key]
            self.y = self.dfise.data[self.key]
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
dfise = dfise.dfise(sys.argv[1])

print 'Fields in DFISE file:'
for i in dfise.data.keys():
    print i


eV_plots = [
    plot_def_dfise(dfise, 'Default eQuasiFermiPotential [V]', 'r', '--',  label='$E_{Fn}$'),
    plot_def_dfise(dfise, 'Default hQuasiFermiPotential [V]', 'b', '--',  label='$E_{Fp}$'),
    plot_def_dfise(dfise, 'Default ElectrostaticPotential [V]', 'k', '--', show=False, label='$\Phi$'),
    plot_def_dfise(dfise, 'Default ConductionBandEnergy [eV]', 'k', '-', label='$E_C$'),
    plot_def_dfise(dfise, 'Default ValenceBandEnergy [eV]', 'k', '-', label='$E_V$'),
    plot_def_dfise(dfise, 'Default EffectiveBandGap [eV]', 'k', '-', show=False, label='$E_{g,eff}$') ]
                
conc_plots = [
    plot_def_dfise(dfise, 'Default AcceptorConcentration [cm^-3]','0.75','--', label='$N_a$'),
    plot_def_dfise(dfise, 'Default DonorConcentration [cm^-3]','0.75','--', label='$N_d$'),
    plot_def_dfise(dfise, 'Default hDensity [cm^-3]',  label='$p$'),
    plot_def_dfise(dfise, 'Default eDensity [cm^-3]', label='$n$'),
    plot_def_dfise(dfise, 'Default hEffectiveStateDensity [cm^-3]', show=False, label='$N_{V,eff}$'),
    plot_def_dfise(dfise, 'Default eEffectiveStateDensity [cm^-3]', show=False, label='$N_{C,eff}$') ]

rate_plots = [
    plot_def_dfise(dfise, 'Default srhRecombination [cm^-3*s^-1]', label='SRH Rate'),
    plot_def_dfise(dfise, 'Default RadiativeRecombination [cm^-3*s^-1]', label='Radiative Rate'),
    plot_def_dfise(dfise, 'Default AugerRecombination [cm^-3*s^-1]',  label='Auger Rate'),
    plot_def_dfise(dfise, 'Default OpticalGeneration [cm^-3*s^-1]', label='Optical Generation'),
    plot_def_dfise(dfise, 'Default tSRHRecombination [cm^-3*s^-1]', label='TAT SRH'),
    plot_def_dfise(dfise, 'Default eBand2BandGeneration [cm^-3*s^-1]','0.0', 'steps', label='eB2B Generation'),
    plot_def_dfise(dfise, 'Default hBand2BandGeneration [cm^-3*s^-1]', '0.0', 'steps', label='hB2B Generation'),
    plot_def_dfise(dfise, 'Default eBarrierTunneling [cm^-3*s^-1]','r',  label='eBarrier Tunneling'),
    plot_def_dfise(dfise, 'Default hBarrierTunneling [cm^-3*s^-1]', 'r',label='hBarrier Tunneling')]



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
        
        #redraw layer stack
        self.ax0.clear()
        for i in epi.layers:
            if i.material == 'InGaAsN':
                label = i.material + '\n' +'$E_g$=0.92 eV'
            else:
                label = i.material
            pat1 = matplotlib.patches.Rectangle((i.ytop,0),i.ybot-i.ytop,1, color=colours[matcolordict[i.material]], alpha=0.3)
            self.ax0.add_patch(pat1)
            t = matplotlib.textpath.TextPath((0,0),label,rotation='vertical', va='bottom', ha='center',size=12)
            bb1 = pat1.get_extents()
            bb2 = t.get_extents()
#            print bb1.width, bb2.height
            if bb2.height*6.0 < bb1.width-2:
                if i.doping < 0:
                    dsign = '$p\/'
                    (dfloat,dexp) = me(-i.doping)
                else:
                    dsign = '$n\/'
                    (dfloat,dexp) = me(i.doping)
                dstring = dsign + str(dfloat) + '\\times 10^{' + str(dexp) + '}$'
#                self.ax0.text((i.ytop+i.ybot)/2,0.05,label + '\n' + dstring,rotation='vertical', va='bottom', ha='center', multialignment='left',size=10, clip_on=True)
 #           elif bb2.height*1.2 < bb1.width-2:
            self.ax0.text((i.ytop+i.ybot)/2,0.05,label,rotation='vertical', va='bottom', ha='center',multialignment='left',size=12, clip_on=True)
            if i.material == 'Germanium':
                self.ax0.text(i.ytop+0.5,0.05,label,rotation='vertical', va='bottom', ha='center',multialignment='left',size=12, clip_on=True)
        self.canvas.draw()

    def initUI(self):

        # Figure and Axes
        self.p1 = Figure(dpi=100)
#        gs = matplotlib.gridspec.GridSpec(4,1,height_ratios=[1.75,4,4,4], hspace=0.1)
        gs = matplotlib.gridspec.GridSpec(2,1,height_ratios=[1.2,5], hspace=0.03, left=0.1, right=0.95, top=0.95, bottom=0.1)
        self.ax0 = self.p1.add_subplot(gs[0,0])
        self.ax1 = self.p1.add_subplot(gs[1,0])
        self.ax0.xaxis.set_visible(False)
        self.ax0.yaxis.set_visible(False)

        self.canvas = FigureCanvas(self.p1)
        data_vbox = QtGui.QVBoxLayout()


        self.ax1_mgr = plot_manager.plot_manager(data_vbox, self, self.ax1, eV_plots, 'Band Diagram', 'Y Position [$\mathrm{\mu m}$]', 'Energy [eV]', False, True)

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
        self.hscale_min_box.returnPressed.connect(self.hscale_max_box.selectAll)        
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
