#!/usr1/bin/python

# Note: This module is written in Cython, which is a variant of Python intended to be converted to
# C code and compiled.  The main difference is the use of cdef statements and defining variable types.

# make division of integers return a float as in future versions of Python.
from __future__ import division

import csv
import numpy as np
cimport numpy as np
import string
import re
import sdevice_cmd
from scipy.interpolate import interp1d
from scipy.integrate import trapz
from scipy import  arcsin
from libc.math cimport cos, sin, exp
import math
import cmath
import h5py

import tdr
cimport tmm.tmm_core_mw as tmm
import  tmm.tmm_core_mw as tmm

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
    cdef public double E_min, E_max, wl_min, wl_max
    cdef public double S_hat_den
    cdef public yvalues
    cdef public TMMf_TE, TMMf_TM, TMMb_TE, TMMb_TM
   
    def __init__(self, name, material, materialfile, thickness, doping,
                    molefraction,  ext, double ytop):
        self.name = name
        self.material = material
        if self.material in ['GaAsOx', 'TiOx', 'MgF', 'SiN', 'SiO2', 'Si3N4', 'Oxide', 'Nitride']:
           self.material_type = 'Dielectric'	
        else:
           self.material_type = 'Semiconductor'

        self.materialfile = materialfile
        self.thickness = float(thickness)
        if len(doping) > 0:
            self.doping = float(doping) # > 0: ptype, <0: ntype
        else:
            self.doping = 0.0
        if len(molefraction) > 0:
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

    def get_material(self):
        return self.material

    def get_doping(self):
        return self.doping

    def get_material_type(self):
        return self.material_type

    def get_E_minmax(self):
        return (self.E_min, self.E_max)

    def get_name(self):
        return self.name

    def get_ytop_ybot(self):
        return (self.ytop, self.ybot)

    def get_yvalues(self):
        return self.yvalues

    def get_E_list(self):
        return np.array(self.E_list, dtype='float64')

    def get_alpha(self, E_index):
        return self.alpha_list[E_index]

    def get_TMM(self,fb, pol, E_ind, th_ind):
        if fb == 'f' and pol == 'TE':
            return self.TMMf_TE[E_ind][th_ind]
        elif fb == 'f' and pol == 'TM':
            return self.TMMf_TM[E_ind][th_ind]            
        if fb == 'b' and pol == 'TE':
            return self.TMMb_TE[E_ind][th_ind]
        elif fb == 'b' and pol == 'TM':
            return self.TMMb_TM[E_ind][th_ind]            

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
        cdef int i = 0
        cdef double E

        for E in self.E_list:
           S_num[i] = self.S_hat_num(i)
           i += 1
	# need a negative because we're integrating from large to small energy.
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
             print 'S_hat_den', self.S_hat_den
      else:
       return 0.0

# complex index of refraction interpolated to arbitrary wavelength (um).
    def nk(self, double wl):
       return complex(self.index_n(wl), self.index_k(wl))


# **********************************************************
# class containing a list of all layers in the epi structure.
# Each layer is represented by an instance of class epilayer.

