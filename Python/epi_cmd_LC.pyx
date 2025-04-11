
# cython: profile=True
# Note: This module is written in Cython, which is a variant of Python intended to be converted to
# C code and compiled.  The main difference is the use of cdef statements and defining variable types.

# make division of integers return a float as in future versions of Python.
from __future__ import division


import csv
import numpy as np
cimport numpy as np
import sdevice_cmd
from scipy.interpolate import interp1d
from scipy.integrate import trapz
from math import cos, sin, exp, pi
import h5py
import re
import tdr
cimport  tmm.tmm_core_mw as tmm
import blist


cdef double e_charge = 1.602e-19 # C
cdef double h = 6.626e-34      # J.s
cdef double c0 = 299792458.0   # m/s
cdef double kb = 1.3806488e-23 # J/K

# ***************************************************
# Class with data on a specific layer in the epi file
#    epi



cdef class epilayer:
    cdef public double doping, Eg_300, xmole, ymole
    cdef public double ytop, ybot, thickness, Brad
    cdef public name, material, material_type, materialfile, ext
    cdef public par, index_n, index_k, nk, nk_data
    cdef public np.ndarray E_list,  alpha_list, wl_list, n_list
    cdef public double E_min, E_max, wl_min, wl_max, wl_emission_min, wl_emission_max
    cdef public double S_hat_den
    cdef public yvalues
   
    def __init__(self, name, material, materialfile, thickness, doping,
                    molefraction,  ext, double ytop):
        self.name = name
        self.material = material
        if self.material in ['GaAsOx', 'TiOx', 'MgF', 'SiN', 'SiO2', 'Si3N4', 'Oxide', 'Nitride', 'TaO']:
           self.material_type = 'Dielectric'
        elif self.material in ['Gold']:
            self.material_type = 'Metal'
        elif self.material in ['Air']:
            self.material_type = 'Air/Vacuum'
        else:
           self.material_type = 'Semiconductor'

        self.materialfile = materialfile
        self.thickness = float(thickness)
        if len(doping) > 0 and (not molefraction.isspace()):
            self.doping = float(doping) # > 0: ptype, <0: ntype
        else:
            self.doping = 0.0

        if len(molefraction) > 0 and (not molefraction.isspace()):
            if molefraction[0] == '(':
                moles = molefraction.strip('()').split(' ')
                self.xmole = float(moles[0])
                self.ymole = float(moles[1])
            else:
                self.xmole = float(molefraction)
                self.ymole = 0.0
        self.ext = ext
        self.ytop = ytop
        self.ybot = ytop + self.thickness

# numerator of the spectral distribution of PL emission. Assume 300K.
# wavelength should be in um.
# parameter i is the index to the layer's E_list property.
    def S_hat_num(self,int i):
        cdef double alpha = self.alpha_list[i] # absorption coefficient in um^-1
        cdef double n = self.n_list[i]
        cdef double T = 300.0
        cdef double  E = self.E_list[i]
        cdef double S = alpha*(n*n)*(E*E)*exp(-E/(kb*T))
        return S

# denominator.  Integrate numerator over all energies.
    def calc_S_hat_den(self):
        cdef np.ndarray[double, ndim=1, negative_indices=False] S_num = np.empty(len(self.E_list), dtype='float')
        cdef double E

        for i in xrange(len(self.E_list)):
             S_num[i] = self.S_hat_num(i)

        self.S_hat_den = trapz(S_num, x=self.E_list)
        assert self.S_hat_den != 0.0, 'Found S_hat_den == NaN, material {0}, k_list: {1}'.format(self.material, self.alpha_list)


# Normalized spectral emission distribution.  If denominator has not already been calculated, it will be done automatically.
# wavelength should be in um.
# parameter i is the index to the layer's E_list property.
    def S_hat(self, int i):
        if self.material_type == 'Semiconductor':
           if self.S_hat_den == 0.0:
                self.calc_S_hat_den()
           try:
               return self.S_hat_num(i)/self.S_hat_den
           except ZeroDivisionError:
               print( 'S_hat_den', self.S_hat_den)
        else:
           return 0.0

