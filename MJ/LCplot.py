from mpl_toolkits.mplot3d import Axes3D
from mpl_toolkits.mplot3d.art3d import Poly3DCollection, Line3D
from matplotlib.cm import ScalarMappable
from matplotlib.colors import Normalize
import matplotlib.pyplot as plt
import numpy as np

plt.rcParams['text.usetex']=True
plt.rcParams['font.family']='sans-serif'
plt.rcParams['font.sans-serif']='Helvetica, Bitstream Vera Sans, Lucida Grande, Verdana, Geneva, Lucid, Arial, Helvetica, Avant Garde, sans-serif'
plt.rcParams['text.latex.preamble']=r'\usepackage{sansmath}\sansmath'
plt.rcParams['font.size']=7.
plt.rcParams['figure.figsize']=(3.5,3.5)
plt.rcParams['figure.subplot.top']=1.
plt.rcParams['figure.subplot.left']=0.
plt.rcParams['figure.subplot.right']=1.

#titles = ['J1', 'J2', 'J3', 'J4', 'J5', 'J6', 'J7', 'J8', 'J9', 'J10', 'J11', 'J12']
titles = ['']*12

row = [[0.33, 0.20, 0.12, 0.08, 0.06, 0.05, 0.03, 0.03, 0.02, 0.01, 0.01, 0.00],
       [0.15, 0.31, 0.16, 0.10, 0.07, 0.05, 0.04, 0.03, 0.02, 0.01, 0.01, 0.00],
       [0.08, 0.15, 0.28, 0.15, 0.09, 0.06, 0.04, 0.03, 0.02, 0.01, 0.01, 0.00],
       [0.06, 0.08, 0.13, 0.28, 0.15, 0.09, 0.06, 0.04, 0.03, 0.02, 0.01, 0.00],
       [0.04, 0.05, 0.07, 0.13, 0.30, 0.15, 0.08, 0.05, 0.03, 0.02, 0.01, 0.00],
       [0.02, 0.03, 0.04, 0.07, 0.13, 0.32, 0.16, 0.08, 0.05, 0.03, 0.02, 0.01],
       [0.02, 0.02, 0.03, 0.04, 0.06, 0.13, 0.34, 0.17, 0.08, 0.04, 0.02, 0.01],
        [0.01, 0.01, 0.01, 0.02, 0.03, 0.06, 0.14, 0.38, 0.18, 0.08, 0.04, 0.01],
       [0.01, 0.01, 0.01, 0.01, 0.02, 0.03, 0.05, 0.14, 0.43, 0.19, 0.07, 0.02],
       [0.00, 0.00, 0.00, 0.01, 0.01, 0.01, 0.02, 0.04, 0.13, 0.51, 0.19, 0.04],
       [0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.01, 0.01, 0.03, 0.12, 0.63, 0.18],
       [0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.01, 0.05, 0.89]]

length = len(titles)
fig = plt.figure()
ax = fig.add_subplot(111, projection='3d')
x = np.arange(length)+0.5
y = np.zeros(12)
z = np.array(row)
width = 1.

sm = ScalarMappable(cmap='viridis', norm=Normalize(vmin=-.1, vmax=0.4))
for i in range(len(row)):
    colors = sm.to_rgba(row[i])
    for j in range(len(row[i])):
        ax.bar3d(j+0.5, y+i+0.5, np.zeros(length), 0.75, 0.75, row[i][j], color=colors[j], linewidth=0.5)

    
ax.set_xticks(x + width/2)
ax.set_xticklabels(titles, rotation=0)
ax.set_yticklabels(titles, rotation=0)
ax.set_yticks(x+width/2)

ax.set_xlabel('Absorbing Junction \unsansmath $l$', labelpad=-6)
ax.set_ylabel('Emitting Junction \unsansmath $i$', labelpad=-4)
ax.zaxis.set_rotate_label(False)
ax.set_zlabel('Coupling factor \unsansmath $K_{il}$', labelpad=-6, rotation=90)
ax.set_xlim(0,13)
ax.set_ylim(0,13)
ax.set_zlim(0.012,0.9)
ax.set_aspect('equal')
ax.tick_params(pad=0)

for i in range(12):
    ax.text(i*(19/12.)-3.4, -2.7, 0, str(i+1), fontsize=6.)
    ax.add_artist(Line3D((i*(18/12.)-2, i+1), (-2.0, -0.5),(0,-0.005), color='0.8'))
    ax.text(-3.8, i*(15/12.)-0.10, 0, str(i+1), fontsize=6.)
    ax.add_artist(Line3D((-2.4, -0.5), (i*(14/12.)+.3, i+1),(0,-0.005), color='0.8'))

ax.view_init(azim=-143,elev=19)
#fig.autofmt_xdate()
fig.tight_layout()
plt.show()