class epifile:
    def __init__(self, filename):
        with open(filename, 'rb') as csvfile:
            print '\n*** Getting layer structure from ', filename
            self.r = csv.reader(csvfile, delimiter=',', quotechar='"', quoting=csv.QUOTE_MINIMAL, skipinitialspace=True)
            self.filename = filename
            self.layers = []
            self.ytop = 0.0
            self.ybot = 0.0

            for row in self.r:
                if len(row) > 0:
                    if len(row[0].lstrip('\t')) >2:
                        if  row[0].lstrip('\t')[0] != '$':
                            self.add_layer(row)
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
                                    self.add_layer([re.sub("\$i",str(i),rl.name),rl.material,rl.materialfile,str(rl.thickness),str(rl.doping), '(' + str(rl.xmole) +' '+str(rl.ymole)+')',rl.ext,self.ybot])
                                
    def add_layer(self, row):
                layer = epilayer(row[0].lstrip('\t'), row[1], row[2], row[3], row[4], row[5], row[6],self.ybot)
                self.ybot = layer.ybot
                self.layers.append(layer)
                print '  ', layer.name, '\t', layer.material, '\t', layer.thickness, 'um'

    # ---------------------------------------------------------------------------------------------------------------------------
    # read par files generated by MatPar.  file argument is the main MatPar file containing names of sub-files, e.g. n137_mpr.par
    #   Extract material parameters that we need for calculations.
    #
    def read_parfiles(self, file):
        cdef  epilayer i
        print '\n*** Getting additional material parameters'
        parfiles = sdevice_cmd.sdevice_file(file)

	# list of polar angles for numerical integration
        self.theta_list = np.array(np.linspace(0.0, 0.495*math.pi, 20), dtype='float64')
        for i in self.layers:
		# Get extra material parameters from MatPar output.
                if i.name in parfiles.region_files:
                        parfile = sdevice_cmd.sdevice_file(parfiles.region_files[i.name])
                elif i.material in parfiles.material_files:
                        parfile = sdevice_cmd.sdevice_file(parfiles.material_files[i.material])
                i.par = parfile.par

		# set up n,k for tmm library
                i.nk_data = []
                for j in range(len(i.par['TableODB']['wl'])):
                        i.nk_data.append( np.complex(i.par['TableODB']['n'][j], i.par['TableODB']['k'][j] ))
                i.index_n = interp1d(i.par['TableODB']['wl'], i.par['TableODB']['n'], kind='linear')
                i.index_k = interp1d(i.par['TableODB']['wl'], i.par['TableODB']['k'], kind='linear')


		# for semiconductors, cache an array of energies near the bandgap, covering the range of luminescence for this layer.
                if i.material_type == 'Semiconductor':
                   i.Eg_300 = parfile.Eg_T(300.0)*e_charge   # in J
                   i.E_min = i.Eg_300 - 3*kb*300
                   i.E_max = i.Eg_300 + 6*kb*300
                   i.E_list = np.linspace(i.E_min, i.E_max,30)
                   i.wl_list = 1e6*h*c0/i.E_list
		   # also cache alpha values to minimize interpolations.
                   i.alpha_list = 4*math.pi*i.index_k(i.wl_list)/i.wl_list	# um^-1
                   i.n_list = i.index_n(i.wl_list)	# um^-1
                   i.Brad = i.par['RadiativeRecombination']['C']
                   print '  ', i.name, '\t\tEg=', i.Eg_300, 'eV', '\tBrad=', i.Brad
		# Track wavelength range that is available for all materials.
                i.wl_max = i.par['TableODB']['wl'][-1]
                i.wl_min = i.par['TableODB']['wl'][0]
                if hasattr(self,'wl_min'):
                        if i.wl_min > self.wl_min:
                                self.wl_min = i.wl_min
                        if i.wl_max < self.wl_max:
                                self.wl_max = i.wl_max
                else:
                        self.wl_min = i.wl_min
                        self.wl_max = i.wl_max
        print '\n*** All materials have nk data in the range:  [', self.wl_min, 'to', self.wl_max, '] um'

        # Now generate TMM solutions for this layer for relevant values of photon energy and incidence angle with TE and TM polarization.
        # These will be reused many times, so it's best to pre-calculate them and cache. The function tmm.coh_tmm is very slow.
        
        cdef epilayer layer
        cdef double wl , E, th
        cdef int k
        cdef np.ndarray d_list_top, d_list_bot, 
        cdef np.ndarray nk_list_top, nk_list_bot

        for k in range(len(self.layers) ):
           layer = self.layers[k]
           if layer.material_type == 'Semiconductor':
              layer.TMMf_TE = []
              layer.TMMf_TM = []
              layer.TMMb_TE = []
              layer.TMMb_TM = []

              for E in layer.E_list:
                  wl = 1e6*h*c0/E

                  (d_list_top, nk_list_top) = self.build_tmm_lists(k, 0, wl)
                  (d_list_bot, nk_list_bot) = self.build_tmm_lists(k, len(self.layers)-1, wl)

                  TMMf_TE_E = []
                  TMMf_TM_E = []
                  TMMb_TE_E = []
                  TMMb_TM_E = []
                  for th in self.theta_list:
                          sin_th_r = math.sin(th)/(1.+layer.index_k(wl)**2/layer.index_n(wl)**2)
                          sin_th_im = -sin_th_r*layer.index_k(wl)/layer.index_n(wl)
                          th_c = cmath.asin(complex(sin_th_r, sin_th_im))

                          TMMf_TE_E.append( tmm.coh_tmm(tmm.TE, nk_list_top, d_list_top, complex(th), wl) )
                          TMMf_TM_E.append( tmm.coh_tmm(tmm.TM, nk_list_top, d_list_top, complex(th), wl) )
                          TMMb_TE_E.append( tmm.coh_tmm(tmm.TE, nk_list_bot, d_list_bot, complex(th), wl) )
                          TMMb_TM_E.append( tmm.coh_tmm(tmm.TM, nk_list_bot, d_list_bot, complex(th), wl) )
                  layer.TMMf_TE.append(TMMf_TE_E)
                  layer.TMMf_TM.append(TMMf_TM_E)
                  layer.TMMb_TE.append(TMMb_TE_E)
                  layer.TMMb_TM.append(TMMb_TM_E)

    # ----------------------------------------------------------------------------------------------------
    # Open a TDR mesh file and get vertices associated with each layer (and corresponding y-values).
    #
    def get_layer_vertices(self, tdr_file):

        print '\n*** Finding unique y-coordinates in', tdr_file
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

        # indexing with [()] forces making a copy of the TDR dataset rather than reading from the TDR on request.
        # this gives a huge speed-up over reading data from the TDR file one element at a time.

        # In the TDR file, the dataset ['elements_0'] is a list of integers.  It consists of an integer indicating the
        # element type , followed by indices of each of the vertices for that element,
        # and repeated for every element in the region.  See the PMI section of the sdevice manual for the different possible element types.
        # type=1 is a line element (2 vertices) found at contacts in a 2D problem, and type=2 is a 2D triangle element (3 vertices).

        # ['vertex'] is a list of all vertices in the mesh. For each vertex it contains the 3D coordinates as an array of double floats.
        # The indices in ['elements_0'] can be used to find corresponding vertex coordinates in [u'vertex'].
        
        cdef epilayer l
        cdef np.ndarray elements
        cdef size, vert
        cdef yval

        for l in self.layers:
                if l.name in regions:
                        l.yvalues = blist.sortedset()
                        elements = t.collection[u'geometry_0'][regions[l.name]][u'elements_0'][()]
                        elem = iter(elements)
                        size = elem.next()
                        done = False
                        while done == False:
                                for cnt in range(size+1):
                                        vert = elem.next()
                                        yval = vertices[vert][1]
                                        l.yvalues.add(yval)
                                try:
                                       size = elem.next()
                                except StopIteration:
                                       done = True
                # overwrite calculated layer boundaries with values from mesh 
                # avoids some problems due to roundoff errors.
                l.ytop = l.yvalues[0]
                l.ybot = l.yvalues[-1]					
                print '   ', l.name, ': ', len(l.yvalues), ' unique y-coords'


    # Set up lists of layer thickness and n,k for input to TMM calculation.
    # 
    def build_tmm_lists(self, int startlayer, int endlayer, double wl):
                cdef np.ndarray[double , ndim=1,  negative_indices=False] d_list = np.zeros( abs(startlayer - endlayer) + 2, dtype='float')
                cdef np.ndarray[complex, ndim=1,  negative_indices=False] nk_list = np.zeros( abs(startlayer - endlayer) + 2, dtype='complex')
                cdef epilayer layer = self.layers[startlayer]
                cdef int dl

                assert layer.index_k(wl) >= 0.
                assert layer.index_n(wl) > 0.

                d_list[0] = tmm.inf
                nk_list[0] = complex(layer.nk(wl).real)
                #nk_list[0] = layer.index_n(wl)
                if startlayer > endlayer:
                        dl = -1
                else:
                        dl = 1
                cdef int index = startlayer
                cdef int i = 1
                while index != endlayer:
                        index += dl
                        layer = self.layers[index]
                        d_list[i] =layer.thickness
                        nk_list[i] = layer.nk(wl)
                        assert nk_list[i].real > 0.
                        assert nk_list[i].imag >= 0.
                        i += 1
                d_list[i] = tmm.inf
                nk_list[i] = 1.0+0.0j
                return (d_list, nk_list)

    def P_E(self, int layer_i, double yA, double yB, int E_index):
                cdef epilayer layer = self.layers[layer_i]
                cdef np.ndarray[np.float64_t, ndim=1,  negative_indices=False]  P_Es = np.empty(len(self.theta_list), dtype = 'float64')
                cdef double wl = 1e6*h*c0/layer.E_list[E_index]
                cdef int th_index = 0
                cdef double theta, acost, P_TE, P_TM
                cdef double yfr = layer.ytop
                cdef double ybot = layer.ybot
                cdef double alpha = layer.alpha_list[E_index]
                try:
                      for theta in self.theta_list:
                          acost =  alpha / cos(theta)
                          P_TE = P_Etheta(layer_i, yA, yB, yfr, ybot, layer.TMMf_TE[E_index][th_index].Ref,
 				layer.TMMb_TE[E_index][th_index].Ref, wl, theta, acost)
                          P_TM = P_Etheta(layer_i, yA, yB, yfr, ybot, layer.TMMf_TM[E_index][th_index].Ref,
				layer.TMMb_TM[E_index][th_index].Ref, wl, theta, acost)
                          P_Es[th_index] = (0.5*P_TE + 0.5*P_TM)*sin(theta)
                          th_index += 1
                      return trapz(P_Es, x=self.theta_list)
                except OverflowError:
                        print '***** Rf_TE', layer.TMMf_TE[E_index][th_index].Ref, 'Rf_TM', layer.TMMf_TM[E_index][th_index].Ref
                        print '***** Rb_TE', layer.TMMb_TE[E_index][th_index].Ref, 'Rb_TM', layer.TMMb_TM[E_index][th_index].Ref
                        raise


    # coupling coefficient of photon emitted at yA being absorbed at yB in the same layer.  This 
    # integrates over energy by calling P_E many times and integrating with trapz.
    #  in turn, P_E integrates over theta by calling P_Etheta repeatedly and integrating with trapz.
    #  This is the integral in eq. (5).
    def Pabs(self, int layer_i, double yA, double yB):
                cdef epilayer layer = self.layers[layer_i]
                assert yA >= layer.ytop
                assert yA <= layer.ybot
                assert yB >= layer.ytop
                assert yB <= layer.ybot 

                if layer.material_type != 'Semiconductor':
                     return 0.0

                cdef np.ndarray[np.float64_t, ndim=1,  negative_indices=False] Ps = np.empty(len(layer.E_list), dtype='float64')
                cdef int E_index = 0
                cdef double E

                for E in layer.E_list:
                        Ps[E_index] = self.P_E(layer_i, yA, yB,E_index)*layer.S_hat(E_index)
                        E_index += 1
                return trapz(Ps, x=layer.E_list)


    def PE_LL(self, int li, int lk, double yA, double yB, int E_index):
    # eq (16,17) with TE and TM polarizations, integrated over theta
            assert li != lk
            cdef epilayer layer_i = self.layers[li]
            cdef epilayer layer_k = self.layers[lk]

            cdef np.ndarray[np.float64_t, ndim=1,  negative_indices=False]  P_Es = np.empty(len(self.theta_list), dtype = 'float64')
            cdef int th_index = 0
            cdef double theta, acost
            cdef double yfr = layer_i.ytop
            cdef double ybot = layer_i.ybot
            cdef double alpha = layer_i.alpha_list[E_index]
            cdef double yk_top = layer_k.ytop
            cdef double yk_bot = layer_k.ybot
            cdef double a
            
            for theta in self.theta_list:
                acost =  alpha / cos(theta)
                # TE polarization
                tmmf = layer_i.TMMf_TE[E_index][th_index]
                tmmb = layer_i.TMMb_TE[E_index][th_index]
                # if tmmb.Ref == 1, then Pesc_f will be zero and we don't need to include the result.
                if li > lk:
                    if tmmf.power_entering > 0.0:
                        Pesc = Pesc_f(yA, yfr, ybot, acost, tmmf.Ref, tmmb.Ref, tmmf.power_entering)
                        a = position_resolved_a(li - lk, yk_bot - yB , tmmf)
                        P_Es[th_index] = 0.5*a*Pesc*sin(theta)/tmmf.power_entering
                else:
                    if tmmb.power_entering > 0.0:
                        try:
                            Pesc = Pesc_b(yA, yfr, ybot, acost, 1.-tmmf.power_entering, 1.-tmmb.power_entering, tmmb.power_entering)
                        except AssertionError:
                            print yA, yfr, ybot, acost,  1.-tmmf.power_entering,  1.-tmmb.power_entering, tmmb.power_entering
                            raise
                        a = position_resolved_a(lk - li,yB -  yk_top , tmmb)
                        P_Es[th_index] = 0.5*a*Pesc*sin(theta)/tmmb.power_entering
                # TM polarization
                tmmf = layer_i.TMMf_TM[E_index][th_index]
                tmmb = layer_i.TMMb_TM[E_index][th_index]
                if li > lk:
                    if tmmf.power_entering > 0.0:
                        Pesc = Pesc_f(yA, yfr, ybot, acost,  1.-tmmf.power_entering,  1.-tmmb.power_entering, tmmf.power_entering)
                        a = position_resolved_a(li - lk, yk_bot - yB , tmmf)
                        P_Es[th_index] += 0.5*a*Pesc*sin(theta)/tmmf.power_entering
                else:
                    if tmmb.power_entering > 0.0:
                        try:
                            Pesc = Pesc_b(yA, yfr, ybot, acost,  1.-tmmf.power_entering,  1.-tmmb.power_entering, tmmb.power_entering)
                        except AssertionError:
                            print yA, yfr, ybot, acost,  1.-tmmf.power_entering, 1.-tmmb.power_entering, tmmb.power_entering
                            raise
                        a = position_resolved_a(lk - li,yB -  yk_top , tmmb)
                        P_Es[th_index] += 0.5*a*Pesc*sin(theta)/tmmb.power_entering

                th_index += 1
            cdef double res =  trapz(P_Es, x=self.theta_list)
            if res == np.inf:
                print li, lk, yA, yB, Pesc, a, tmmf.Ref, tmmb.Ref
                print 'd\n', tmmb.d_list
                print 'n\n', tmmb.n_list
                raise ValueError
            return res

    def Pabs_LL(self, int li, int lk, double yA, double yB):
    # coupling coefficient for emission and absorption in different layers.
        cdef epilayer layer_i = self.layers[li]
        if layer_i.material_type != 'Semiconductor':
            return 0.0

        cdef np.ndarray[np.float64_t, ndim=1,  negative_indices=False] Ps = np.empty(len(layer_i.E_list), dtype='float64')
        cdef int E_index = 0
        cdef float E
        for E in layer_i.E_list:
              Ps[E_index] = self.PE_LL(li, lk, yA, yB, E_index)*layer_i.S_hat(E_index)
              E_index += 1
        return trapz(Ps, x=layer_i.E_list)
	


	# probability of photon emitted at yA in layer i being re-absorbed at yB in the same layer.
	# E - photon energy in J
	# theta - polar direction of photon emission.
	# Rf, Rb - reflectivity of front and back of layer i from TMM calculation.
