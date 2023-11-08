Before preparing data, you must download the following files.

1. [2019-12-11-cis-eQTLsFDR0.05-ProbeLevel-CohortInfoRemoved-BonferroniAdded.txt.gz](https://molgenis26.gcc.rug.nl/downloads/eqtlgen/cis-eqtl/2019-12-11-cis-eQTLsFDR0.05-ProbeLevel-CohortInfoRemoved-BonferroniAdded.txt.gz)

2. [2018-07-18_SNP_AF_for_AlleleB_combined_allele_counts_and_MAF_pos_added.txt.gz](https://molgenis26.gcc.rug.nl/downloads/eqtlgen/cis-eqtl/2018-07-18_SNP_AF_for_AlleleB_combined_allele_counts_and_MAF_pos_added.txt.gz)

3. druggable_genome_new.txt.

You will need to provide the druggable genome file. The publicly available version of the druggable genome provided by Finan at al. can be used instead of druggable_genome_new.txt.

https://pubmed.ncbi.nlm.nih.gov/28356508/

######################################################################


* : New file created by running the script

Organization of files and folders

TwoSample project
   eqtl_data_eqtlgen
      SPLIT
         *exposure.100 - 151 3@
      2018-07-18_SNP_AF_for_AlleleB_combined_allele_counts_and_MAF_pos_added.txt.gz 2@
      2019-12-11-cis-eQTLsFDR0.05-ProbeLevel-CohortInfoRemoved-BonferroniAdded.txt.gz 2@
      *eqtlgen_exposure_dat_snps_5kb_window.txt(=full.txt) 2@ 3@
   Crohn_disease
      *SPLIT
         *exposure.100 - 151 5&6@
         combine_results.R 7@
         *DAT 7@
         *RES_COR 7@
         *RES_UNC 7@
         *STG 7@ 
         *plotting_MR.R 8@
         *JAK2.pdf 8@
      crohn_disease.vcf.gz
      crohn_disease.vcf.gz.tbi
      creat_rsid_with_VCF.bash (vcfRSindex.bash) 4@
      *crohn_disease.vcf.rsidx 4@
      ruuning_MR.R (liberalRun.R) 5&6@
   TGZ
   *1kg.v3.tgz
   *EUR.bed
   *EUR.bim
   *EUR.fam
   TwoSampleMR_to_MR.R (dat2MRInput.R) 5&6@
   druggalbe_genome_new.txt
   install_gwasvcf.R 1@
   Split_exposure_into_chunks.R (files are needed : eqtlgen_exposure_dat_snps_5kb_window.txt(=full.txt)) 3@
   data_prep_eqtlgen.R (files are needed : 2018~txt.gz, 2019~txt.gz, druggable_genome~~.txt) 2@