# complex index of refraction interpolated to arbitrary wavelength (um).
    def nk(self, double wl):
       return complex(self.index_n(wl), self.index_k(wl))


# **********************************************************
# class containing a list of all layers in the epi structure.
# Each layer is represented by an instance of class epilayer.
# Reads in a pre-processed epi file ( i.e. pp@node@_epi.cmd)
# 

class epifile:
    def __init__(self, filename):
        with open(filename, 'r') as csvfile:
            print( '\n*** Getting layer structure from ', filename)
            self.r = csv.reader(csvfile, delimiter=',', quotechar='"', quoting=csv.QUOTE_MINIMAL, skipinitialspace=True)
            self.filename = filename
            self.layers = []
            self.backlayers = [] # add seperate layer list for back materials
            self.ytop = 0.0
            self.ybot = 0.0


            for row in self.r:
                if len(row) > 0:
                    if len(row[0].lstrip('\t')) >2:
                        if  row[0].lstrip('\t')[0] != '$':
                            self.add_layer(row, False)
                        elif row[0].lstrip('\t').split(' ')[0] == '$repeat':
                            N = int(row[0].split(' ')[1])
                            row = self.r.next()
                            replayers = []
                            while row[0].lstrip('\t') != '$end':
                                    replayer = epilayer(row[0].lstrip('\t'),row[1],row[2],row[3], row[4], row[5], row[6],0)
                                    replayers.append(replayer)
                                    row = self.r.next()
                            for i in range(N):
                                for rl in replayers:
                                    self.add_layer([re.sub("\$i",str(i),rl.name),rl.material,rl.materialfile,str(rl.thickness),str(rl.doping), '(' + str(rl.xmole) +' '+str(rl.ymole)+')',rl.ext,self.ybot], False)


    # ---------------------------------------------------------------------------------

		# Sets the layers at the bottom of the stack
    def bottom_material(self, mat, mat_file, thick):
        print( '\n*** Adding additional layers to bottom of the stack')#
        for i in range(len(mat)):
            backlayer = [f'back_mat_{i}', mat[i], mat_file[i], thick[i], '\t', '\t', '\t'] #doping and moelfraction set to 0 by default (### NOTE; might want to be able to change these later), ext (mesh from Sentaurus) is left blank, ytop is ybot from whatever the previous layer was and is set in the add_layer function
            self.add_layer(backlayer, True)

		# ----------------------------------------------------------------------------------

    def add_layer(self, row, backmat):
                layer = epilayer(row[0].lstrip('\t'), row[1].lstrip('\t'), row[2].lstrip('\t'), row[3], row[4], row[5], row[6],self.ybot)
                self.ybot = layer.ybot
                if backmat == False: #distinguish between a layer in the main stack where coupling sould be considered and one where coupling can be ignored
                    self.layers.append(layer)
                else:
                    self.backlayers.append(layer)
                print( '  ', layer.name, '\t', layer.material, '\t', layer.thickness, 'um')

    # -------------------------------------------------------------------------------------
    # read par files generated by MatPar.  file argument is the main MatPar file containing 
    # names of sub-files, e.g. n137_mpr.par  Extract material parameters that we need for
    # calculations and add the data to the corresponding layer objects..

    def read_parfiles(self, file):
        cdef  epilayer i
        print( '\n*** Getting additional material parameters')
        parfiles = sdevice_cmd.sdevice_file(file)

	# list of polar angles for numerical integration. Note - Avoid using exactly pi/2.
        self.theta_list = np.array(np.linspace(0., 1.55, 20), dtype='float64') # angles too close to pi/2 cause problems, cut off at around 77 degrees (1.57 approx pi/2)
        for i in self.layers + self.backlayers: # get material params for layers and backlayers
		# Get extra material parameters from MatPar output.
                if i.name in parfiles.region_files:
                        parfile = sdevice_cmd.sdevice_file(parfiles.region_files[i.name])
                elif i.material in parfiles.material_files:
                        print(sdevice_cmd.sdevice_file(parfiles.material_files[i.material]))
                        parfile = sdevice_cmd.sdevice_file(parfiles.material_files[i.material])
                i.par = parfile.par

		# set up n,k for tmm library
                i.nk_data = []
                for j in range(len(i.par['TableODB']['wl'])):
                        i.nk_data.append( np.complex(i.par['TableODB']['n'][j], i.par['TableODB']['k'][j] ))
                if i.material == 'TaO': # want a constant interpolation for this material -pwils
                    i.index_n = interp1d(i.par['TableODB']['wl'], i.par['TableODB']['n'], kind='linear', bounds_error = False, fill_value = (np.real(i.nk_data[0]), np.real(i.nk_data[-1])))
                    i.index_k = interp1d(i.par['TableODB']['wl'], i.par['TableODB']['k'], kind='linear', bounds_error = False, fill_value = (np.imag(i.nk_data[0]), np.imag(i.nk_data[-1])))
                else: # linear interpolation with linear extrapolation, a warning will be printed if the emission wavelengths are in an extrapolated region -pwils
                    i.index_n = interp1d(i.par['TableODB']['wl'], i.par['TableODB']['n'], kind='linear', bounds_error = False, fill_value = 'extrapolate')
                    i.index_k = interp1d(i.par['TableODB']['wl'], i.par['TableODB']['k'], kind='linear', bounds_error = False, fill_value = 'extrapolate')

		# Track wavelength range that is available for all materials.
                i.wl_max = i.par['TableODB']['wl'][-1]
                i.wl_min = i.par['TableODB']['wl'][0]

		# for semiconductors, cache an array of energies near the bandgap, covering the range of luminescence for this layer.
                if i.material_type == 'Semiconductor':
                   i.Eg_300 = parfile.Eg_T(300.0)*e_charge   # in J
                   i.E_min = i.Eg_300
                   i.E_max = i.Eg_300 + 10*kb*300
                   i.E_list = np.linspace(i.E_min, i.E_max,30)
                   i.wl_list = 1e6*h*c0/i.E_list # in um
                   i.wl_emission_min = i.wl_list[-1] # shortest emission wavelength for the material -pwils
                   i.wl_emission_max= i.wl_list[0] #longest emission wavelenght for the material
		   # also cache alpha values to minimize interpolations.
                   i.alpha_list = 4*pi*i.index_k(i.wl_list)/i.wl_list	# um^-1
                   i.alpha_list[0] = 0.
                   i.n_list = i.index_n(i.wl_list)	# um^-1
                   i.Brad = i.par['RadiativeRecombination']['C']
                   print( '  ', i.name, '\t',i.material, 'Eg=', i.Eg_300/e_charge, 'eV', 'Brad=', i.Brad, 'wl_min=', i.wl_min, 'wl_max=', i.wl_max)

