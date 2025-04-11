
# cython: profile=True
# -*- coding: utf-8 -*-
"""
For information see the docstring of each function, and also see manual.pdf

The most two important functions are:

coh_tmm(...) -- the transfer-matrix-method calculation in the coherent
case (i.e. thin films)

inc_tmm(...) -- the transfer-matrix-method calculation in the incoherent
case (i.e. films tens or hundreds of wavelengths thick, or whose
thickness is not very uniform.

These functions are all imported into the main package (tmm) namespace,
so you can call them with tmm.coh_tmm(...) etc.
"""

#make division of integers work as expected
from __future__ import division

from numpy import inf, zeros, array, nan, isnan
from cmath import cos, sin, exp, pi, sqrt
import scipy as sp
import numpy as np
cimport numpy as np
import math

import sys
EPSILON = sys.float_info.epsilon # typical floating-point calculation error

# choose data type used to store complex numbers
complex_type = np.complex256

# class members are declared in .pxd file.
cdef class Tmm_data_internalsource:
    def __init__(self):
        pass
    
TE = 0
TM = 1

cdef np.ndarray make_2x2_array(a, b, c, d, dtype=float):
    """
    Makes a 2x2 numpy array of [[a,b],[c,d]]
    
    Same as "numpy.array([[a,b],[c,d]], dtype=float)", but ten times faster
    """
    cdef np.ndarray my_array = np.empty((2,2),dtype=dtype)
    my_array[0,0] = a
    my_array[0,1] = b
    my_array[1,0] = c
    my_array[1,1] = d
    return my_array

cdef  make_2x2_interface_matrix(complex r, complex t):
    """
    Makes a 2x2 interface matrix
    """
    cdef my_array = np.empty((2,2),dtype=complex_type)
    my_array[0,0] = 1.
    my_array[0,1] = r
    my_array[1,0] = r
    my_array[1,1] = 1.
    return my_array/t


cdef make_2x2_prop_matrix(complex delta):
    """
    Makes a 2x2 wave propagation matrix
    """
    cdef np.ndarray my_array = np.zeros((2,2),dtype=complex_type)
    try:
        my_array[0,0] = np.exp(-1j*delta)
        my_array[1,1] = np.exp(1j*delta)
    except OverflowError:
        print delta, my_array
        raise
    return my_array

cdef list_snell_li(np.ndarray[complex, ndim=1, negative_indices=False] n_list, complex th_i, int li ):
    """
    return list of angle theta in each layer based on angle th_i in layer i,
    using Snell's law. n_list is index of refraction of each layer. Note that
    "angles" may be complex!!

    li is the layer index within the TMM stack (including the top air layer).
    
    """
    #Important that the arcsin here is scipy.arcsin, not numpy.arcsin!! (They
    #give different results e.g. for arcsin(2).)
    #Use real_if_close because e.g. arcsin(2 + 1e-17j) is very different from
    #arcsin(2) due to branch cut
    return sp.arcsin(np.real_if_close(n_list[li]*np.sin(th_i) / n_list))


cdef complex interface_r(int polarization, complex n_i, complex n_f, complex th_i, complex th_f):
    """
    reflection amplitude (from Fresnel equations)

    polarization is either "s" or "p" for polarization

    n_i, n_f are (complex) refractive index for incident and final

    th_i, th_f are (complex) propegation angle for incident and final
    (in radians, where 0=normal). "th" stands for "theta".
    """
    if polarization == TE:
        #return 2 * n_i * cos(th_i) / (n_i * cos(th_i) + n_f * cos(th_f))
        return ((n_i * cos(th_i) - n_f * cos(th_f)) /
                (n_i * cos(th_i) + n_f * cos(th_f)))
    elif polarization == TM:
        return ((n_f * cos(th_i) - n_i * cos(th_f)) /
                (n_f * cos(th_i) + n_i * cos(th_f)))
    else:
        raise ValueError("Polarization must be TE or TM")

cdef complex interface_t(int polarization, complex n_i, complex n_f, complex th_i, complex th_f):
    """
    transmission amplitude (frem Fresnel equations)

    polarization is either "s" or "p" for polarization

    n_i, n_f are (complex) refractive index for incident and final

    th_i, th_f are (complex) propegation angle for incident and final
    (in radians, where 0=normal). "th" stands for "theta".
    """
    if polarization == TE:
        return 2. * n_i * cos(th_i) / (n_i * cos(th_i) + n_f * cos(th_f))
    elif polarization == TM:
        return 2. * n_i * cos(th_i) / (n_f * cos(th_i) + n_i * cos(th_f))
    else:
        raise ValueError("Polarization must be TE or TM")




