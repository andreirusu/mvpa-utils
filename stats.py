from mvpa2.suite import *
from scipy.stats import ks_2samp
import numpy as np
import matplotlib.pyplot as plt


stats=h5load('PRED.smlr.one_back.rest.roi.hdf5')

#s = [ ( (stats[k]['sess2']['counts'][1] - stats[k]['sess2']['counts'][2]) - (stats[k]['sess1']['counts'][1] - stats[k]['sess1']['counts'][2] ) ) for k in stats['subjects']]
#s1 = [ ( (stats[k]['sess3']['counts'][1] - stats[k]['sess3']['counts'][2]) - (stats[k]['sess1']['counts'][1] - stats[k]['sess1']['counts'][2] ) ) for k in stats['subjects']]
#s2 = [ ( (stats[k]['sess3']['counts'][1] - stats[k]['sess3']['counts'][2]) - (stats[k]['sess2']['counts'][1] - stats[k]['sess2']['counts'][2] ) ) for k in stats['subjects']]


#s = np.abs([ ( (stats[k]['sess2']['counts'][1]  - stats[k]['sess1']['counts'][1] ) ) for k in stats['subjects']])
#s1 = np.abs([ ( (stats[k]['sess3']['counts'][1] - stats[k]['sess1']['counts'][1] ) ) for k in stats['subjects']])
#s2 = np.abs([ ( (stats[k]['sess3']['counts'][1] - stats[k]['sess2']['counts'][1] ) ) for k in stats['subjects']])


s   =   [ (stats[k]['sess2']['counts'][1] - stats[k]['sess2']['counts'][2]) - (stats[k]['sess1']['counts'][1] - stats[k]['sess1']['counts'][2])  for k in stats['subjects'] ]
s1  =   [ (stats[k]['sess3']['counts'][1] - stats[k]['sess3']['counts'][2]) - (stats[k]['sess1']['counts'][1] - stats[k]['sess1']['counts'][2])  for k in stats['subjects'] ]
s2  =   [ (stats[k]['sess3']['counts'][1] - stats[k]['sess3']['counts'][2]) - (stats[k]['sess2']['counts'][1] - stats[k]['sess2']['counts'][2])  for k in stats['subjects'] ]
sub =   [ k  for k in stats['subjects'] ]

print(s2, sub)


for k in range(0, 21):
    print(str(sub[k]) + ' : ' +  str(s2[k]))

print(ks_2samp(s,s1))
print(ks_2samp(s,s2))
print(ks_2samp(s1,s2))

plt.figure()
plt.hist(s)

plt.figure()
plt.hist(s1)

plt.figure()
plt.hist(s2)

plt.show()

