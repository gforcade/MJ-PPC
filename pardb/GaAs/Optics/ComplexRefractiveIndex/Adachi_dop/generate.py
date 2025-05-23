import numpy
import csv
from glob import glob
import matplotlib.pyplot as plt
import copy 
import string 

Adachi_data = dict()
Adachi_data['wl'] = []
Adachi_data['n'] = []
Adachi_data['k'] = []
with open('GaAs.dat', 'rb') as f:
	reader = csv.reader(f)
	for r in reader:
	    if float(r[0]) < 0.788:
		Adachi_data['wl'].append(float(r[0]))
		Adachi_data['n'].append(float(r[1]))
		Adachi_data['k'].append(float(r[2]))		


Levinshtein_data = dict()
new_data = dict()
for fname in glob('../../TableODB/Levinshtein/levinshtein*.par'):
	dop = float(fname.split('-')[-1].split('.')[0])
	typ = fname.split('-')[1]
	if typ == 'p':
		dop = -dop
	print fname, dop
	Levinshtein_data[dop] = dict()
	new_data[dop] = dict()
	Levinshtein_data[dop]['wl'] = []
	Levinshtein_data[dop]['n'] = []
	Levinshtein_data[dop]['k'] = []
	with open(fname, 'rb') as f:
		reader = csv.reader(f, delimiter=' ')
		for r in reader:
		   if r[0]!= '#' and float(r[0]) >= 0.788:
   			Levinshtein_data[dop]['wl'].append(float(r[0]))		
   			Levinshtein_data[dop]['n'].append(float(r[1]))
   			Levinshtein_data[dop]['k'].append(float(r[2]))
	new_data[dop]['wl'] = copy.copy(Adachi_data['wl'])	
	new_data[dop]['n'] = copy.copy(Adachi_data['n'])
	new_data[dop]['k'] = copy.copy(Adachi_data['k'])
	
	last_i = len(Adachi_data['wl'])-1
	prev_k = Adachi_data['k'][last_i-10]
	prev_wl = Adachi_data['wl'][last_i-10]
	next_k = Levinshtein_data[dop]['k'][0]
	next_wl = Levinshtein_data[dop]['wl'][0]

	for k in range(last_i-9, last_i+1):
		new_data[dop]['k'][k] = (Adachi_data['wl'][k]-prev_wl)*(next_k-prev_k)/(next_wl-prev_wl) + prev_k
	new_data[dop]['wl'] = new_data[dop]['wl'] + Levinshtein_data[dop]['wl']
	new_data[dop]['n'] = new_data[dop]['n'] + Levinshtein_data[dop]['n']
	new_data[dop]['k'] = new_data[dop]['k'] + Levinshtein_data[dop]['k']
	
f = plt.figure()
ax1 = f.add_subplot(2,1,1)
ax2 = f.add_subplot(2,1,2)

ax1.plot(Adachi_data['wl'], Adachi_data['n'], '-x', label ='A')
ax2.plot(Adachi_data['wl'], Adachi_data['k'], '-x', label ='A')
for key in Levinshtein_data.keys():
	print key
	if key <0:
		style = '--'
	else:
		style = '-+'
	ax1.plot(new_data[key]['wl'], new_data[key]['n'], style, label='L ' + str(key))
	ax2.plot(new_data[key]['wl'], new_data[key]['k'], style, label='L ' + str(key))
ax1.set_ylabel('n')
ax2.set_ylabel('k')
ax1.set_xlim(0.6, 0.95)
ax2.set_xlim(0.6, 0.95)
ax2.set_ylim(0,0.2)

for d in new_data.keys():
	if d < 0:
		dtype = 'p'
	else:
		dtype = 'n'
	with open('Adachi_dop-' + dtype + '-' + string.join(str(abs(d)).split('+'), '') + '.dat', 'wb') as newfile:
		wr = csv.writer(newfile, delimiter=' ')
		wr.writerow(['# GaAs n,k data based on Adachi, with doping-dependent near-bandedge data from Casey'])
		wr.writerow(['# This data file generated using generate.py'])
		wr.writerow(['# See Adachi_dop.tcl for details.'])
		wr.writerow(['# '])
		for r in range(len(new_data[d]['wl'])):
			wr.writerow([new_data[d]['wl'][r], new_data[d]['n'][r], new_data[d]['k'][r]])


ax2.legend()
plt.show()
