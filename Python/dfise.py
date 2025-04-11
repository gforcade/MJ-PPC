
import csv
import numpy as np
##import ASTMG173

# Class to read in a .dfise file produced by Sentaurus

# example:
# import dfise  # loads the modules dfise.py.
# import matplotlib.pyplot as plt
#
#   create an instance of class dfise from the given file.
# d = dfise.dfise('n1781_des.plt')
#
#   print all avaialble dataset names
# print 'Available datasets:'
# for i in d.data.keys():
#    print i
#
#   plot I-V curve (assuming this file contains I-V data).
# plt.plot(d.data['anode OuterVoltage'], d.data['cathode TotalCurrent'])
#
#   label axes
# plt.xlabel('Bias Voltage [$\mathrm{V}$]')
# plt.ylabel('Current [$\mathrm{A}$]')
# plt.show()


qe = 1.602e-19 # C
h = 6.626e-34 # J.s
c0 = 299792458 # m/s

class dfise:
    def __init__(self, filename):
        with open(filename, 'r') as csvfile:
            self.r = csv.reader(csvfile, delimiter=' ', quotechar='"', quoting=csv.QUOTE_MINIMAL, skipinitialspace=True)
            row = next(self.r)
            assert row[0] == 'DF-ISE', 'file does not appear to be in DF=ISE format'
            self.filename = filename
            print( 'Reading DF-ISE file', filename)
            if len(row) > 0:
                for row in self.r:
                    if len(row) > 0:
                        if row[0] == 'Info':
                            self.readInfo()
                        if row[0] == 'Data':
                            self.readData()

    def readInfo(self):
#        print 'starting readInfo'
        self.datasets = []
        self.functions = []
        for row in self.r:
            if row[0] == '}':
                break
            elif row[0] == 'version':
                self.dfise_version = row[2]
            elif row[0] == 'type':
                self.dfise_type = row[2]
            elif row[0] == 'datasets':
                stop = False
                if len(row) > 3:
                    ds = []
                    for i in row[3:]:
                        if i != ']':
                            ds.append(i)
                        else:
                            stop = True
                    self.datasets.append(ds)

                while stop == False:
                    ds = []
                    row = self.r.__next__()
                    for i in row:
                        if i != ']':
                            ds.append(i)
                        else:
                            stop = True
                    self.datasets.append(ds)
                    
            elif row[0] == 'functions':
                stop = False
                if len(row) > 3:
                    func = []
                    for i in row[3:]:
                        if i != ']':
                            func.append(i)
                        else:
                            stop = True
                    self.functions.append(func)

                while stop == False:
                    func = []
                    row = self.r.__next__()
                    for i in row:
                        if i != ']':
                            func.append(i)
                        else:
                            stop = True
                    self.functions.append(func)
#                print( 'functions:' , self.functions)

    def readData(self):
            stop = False
            self.data = dict()
            for i in self.datasets:
                for j in i:
                    self.data[j] = []
            while stop == False:
                for i in self.datasets:
                  try:
                    row = self.r.__next__()
                    if row[0] != '}':
                        for j,k in zip(i,row):
                            self.data[j].append(float(k))
                    else:
                        stop= True
                        break
                  except StopIteration:
                    stop=True
                    print( "Warning - file is incomplete!")
                    pass
            for i in self.datasets:
                for j in i:
                    self.data[j] = np.array(self.data[j])

    # for EQE files:
    #    wavelengths should be in um
    #    incident intensity should be 1 W/cm^2
    #    AreaFactor should be used to make currents equal current density (A/cm^2)

    def wavelengths(self):
        wlstring = 'Device=,File=CommandFile/Physics,DefaultRegionPhysics,ModelParameter=Optics/Excitation/Wavelength'
        assert wlstring in self.data.keys()
        return self.data[wlstring]

    # return incident photon flux density
    def photonflux(self):
        wl = self.wavelengths()
        intensity = 1.0 # [W/cm^2]
        photon_energy = h*c0/(wl*1e-6) # [J]
        J_ph = intensity/photon_energy  # [photons/cm^2.s]
        return J_ph

    # return EQE array
    def eqe(self, contact):
        currentstring = contact + ' TotalCurrent'
        assert currentstring in self.data.keys()
        J_sc = -self.data[currentstring] # [A/cm^2]
        eqe = J_sc/(qe*self.photonflux())
        return eqe

    # integrate EQE over spectrum to get Jsc for 1000 W/m^2 intensity.
    # Jsc = qe*integral(eqe*photon_flux_density)dlambda
    # contact : string with name of contact to use for eqe.
    # spec: one of 'AM0', 'AM1.5G', 'AM1.5D'.
    # example: self.integ_current('ASTMG173.csv', 'AM1.5D', 'anode')
    # returns Jsc in A/cm^2.
    def integ_current(self, specfile, spec, contact):
        astm_g173 = ASTMG173.ASTMG173(specfile)
        # interpolate simulated EQE onto ASTM spectrum wavelengths
        EQE_interp = np.interp(astm_g173.wl, self.wavelengths(), self.eqe(contact))
        es = h*c0/(astm_g173.wl*1e-6)
        # Calculate flux for 1000 W/m^2 intensity
        flux = 1e-4*(1000.0/astm_g173.irradiance[spec])*astm_g173.spectra[spec]/es
        Jsc = qe*np.trapz(EQE_interp*flux, astm_g173.wl)
        return Jsc    
    
