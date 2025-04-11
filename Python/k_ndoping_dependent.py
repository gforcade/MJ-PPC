# -*- coding: utf-8 -*-
"""
Created on Tue Sep 27 17:57:55 2022

k data calculated assuming equations from Anderson, "Absorption Constant of Pb1 -xSnxTe and Hg1 -xCdxTe Alloys," Infrared physics, 1980.

Auther: Gavin Forcade
"""


 

def inv_calc(a,b):
    #calculate the inverse, useful for numpy array manipulations
    return a/b



def np_factor(delt,Eg,m0_star):
    #nonparabolicity factor up to k**6. Raymond et al. 1979.
    # take delta, Eg in eV.  m0_star in m0 units.
    x = delt / Eg
    return (1.0 - m0_star/m_0)**2.0 * (1.0 + x + 0.25*x**2.0)/(1.0 + 4.0/3.0*x + 4.0/9.0*x**2.0) / Eg  




def fermi(t,phi,N):
    #calculates the n-type fermi energy for nonparabolic conduction band, with alpha = 1/E_0
    def func(x):
        return x**0.5*(1.0 + x/phi)**(0.5)*(1.0 + 2.0*x/phi)/(1.0 + np.exp(x - t))
    #integration function
    integ = integrate.quad(func,0.0,10.0**2)
    return abs(integ[0] - N)       




def k_omega(omega,E0_T_InAs_value,P,mh):
    #equation in Anderson 1980 paper (Eq. 18)
    #breaking down equation  #divide P by 100 to convert from eVcm to eVm #divide P term by e to convert to eV3 s2 kg-1 
    lump = (1.0 + m_0/mh)*(2.0*hbar_eV*omega/E0_T_InAs_value - 1.0)
    k1 = (4.0/3.0*(P/100.0)**2.0/e + hbar_eV**2.0*E0_T_InAs_value/m_0*lump)/ (hbar_eV**4.0/m_0**2.0 * (1.0 + m_0/mh)**2.0)
    k2 = 1.0 - (1.0 - (4.0*hbar_eV**4.0/(m_0)**2*(1 + m_0/mh)**2.0*hbar_eV*omega*(hbar_eV*omega - E0_T_InAs_value))/(4.0/3.0*(P/100.0)**2.0/e + hbar_eV**2.0*E0_T_InAs_value/m_0*lump)**2.0 )**(0.5)
    return k1*k2  #outputs k**2 [kg eV-1 s-2] 





def BM(omega,T,mh,k_om,F):
    #Burstein-Moss effect #Anderson 1980 Eq. 17
    top = -np.expm1(-hbar_eV*omega/(kb*T))
    bot = 1.0 + np.exp(- (F + hbar_eV**2.0*k_om/(2*mh))/(kb*T))
    bot2 = 1.0 + np.exp(- (hbar_eV*omega - F - hbar_eV**2.0*k_om/(2.0*mh))/(kb*T) )
    return top/(bot*bot2)





def alpha_lh(omega,E0_T_InAs_value,eps_inf,P):
    #function for light hole band absorption #Anderson 1980 Eq. 14
    return (1.0 + 2.0*(E0_T_InAs_value/(hbar_eV*omega))**2.0)*(abs((hbar_eV*omega)**2.0 - E0_T_InAs_value**2.0))**(0.5)/(137.0*(6.0*eps_inf)**(0.5)*4.0*P)*100.0  #multiplied by 100 to convert cm to m