cdef get_k_vec(complex nk, double lambda0, double phi):
    """
    Find the complex k vector corresponding to propagation direction phi.
    See the memo on TMM calculations for details.
    lambda0 should be in um.
    """
    #print('Original angle', phi)
    lambda0=lambda0*1e-6

    # Quadratic formula coefficients
    cdef double a = 1.0
    cdef double b = (4.0*pi*pi/(lambda0*lambda0))*(nk.real*nk.real - nk.imag*nk.imag)
    cdef  double c = - (4.0*pi*pi*nk.real*nk.imag/(lambda0*lambda0*sp.cos(phi)) )**2.

    # Two roots of the quadratic eq.
    cdef complex k2_1 = (-b + sqrt(b*b -4.0*a*c))/(2.0*a)
    cdef complex k2_2 = (-b - sqrt(b*b -4.0*a*c))/(2.0*a)

    # We need a root that is real and >=0.
    assert np.isreal(k2_1), 'get_k_vec root is not real'
    assert k2_1.real >= 0.0, 'get_k_vec root is < 0'

    cdef double k2_mag
    if np.isreal(k2_1) and k2_1.real >= 0.0:
          k2_mag = sqrt(k2_1).real
    elif np.isreal(k2_2) and k2_2.real >= 0.0:
          k2_mag = sqrt(k2_2).real
    else:
          print 'get_k_vec - invalid roots'
          raise ValueError

    cdef double k1_mag
    if k2_mag != 0.:
        k1_mag = (4.0*pi*pi*nk.real*nk.imag/(lambda0*lambda0*sp.cos(phi)*k2_mag)).real
    else:
        # k vector is entirely real.
        k1_mag = (2.0*pi*nk.real/lambda0) # was squared, removed **2 -pwils

    cdef np.ndarray[double, ndim=2, negative_indices=False] k1 = np.array([[k1_mag*sp.sin(phi),k1_mag*sp.cos(phi)]], dtype=float).T
    cdef np.ndarray[double, ndim=2, negative_indices=False] k2 = np.array([[0.0, k2_mag]], dtype=float).T

    cdef np.ndarray[complex, ndim=2, negative_indices=False] k_vec = np.array(k1 + 1.0j*k2, dtype=complex)

    # complex propagation angle.  |k_vec||y_hat|cos(theta) = k_vec.y_hat
    cdef complex costheta=np.dot(k_vec.T, np.array([[0.0,1.0]]).T)[0,0]/sqrt(np.dot(k_vec.T,k_vec)[0,0])
    cdef complex new_theta = sp.arccos(costheta)

    return k_vec*1e-6, new_theta

cdef calc_2x2_inverse(M):
    new_array = np.empty((2,2), dtype=complex_type)
    new_array[0,0] = M[1,1]
    new_array[0,1] = -M[0,1]
    new_array[1,0] = -M[1,0]
    new_array[1,1] = M[0,0]
    return new_array/(M[0,0]*M[1,1] - M[0,1]*M[1,0])


