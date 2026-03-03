# Random binary alloys: generalized stacking fault energies

## Foreword

The purpose of this project is to calculate the generalized stacking fault energies (GSFEs) of 90 binaries. The peak value of the GSFE curve is called the unstable stacking fault energy (USFE).

All alloys have a body-centered cubic (BCC) lattice. For each alloy, we need to run 1 LAMMPS simulations to generate the chemical short-range order (CSRO) structure and 20 LAMMPS simulations to obtain the mean GSFE curve. Therefore, in total 1,890 LAMMPS simulations are needed. The GSFE curves of the random structures of these binaries were presented in [our previous paper](https://doi.org/10.1007/s11837-025-07728-x).

The 90 binaries include

- 9 binaries based on Mo<sub>_x_</sub>Nb<sub>1-_x_</sub>, where _x_ varies from 0.1 to 0.9
- other combinations of metals, including MoTa, MoV, MoW, NbTa, NbV, NbW, TaV, TaW, and VW

The interatomic potential was developed by [Wang et al.](https://doi.org/10.1038/s41524-024-01330-6).

Note: Pay attention to the amount of data in our \$HOME. They can build up quickly. Once the data exceeds 20 GB, we won't be able to run anything. In addition, it may be wise to [run those high-throughput simulations automatically](https://github.com/RichardBrinlee/USFE25_high_throughput), as opposed to manually making changes to the files.

## LAMMPS

LAMMPS on [OSCER](http://www.ou.edu/oscer.html) likely does not come with many packages. To finish this project, the [MLIP](https://mlip.skoltech.ru) package is needed.

To install LAMMPS with MLIP, use the file `lmp_mlip.sh` in the `MTP/` directory in this GitHub repository. First, cd to any directory on OSCER, e.g., \$HOME, then

	el9
	sh lmp_mlip.sh

Note that the 6th and 7th commands in `lmp_mlip.sh` will load modules. If one cannot load them, try `module purge` first.

Once the `sh` run is finished, we should find a file `lmp_intel_cpu_intelmpi` in the `software/lammps-mtp/interface-lammps-mlip-2/` directory on OSCER. And that is the LAMMPS executable with MLIP.

Note that we need to exit the el9 container by `exit` before running any LAMMPS simulations. Each time we run a new type of simulation, create a new directory.

## CSRO

### Mo<sub>0.1</sub>Nb<sub>0.9</sub>

Run a LAMMPS simulation with files `lmp_mcnpt.in`, `lmp.batch`, `fitted.mtp`, and `mlip.ini`. The first file can be found in the `csro/` directory in this GitHub repository. The second file can be found in this GitHub repository. The other two files, retrieved from [another GitHub repository](https://github.com/ucsdlxg/MoNbTaVW-ML-interatomic-potential-and-CRSS-ML-model), can be found in the `MTP/` directory in this GitHub repository. Make sure the correct input file name is used in `lmp.batch`, and submit the job by

	sbatch lmp.batch

Once it is finished, we will find a new data file `data.GSFE` which will be used later.

### Mo<sub>0.2</sub>Nb<sub>0.8</sub> to Mo<sub>0.9</sub>Nb<sub>0.1</sub>

For each alloy, make two changes to `lmp_mcnpt.in`

- line 15, use the corresponding lattice parameter, which can be found in the file `random.xlsx` in this GitHub repository.
- line 36, replace `0.1` with _x_ in Mo<sub>_x_</sub>Nb<sub>1-_x_</sub>

### Mo<sub>_x_</sub>Ta<sub>1-_x_</sub>

The MTP files used here specify the five elements for each type:

	type 1: Ta
	type 2: Nb
	type 3: V
	type 4: Mo
	type 5: W

In the input file for Mo<sub>0.1</sub>Nb<sub>0.9</sub>, there are three lines:

	create_atoms 2 box
	set type 2 type/ratio 4 0.1 134
	fix 1 all atom/swap 1 1 114514 ${temperature} types 2 4

The first line fill the box with all Nb atoms (type 2). The second line randomly changes 10% of Nb atoms (type 2) to Mo atoms (type 4). The third line swaps Nb atoms (type 2) with Mo atoms (type 4). 

Therefore, to study Mo<sub>_x_</sub>Ta<sub>1-_x_</sub>, we need to modify those three lines to

	create_atoms 1 box
	set type 1 type/ratio 4 x 384
	fix 1 all atom/swap 1 1 114514 ${temperature} types 1 4

where _x_ is the atomic percentage of Mo atoms.

### Other binary alloys

The same logic can be applied to all other binary alloys. For example, for V<sub>0.3</sub>W<sub>0.7</sub>, those three lines should be

	create_atoms 5 box
	set type 5 type/ratio 3 0.3 384
	fix 1 all atom/swap 1 1 114514 ${temperature} types 5 3

## GSFE for any alloy

### Plane 1

The simulation requires files 
`lmp_gsfe.in`, `data.CSRO` `lmp.batch`, `fitted.mtp`, and `mlip.ini`. The first file can be found in the `gsfe/` directory in this GitHub repository. The second file is the exact data file generated previously for a given alloy.

Modify `lmp_gsfe.in`:

- line 16, replace the number `3.3` with the corresponding lattice parameter

Then run the simulation. Once it is finished, we will find a new file `gsfe_ori`. Run

	sh gsfe_curve.sh

which would yield a new file `gsfe`. The first column is the displacement along the $\left<111\right>$ direction while the second column is the GSFE value, in units of mJ/m<sup>2</sup>. The USFE is the peak GSFE value.

### Plane 2

According to [this paper](http://dx.doi.org/10.1016/j.intermet.2020.106844), in an alloy, multiple GSFE curves should be calculated. Hence, we need to make a change to `lmp_gsfe.in`:

- line 54, change the number `1` to `2`

Then run the simulation and obtain another GSFE curve and another USFE value.

### Other planes

Increase the integer in line 54 of `lmp_gsfe.in` from 3 to 20 to obtain 20 USFE values in total. Then calculate the mean USFE value.

## Contributors

<!--A huge thank you to the first 20 contributors who ran simulations for the final project in Dr. Shuozhi Xu's [Computational Materials Science course in Spring 2026](https://shuozhixu.github.io/teaching/spring-2026/AME4970-5970-Syllabus.pdf) at the University of Oklahoma!-->

xxxx

- Mo<sub>0.1</sub>Nb<sub>0.9</sub>, Mo<sub>0.2</sub>Nb<sub>0.8</sub>, Mo<sub>0.3</sub>Nb<sub>0.7</sub>, Mo<sub>0.4</sub>Nb<sub>0.6</sub>

Mustafa Alhayek

- Mo<sub>0.5</sub>Nb<sub>0.5</sub>, Mo<sub>0.5</sub>Ta<sub>0.5</sub>, Mo<sub>0.5</sub>V<sub>0.5</sub>, Mo<sub>0.5</sub>W<sub>0.5</sub>, Nb<sub>0.5</sub>Ta<sub>0.5</sub>, Nb<sub>0.5</sub>V<sub>0.5</sub>, Nb<sub>0.5</sub>W<sub>0.5</sub>, Ta<sub>0.5</sub>V<sub>0.5</sub>, Ta<sub>0.5</sub>W<sub>0.5</sub>, V<sub>0.5</sub>W<sub>0.5</sub>

## Reference

If you use any files from this GitHub repository, please cite

- Richard Brinlee, Amin Poozesh, Anvesh Nathani, Anshu Raj, Xiang-Guo Li, Iman Ghamarian, Shuozhi Xu, [Integrating atomistic simulations and machine learning to predict unstable stacking fault energies of refractory non-dilute random alloys](https://doi.org/10.1007/s11837-025-07728-x), JOM 77 (2025) 8127--8136