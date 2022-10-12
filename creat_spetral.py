from obspy import read
import os
import re

def read_a_sac(fileinput,fbeg,fend):
    f=read(fileinput)
    delta=f[0].stats.delta
    nbeg=int(fbeg/delta)
    nend=int(fend/delta)+1
    if nend-nbeg<16:
        result=[str(nend-nbeg)]
        for i in range(nbeg,nend):
            temp_freq=i*delta
            temp_amp=f[0].data[i]
            result.append(str(temp_freq)+"  "+str(temp_amp))
    else:
        result=[str(len(range(nbeg,nend,int((nend-nbeg)/15))))]
        for i in range(nbeg,nend,int((nend-nbeg)/15)):
            temp_freq=i*delta
            temp_amp=f[0].data[i]
            result.append(str(temp_freq)+"  "+str(temp_amp))
    output="./"+fileinput.split('/')[-1]+".txt"
    with open(output,'w') as f:
        f.write('\n'.join(result))

#fileinput=('./sacfile/A.X1.53008.01.BHZ.D.2013.243.011546.SAC_sec33to25_spetral')
fileinput=os.sys.argv[1]

fbeg=1/float(fileinput.split('to')[0].split('_sec')[1])
fend=1/float(fileinput.split('to')[1].split('_spe')[0])

read_a_sac(fileinput,fbeg,fend)