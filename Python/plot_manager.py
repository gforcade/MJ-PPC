from PySide import QtGui, QtCore
import matplotlib
import string

class plot_manager:
    def __init__(self, parent, ui, ax, plots, plottitle, xtitle, ytitle, logscale, ticklabels):

        # class to handle a subplot and related controls
        self.plots = plots
        self.ax = ax
        self.parent = parent
        self.xtitle = xtitle
        self.ytitle = ytitle
        self.logscale = logscale
        self.ticklabels = ticklabels
        self.ui = ui
        
        # create controls
        qgroupbox = QtGui.QGroupBox()
#        qgroupbox.setLineWidth(2)
        qgroupbox.setTitle(plottitle)
        qgroupbox.setFlat(True)
        vbox =QtGui.QVBoxLayout(qgroupbox)
        hbox = QtGui.QHBoxLayout()
        
        self.logscale_checkbox = QtGui.QCheckBox('Log Scale')
        if self.logscale:
            self.ax.set_yscale('log')
            self.logscale_checkbox.setCheckState(QtCore.Qt.Checked)   
        vbox.addWidget(self.logscale_checkbox)
        self.logscale_checkbox.stateChanged.connect(self.logscale_state)
        self.logscale_checkbox.stateChanged.connect(self.ui.canvas.draw)
        
        self.scalemin = QtGui.QLineEdit('0')
        self.scalemax = QtGui.QLineEdit('0')
        self.scalemin.setFixedWidth(70)
        self.scalemax.setFixedWidth(70)        
        self.scale_apply = QtGui.QPushButton('Apply')
        self.scale_reset = QtGui.QPushButton('Zoom Full')
        vbox1 = QtGui.QVBoxLayout()
        vbox2 = QtGui.QVBoxLayout()
        vbox3 = QtGui.QVBoxLayout()        

        vbox1.addWidget(QtGui.QLabel('Max'))
        vbox2.addWidget(self.scalemax)
        vbox1.addWidget(QtGui.QLabel('Min'))        
        vbox2.addWidget(self.scalemin)
        vbox3.addWidget(self.scale_apply)
        self.scale_apply.clicked.connect(self.set_yscale)
        self.scale_apply.clicked.connect(self.ui.canvas.draw)        
        vbox3.addWidget(self.scale_reset)
        self.scalemax.returnPressed.connect(self.scalemin.setFocus)
        self.scalemax.returnPressed.connect(self.scalemin.selectAll)        
        self.scalemin.returnPressed.connect(self.scale_apply.clicked)
        self.scale_reset.clicked.connect(self.reset_yscale)
        self.scale_reset.clicked.connect(self.ui.canvas.draw)        

        hbox.addLayout(vbox1)
        hbox.addLayout(vbox2)
        hbox.addStretch(10)
        hbox.addLayout(vbox3)
        vbox.addLayout(hbox)

        parent.addWidget(qgroupbox)

        for i in range(len(plots)):
            if plots[i].valid:
                print 'valid', plots[i].label
                box = QtGui.QCheckBox(string.join(plots[i].label.strip("{}\\$").split('{'),sep=''))
                if plots[i].show:
                    box.setCheckState(QtCore.Qt.Checked)
                box.stateChanged.connect(plots[i].set_show)
                box.stateChanged.connect(self.redraw)
                vbox.addWidget(box)
            else:
                print 'invalid', plots[i].label
        vbox.addWidget(QtGui.QLabel(''))

        self.add_plots()
        self.set_axes()      

    def add_plots(self):
            self.ax.cla()
            for i in self.plots:
                if i.show and i.valid:
                    if i.color == '':
                        self.ax.plot(i.x,i.yscale*i.y, linestyle = i.linestyle, linewidth=1.5, label=i.label)
                    else:
                        self.ax.plot(i.x,i.yscale*i.y, color = i.color, linestyle = i.linestyle, linewidth=1.5, label=i.label)
            legend = self.ax.legend(bbox_to_anchor=(1.00, 1), loc=2, borderaxespad=0.)
#            legend.draggable(True)

    def set_axes(self):
        if self.ticklabels == False:
            self.ax.set_xticklabels([])
        self.ax.set_xlabel(self.xtitle)
        self.ax.set_ylabel(self.ytitle)
        self.logscale_state(self.logscale)
        (self.ymin, self.ymax) = self.ax.get_ylim()
        self.scalemax.setText(str(self.ymax))
        self.scalemin.setText(str(self.ymin))
#        self.ax.set_xlim(self.parent.min_x, self.parent.max_x)

    def set_yscale(self):
        self.ax.set_ylim(float(self.scalemin.text()), float(self.scalemax.text()))

    def reset_yscale(self):
        self.scalemin.setText(str(self.ymin))
        self.scalemax.setText(str(self.ymax))        
        self.set_yscale()


    def logscale_state(self, state):
        if state:
           self.ax.set_yscale('symlog')
           self.logscale = True
        else:
            self.ax.set_yscale('linear')
            self.logscale = False

    def redraw(self):
        self.ax.cla()
        self.add_plots()
        self.set_axes()
        self.ui.canvas.draw()
