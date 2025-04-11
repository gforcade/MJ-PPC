import csv
import numpy as np
import glob
import string
import ASTMG173

# Class to read in a .log file produced by Oriel IQE-200 machine
#    read_qe
#        __init__(filename)
#        v
#        i
#        filename
#        sample
#        temp
#        cellarea

e_charge = 1.602e-19 # C
h = 6.626e-34 # J.s
c0 = 299792458.0 # m/s

class qe:
    def __init__(self, filename):
        with open(filename, 'rb') as qefile:
            reader = csv.reader(qefile, delimiter='\t')
            print 'Reading QE file', filename
            stop = False
            while stop == False:
                row = reader.next() # 'Labview IV Data'
                if row[0] == 'wavelength':  # line start of I-V data
                        stop=True
                        self.data = dict()
                        self.columns = row
                        for i in row:
                            self.data[i] = []
                elif row[0] == 'User:':
                        self.user = row[1]
                elif row[0] == 'Test Name:':
                    self.test_name = row[1]
                elif row[0] == 'Notes:':
                    self.notes = row[1]
                elif row[0] == 'Time:':
                    self.Time = row[1]
                elif row[0] == 'Method:':
                    self.method = row[1]
                elif row[0] == 'Scan Type :':
                    self.scan_type = row[1]
            for row in reader:
                for i in range(len(row)):
                    self.data[self.columns[i]].append(float(row[i]))
            # return wavelengths in um
            self.data['wavelength'] = np.array(self.data['wavelength'])/1000.0


    # integrate EQE over spectrum to get Jsc for 1000 W/m^2 intensity.
    # Jsc = qe*integral(eqe*photon_flux_density)dlambda
    # contact : string with name of contact to use for eqe.
    # spec: one of 'AM0', 'AM1.5G', 'AM1.5D'.
    # example: self.integ_current('ASTMG173.csv', 'AM1.5D', 'anode')
    # returns Jsc in A/cm^2.
    def integ_current(self, specfile, spec):
        astm_g173 = ASTMG173.ASTMG173(specfile)
        # interpolate simulated EQE onto ASTM spectrum wavelengths
        EQE_interp = np.interp(astm_g173.wl, self.data['wavelength'], self.data['EQE'])
        es = h*c0/(astm_g173.wl*1e-6)
        # Calculate flux for 1000 W/m^2 intensity
        flux = 1e-4*(1000.0/astm_g173.irradiance[spec])*astm_g173.spectra[spec]/es
        Jsc = e_charge*np.trapz(EQE_interp*flux, astm_g173.wl)
        return Jsc    
