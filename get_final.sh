#!/bin/bash
#PBS  -q normal
#PBS  -N jobname 
#PBS  -l nodes=1:ppn=15
#PBS  -l walltime=4:00:00


CODEPATH=/home/yuanliu/codes
export PATH=$PATH:$CODEPATH/Shan_lib
export PATH=$PATH:$CODEPATH/Sparse_Lucy
export PATH=$PATH:$CODEPATH/sac/bin
export SACAUX=$CODEPATH/sac/aux
export PATH=/home/yuanliu/codes/gmt/gmt-4.5.11/bin:$PATH

### This changes your directory to the directory from where you used "qsub" to 
### submit this job
cd $PBS_O_WORKDIR
mkdir /dev/shm/yuanliu
rsync -av $PBS_O_WORKDIR/ /dev/shm/yuanliu 
cd /dev/shm/yuanliu

#prepare for the following computation
pre_cal.sh

#run the main program, first iteration
for i in `seq 1 15`; do
    numactl -C +$((i-1)) ./main_$i.sh 1 &
done
wait

#second iteration
for i in `seq 1 15`; do
	numactl -C +$((i-1)) ./main_$i.sh 234 &
done
wait

#third iteration
for i in `seq 1 15`; do
	numactl -C +$((i-1)) ./main_$i.sh 234 &
done
wait

#fourth iteration
for i in `seq 1 15`; do
	numactl -C +$((i-1)) ./main_$i.sh 234 &
done
wait

#process all data
cp geometry.dat edge_location.txt final_para/
cd final_para
#rm -rf dyna_pxpy AB_all* azi_rad_geo_all
cat pxpy_[A-Z0-9]* > dyna_pxpy
cat AB_[A-Z0-9]* > AB_all
cat azi_rad_geo_[A-Z0-9]* > azi_rad_geo_all
#ls pxpy_[A-Z0-9]* > ../good_sta
#calculate structural phase velocity

cal_stru_velo.sh

#plot AxAy
#image_A

#plot travel_time peak_amp
#image_time_amp

#plot dyna_velo stru_velo azi_var rad_patt geo_spread
#image_para

#store all the figures
#mv *.ps ../plots
cd ..
#update st.txt to include good stations only
#awk '{x=$1;split(x,aa,"_");print "saclst stlo stla f *"aa[2]"*"}' good_sta | sh | awk '{print $2,$3}'> final_para/st.txt
### After everything is done, copy all of the results off of the SSD back to 
### where you submitted the job
tar -cf $PBS_O_WORKDIR/ssdout.$PBS_JOBID.tar /dev/shm/yuanliu/final_para 
rm -rf /dev/shm/yuanliu
cd $PBS_O_WORKDIR
tar -xf ssdout.$PBS_JOBID.tar
mv dev/shm/yuanliu/final_para .
