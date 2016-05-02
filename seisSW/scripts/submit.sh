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

echo 
echo " create new job_info file ..."
rm -rf job_info
mkdir job_info

echo 
echo " create result file ..."
mkdir -p RESULTS

echo
echo '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~'
echo
echo

workflow_DIR="$package_path/workflow"

if [ "$job" ==  "modeling" ] || [ "$job" ==  "Modeling" ]
then
echo " ########################################################"
echo " Forward modeling .." 
echo " ########################################################"
cp $workflow_DIR/Modeling.sh $Job_title.sh

elif [ "$job" ==  "kernel" ] || [ "$job" ==  "Kernel" ]
then
echo " ########################################################"
echo " Adjoint Inversion .." 
echo " ########################################################"
cp $workflow_DIR/Kernel.sh $Job_title.sh

elif [ "$job" ==  "inversion" ]
then
echo " ########################################################"
echo " Adjoint Inversion .." 
echo " ########################################################"
cp $workflow_DIR/AdjointInversion.sh $Job_title.sh
fi

echo
echo " renew parameter file ..."
cp $package_path/SRC/seismo_parameters.f90 ./bin/
cp $package_path/scripts/renew_parameter.sh ./
./renew_parameter.sh

echo 
echo " complile source codes ... "
rm -rf *.mod make_file
cp $package_path/make/make_$compiler ./make_file
FILE="make_file"
sed -e "s#^SRC_DIR=.*#SRC_DIR=$package_path/SRC#g"  $FILE > temp;  mv temp $FILE
make -f make_file clean
make -f make_file

echo 
echo " edit request nodes and tasks ..."
if [ $NSRC -le ${max_nproc_per_node} ] 
then
   ntasks=$NSRC 
   nodes=1
else
  ntasks=${max_nproc_per_node}
  nodes=$(echo $(echo "$NSRC $ntasks" | awk '{ print $1/$2 }') | awk '{printf("%d\n",$0+=$0<0?0:0.999)}')
fi
echo " Request $nodes nodes and $ntasks tasks per node"

echo
echo '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~'
echo

echo "submit job"
echo

if [ $system == 'slurm' ]; then
    echo "slurm system ..."
    echo "sbatch -p $queue -N $nodes --ntasks-per-node=$ntasks --time=$WallTime --error=job_info/error --output=job_info/output $Job_title.sh"
    sbatch -p $queue -N $nodes --ntasks-per-node=$ntasks --time=$WallTime --error=job_info/error --output=job_info/output $Job_title.sh

elif [ $system == 'pbs' ]; then
    echo "pbs system ..."
    echo
    qsub -q $queue -l nodes=$nodes:ppn=$max_nproc_per_node -l --walltime=$WallTime -e job_info/error -o job_info/output  $Job_title.sh
fi
echo