#cdef coh_tmm_internalsource(int pol, np.ndarray[complex, ndim=1, negative_indices=False] n_list,
#            np.ndarray[double, ndim=1, negative_indices=False] d_list, int li, double yA, double phi_i, double lam_vac):
cpdef Tmm_data_internalsource coh_tmm_internalsource(int pol, np.ndarray[complex, ndim=1, negative_indices=False] n_list, 
        np.ndarray[double, ndim=1, negative_indices=False]  d_list, int li, double yA, double phi_i, double lam_vac):
    """
    Main "coherent transfer matrix method" calc. Given parameters of a stack,
    calculates everything you could ever want to know about how light
    propagates in it. (If performance is an issue, you can delete some of the
    calculations without affecting the rest.)
    
    pol is light polarization, tmm.TE or tmm.TM.
 
   
    n_list is the list of refractive indices, in the order that the light would
    pass through them. The 0'th element of the list should be the semi-infinite
    medium from which the light enters, the last element should be the semi-
    infinite medium to which the light exits (if any exits).
    
    phi_i is the angle of propagation in layer li - 0 for normal, pi/2 for glancing.
    This is the real-valued, geometric angle of propagation, not the complex angle of incidence.
    
    d_list is the list of layer thicknesses (front to back). Should correspond
    one-to-one with elements of n_list. First and last elements should be "inf".
    
    lam_vac is vacuum wavelength of the light.
    
    Outputs the following as a dictionary (see manual for details)
    r--reflection amplitude
    t--transmission amplitude
    R--reflected wave power (as fraction of incident)
    T--transmitted wave power (as fraction of incident)
    power_entering--Power entering the first layer, usually (but not always)
      equal to 1-R (see manual).
    vw_list-- n'th element is [v_n,w_n], the forward- and backward-traveling
      amplitudes, respectively, in the n'th medium just after interface with
      (n-1)st medium.
    kz_list--normal component of complex angular wavenumber for
      forward-traveling wave in each layer.
    th_list--(complex) propagation angle (in radians) in each layer
    pol, n_list, d_list, th_0, lam_vac--same as input
l
    """
    cdef np.ndarray th_list
    cdef np.ndarray kz_list
    cdef np.ndarray vw_list_l    
    cdef np.ndarray vw_list_r
    cdef np.ndarray r_list
    cdef np.ndarray t_list
    cdef Tmm_data_internalsource data

    cdef int num_layers
    cdef np.ndarray delta

    cdef np.ndarray M_list_l
    cdef np.ndarray M_list_r

    num_layers = n_list.size    
    #input tests
    if (n_list.ndim != 1) or (d_list.ndim != 1) or (n_list.size != d_list.size):
        raise ValueError("Problem with n_list or d_list!")
    if (d_list[0] != inf) or (d_list[num_layers - 1] != inf):
        raise ValueError('d_list must start and end with inf!')

    #print 'coh_tmm: n_list.imag', pol, n_list.imag

    #th_list is a list with, for each layer, the angle that the light travels
    #through the layer. Computed with Snell's law. Note that the "angles" may be
    #complex!

    #### MW Changed - compute snell angles based on theta in layer i, not angle of incidence on the top of stack
    k_vec, th_i = get_k_vec(n_list[li+1],lam_vac, phi_i)

### check conditions on the initial angle

    th_list = list_snell_li(n_list, th_i, li+1) +0.j


### check the conditions on the angle for the front layer (usually air) -pwils
    #print('reverse imag part at start and emission point  and back if neg andzerod out kz if small back em only ')
    if abs(np.real(n_list[0]*cos(th_list[0]))) < 1e-7:
        if np.imag(n_list[0]*cos(th_list[0])) > 0:
            th_list[0] = th_list[0]
        else:
            th_list[0] = np.pi - (th_list[0])
    if np.imag(n_list[li+1]*cos(th_list[li+1])) > 0:
        th_list[li+1] = th_list[li+1]
    else:
        th_list[li+1] = np.pi - th_list[li+1]
    # if np.imag(n_list[25]*cos(th_list[25])) > 0:
    #     th_list[25] = th_list[25]
    # else:
    #     th_list[25] = np.pi - th_list[25]
    # if abs(np.imag(n_list[0]*cos(th_list[0]))) < 1e-7:
    #     if np.real(n_list[0]*cos(th_list[0])) < 0:
    #         th_list[0] = th_list[0]
    #     else:
    #         th_list[0] = np.pi - (th_list[0])
# ###############

    #kz is the z-component of (complex) angular wavevector for forward-moving
    #wave. Positive imaginary part means decaying.
    kz_list = 2 * np.pi * n_list * sp.cos(th_list) / lam_vac
    for i in range(len(kz_list)):
        if n_list[i].imag == 0:
            kz_list[i] = kz_list[i].real + 0.j
        if abs(kz_list[i].real) < 1e-10:
            kz_list[i] = 0 + kz_list[i].imag

    #delta is the total phase accrued by traveling through a given layer.
    #ignore warning about inf multiplication
    olderr = sp.seterr(invalid= 'ignore')
    delta = kz_list * d_list
    sp.seterr(**olderr)
    
    #t_list[i,j] and r_list[i,j] are transmission and reflection amplitudes,
    #respectively, coming from i, going to j. Only need to calculate this when
    #j=i+1. (2D array is overkill but helps avoid confusion.)
    t_list = zeros((num_layers,num_layers),dtype=complex_type)
    r_list = zeros((num_layers,num_layers),dtype=complex_type)
    for i in xrange(num_layers-1):
        t_list[i,i+1] = interface_t(pol,n_list[i],n_list[i+1],
                                     th_list[i],th_list[i+1])
        r_list[i,i+1] = interface_r(pol,n_list[i],n_list[i+1],
                                     th_list[i],th_list[i+1])
    ####  MW - Big changes starting from here...

    #At the interface between the (n-1)st and nth material, let v_n be the
    #amplitude of the wave on the nth side heading forwards (away from the
    #boundary), and let w_n be the amplitude on the nth side heading backwards
    #(towards the boundary). Then (v_n,w_n) = M_n (v_{n+1},w_{n+1}). M_n is
    #M_list[n]. M_0 and M_{num_layers-1} are not defined.
    #My M is a bit different than Sernelius's, but Mtilde is the same.

    M_list_l = zeros((li+1,2,2),dtype=complex_type)
    M_list_r = zeros((num_layers-2-li,2,2),dtype=complex_type)

    # single pass transmission through layers.
    T_list_l = zeros((li+1), dtype=float)
    T_list_r = zeros((num_layers-2-li), dtype=float)

    for i in range(len(M_list_l)-1):
