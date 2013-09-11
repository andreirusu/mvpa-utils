from mvpa2.suite import *
from scipy.stats import ks_2samp
import numpy as np
import matplotlib.pyplot as plt

from tools import *

stats1  =   h5load('../datasets/PRED.knn.one_back.rest.sess1.full.hdf5')
stats2  =   h5load('../datasets/PRED.knn.one_back.rest.sess2.full.hdf5')
stats3  =   h5load('../datasets/PRED.knn.one_back.rest.sess3.full.hdf5')

#s = [ ( (stats[k]['sess2']['counts'][1] - stats[k]['sess2']['counts'][2]) - (stats[k]['sess1']['counts'][1] - stats[k]['sess1']['counts'][2] ) ) for k in stats['subjects']]
#s1 = [ ( (stats[k]['sess3']['counts'][1] - stats[k]['sess3']['counts'][2]) - (stats[k]['sess1']['counts'][1] - stats[k]['sess1']['counts'][2] ) ) for k in stats['subjects']]
#s2 = [ ( (stats[k]['sess3']['counts'][1] - stats[k]['sess3']['counts'][2]) - (stats[k]['sess2']['counts'][1] - stats[k]['sess2']['counts'][2] ) ) for k in stats['subjects']]


#s = np.abs([ ( (stats[k]['sess2']['counts'][1]  - stats[k]['sess1']['counts'][1] ) ) for k in stats['subjects']])
#s1 = np.abs([ ( (stats[k]['sess3']['counts'][1] - stats[k]['sess1']['counts'][1] ) ) for k in stats['subjects']])
#s2 = np.abs([ ( (stats[k]['sess3']['counts'][1] - stats[k]['sess2']['counts'][1] ) ) for k in stats['subjects']])

'''
s   =   [ (stats2[k]['counts'][1] - stats2[k]['counts'][2]) - (stats1[k]['counts'][1] - stats1[k]['counts'][2])  for k in stats1['subjects'] ]
s1  =   [ (stats3[k]['counts'][1] - stats1[k]['counts'][1])  for k in stats1['subjects'] ]
s2  =   [ (stats3[k]['counts'][1] - stats3[k]['counts'][2]) - (stats2[k]['counts'][1] - stats2[k]['counts'][2])  for k in stats1['subjects'] ]

sub =   [ k  for k in stats1['subjects'] ]

print(s, s1, s2, sub)


for k in range(0, 3):
    print(str(sub[k]) + ' : ' +  str(s2[k]))

print(ks_2samp(s,s1))
print(ks_2samp(s,s2))
print(ks_2samp(s1,s2))

#plt.figure()
plt.hist(s, 100)

#plt.figure()
plt.hist(s1, 100)

#plt.figure()
plt.hist(s2, 100)

'''

sub     =   [ k  for k in stats1['subjects'] ]
        
        
for subject_dir in stats1['subjects']:
    print('Subject: ' + subject_dir)
    import re
    subject_nr = int(re.findall(r'\d+', subject_dir)[0])
    if SUBJECT_GROUP[subject_nr] == 1 :
        print('Rewarderd category: chair')
    elif SUBJECT_GROUP[subject_nr] == 2 :
        print('Rewarderd category: house')
    else:
        raise NameError('Wrong subject group!')



s   =   [ (stats2[k]['counts'][1] - stats1[k]['counts'][1])  for k in stats1['subjects'] ]
s1  =   [ (stats3[k]['counts'][1] - stats1[k]['counts'][1])  for k in stats1['subjects'] ]
s2  =   [ (stats3[k]['counts'][1] - stats2[k]['counts'][1])  for k in stats1['subjects'] ]



print(sub)
print(s)
print(s1)
print(s2)


plt.hist(s, 100)
plt.hist(s1, 100)
plt.hist(s2, 100)


plt.show()

