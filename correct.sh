houzui=$1

mv dlnA.txt dlnA_temp_cp.txt
for f in *dlnA.txt
do
    temp=`cat $f`
    echo "$temp">>temp_kernel.txt
done
#cat dlnA.txt | awk -F ' ' '{print$2,$7}'>temp_kernel.txt
#sed 's/.D.2013.251.055104.SAC_sec5.5to4.8_spetral.txt_kernel//g' temp1.txt>>temp2.txt
#sed 's/.D.2013.251.055104.SAC_sec10to8.5_spetral.txt_kernel//g' temp1.txt>temp2.txt
#sed 's/A.//g' temp2.txt >temp1.txt
#mv temp1.txt temp_kernel.txt

noradfile="6.noradWithgeo"$houzui".csv"

cp /home/y_piao/work/3_radiation_cps/all_event_creat_csv_2/6.noradWithgeo/$noradfile ./
#id dist depmax_notad_with_geo depmax
cat $noradfile |awk -F ',' '{if($3~/2012-07-17/)print$1,$9,$10,$33}'>temp_csv.txt

#cat $noradfile |awk -F ',' '{if($3~/2013-09-08/)print$0}'>tempthis.csv
#cat temp2.txt|awk -F ' ' '{if($3!~/node/)print$0}'>temp_temp
#mv temp_temp temp_csv.txt
#mv temp2.txt temp_withnode.txt

python3 correct.py