#        D = make_2x2_interface_matrix(r_list[i,i+1], t_list[i,i+1])
#        P = make_2x2_prop_matrix(delta[i+1])
#        M_list_l[i] =  np.dot(D,P)

        M_list_l[i] = (1./t_list[i,i+1]) * np.dot(
            make_2x2_array(1., r_list[i,i+1], r_list[i,i+1], 1., dtype=complex_type),
            make_2x2_prop_matrix(delta[i+1]))

        T_list_l[i] = abs(np.exp(1j*delta[i+1]) )
        #print 'L Matrix', i, '\nD\n', D, '\nP\n', P, '\nM\n', M_list_l[i]

    M_list_l[li] = (1./t_list[li,li+1]) * np.dot(
            make_2x2_array(1., r_list[li,li+1], r_list[li,li+1], 1., dtype=complex_type),
            make_2x2_prop_matrix(kz_list[li+1]*yA))

    T_list_l[li] = abs( np.exp(1j*kz_list[li+1]*yA) )

    M_list_r[0] = (1./t_list[li+1,li+2]) * np.dot(
            make_2x2_prop_matrix(kz_list[li+1]*(d_list[li+1]-yA)),
            make_2x2_array(1., r_list[li+1,li+2], r_list[li+1,li+2], 1., dtype=complex_type))
    T_list_r[0] = abs( np.exp(1j*kz_list[li+1]*(d_list[li+1]-yA)) )

    for i in xrange(li+1, li+len(M_list_r)):
        M_list_r[i-li] = (1./t_list[i+1,i+2]) * np.dot(
            make_2x2_prop_matrix(delta[i+1]),
            make_2x2_array(1., r_list[i+1,i+2], r_list[i+1,i+2], 1., dtype=complex_type))
        T_list_r[i-li] = abs( np.exp(1j*delta[i+1]) )

    # Build transfer matrices L0, N0
    # L0 -- front transfer matrix.  if any layer will absorb all incoming light, don't multiply --
    # treat it as the bounding semi-infinite medium and assume all fields in layers
    # beyond it are zero.

    L0 = make_2x2_array(1, 0, 0 ,1, dtype=complex_type)
    L_lim = 0
    for i in range(len(M_list_l), 0, -1):
         M = np.dot(M_list_l[i-1], L0)
         # print 'M[1,1] =', M[1,1]
         if T_list_l[i-1] > 1e-4 and abs(M[1,1]) > 1e-2:
              L0 = M # !!!
         else:
              #print('Full absorption, L_lim=', i)
              L_lim = i
              break
 
    # N0 -- back transfer matrix
    N0 = make_2x2_array(1,0,0,1, dtype=complex_type)
    N_lim = len(M_list_r -1)
    for i in range(len(M_list_r)):
         M = np.dot(N0, M_list_r[i])
         #print 'M[0,0]=', M[0,0]
         if T_list_r[i] > 1e-4 and abs(M[0,0]) < 1e2:
              N0 = M
         else:
         #     print 'Full absorption, N_lim=', i
              N_lim = i
              break

    # Fields to left (or top) of source. See (50), (51)
    #    if phi_i < pi/2:

    # forward emission
    Ef_l1 =  -L0[0,1]*N0[1,0] /(L0[0,1]*N0[1,0]+L0[0,0]*N0[0,0])
    Eb_l1 =   L0[0,0]*N0[1,0] /(L0[0,1]*N0[1,0]+L0[0,0]*N0[0,0])
    Ef_r1 = Ef_l1 + 1.
    Eb_r1 = Eb_l1
