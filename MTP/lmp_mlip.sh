#!/usr/bin/bash

mkdir -p software
cd software
rm -rf lammps-mtp
module load intel/2023b
module load git/2.41.0-GCCcore-12.3.0-nodocs
mkdir lammps-mtp
cd lammps-mtp
git clone https://gitlab.com/ashapeev/mlip-2.git
cd mlip-2
./configure
make mlp
make libinterface
cd ..
mkdir interface-lammps-mlip-2
cd interface-lammps-mlip-2
git clone https://gitlab.com/ashapeev/interface-lammps-mlip-2.git .
cp ../mlip-2/lib/lib_mlip_interface.a .
cd ..
wget --no-check-certificate https://download.lammps.org/tars/lammps-22Dec2022.tar.gz
tar -xf lammps-22Dec2022.tar.gz
cd interface-lammps-mlip-2
./install.sh ../lammps-22Dec2022 intel_cpu_intelmpi