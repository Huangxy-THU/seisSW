#!/bin/bash
## data pre-processing work flow(window,WT, demean, detrend, tapering, filtering .... )
source $SUBMIT_DIR/parameter

SU_process=0
# low-pass filtering
LPF=0
f1=1
f2=3
f3=4
f4=5
## dip-filtering
dip_filter=0
is_SW=0
is_BW=0
slope1=-0.003
slope2=-0.002
slope3=-0.0015
slope4=0.0000
slope5=0.0015
slope6=0.002
slope7=0.003
bias_neg=-0.004
bias_pos=0.004
amp1=0.0
amp2=0.0
amp3=1.0
amp4=1.0
amp5=1.0
amp6=0.0
amp7=0.0
taper_x1=10
taper_x2=10
taper_t1=350
taper_t2=350

######################## X comp ###################################################################################
input_file=$1
output_file=$2


cp $input_file in_file

#little to big endian
if [[ $endian = "little_endian" ]]; then
suoldtonew <in_file> out_file
cp out_file in_file
fi

if [ $SU_process -eq 1 ]; then

if [ $dip_filter -eq 1 ]; then
 sushw<in_file key=d2 a=$dr>out_file
 cp out_file in_file

 ## dip filtering
 # taper
  sutxtaper<in_file tbeg=$taper_t1 tend=$taper_t2  key=tr tr1=$taper_x1 tr2=$taper_x2 taper=5 ntr=$NREC>out_file
  cp out_file in_file
  cp out_file in_file1

 # band-pass filter 
#  ./cwp/sufilter f=$f1,$f2,$f3,$f4 amps=0,1,1,0 <in_file>out_file
#  cp out_file in_file
 # anti-aliasing slope filter
 sudipfilt<in_file slopes=$slope1,$slope2,$slope3,$slope4 amps=$amp1,$amp2,$amp3,$amp4 bias=$bias_neg>out_file
  cp out_file in_file
 sudipfilt<in_file slopes=$slope5,$slope6,$slope7,$slope8 amps=$amp5,$amp6,$amp7,$amp8 bias=$bias_pos>out_file
  cp out_file in_file 

 sudiff in_file1 in_file>out_file
 cp in_file in_file1
 cp out_file in_file

# tapering the final result
# SW
if [ $is_SW -eq 1 ]; then
  sutxtaper<in_file tbeg=$taper_t1 tend=$taper_t2  key=tr tr1=$taper_x1 tr2=$taper_x2 taper=5 ntr=$NREC>out_file
  cp out_file in_file
#  cp out_file $2
fi

# BW
if [ $is_BW -eq 1 ]; then
  sutxtaper<in_file1 tbeg=$taper_t1 tend=$taper_t2  key=tr tr1=$taper_x1 tr2=$taper_x2 taper=5 ntr=$NREC>out_file
  cp out_file in_file
#  cp out_file $3
fi

fi

 # FFT-based low-pass filtering 
if [ $LPF -eq 1 ]; then
 sufilter f=$f1,$f2,$f3,$f4 amps=1,1,0,0 <in_file>out_file
   cp out_file in_file
fi

fi # SU_process

# convert foreign to native/system endian 
if [[ $endian = "little_endian" ]]; then
    suswapbytes <in_file format=0 ns=$NSTEP >out_file
    cp out_file in_file
fi

  ## save final result
  cp in_file $output_file

 ## clean up
 rm -rf out_file in_file*

