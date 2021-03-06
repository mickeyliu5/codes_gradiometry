#!/bin/bash

#unzip seed file, change the file name
rdseed -pdf *.seed
#change the name of raw data to TA.
ls SAC_* | awk -F_ '{print "mv "$0,$1"_"$2"_TA_"$4"_"$5"_"$6"_"$7}'  | sh
ls *.SAC | awk '{x=$1;split(x,aa,".");print "mv "$1,"TA."aa[8]".z"}' | sh

#plot bad stations
saclst stlo stla f *.z > st.info
awk '{x=$1;split(x,aa,".");print aa[2],$2,$3}' st.info > location
awk '{print $2,$3}' st.info > st.txt 
#make the map boundary larger to find bad stations
R=`minmax -C st.txt | awk '{printf "-R%.f\/%.f\/%.f\/%.f\n",$1-5,$2+5,$3-2,$4+2}'`
pscoast $R -B5/4  -Na -JM15 -K -G255/239/213 -Y2i -W0.10p  -A5000  > station.ps
psxy st.txt -R -J -Sc0.03i -K -G0/0/255 -O  >> station.ps
awk '{ print $2+0.15,$3+0.05,"4 3 0 1",$1}' location  | pstext -R -J -P -O  >> station.ps

