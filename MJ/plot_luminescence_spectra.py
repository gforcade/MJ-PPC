import os, sys

sys.path.append(os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', 'Python'))
sys.path.append(os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', 'Python', 'tmm'))

import h5py
import pyximport; pyximport.install()
import epi_cmd_LC
from scipy.integrate import trapz
import numpy as np
import matplotlib.pyplot as plt
import seaborn as sns
import itertools

sns.set_theme(style = 'whitegrid',font_scale = 1.5, rc = {"font.size": 20, "lines.linewidth": 2})
colours = sns.color_palette('Set1')
colours_list = {'InP': colours[0], 'InAlAs': colours[1], 'InGaAs': colours[2],
                    'GaInP': colours[3], 'GaAs': colours[4], 'TaO': colours[5], 'MgF': colours[6]}

LC_node = 555
epi_node = 75
sde_node = 79
MatPar_node = 91
wtot = 1.

e_charge = 1.602e-19 # C
h = 6.626e-34      # J.s
c0 = 299792458.0   # m/s
kb = 1.3806488e-23 # J/K

print('***')
print('*** Plot data used for luminescent coupling')

# Open an epi file
e = epi_cmd_LC.epifile('results/nodes/' + str(epi_node) + '/pp'+ str(epi_node) + '_epi.cmd')
#e.bottom_material('Gold', 'Gold.par', 0, 0)
# Add MatPar data to the epi layer stack
# including n,k vs. wavelength and B_rad
e.read_parfiles('results/nodes/' + str(MatPar_node) + '/n' + str(MatPar_node) + '_mpr.par')

print('')
f1 = plt.figure(1)
ax1 = f1.add_subplot(1,2,1)
ax2 = f1.add_subplot(1,2,2)

f2 = plt.figure(2)
ax2_1 =f2.add_subplot(1,2,1)
ax2_2 =f2.add_subplot(1,2,2)

palette0 = itertools.cycle(colours)
palette00 = itertools.cycle(colours)
material_list = []
for li in range(len(e.layers)):
   if e.layers[li].material_type == 'Semiconductor' and (e.layers[li].material).lstrip(' ') not in material_list:
      Eg = e.layers[li].Eg_300
      if e.layers[li].material == 'GaAs':
          Eg -= 0.01*e_charge
      material_list.append((e.layers[li].material).lstrip(' '))
      print(e.layers[li].name, 'Eg=', Eg/e_charge)
      print(e.layers[li].par['Bandgap'])
      wls = e.layers[li].wl_list
      S_hats = np.zeros(len(wls))
      for i in range(len(wls)):
           S_hats[i] = e.layers[li].S_hat(i)
      print(S_hats)
      ax1.plot(wls, S_hats, label=(e.layers[li].material).lstrip(' '),
               color = colours_list[(e.layers[li].material).lstrip(' ')], marker = 'o', markeredgecolor = 'k', ls = '-')
      ax2.plot(wls, e.layers[li].alpha_list, label=(e.layers[li].material).lstrip(' '),
               color = colours_list[(e.layers[li].material).lstrip(' ')], marker = 'o', markeredgecolor = 'k', ls = '-')
#      ax1.axvline(1e6*h*c0/Eg, c='k', linewidth=0.2)
#      ax2.axvline(1e6*h*c0/Eg, c='k', linewidth=0.2)

#plot nk data
material_list = []
emission_range = np.linspace(e.wl_emission_min, e.wl_emission_max, 50)

palette1 = itertools.cycle(colours)
palette2 = itertools.cycle(colours)
for li in range(len(e.layers)):
    if (e.layers[li].material).lstrip(' ') not in material_list:
      material_list.append((e.layers[li].material).lstrip(' '))
      nk_vals = [e.layers[li].nk(x) for x in emission_range]
      ax2_1.plot(emission_range, np.real(nk_vals), label = (e.layers[li].material).lstrip(' '),
                 color = colours_list[(e.layers[li].material).lstrip(' ')], ls = '-', marker = 'o', markeredgecolor = 'k')
      ax2_2.plot(emission_range, np.imag(nk_vals), label = (e.layers[li].material).lstrip(' '),
                 color = colours_list[(e.layers[li].material).lstrip(' ')], ls = '-', marker = 'o', markeredgecolor = 'k')

ax1.set_xlabel('Wavelength $\mathit{\lambda}$ ($\mu m$)')
ax2.set_xlabel('Wavelength $\mathit{\lambda}$ ($\mu m$)')
ax1.set_ylabel('Normalized Distribution of Luminescence $\mathit{\hat S}$ ($\/ J^{-1}$)')
ax2.set_ylabel('$\mathit{\\alpha}$ ($\mu m^{-1}$)')

ax2_1.set_xlabel('Wavelength $\mathit{\lambda}$ ($\mu m$)')
ax2_1.set_ylabel('Re(n)')
ax2_2.set_xlabel('Wavelength $\mathit{\lambda}$ ($\mu m$)')
ax2_2.set_ylabel('Im(n)')


ax1.legend()
ax2.legend()
ax2_1.legend()
plt.show()
