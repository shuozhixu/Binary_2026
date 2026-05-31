# Refractory non-dilute random binary alloys

## Foreword

The purpose of this project is to calculate the lattice parameter, lattice distortion, elastic constants, and generalized stacking fault energies (GSFEs) of 110 binaries.

All alloys have a body-centered cubic (BCC) lattice. For each alloy, we need to run 1 LAMMPS simulations to generate the chemical short-range order (CSRO) structure, 3 LAMMPS simulation to calculate its lattice parameter, lattice distortion, and elastic constants, repsectively, and 20 LAMMPS simulations to obtain the mean GSFE curve. Therefore, in total 2,640 LAMMPS simulations are needed. The lattice parameter and GSFE curves of the random structures of these binaries were presented in [our previous paper](https://doi.org/10.1007/s11837-025-07728-x) and can be found in the file `random.xlsx` in this GitHub repository.

The 110 binaries include

- 11 binaries based on Mo<sub>_x_</sub>Nb<sub>1-_x_</sub>, where _x_ varies from 0.1 to 0.9, plus where _x_ = 0.05 and _x_ = 0.95
- other combinations of metals, including MoTa, MoV, MoW, NbTa, NbV, NbW, TaV, TaW, and VW

The interatomic potential was developed by [Wang et al.](https://doi.org/10.1038/s41524-024-01330-6).

Note: Pay attention to the amount of data in our \$HOME. They can build up quickly. Once the data exceeds 20 GB, we won't be able to run anything. In addition, it may be wise to [run those high-throughput simulations automatically](https://github.com/RichardBrinlee/USFE25_high_throughput), as opposed to manually making changes to the files.

## LAMMPS

LAMMPS on [OSCER](http://www.ou.edu/oscer.html) likely does not come with many packages. To finish this project, the [MLIP](https://mlip.skoltech.ru) package is needed.

To install LAMMPS with MLIP, use the file `lmp_mlip.sh` in this GitHub repository. First, cd to your \$HOME on OSCER, then

	el9
	sh lmp_mlip.sh

Note that the 6th and 7th commands in `lmp_mlip.sh` will load modules. If one cannot load them, try `module purge` first.

Once the `sh` run is finished, we should find a file `lmp_intel_cpu_intelmpi` in the `software/lammps-mtp/interface-lammps-mlip-2/` directory on OSCER. And that is the LAMMPS executable with MLIP.

Note that we need to exit the el9 container by `exit` before running any LAMMPS simulations. Each time we run a new type of simulation, create a new directory.

## CSRO

### Mo<sub>0.05</sub>Nb<sub>0.95</sub>

Run a LAMMPS simulation with files `lmp_mcnpt.in`, `lmp.batch`, `fitted.mtp`, and `mlip.ini`. The first file can be found in the `csro/` directory in this GitHub repository. The second file can be found in this GitHub repository. The other two files can be found in the `potential/` directory in [another GitHub repository](https://github.com/ucsdlxg/MoNbTaVW-ML-interatomic-potential-and-CRSS-ML-model). Make sure the correct input file name and partition are used in `lmp.batch`, and submit the job by

	sbatch lmp.batch

The job should be finished in 120 to 168 hours. Once it is finished, we will find a new data file `data.CSRO` which will be used later.

### From Mo<sub>0.1</sub>Nb<sub>0.9</sub> to Mo<sub>0.95</sub>Nb<sub>0.05</sub>

For each alloy, make two changes to `lmp_mcnpt.in`

- line 15, use the lattice parameter of the random alloy with the same composition.
- line 36, replace `0.05` with _x_ in Mo<sub>_x_</sub>Nb<sub>1-_x_</sub>

### Mo<sub>_x_</sub>Ta<sub>1-_x_</sub>

The MTP files used here specify the five elements for each type:

	type 1: Ta
	type 2: Nb
	type 3: V
	type 4: Mo
	type 5: W

In the input file for Mo<sub>0.05</sub>Nb<sub>0.95</sub>, there are three lines:

	create_atoms 2 box
	set type 2 type/ratio 4 0.05 134
	fix 1 all atom/swap 1 1 114514 ${temperature} types 2 4

The first line fill the box with all Nb atoms (type 2). The second line randomly changes 5% of Nb atoms (type 2) to Mo atoms (type 4). The third line swaps Nb atoms (type 2) with Mo atoms (type 4). 

Therefore, to study Mo<sub>_x_</sub>Ta<sub>1-_x_</sub>, we need to modify those three lines to

	create_atoms 1 box
	set type 1 type/ratio 4 x 134
	fix 1 all atom/swap 1 1 114514 ${temperature} types 1 4

where _x_ is the atomic percentage of Mo atoms.

### Other binary alloys

Changes should be made to the input file for all other binary alloys. For example, for V<sub>0.3</sub>W<sub>0.7</sub>, those three lines should be

	create_atoms 5 box
	set type 5 type/ratio 3 0.3 134
	fix 1 all atom/swap 1 1 114514 ${temperature} types 5 3

## Lattice parameter

For each alloy, the lattice parameter can be calculated by

	(lx/(2*sqrt(6.))+ly/(3*sqrt(3.))+lz/(16*sqrt(2.)))/3.

where `lx`, `ly`, and `lz` can be found in the data file `data.CSRO`, i.e.,

	lx = xhi - xlo
	ly = yhi - ylo
	lz = zhi - zlo

## Lattice distortion

kljl

## Elastic constants

For each alloy, run a LAMMPS simulation with files `in.elastic`, `displace.mod`, `init.mod`, `potential.mod`, `fitted.mtp`, `mlip.ini`, and `data.CSRO`. The first four files can be found in the `ela_const/` directory in this GitHub repository. In the batch file, designate `in.elastic` as the input file.

Once the simulation is finished, we will find an output file, `*.out`, at the end of which we will find values of C11all, C12all etc. Those are the elastic constants in the [11-2]-[111]-[1-10] system (recall the `lmp_mcnpt.in` file). Hence, they should be [converted](https://github.com/shuozhixu/elastic_tensor) to those in the [100]-[010]-[001] system. Once converted, using Equations 10-12 of [this paper](https://doi.org/10.1016/j.commatsci.2021.110942) to calculate three effective BCC elastic constants.

## GSFE

### Plane 1

The simulation requires files 
`lmp_gsfe.in`, `data.CSRO` `lmp.batch`, `fitted.mtp`, and `mlip.ini`. The first file can be found in the `gsfe/` directory in this GitHub repository. The second file is the data file generated from the previous simulation for a given alloy.

Modify `lmp_gsfe.in`:

- line 16, replace the number `3.3` with the corresponding lattice parameter

Then run the simulation, which should be finished in less than two minutes. This means that even with one core, the simulation would finish within 30 minutes. Once it is finished, we will find a new file `gsfe_ori`. Run

	sh gsfe_curve.sh

which would yield a new file `gsfe`. The first column is the displacement along the $\left<111\right>$ direction while the second column is the GSFE value, in units of mJ/m<sup>2</sup>. The peak value of the GSFE curve is called the unstable stacking fault energy (USFE).

### Plane 2

According to [this paper](http://dx.doi.org/10.1016/j.intermet.2020.106844), in an alloy, multiple GSFE curves should be calculated. Hence, we need to make a change to `lmp_gsfe.in`:

- line 54, change the number `1` to `2`

Then rerun the simulation and obtain another GSFE curve and another USFE value.

### Other planes

Increase the integer in line 54 of `lmp_gsfe.in` from 3 to 20 to obtain 20 USFE values in total. Then calculate the mean USFE value.

## Contributors

A huge thank you to the 22 contributors who ran simulations for the final project in Dr. Shuozhi Xu's [Computational Materials Science course in Spring 2026](https://shuozhixu.github.io/teaching/spring-2026/AME4970-5970-Syllabus.pdf) at the University of Oklahoma!

Zaid Jasasra

- Mo<sub>0.05</sub>Nb<sub>0.95</sub>, Mo<sub>0.1</sub>Nb<sub>0.9</sub>, Mo<sub>0.2</sub>Nb<sub>0.8</sub>, Mo<sub>0.3</sub>Nb<sub>0.7</sub>, Mo<sub>0.4</sub>Nb<sub>0.6</sub>

Mohamed Arabyat

- Mo<sub>0.6</sub>Nb<sub>0.4</sub>, Mo<sub>0.7</sub>Nb<sub>0.3</sub>, Mo<sub>0.8</sub>Nb<sub>0.2</sub>, Mo<sub>0.9</sub>Nb<sub>0.1</sub>, Mo<sub>0.95</sub>Nb<sub>0.05</sub>

Cassidy Barry

- Mo<sub>0.05</sub>Ta<sub>0.95</sub>, Mo<sub>0.1</sub>Ta<sub>0.9</sub>, Mo<sub>0.2</sub>Ta<sub>0.8</sub>, Mo<sub>0.3</sub>Ta<sub>0.7</sub>, Mo<sub>0.4</sub>Ta<sub>0.6</sub>

Jacob Bussey

- Mo<sub>0.6</sub>Ta<sub>0.4</sub>, Mo<sub>0.7</sub>Ta<sub>0.3</sub>, Mo<sub>0.8</sub>Ta<sub>0.2</sub>, Mo<sub>0.9</sub>Ta<sub>0.1</sub>, Mo<sub>0.95</sub>Ta<sub>0.05</sub>

Caden Chavalitanonda

- Mo<sub>0.05</sub>V<sub>0.95</sub>, Mo<sub>0.1</sub>V<sub>0.9</sub>, Mo<sub>0.2</sub>V<sub>0.8</sub>, Mo<sub>0.3</sub>V<sub>0.7</sub>, Mo<sub>0.4</sub>V<sub>0.6</sub>

Dakota Filibeck

- Mo<sub>0.6</sub>V<sub>0.4</sub>, Mo<sub>0.7</sub>V<sub>0.3</sub>, Mo<sub>0.8</sub>V<sub>0.2</sub>, Mo<sub>0.9</sub>V<sub>0.1</sub>, Mo<sub>0.95</sub>V<sub>0.05</sub>

Max Cheng

- Mo<sub>0.05</sub>W<sub>0.95</sub>, Mo<sub>0.1</sub>W<sub>0.9</sub>, Mo<sub>0.2</sub>W<sub>0.8</sub>, Mo<sub>0.3</sub>W<sub>0.7</sub>, Mo<sub>0.4</sub>W<sub>0.6</sub>

Luke Gilchrest

- Mo<sub>0.6</sub>W<sub>0.4</sub>, Mo<sub>0.7</sub>W<sub>0.3</sub>, Mo<sub>0.8</sub>W<sub>0.2</sub>, Mo<sub>0.9</sub>W<sub>0.1</sub>, Mo<sub>0.95</sub>W<sub>0.05</sub>

Matthew Heath

- Nb<sub>0.05</sub>Ta<sub>0.95</sub>, Nb<sub>0.1</sub>Ta<sub>0.9</sub>, Nb<sub>0.2</sub>Ta<sub>0.8</sub>, Nb<sub>0.3</sub>Ta<sub>0.7</sub>, Nb<sub>0.4</sub>Ta<sub>0.6</sub>

Stryker Herrera

- Nb<sub>0.6</sub>Ta<sub>0.4</sub>, Nb<sub>0.7</sub>Ta<sub>0.3</sub>, Nb<sub>0.8</sub>Ta<sub>0.2</sub>, Nb<sub>0.9</sub>Ta<sub>0.1</sub>, Nb<sub>0.95</sub>Ta<sub>0.05</sub>

Sarah Kemppainen

- Nb<sub>0.05</sub>V<sub>0.95</sub>, Nb<sub>0.1</sub>V<sub>0.9</sub>, Nb<sub>0.2</sub>V<sub>0.8</sub>, Nb<sub>0.3</sub>V<sub>0.7</sub>, Nb<sub>0.4</sub>V<sub>0.6</sub>

Connor Lane

- Nb<sub>0.6</sub>V<sub>0.4</sub>, Nb<sub>0.7</sub>V<sub>0.3</sub>, Nb<sub>0.8</sub>V<sub>0.2</sub>, Nb<sub>0.9</sub>V<sub>0.1</sub>, Nb<sub>0.95</sub>V<sub>0.05</sub>

Samuel Li

- Nb<sub>0.05</sub>W<sub>0.95</sub>, Nb<sub>0.1</sub>W<sub>0.9</sub>, Nb<sub>0.2</sub>W<sub>0.8</sub>, Nb<sub>0.3</sub>W<sub>0.7</sub>, Nb<sub>0.4</sub>W<sub>0.6</sub>

Gabriel Marostegan Mendes

- Nb<sub>0.6</sub>W<sub>0.4</sub>, Nb<sub>0.7</sub>W<sub>0.3</sub>, Nb<sub>0.8</sub>W<sub>0.2</sub>, Nb<sub>0.9</sub>W<sub>0.1</sub>, Nb<sub>0.95</sub>W<sub>0.05</sub>

Logan McMains

- Ta<sub>0.05</sub>V<sub>0.95</sub>, Ta<sub>0.1</sub>V<sub>0.9</sub>, Ta<sub>0.2</sub>V<sub>0.8</sub>, Ta<sub>0.3</sub>V<sub>0.7</sub>, Ta<sub>0.4</sub>V<sub>0.6</sub>

Lucas Ortiz

- Ta<sub>0.6</sub>V<sub>0.4</sub>, Ta<sub>0.7</sub>V<sub>0.3</sub>, Ta<sub>0.8</sub>V<sub>0.2</sub>, Ta<sub>0.9</sub>V<sub>0.1</sub>, Ta<sub>0.95</sub>V<sub>0.05</sub>

Vivek Pranabdev

- Ta<sub>0.05</sub>W<sub>0.95</sub>, Ta<sub>0.1</sub>W<sub>0.9</sub>, Ta<sub>0.2</sub>W<sub>0.8</sub>, Ta<sub>0.3</sub>W<sub>0.7</sub>, Ta<sub>0.4</sub>W<sub>0.6</sub>

Rajan Rijal

- Ta<sub>0.6</sub>W<sub>0.4</sub>, Ta<sub>0.7</sub>W<sub>0.3</sub>, Ta<sub>0.8</sub>W<sub>0.2</sub>, Ta<sub>0.9</sub>W<sub>0.1</sub>, Ta<sub>0.95</sub>W<sub>0.05</sub>

Lauren Robinowitz

- V<sub>0.05</sub>W<sub>0.95</sub>, V<sub>0.1</sub>W<sub>0.9</sub>, V<sub>0.2</sub>W<sub>0.8</sub>, V<sub>0.3</sub>W<sub>0.7</sub>, V<sub>0.4</sub>W<sub>0.6</sub>

Caden Sayers

- V<sub>0.6</sub>W<sub>0.4</sub>, V<sub>0.7</sub>W<sub>0.3</sub>, V<sub>0.8</sub>W<sub>0.2</sub>, V<sub>0.9</sub>W<sub>0.1</sub>, V<sub>0.95</sub>W<sub>0.05</sub>

Jordan Sloan

- Mo<sub>0.5</sub>Nb<sub>0.5</sub>, Mo<sub>0.5</sub>Ta<sub>0.5</sub>, Mo<sub>0.5</sub>V<sub>0.5</sub>, Mo<sub>0.5</sub>W<sub>0.5</sub>, Nb<sub>0.5</sub>Ta<sub>0.5</sub>

Jaelyn Tims

- Nb<sub>0.5</sub>V<sub>0.5</sub>, Nb<sub>0.5</sub>W<sub>0.5</sub>, Ta<sub>0.5</sub>V<sub>0.5</sub>, Ta<sub>0.5</sub>W<sub>0.5</sub>, V<sub>0.5</sub>W<sub>0.5</sub>

<!--## Submission

Students who take the Computational Materials Science course in Spring 2026 shall submit the following to the "Data submission" assignment on Canvas for each alloy:

- The `lmp_mcnpt.in` file
- One `lmp_gsfe.in` file, where the integer number in line 54 is 10
- The `data.CSRO` file generated by the CSRO simulation
- The `log.lammps` file from the CSRO simulation
- All 20 `gsfe` files, named `gsfe-1`, `gsfe-2` etc, where `1` or `2` is the integer number in line 54 of the corresponding `lmp_gsfe.in` file
- All 20 USFE values and the mean USFE value, provided in a text or excel file

Please use five folders, each named after its corresponding alloy (e.g., Mo<sub>0.05</sub>Nb<sub>0.95</sub>).-->

## Reference

If you use any files from this GitHub repository, please cite

- Richard Brinlee, Amin Poozesh, Anvesh Nathani, Anshu Raj, Xiang-Guo Li, Iman Ghamarian, Shuozhi Xu, [Integrating atomistic simulations and machine learning to predict unstable stacking fault energies of refractory non-dilute random alloys](https://doi.org/10.1007/s11837-025-07728-x), JOM 77 (2025) 8127--8136