#    else:
        # see (56), (57)
    Ef_l2 = -L0[0,1]*N0[0,0] /(L0[0,1]*N0[1,0]+L0[0,0]*N0[0,0])
    Eb_l2 =  L0[0,0]*N0[0,0] /(L0[0,1]*N0[1,0]+L0[0,0]*N0[0,0])
    Ef_r2 = Ef_l2
    Eb_r2 = Eb_l2-1.

    vw=np.array([[ Ef_l1, Eb_l1]], dtype=complex_type).T

    # vw_list contains v,w at all interfaces plus emision point   
    vw_list_l1=zeros((li+2,2), dtype=complex_type)
    vw_list_r1=zeros((num_layers-li-1,2), dtype=complex_type)

    # Set v,w for layers left of source (when the emission occurs in the forward direction)
    vw_list_l1[li+1,:] = vw.T
    # stop short of the layer that absorbed all light above.
    for k in range(len(M_list_l), 0, -1):
        if k > L_lim:
           vw = np.dot(M_list_l[k-1], vw)
           vw_list_l1[k-1,:] = vw.T
           if abs(vw_list_l1[k-1, 0]) < 1e-9: #removed small Ef fields before error accrues -pwils (updated 1e-9 2023-04-18)
               break
        else:
           break

    vw=np.array([[ Ef_r1, Eb_r1]], dtype=complex_type).T

    # Fields to right of source (when the emission occurs in the forward direction)
    vw_list_r1[0,:] = vw.T
    for k in xrange(len(M_list_r)):
        if k < N_lim:
           vw = np.dot(calc_2x2_inverse(M_list_r[k]), vw)
           vw_list_r1[k+1,:] = vw.T
           #if abs(vw_list_r1[k-1, 1]) < 1e-9: #removed small Eb fields before error accrues -pwils
           #    break
        else:
             break

####### original
    vw=np.array([[ Ef_l2, Eb_l2]], dtype=complex_type).T # !!!
    #print 'wv_l', vw
    # vw_list contains v,w at all interfaces plus emision point
    vw_list_l2=zeros((li+2,2), dtype=complex_type)
    vw_list_r2=zeros((num_layers-li-1,2), dtype=complex_type)

    # Set v,w for layers left of source (when the emission occurs in the backward direction)
    vw_list_l2[li+1,:] = vw.T
    # stop short of the layer that absorbed all light above.
    for k in range(len(M_list_l), 0, -1):
        if k > L_lim:
           vw = np.dot(M_list_l[k-1], vw)
           vw_list_l2[k-1,:] = vw.T
           if abs(vw_list_l2[k-1, 0]) < 1e-9: #removed small Ef fields before error accrues -pwils
               break
        else:
           break

    vw=np.array([[ Ef_r2, Eb_r2]], dtype=complex_type).T

    # Fields to right of source (when the emission occurs in the backward direction)
    vw_list_r2[0,:] = vw.T
    for k in xrange(len(M_list_r)):
        if k < N_lim:
           vw = np.dot(calc_2x2_inverse(M_list_r[k]), vw)
           vw_list_r2[k+1,:] = vw.T
           #if abs(vw_list_r2[k-1, 1]) < 1e-9: #removed small Eb fields before error accrues -pwils
           #    break
        else:
             break
####### reversing the "forward" direction -pwils
#    vw=np.array([[ Ef_l2, Eb_l2]], dtype=complex_type).T
#    #print 'wv_l', vw
#    # vw_list contains v,w at all interfaces plus emision point
#    vw_list_l2=zeros((li+2,2), dtype=complex_type)
#    vw_list_r2=zeros((num_layers-li-1,2), dtype=complex_type)
#
#    # Set v,w for layers left of source
#    vw_list_l2[li+1,:] = vw.T
#    # stop short of the layer that absorbed all light above.
#    for k in xrange(len(M_list_l), 0, -1):
#        if k > L_lim:
#           vw = np.dot(calc_2x2_inverse(M_list_l[k-1]), vw)
#           vw_list_l2[k-1,:] = vw.T
#        else:
#           break
#
#    vw=np.array([[ Ef_r2, Eb_r2]], dtype=complex_type).T
#
#    # Fields to right of source
#    vw_list_r2[0,:] = vw.T
#    for k in xrange(len(M_list_r)):
#        if k < N_lim:
#           vw = np.dot(M_list_r[k], vw)
#           vw_list_r2[k+1,:] = vw.T
#        else:
#             break
#######################

    # print '\nvw_list_l\n', vw_list_l, '\nvw_list_r\n', vw_list_r
    cdef n_i = n_list[li+1]


    # component of Poynting vector in z direction, left and right of source.
    cdef float Sr1, Sr2
    cdef float Sl1, Sl2
    if pol == TE:
        Sr1 = (n_i*cos(th_i) * (Ef_r1.conjugate() + Eb_r1.conjugate())*( Ef_r1 - Eb_r1) ).real
        Sl1 = (n_i*cos(th_i) * (Ef_l1.conjugate() + Eb_l1.conjugate())*( Ef_l1 - Eb_l1) ).real
        Sr2 = (n_i*cos(th_i) * (Ef_r2.conjugate() + Eb_r2.conjugate())*( Ef_r2 - Eb_r2) ).real
        Sl2 = (n_i*cos(th_i) * (Ef_l2.conjugate() + Eb_l2.conjugate())*( Ef_l2 - Eb_l2) ).real

    elif pol == TM:
        Sr1 = (n_i*cos(th_i).conjugate() * (Ef_r1 + Eb_r1)*( Ef_r1.conjugate() - Eb_r1.conjugate() ) ).real
        Sl1 = (n_i*cos(th_i).conjugate() * (Ef_l1 + Eb_l1)*( Ef_l1.conjugate() - Eb_l1.conjugate() ) ).real
        Sr2 = (n_i*cos(th_i).conjugate() * (Ef_r2 + Eb_r2)*( Ef_r2.conjugate() - Eb_r2.conjugate() ) ).real
        Sl2 = (n_i*cos(th_i).conjugate() * (Ef_l2 + Eb_l2)*( Ef_l2.conjugate() - Eb_l2.conjugate() ) ).real

    else:
         raise ValueError