# keep track of the maximum and minimum wavelengths available in each of the .par files
                if hasattr(self,'wl_min'):
                        if i.wl_min > self.wl_min:
                                self.wl_min = i.wl_min
                        if i.wl_max < self.wl_max:
                                self.wl_max = i.wl_max
                else:
                        self.wl_min = i.wl_min
                        self.wl_max = i.wl_max

# keep track of the maximum and minimum emission wavelengths required for each of the semiconductors -pwils
                if i.material_type == "Semiconductor":
                    if hasattr(self,'wl_emission_min'):
                            if i.wl_emission_min < self.wl_emission_min:
                                    self.wl_emission_min = i.wl_emission_min
                            if i.wl_emission_max > self.wl_emission_max:
                                    self.wl_emission_max = i.wl_emission_max
                    else:
                            self.wl_emission_min = i.wl_emission_min
                            self.wl_emission_max = i.wl_emission_max
        print( '\n*** All materials have nk data in the range:  [', self.wl_min, 'to', self.wl_max, '] um')
        print('\n*** Maximum emission wavelength:', self.wl_emission_max, '   Minimum emission wavelength:', self.wl_emission_min)
        if self.wl_min > self.wl_emission_min or self.wl_max < self.wl_emission_max:
            print('\n***Warning: Wavelength range of emitted photons is outside the bounds for some of the material file nk data. This may result in extrapolating the necessary data.')



    # ----------------------------------------------------------------------------------------------------
    # Open a TDR mesh file and get vertices associated with each layer (and corresponding y-values).
    #
    def get_layer_vertices(self, tdr_file):

        print( '\n*** Finding unique y-coordinates in', tdr_file)
        t = tdr.tdr(tdr_file)
        cdef np.ndarray vertices = t.collection[u'geometry_0'][u'vertex'][()]
        regions = dict()
        # Find regions in TDR file and map keys (i.e. region_0) to names (i.e. emitter)
        for i in t.collection[u'geometry_0'].keys():
                parts = i.split('_')
                if len(parts) == 2 and parts[0] == 'region':
                        r= t.collection[u'geometry_0'][i]
                        # Map region names to TDR region indices
                        regions[r.attrs[u'name']] = i

        # now iterate over layers in epi-file.  Find mesh regions matching each layer. Make a sorted set containing
        # all unique y-coodinates of mesh vertices in the region.

        # indexing with [()] forces making a copy of the whole TDR dataset as a numpy array.
        # this gives a huge speed-up over reading data from the TDR file one element at a time.

        # In the TDR file, the dataset ['elements_0'] is a list of integers.  It consists of an integer indicating the
        # element type , followed by indices of each of the vertices for that element,
        # and repeated for every element in the region.  See the PMI section of the sdevice manual for the different possible element types.
        # type=1 is a line element (2 vertices) found at contacts in a 2D problem, and type=2 is a 2D triangle element (3 vertices).

        # ['vertex'] is a list of all vertices in the mesh. For each vertex it contains the 3D coordinates as an array of double floats.
        # The vertex indices in ['elements_0'] can be used to find corresponding vertex coordinates in [u'vertex'].
        
        cdef epilayer l
        cdef np.ndarray elements
        cdef size, vert
        cdef yval

        for l in self.layers:
                if l.name.encode('ascii') in regions:
                        # build list of unique y-values in the region.
                        l.yvalues = blist.sortedset()
                        elements = t.collection[u'geometry_0'][regions[l.name.encode('ascii')]][u'elements_0'][()]
                        elem = iter(elements)
                        size = elem.__next__()
                        done = False
                        while done == False:
                                for cnt in range(size+1):
                                        vert = elem.__next__()
                                        yval = vertices[vert][1]
                                        l.yvalues.add(yval)
                                try:
                                       size = elem.__next__()
                                except StopIteration:
                                       done = True
                # overwrite calculated layer boundaries with values from mesh file
                # avoids some problems due to roundoff errors.
                l.ytop = l.yvalues[0]
                l.ybot = l.yvalues[-1]					
                print( '   ', l.name, ': ', len(l.yvalues), ' unique y-coords')

