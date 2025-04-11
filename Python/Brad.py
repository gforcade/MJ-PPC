
## using the model proposed by lumb to calculate Brad.
## includes photon recycling within the same layer
## Lumb et al., "Incorporating photon recycling into the analytical drift-diffusion model of high efficiency solar cells," 2014.


def Brad_PR(t,wl,n,k,Eg,T,Nc,Nv):	
	
	#nkDataFile is the directory to the nk data, see below for rest of input definitions

	##define constants
	h = 6.62607015e-34	#[m2kg/s]
	c = 3e8			#[m/s]
	e = 1.602e-19		#[C]
	heV = h/e		#[eV s]
	kB = 8.617333e-5	#[eVK-1]
	Eg = float(Eg)		#[eV]	layer bandgap
	t = float(t)*1e-6	#[m]	layer thickness
	T = float(T)		#[K]	layer temperature
	Nc = float(Nc)*1e2**3	#[m-3]	conduction band density of states
	Nv = float(Nv)*1e2**3	#[m-3]	valence band density of states
	ni2 = Nc*Nv*np.exp(-Eg/(kB*T))	#[m-6]
	rad_step = 1e-3		#[rad] angle integration step size
	E_step = 0.001		#[eV] energy integration step size
	n = np.asarray(n.split(' '),dtype=float)
	k = np.asarray(k.split(' '),dtype=float)
	wl = np.asarray(wl.split(' '),dtype=float)	#[um]


	##load nk data
	E_old = np.flipud(h*c/e/wl*1e6)
	n = np.flipud(n)
	k = np.flipud(k)
	E = np.arange(Eg-0.1,Eg+0.5,E_step)
	n = np.interp(E,E_old,n)
	abs_coef = 4.0*np.pi*np.interp(E,E_old,k)*E*e/(h*c)


	##compute Brad
	Fermi_Dirac = np.exp( E/(kB*T)) - 1.0
	SE =  np.trapz(abs_coef * n**2 * E**2 / Fermi_Dirac,E)			#SE: got rid of 2/(h^3c^2) as f ~ J_em/SE cancels it out 
	Brad = SE * 2.0 / (heV**3 * c**2 * ni2 * 100**-3) * 4.0 * np.pi		#[cm3 s-1] 	# Lumb had typo in their paper, should be 8pi and not 2pi


	##compute photon recycling factor
	abs_front = np.zeros(len(E))
	abs_rear = np.zeros(len(E))
	abs_rear_crit = np.zeros(len(E))
	#loop through energies for angle integration
	for indE in range(len(E)):
		#light transmitting through front at angles less than critical angle,
		angle = np.arange(0.0,np.arcsin(1.0/n[indE]),rad_step)
		abs_front[indE] = np.trapz((1.0-np.exp(-t*abs_coef[indE]/np.cos(angle))) * np.sin(angle) * np.cos(angle),angle)
		#rear absorption: integrate up to critical angle assuming full path absorption (light escapes), and double pass above this angle (trapped light)
		abs_rear[indE] = np.trapz((1.0-np.exp(-t*abs_coef[indE]/np.cos(angle))) * np.sin(angle) * np.cos(angle),angle)
		angle = np.arange(np.arcsin(1.0/n[indE]),np.pi/2.0,rad_step)
		abs_rear_crit[indE] = np.trapz((1.0-np.exp(-2.0*t*abs_coef[indE]/np.cos(angle))) * np.sin(angle) * np.cos(angle),angle)
	J_em =  np.trapz(E**2 / Fermi_Dirac * 2.0 * np.pi * n**2 * (abs_front + abs_rear + abs_rear_crit),E)				#J_em: got rid of 2/(h^3c^2) as f ~ J_em/SE cancels it out 
	f = 1.0 - J_em / (4.0 * np.pi * t * SE)

	print(Brad)
	#print(f)



if __name__=='__main__':
	import sys
	import numpy as np
	Brad_PR(*sys.argv[1:])