def alpha_hh(omega,E0_T_InAs_value,eps_inf,P,mhh,k_om):
    #function for heavy hole band absorption #Anderson 1980 Eq. 16
    #the approximate version
    #return (3.0/2.0*hbar_eV*omega*(abs(hbar_eV*omega - E0_T_InAs_value)))**(0.5)/(137.0*eps_inf**(0.5)*P*(1.0 + 3.0/(4.0*m_0*P**2.0)*e*100.0**2.0*hbar_eV**2.0*E0_T_InAs_value*(1.0 + m_0/mhh)*(2.0*hbar_eV*omega/E0_T_InAs_value - 1.0)))*100.0 #multiply by 100 to convert cm to m, and by e to convert eV to J
    #the exact version 
    sqr = (1.0 + 8.0*(P/100.0)**2.0*(k_om/e)/(3.0*E0_T_InAs_value**2.0))**(0.5)
    top = E0_T_InAs_value*(abs(k_om/e))**(0.5)/(hbar_eV*omega*2.0)*(sqr + 1.0) #k from kg eV-1 s-2 to m-1
    bot = 137.0*eps_inf**(0.5)*(1.0 + 3.0/4.0*hbar_eV**2.0*E0_T_InAs_value*e*(1.0 + m_0/mhh)*sqr/(m_0*(P/100.0)**2.0))
    return top/bot 




def k_ext(omega,E0_T_InAs_value,eps_inf,P,mhh,mlh,T,F,n_or_p):
    #total extinction coefficient from IB absorption
    k_om = k_omega(omega,E0_T_InAs_value,P,mhh)
    if n_or_p == 0:    #using moss-burstein effect when n_type
        alpha_lb = np.where(hbar_eV*omega <= E0_T_InAs_value,0.0,alpha_lh(omega,E0_T_InAs_value,eps_inf,P)*BM(omega,T,mlh,k_om,F) + alpha_hh(omega,E0_T_InAs_value,eps_inf,P,mhh,k_om)*BM(omega,T,mhh,k_om,F))
    else: #p-type material, thus dont include moss-burstein effect
        alpha_lb = np.where(hbar_eV*omega <= E0_T_InAs_value,0.0, alpha_lh(omega,E0_T_InAs_value,eps_inf,P) + alpha_hh(omega,E0_T_InAs_value,eps_inf,P,mhh,k_om) ) #alpha_lh(omega,E0_T_InAs_value,eps_inf,P) + alpha_hh(omega,E0_T_InAs_value,eps_inf,P,mhh,k_om)
    return alpha_lb*c/(2.0*omega) #returns k (extinction coefficient)


def tcl_to_python(k_in,anderson_cutoff,wl,Eg, delt ,eps_inf, P, Nc,N0,me, mhh,mlh,T):
    #convert things to be useful in python
    omega = inv_calc(2*np.pi*c*1e6,np.asarray(wl.split(' '),dtype=float))	#wl in um
    k_in = np.asarray(k_in.split(' '),dtype=float)				
    Eg = float(Eg)	#[eV]
    delt = float(delt)	#[eV]
    P = float(P)	#[eV cm]
    eps_inf = float(eps_inf)
    me = float(me)*m_0	#[kg]
    mhh = float(mhh)*m_0	#[kg]
    mlh = float(mlh)*m_0	#[kg]
    T = float(T)
    Nc = float(Nc)
    N0 = float(N0)
    if N0 > 0: #n-type
        n_or_p = 0
        #calculating the fermi energy
        res = optimize.minimize(fermi,0.0,args=(1.0/(kb*T*np_factor(delt,Eg,me)),np.pi**(0.5)/2.0*N0/(Nc)),method="Nelder-Mead") #Nc from cm-3 to m-3
        F = res.x[0]*kb*T + Eg #fermi energy relative to the valence band
    else: #p-type
        n_or_p = 1 
        N0 = abs(N0)
        F = 0.0
    k = k_ext(omega,Eg,eps_inf,P,mhh,mlh,T,F,n_or_p)
    k = np.where(np.asarray(wl.split(' '),dtype=float) < float(anderson_cutoff),k_in,k)
    np.savetxt(sys.stdout,k,newline=' ',fmt="%.5f")


if __name__=='__main__':
    import sys
    import numpy as np
    from scipy import integrate,optimize
    m_0 =0.9109e-30		#kg
    hbar_eV = 6.5821e-16 	#eV s 
    e= 1.602e-19		#C
    c= 3e8			#m/s
    kb = 8.617333e-5 	#eV K-1
    tcl_to_python(*sys.argv[1:])





