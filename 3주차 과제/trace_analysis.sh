#!/bin/sh

files=$@

if [ ! -d plot ] 
then
    mkdir -p plot
fi

for file in $files
do
	plotfile=${file}_gnuplot
cat ${file} | awk '{printf "%s,%d,%d,%.3f,%d\n",$7, $8, $10, $4, NR}' > ${plotfile};

	gnuplot << EOF

set te jpeg giant size 800,600;

set xlabel "Timestamp (second)";

set ylabel "Logical Sector Number";

set pointsize 0.2;

set datafile separator ",";

set output "${file}.jpeg";

plot "< grep R ${plotfile}" u 4:2 ti "Read", "< grep W ${plotfile}" u 4:2 ti "Write", "< grep F ${plotfile}" u 4:2 ti "fsync";

set output "${file}_read.jpeg";

plot "< grep R ${plotfile}" u 4:2 ls 1 ti "Read";

set output "${file}_write.jpeg";

plot "< grep W ${plotfile}" u 4:2 ls 2 ti "Write";

set output "${file}_fsync.jpeg";
plot "< grep F ${plotfile}" u 4:2 ls 3 ti "Fsync";

EOF
mv *.jpeg plot;
rm -f ${plotfile}

done



