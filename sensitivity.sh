spetral_file=$1
kernel_out=$spetral_file"_kernel"
dist=$2

exefile="temp"$spetral_file
cp sensitivity $exefile

$exefile<<EOF
3
$spetral_file
$kernel_out
smooth
1
$dist
EOF

#生成结果图
#python3 draw.py $kernel_out
