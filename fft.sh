#eg: $1=33to25
input='./sacfile/*'$1
#input=$1
sac<<EOF
r $input
taper
fft
keepam
write append _spetral
quit
EOF


for f in ./sacfile/*_spetral
do
    echo "$f  begins"
    python3 creat_spetral.py $f &
done

wait
echo "all files are ok"