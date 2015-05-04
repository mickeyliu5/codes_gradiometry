#!/usr/bin/env python

#get average structural phase velocity, amplification factor for 50 km radius area around the station

from obspy.core.util.geodetics import gps2DistAzimuth

f_sta = open('header_all','r')
for master_info in f_sta:
	master_info = master_info.split()
	master_name = master_info[0]
	master_lon = float(master_info[2])
	master_lat = float(master_info[3])
	f_corr_amp = open('azi_amp_stru_velo','r')
	f_average_amp = open('ave_amp_'+master_name,'w+')
	for line in f_corr_amp:
		line = line.split()
		supp_lon = float(line[0])
		supp_lat = float(line[1])
		supp_azi = line[2]
		supp_amp = line[3]
		supp_velo = line[4]
		#find points within 50km radius of master station
		if gps2DistAzimuth(master_lat,master_lon,supp_lat,supp_lon)[0] < 50000:
			f_average_amp.write(str(supp_lon)+' '+str(supp_lat)+' '+supp_azi+' '+supp_amp+' '+supp_velo+'\n')
	f_corr_amp.close()
	f_average_amp.close()
f_sta.close()