#    if li == 22 and abs(yA - (4.05390625 - 3.9890000000000008)) < 0.001: # yA - selected distance into layer 22
#        print '*** debugging output: yA = 4.05390625 in layer 22'
#        print 'vw_list_l1\n', vw_list_l1
#        print 'vw_list_r1\n', vw_list_r1
#        print 'vw_list_l2\n', vw_list_l2
#        print 'vw_list_r2\n', vw_list_r2
#        print 'M_list_l\n', M_list_l
#        print 'M_list_r\n', M_list_r
#        print 'L0\n', L0
#        print 'N0\n', N0
#        print 'delta_list\n', delta
#        print 'Sl2', Sl2, 'Sr2', Sr2
#    if li == 8 and abs(yA - (1.45940625 - 1.379)) < 0.001:
#        print '*** debugging output: yA = 1.45940625 in layer 8'
#        print 'vw_list_l1\n', vw_list_l1
#        print 'vw_list_r1\n', vw_list_r1
#        print 'vw_list_l2\n', vw_list_l2
#        print 'vw_list_r2\n', vw_list_r2
#        print 'M_list_l\n', M_list_l
#        print 'M_list_r\n', M_list_r
#        print 'r_list', r_list
#        print 't_lsit', t_list
#        print 'L0\n', L0
#        print 'N0\n', N0
#        print 'delta_list\n', delta
#        print 'Sl2', Sl2, 'Sr2', Sr2
 #   assert Sr - Sl > 0., 'Invalid power output, Sr={0}, Sl={1}'.format(Sr, Sl)
 # added the reflection and transmission coefficients to the dataset -pwils
    data = Tmm_data_internalsource()
    data.kz_list = kz_list;
    data.r_list = r_list;
    data.t_list = t_list;
    data.M_list_r = M_list_r;
    data.M_list_l = M_list_l;
    data.vw_list_r1 = vw_list_r1; data.vw_list_l1 = vw_list_l1;
    data.vw_list_r2 = vw_list_r2; data.vw_list_l2 = vw_list_l2;

    data.th_list = th_list; data.cos_th_list = sp.cos(th_list)
    data.pol = pol; data.n_list = n_list; data.d_list = d_list
    data.th_i = th_i ; data.lam_vac = lam_vac
    data.source_layer = li; data.yA = yA
    data.power_output1 = Sr1 - Sl1
    data.power_output2 = Sr2 - Sl2
    if data.power_output1 == 0. or data.power_output2 == 0.:
       print "li={0}, yA={1}, power_out1={2}, power_out2={3}".format(li, yA, data.power_output1, data.power_output2)
    return data

def check_layer(lk, data_TE, data_TM):
     result = False
     # print data_TE
     if lk < data_TE.source_layer:
          if abs(data_TE.vw_list_l1[lk+1][1]) > 1e-5 or abs(data_TM.vw_list_l1[lk+1][1]) > 1e-5:
               result = True
     elif lk > data_TE.source_layer:
          if abs(data_TE.vw_list_r1[lk-data_TE.source_layer][0]) > 1e-5 or abs(data_TM.vw_list_r1[lk-data_TM.source_layer][0]) > 1e-5:
               result = True
     else:
          result = True
     return result