cdef double P_Etheta(int layer_i, double yA, double yB, double yfr, double ybot, double Rf, double Rb,  double wl, double theta, double acost):
        cdef double ytemp, Rtemp
        cdef double F1, P, result
        # swap yA/yB, Rf/Rb.
        if yB > yA:
                ytemp = yA
                yA = yB
                yB = ytemp

                Rtemp = Rf
                Rf = Rb
                Rb = Rtemp
        try:
                F1 =  exp(-acost*(yA-yB))                       # direct flight A to B
                F1 += exp(-acost*(yA-2*yfr+yB))*Rf              # reflection from front
                F1 += exp(-acost*(2*ybot-yA-yB))*Rb             # reflection from back
                F1 += exp(-acost*(2*ybot-yA+yB-2*yfr))*Rf*Rb    # reflections front and back
        except OverflowError:
                print '*** ', 'theta/pi', theta/math.pi, 'acost', acost, 'yA', yA, 'yB',yB
                print '*** ', 'yfr', yfr, 'ybot', ybot, 'Rf', Rf, 'Rb', Rb
                raise
        # consider extra double passes....
        P = 1.0 - exp(-2*acost*(ybot-yfr))*Rf*Rb
        result = acost*F1/P
        return result

# eqs (13, 14).  These are the same as Steiner's expression for P_esc.
# note we're considering up and down emission together, so probability should be 0.0 < P < 2.0
# this is why integration over polar angle is done only between 0 to pi/2.
cdef double Pesc_f(double yA, double yf, double yb, double acost, double Rf, double Rb, double pow_e):
    assert Rf <= 1.000001, "Pesc_f Rf >1"
    assert Rb <= 1.000001, "Pesc_f Rb >1"
    assert pow_e <= 1.000001, "Pesc_f pow_e >1"
    
    cdef double num, den, P
    num  = exp(-acost*(yA-yf)) + Rb*exp(-acost*(2*yb-yf-yA))
    den = 1.0 - Rf*Rb*exp(-2*acost*(yb-yf))
    P = pow_e*num/den
    #assert P <= 2.0, 'Pesc_f yields P > 2: {0}'.format(P)
    #assert P >= 0.0, 'Pesc_b yields P < 0: {0}, ({1}  + {2})/{3}'.format(P, (1.0-Rb)*exp(-acost*(yb-yA)), (1.0-Rb)*Rf*exp(-acost*(yb+yA-2*yf)), den)
    return P

