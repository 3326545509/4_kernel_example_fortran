file_velocity='f_0.1950.phvel.txt'
houzui='5.5to4.8'

sh fft.sh $houzui
sh dataCollect.sh
ifort -132 -save -o sensitivity sensitivity.f
gfortran plus.f90 -o plus
i=1
imax=`cat data.txt|wc -l`
while(($i<=$imax))
do
id=`cat data.txt |awk -F ' ' '{if(NR=="'$i'")print$1}'`
slo=`cat data.txt |awk -F ' ' '{if(NR=="'$i'")print$2}'`
sla=`cat data.txt |awk -F ' ' '{if(NR=="'$i'")print$3}'`
rlo=`cat data.txt |awk -F ' ' '{if(NR=="'$i'")print$4}'`
rla=`cat data.txt |awk -F ' ' '{if(NR=="'$i'")print$5}'`
dist=`cat data.txt |awk -F ' ' '{if(NR=="'$i'")print$6}'`
spetral_file=$id".txt"
kernel_file=$spetral_file"_kernel"
#-----生成计算kernel并相加的执行sh文件--------
echo "sh sensitivity.sh $spetral_file $dist">$i"temp.sh"
#=========求和=============
newexe=$i'temp_plus_exe'
newin=$i'temp_plus_in'
cat >${newin}<<EOF
$file_velocity
$kernel_file
$slo $sla $rlo $rla $dist
EOF
cat >>$i'temp.sh'<<EOF
cp plus $newexe
$newexe<$newin
EOF
#=========================
let i++
done

echo "==Plus begin=="
for f in ./*temp.sh
do
sh $f &
done

wait
sh correct.sh $houzui

rm *temp*
rm smooth
mkdir result
#mv rotate*png ./result
mv A*txt* ./result