# find absorption density at an arbitrary position in the stack.
# cdef position_resolved_a(int layer, double dist, Tmm_data_internalsource data):
cdef inline double position_resolved_a(int layer, double dist, Tmm_data_internalsource data):
    """
    Starting with output of coh_tmm(), calculate the Poynting vector
    and absorbed energy density a distance "dist" into layer number "layer"

    layer is the index from zero in the multilayer stack.
    """

    assert layer < len(data.d_list)-2, 'Invalid layer {0}'.format(layer)
    assert data.d_list[layer+1] - dist >= -1e-10, 'invalid dist={0}, d={1}, diff {2}'.format(dist, data.d_list[layer+1], data.d_list[layer+1]-dist)
    assert data.power_output1 != 0., 'data.power_output1 = {0}'.format(data.power_output1)
    assert data.power_output2 != 0., 'data.power_output2 = {0}'.format(data.power_output2)

    cdef complex kz  = data.kz_list[layer+1]
    cdef complex th  = data.th_list[layer+1]
    cdef complex cos_th = data.cos_th_list[layer+1]
    cdef complex n   = data.n_list[layer+1]
    cdef complex n_i = data.n_list[data.source_layer+1]
    cdef complex th_i = data.th_i
    cdef complex Ef1, Ef2
    cdef complex Eb1, Eb2
    cdef int pol = data.pol
    cdef float a1
    cdef float a2
    cdef float absor= 0.0

    cdef int lk
    cdef complex vw0_1, vw1_1, vw0_2, vw1_2
    cdef complex mult
    cdef complex r = data.r_list[layer, layer + 1]
    cdef complex t = data.t_list[layer, layer + 1]
    #cdef complex rt_factor


    if (layer < data.source_layer): # calculations with asorbing layers above (left of) the
         # dist will be negative    # the emitting layer have been problematic (absorptance blows up)
         dist = -(data.d_list[layer+1] - dist) # calculating from other side of the layer, so dist is now positive and equal to yB
         #rt_factor = 1/(t*(1 - r*r))
         vw0_1 = data.vw_list_l1[layer+1][0] # vw0_1 = rt_factor*(data.vw_list_l1[layer][0] - r*data.vw_list_l1[layer][1]) # (Ef - r*Eb)/(t(1-r^2)), convert to the other side of the layer boundary #vw0_1 = data.vw_list_l1[layer+1][0]
         vw1_1 = data.vw_list_l1[layer+1][1] # vw1_1 = rt_factor*(-r*data.vw_list_l1[layer][0] + data.vw_list_l1[layer][1])# (-r*Ef + Eb)/(t(1-r^2))                                                 #vw1_1 = data.vw_list_l1[layer+1][1]
         vw0_2 = data.vw_list_l2[layer+1][0] #vw0_2 = rt_factor*(data.vw_list_l2[layer][0] - r*data.vw_list_l2[layer][1]) # same as above except this accounts for the opposite direction emission  #vw0_2 = data.vw_list_l2[layer+1][0]
         vw1_2 = data.vw_list_l2[layer+1][1] #vw1_2 = rt_factor*(-r*data.vw_list_l2[layer][0] + data.vw_list_l2[layer][1])#                                                                         #vw1_2 = data.vw_list_l2[layer+1][1]

    elif layer == data.source_layer:
        if dist < data.yA:
            # dist is negative
            dist = -(data.yA - dist)
            vw0_1 = data.vw_list_l1[layer+1][0]
            vw1_1 = data.vw_list_l1[layer+1][1]
            vw0_2 = data.vw_list_l2[layer+1][0]
            vw1_2 = data.vw_list_l2[layer+1][1]

        else:
            dist = dist - data.yA
            vw0_1 = data.vw_list_r1[0][0]
            vw1_1 = data.vw_list_r1[0][1]
            vw0_2 = data.vw_list_r2[0][0]
            vw1_2 = data.vw_list_r2[0][1]

    else:
         vw0_1 = data.vw_list_r1[layer - data.source_layer][0]
         vw1_1 = data.vw_list_r1[layer - data.source_layer][1]
         vw0_2 = data.vw_list_r2[layer - data.source_layer][0]
         vw1_2 = data.vw_list_r2[layer - data.source_layer][1]

    mult = np.exp( 1j * kz*dist) # multiplier for the positive forward coordinate system
		#mult = np.exp(-1j*kz*dist)   # multiplier for the positve backward coordinate system (essentially -
    # for thick layers, mult may be very large or small, and calculations blow up.  In reality a wave must be attenuated on the     
    # outward pass, so the return pass is not significant.

    if abs(mult) < 1e6:
        Ef1 = vw0_1 * mult # TODO: test whether forward and backward make symettric matrices by themselves
        Ef2 = vw0_2 * mult # backward emissions take the reversed direction as their positive (forward coordinate system) compared to forward emsissions
    else:
        Ef1 = 0.0
        Ef2 = 0.0

    if abs(mult) > 1e-6:
       Eb1 = vw1_1 / mult
       Eb2 = vw1_2 / mult
    else:
       Eb1 = 0.0
       Eb2 = 0.0

    #amplitude of forward-moving wave is Ef, backwards is Eb
    # with transmission into very thick absorbing layers (like a 300 um substrate)
    # Ef may be very small and Eb may overflow.  These cases are not important though because
    # the field is too small to matter.

    assert n.imag >= 0.0, "Negative absorption in layer lk={0}, n= {1}, nlist={2}".format(layer, n, data.n_list)
    
    #absorbed energy density
    if(pol==TE):
        a1 = abs(Ef1+Eb1)
        a1 = a1*a1
        absor = 0.5*a1*(n*cos_th*kz).imag / data.power_output1
        a1 = abs(Ef2+Eb2)
        a1 = a1*a1
        absor += 0.5*a1*(n*cos_th*kz).imag / data.power_output2


    elif(pol==TM):
        a1 = abs(Ef1+Eb1)
        a1 = a1*a1
        a2 = abs(Ef1-Eb1)
        a2 = a2*a2
        absor = 0.5*(n*cos_th.conjugate() * (kz*a2-kz.conjugate()*a1) ).imag / data.power_output1
        a1 = abs(Ef2+Eb2)
        a1 = a1*a1
        a2 = abs(Ef2-Eb2)
        a2 = a2*a2
        absor += 0.5*(n*cos_th.conjugate() * (kz*a2-kz.conjugate()*a1) ).imag / data.power_output2
    else:
        raise ValueError, 'invalid polarization value'
    if abs(absor) > 2000. or np.isnan(absor):
       print '\n**** Excess absorption'
       print 'Emission - from layer', data.source_layer, 'yA=', data.yA, 'th=', data.th_i, 'pol=', pol
       print 'absorbed at layer', layer, 'dist=', dist, 'wl=', data.lam_vac, 'n=', n
       print 'vw0_1', vw0_1, 'vw1_1', vw1_1, 'vw0_2', vw0_2, 'vw1_2', vw1_2, 'kz', kz
       print 'mult', mult
       print '\nEf1', Ef1, 'Eb1', Eb1, '\nEf2', Ef2, 'Eb2', Eb2
       print 'n_list\n', data.n_list
       print 'kz_list\n', data.kz_list
       print 'th_list\n', data.th_list
       # print 'vw_list_l2\n', data.vw_list_l2, '\nvw_list_r2\n', data.vw_list_r2
       print 'M_list_l', data.M_list_l
       # print 'M_list_r', data.M_list_r
       print 'r_list', [data.r_list[i,i+1] for i in range(len(data.n_list)-1)]
       print 't_lsit', [data.t_list[i,i+1] for i in range(len(data.n_list)-1)]
       # sys.exit()
       print  '(vw_list_l2)\n', data.vw_list_l2, '\n(vw_list_r2)\n', data.vw_list_r2#, '\nEf', Ef1, 'Eb', Eb1, '\nEf2', Ef2, 'Eb2', Eb2
       print '(vw_list_l1)\n', data.vw_list_l1, '\n(vw_list_r1)\n', data.vw_list_r2
       print 'absor', absor, 'power_out2', data.power_output2