cdef double Pesc_b(double yA, double yf, double yb, double acost, double Rf, double Rb, double pow_e):
    assert Rf <= 1.0000001, "Pesc_b Rf > 1"
    assert Rb <= 1.0000001, "Pesc_b Rb > 1"
    assert pow_e <= 1.000001, "Pesc_b pow_e > 1 -- pow_e = {0}".format(pow_e)

    cdef double num, den, P
    num  = exp(-acost*(yb-yA)) + Rf*exp(-acost*(yb+yA-2*yf))
    den = 1.0 - Rf*Rb*exp(-2*acost*(yb-yf))

    P = pow_e*num/den
    #assert P <= 2.0, 'Pesc_b yields P > 2: {0}, ({1}  + {2})/{3}, pe={4}, Rf={5}, Rb={6}'.format(P, (1.0-Rb)*exp(-acost*(yb-yA)), (1.0-Rb)*Rf*exp(-acost*(yb+yA-2*yf)), den, pow_e, Rf, Rb)
    #assert P >= 0.0, 'Pesc_b yields P < 0: {0}, ({1}  + {2})/{3}, pe={4}'.format(P, (1.0-Rb)*exp(-acost*(yb-yA)), (1.0-Rb)*Rf*exp(-acost*(yb+yA-2*yf)), den, pow_e)

    return P

