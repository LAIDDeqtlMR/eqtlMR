# About LAIDDeqtlMR: Discovery and verification of disease targets using Mendelian Randomization

Among the Mendelian randomization (MR) methods, Two sample MR is used to conduct integrated analysis of published GWAS and Eqtl data, and target discovery and verification, which is the initial stage of new drug development.


![Figure](https://mrcieu.github.io/TwoSampleMR/articles/img/twosamplemr_schematic_long-01.png)

## Data

Two sample MR는 데이터 셋으로 exposure와 outcome 선정이 필요하다. 각각을 질병으로 타겟을 선정할 수 있으나, 본 프로젝트에서는 exposure는 Eqtl 데이터셋을, outcome으로는 관찰하고자 하는 질병의 GWAS 데이터 셋을 사용한다. 


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