#    else:
#       print '\n**** Absorption values okay'
#       print 'Emission - from layer', data.source_layer, 'yA=', data.yA, 'th=', data.th_i, 'pol=', pol
#       print 'absorbed at layer', layer, 'dist=', dist, 'wl=', data.lam_vac, 'n=', n
#       print 'vw0_1', vw0_1, 'vw1_1', vw1_1, 'vw0_2', vw0_2, 'vw1_2', vw1_2, 'kz', kz
#       print 'mult', mult
#       print '\nEf1', Ef1, 'Eb1', Eb1, '\nEf2', Ef2, 'Eb2', Eb2
#       print 'n_list\n', data.n_list
#       print 'kz_list\n', data.kz_list
#       print 'th_list\n', data.th_list/pi
#       print 'vw_list_l2\n', data.vw_list_l2, '\nvw_list_r2\n', data.vw_list_r2
#       print 'M_list_l', data.M_list_l
#       print 'M_list_r', data.M_list_r
       #print  'abs(vw_list_l2)\n', abs(data.vw_list_l2), '\nabs(vw_list_r2)\n', abs(data.vw_list_r2), '\nEf', Ef1, 'Eb', Eb1, '\nEf2', Ef2, 'Eb2', Eb2
#       print 'absor', absor, 'power_out2', data.power_output2
#       raise ValueError
    return absor
