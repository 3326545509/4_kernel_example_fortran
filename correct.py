import os
import numpy as np
from matplotlib import pyplot as plt
from scipy import stats

def var_fit(x,y,slope,intercept):
    y2=x*slope+intercept
    if x==[] or y==[]:
        return 0
    mean=sum((y2-y)**2)/len(y2)
    return mean

def read(path):
    with open(path,'r')as f:
        row=f.readlines()

    data=[]
    for i in range(len(row)):
        temp=row[i]
        temp=temp.split()
        data.append(temp)
    return data

def draw_subplot(i,titlename,x,y):
    eval("plt.subplot(14"+str(i)+")")
    plt.title(titlename)
    plt.ylim([-3,3])
    plt.xlim([0,800])
    plt.xlabel("dist / km")
    plt.ylabel("amplitude / ln(A)")
    plt.scatter(x,y,edgecolors='black')#,s=1,label='a')
    slope, intercept, r, p, se = stats.linregress(x,y)
    var    =   var_fit(x,y,slope,intercept)
    plt.plot(x,x*slope+intercept,label='var:     '+"{0:.{1}e}".format(var,2)+"\n"\
        +'slope: '+"{0:.{1}e}".format(slope,2))
    plt.legend(loc='upper right')

#data1: id  dist  depmax  amp_norad_withgeo
data1=read('./temp_csv.txt')
#data2: dlnA
data2=read('./temp_kernel.txt')
#print(data1[0])
#print(data2[0])

for i in range(len(data1)):
    for j in range(len(data2)):
        if data1[i][0] in data2[j][0]:
            #print(data1[i][0])
            data1[i].append(data2[j][1])
            continue
print(data1)
dist=[]
dist_norad=[]
depmax=[]
amp_norad_withgeo=[]
dlnA=[]
for i in range(len(data1)):
    dist.append(float(data1[i][1]))
    depmax.append(float(data1[i][2]))
    if data1[i][3]!="node":
        dist_norad.append(float(data1[i][1]))
        amp_norad_withgeo.append(float(data1[i][3]))
        dlnA.append(float(data1[i][4]))
    # else:
    #     print(data1[i][3])
    
dist=np.array(dist)
dist_norad=np.array(dist_norad)
depmax=np.array(depmax)
amp_norad_withgeo=np.array(amp_norad_withgeo)
dlnA=np.array(dlnA)
#print(np.sin(dist/6371))
#print(dist)
#print(amp)
amp1    =   np.log(depmax)
amp1    =   amp1-np.mean(amp1)

amp2    =   np.log(depmax*np.sqrt(np.sin(dist/6371)))
amp2    =   amp2-np.mean(amp2)

amp3    =   np.log(amp_norad_withgeo*np.sqrt(np.sin(dist_norad/6371)))
amp3    =   amp3-np.mean(amp3)

amp4    =   np.log(amp_norad_withgeo*np.sqrt(np.sin(dist_norad/6371))/(1+dlnA))
amp4    =   amp4-np.mean(amp4)

# amp2    =   np.log(amp_norad_withgeo*np.sqrt(np.sin(dist/6371)))
# amp     =   np.log(amp*np.sqrt(np.sin(dist/6371))/(1+dlnA))
# amp     =   amp-np.mean(amp)
# amp2    =   amp2-np.mean(amp2)



plt.style.use(['science'])
plt.figure(figsize=(18,3.5))
draw_subplot(1,'Original data',dist,amp1)
draw_subplot(2,'Geometrical spreading correction',dist,amp2)
draw_subplot(3,'Radiation correction',dist_norad,amp3)
draw_subplot(4,'Scattering correction',dist_norad,amp4)
# eval("plt.subplot(14"+str(1)+")")
# plt.title('Original data')
# plt.ylim([-3,3])
# plt.xlim([0,800])
# plt.xlabel("dist / km")
# plt.ylabel("amplitude / ln(A)")
# plt.scatter(dist,amp1,edgecolors='black')#,s=1,label='a')
# plt.plot(dist,dist*slope1+intercept1,label='var:     '+"{0:.{1}e}".format(var1,2)+"\n"\
#     +'slope: '+"{0:.{1}e}".format(slope1,2))
# plt.legend(loc='upper right')

# plt.subplot(142)
# plt.title('Geometrical spreading correction')
# plt.ylim([-3,3])
# plt.xlim([0,800])
# plt.xlabel("dist / km")
# plt.ylabel("amplitude / ln(A)")
# plt.scatter(dist,amp2,edgecolors='black')#,label='b')

# plt.subplot(143)
# plt.title('Radiation correction')
# plt.ylim([-3,3])
# plt.xlim([0,800])
# plt.xlabel("dist / km")
# plt.ylabel("amplitude / ln(A)")
# plt.scatter(dist_norad,amp3,edgecolors='black')

# plt.subplot(144)
# plt.title('Scattering correction')
# plt.ylim([-3,3])
# plt.xlim([0,800])
# plt.xlabel("dist / km")
# plt.ylabel("amplitude / ln(A)")
# plt.scatter(dist_norad,amp4,edgecolors='black')

plt.savefig('laji.png')