# Integrate absorption over E, theta.
def calc_a(int li, int lk, double yA, double yB, data_list_TE,  data_list_TM,  e):
                      cdef np.ndarray E_list = e.layers[li].E_list
                      cdef np.ndarray th_list = e.theta_list
                      cdef np.ndarray P0_list = np.zeros((len(th_list)), dtype=float)
                      cdef np.ndarray P1_list = np.zeros((len(E_list)), dtype=float)
                      cdef np.ndarray sin_th_list = np.sin(th_list)
                      cdef double yB0 = yB - e.layers[lk].ytop

                      for E_i in xrange(len(E_list)):
                           for th_i in xrange(len(th_list)-1):
                                  P0_list[th_i]  = tmm.position_resolved_a(lk, yB0, data_list_TE[E_i][th_i]) * sin_th_list[th_i]
                                  P0_list[th_i] += tmm.position_resolved_a(lk, yB0, data_list_TM[E_i][th_i]) * sin_th_list[th_i]

                           # Assume all emissions at angle pi/2 are absorbed at y-position of emission.
                           if yA  == yB:
                                  P0_list[-1] = 1.

                           P1_list[E_i] = trapz(P0_list, x=th_list) * e.layers[li].S_hat(E_i)
                      P = trapz(P1_list, x=E_list) 
#                      if P/60. > 5.:
#                            print( 'P1_list\n', P1_list, 'E_list\n', E_list)
 
                      return P