# set up caching for the cos function
def memodict(f):
    """ Memoization decorator for a function taking a single argument """
    class memodict(dict):
        def __missing__(self, key):
            ret = self[key] = f(key)
            return ret 
    return memodict().__getitem__

memcos = memodict(cmath.cos)

def clear_cache():
    memcos.__self__.clear()

# borrowed from  Steve Byrnes' tmm library.  placed here to make a cython version.
cdef double position_resolved_a(int layer, float dist, tmm.Tmm_data coh_tmm_data):
    """
    Starting with output of coh_tmm(), calculate the Poynting vector
    and absorbed energy density a distance "dist" into layer number "layer"
    """
    cdef complex vw0 = coh_tmm_data.vw_list[layer][0]
    cdef complex vw1 = coh_tmm_data.vw_list[layer][1]    
    cdef complex kz = coh_tmm_data.kz_list[layer]
    cdef complex th = coh_tmm_data.th_list[layer]
    cdef complex n = coh_tmm_data.n_list[layer]
    cdef complex n_0 = coh_tmm_data.n_list[0]
    cdef complex th_0 = coh_tmm_data.th_0
    cdef complex Ef
    cdef complex Eb
    cdef int pol = coh_tmm_data.pol
    cdef double a1
    cdef double a2
    cdef double absor= 0.0


    #amplitude of forward-moving wave is Ef, backwards is Eb
    # with transmission into very thick absorbing layers (like a 300 um substrate)
    # Ef may be very small and Eb may overflow.  These cases are not important though because
    # the field is too small to matter. return 0.
    
    Ef = vw0 * cmath.exp(1j * kz * dist)
    if abs(Ef) < 1e-30:
            return 0.0
    try:
        Eb = vw1 * cmath.exp(-1j * kz * dist)
    except OverflowError:
        return 0.0


    assert n.imag != 0.0, "Zero absorption in layer lk, n= {0}, nlist={1}".format(n, coh_tmm_data.n_list)

        
    #print coh_tmm_data.n_list
    #absorbed energy density
    if(pol==tmm.TE):
        a1 = abs(Ef+Eb)*abs(Ef+Eb)
        absor = (n*cmath.cos(th)*kz*a1).imag / (n_0*cmath.cos(th_0)).real

    elif(pol==tmm.TM):
        a1 = abs(Ef+Eb)*abs(Ef+Eb)
        a2 = abs(Ef-Eb)*abs(Ef-Eb)
        absor = (n*np.conj(cmath.cos(th))*
                 ( kz*a2-np.conj(kz)*a1) ).imag / (n_0*np.conj(cmath.cos(th_0))).real
    else:
        raise ValueError, 'invalid polarization value'

    if abs(Ef) < 1e-30 or absor == np.inf:
      #print 'small field values', 'Ef', Ef,'Eb',  Eb,'lk', layer,'dist', dist,'theta', th
      return 0.0
        
    return absor
