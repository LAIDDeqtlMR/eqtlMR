Before preparing data, you must download the following files.

1. [2019-12-11-cis-eQTLsFDR0.05-ProbeLevel-CohortInfoRemoved-BonferroniAdded.txt.gz](https://molgenis26.gcc.rug.nl/downloads/eqtlgen/cis-eqtl/2019-12-11-cis-eQTLsFDR0.05-ProbeLevel-CohortInfoRemoved-BonferroniAdded.txt.gz)

2. [2018-07-18_SNP_AF_for_AlleleB_combined_allele_counts_and_MAF_pos_added.txt.gz](https://molgenis26.gcc.rug.nl/downloads/eqtlgen/cis-eqtl/2018-07-18_SNP_AF_for_AlleleB_combined_allele_counts_and_MAF_pos_added.txt.gz)

3. druggable_genome_new.txt.

You will need to provide the druggable genome file. The publicly available version of the druggable genome provided by Finan at al. can be used instead of druggable_genome_new.txt.

https://pubmed.ncbi.nlm.nih.gov/28356508/

######################################################################


* : New file created by running the script

Organization of files and folders

TwoSample project<br/>
　　eqtl_data_eqtlgen<br/>
　　　　SPLIT<br/>
　　　　　　*exposure.100 - 151 3@<br/>
　　　　2018-07-18_SNP_AF_for_AlleleB_combined_allele_counts_and_MAF_pos_added.txt.gz 2@<br/>
　　　　2019-12-11-cis-eQTLsFDR0.05-ProbeLevel-CohortInfoRemoved-BonferroniAdded.txt.gz 2@<br/>
　　　　*eqtlgen_exposure_dat_snps_5kb_window.txt(=full.txt) 2@ 3@<br/>
　　Crohn_disease<br/>
　　　　*SPLIT<br/>
　　　　　　*exposure.100 - 151 5&6@<br/>
　　　　　　combine_results.R 7@<br/>
　　　　　　*DAT 7@<br/>
　　　　　　*RES_COR 7@<br/>
　　　　　　*RES_UNC 7@<br/>
　　　　　　*STG 7@ <br/>
　　　　　　*plotting_MR.R 8@<br/>
　　　　　　*JAK2.pdf 8@<br/>
　　　　crohn_disease.vcf.gz<br/>
　　　　crohn_disease.vcf.gz.tbi<br/>
　　　　creat_rsid_with_VCF.bash (vcfRSindex.bash) 4@<br/>
      　*crohn_disease.vcf.rsidx 4@<br/>
　　　　ruuning_MR.R (liberalRun.R) 5&6@<br/>
　　TGZ<br/>
　　　　*1kg.v3.tgz<br/>
　　　　*EUR.bed<br/>
　　　　*EUR.bim<br/>
　　　　*EUR.fam<br/>
　　TwoSampleMR_to_MR.R (dat2MRInput.R) 5&6@<br/>
　　druggalbe_genome_new.txt<br/>
　　install_gwasvcf.R 1@<br/>
　　Split_exposure_into_chunks.R (files are needed : eqtlgen_exposure_dat_snps_5kb_window.txt(=full.txt)) 3@
　　data_prep_eqtlgen.R (files are needed : 2018~txt.gz, 2019~txt.gz, druggable_genome~.txt) 2@
