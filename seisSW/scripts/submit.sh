#!/bin/bash

echo 
echo '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~'
echo
echo " source parameter file ..." 
source parameter

echo
echo '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~'
echo
echo " Copy specfem executavles ..."
rm -rf bin
mkdir bin
cp -r $specfem_path/bin/* ./bin/

if $ReStart; then
echo 
echo " create new job_info file ..."
rm -rf job_info
mkdir job_info
fi

echo 
echo " create result file ..."
mkdir -p $result_path

echo
echo '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~'
echo
echo

if [ "$job" ==  "modeling" ]
then
echo " ########################################################"
echo " Forward modeling .." 
echo " ########################################################"
SCRIPTS_DIR="$package_path/scripts"
cp $SCRIPTS_DIR/ForwardModeling_$system.sh $Job_title.sh

elif [ "$job" ==  "kernel" ]
then
echo " ########################################################"
echo " Adjoint Inversion .." 
echo " ########################################################"
SCRIPTS_DIR="$package_path/scripts"
cp $SCRIPTS_DIR/Kernel_$system.sh $Job_title.sh

elif [ "$job" ==  "inversion" ]
then
echo " ########################################################"
echo " Adjoint Inversion .." 
echo " ########################################################"
SCRIPTS_DIR="$package_path/scripts"
cp $SCRIPTS_DIR/AdjointInversion_$system.sh $Job_title.sh
fi

echo
echo " renew parameter file ..."
cp $package_path/SRC/seismo_parameters.f90 ./bin/
cp $package_path/scripts/renew_parameter.sh ./
./renew_parameter.sh

echo 
echo " complile source codes ... "
MAKE_DIR="$package_path/make"
cp $package_path/make/make_$compiler ./make_file
FILE="make_file"
sed -e "s#^SRC_DIR=.*#SRC_DIR=$package_path/SRC#g"  $FILE > temp;  mv temp $FILE
make -f make_file clean
make -f make_file


echo 
echo " edit request nodes and tasks ..."
if [ $NSRC -le ${max_ntasks_per_node} ] 
then
   ntasks=$NSRC 
   nodes=1
else
  ntasks=${max_ntasks_per_node}
  nodes=$(echo $(echo "$NSRC $ntasks" | awk '{ print $1/$2 }') | awk '{printf("%d\n",$0+=$0<0?0:0.999)}')
fi
echo " Request $nodes nodes and $ntasks tasks per node"

   FILE="$Job_title.sh"
   sed -e "s#^\#SBATCH -p.*#\#SBATCH -p $queue#g"  $FILE > temp;  mv temp $FILE
   sed -e "s#^\#SBATCH --nodes=.*#\#SBATCH --nodes=$nodes#g"  $FILE > temp;  mv temp $FILE
   sed -e "s#^\#SBATCH --ntasks-per-node=.*#\#SBATCH --ntasks-per-node=$ntasks#g"  $FILE > temp;  mv temp $FILE
   sed -e "s#^\#SBATCH --time=.*#\#SBATCH --time=$WallTime#g"  $FILE > temp;  mv temp $FILE
echo
echo '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~'
echo

echo " submit job sbatch $Job_title.sh"
echo

sbatch $Job_title.sh
echo
