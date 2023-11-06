# About LAIDDeqtlMR: Discovery and verification of disease targets using Mendelian Randomization

Among the Mendelian randomization (MR) methods, Two sample MR is used to conduct integrated analysis of published GWAS and Eqtl data, and target discovery and verification, which is the initial stage of new drug development.


![Figure](https://mrcieu.github.io/TwoSampleMR/articles/img/twosamplemr_schematic_long-01.png)

## Data

In order to use two sample MR, appropriate exposure and outcome selection is required. In this project, the Eqtl dataset is used as exposure, and the [GWAS dataset](https://gwas.mrcieu.ac.uk/) of the disease to be observed is used as outcome.


* exposure
1000 genomes reference panels for LD for each superpopulation - used by default in OpenGWAS:

http://fileserve.mrcieu.ac.uk/ld/1kg.v3.tgz

* outcome

https://gwas.mrcieu.ac.uk/

## Installation

You'll need to install following in order to run the codes in R. 

```
install.packages("remotes")
install.packages( c( 'BiocManager', 'forestplot', 'remotes' ) )
BiocManager::install( 'VariantAnnotation' )
remotes::install_github( c( 'MRCIEU/TwoSampleMR', 'MRCIEU/gwasvcf', 'MRCIEU/gwasglue', 'MRCIEU/genetics.binaRies' ) )
genetics.binaRies::get_plink_binary()
genetics.binaRies::get_bcftools_binary()

```



**For citation:**

Full documentation available here: https://mrcieu.github.io/TwoSampleMR

GWASVCF : https://github.com/MRCIEU/gwasvcf/blob/master/README.md
