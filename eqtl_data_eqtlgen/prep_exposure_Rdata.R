library("TwoSampleMR")
library("dplyr")
library("stringr")

exp0 <- read_exposure_data(
  filename = "eqtlgen_exposure_dat_snps_5kb_window.txt",
  sep = "\t",
  snp_col = "SNP",
  beta_col = "beta",
  se_col = "se",
  eaf_col = "eaf",
  effect_allele_col = "AssessedAllele",
  other_allele_col = "OtherAllele",
  pval_col = "Pvalue",
  phenotype_col = "GeneSymbol",
  samplesize_col = "NrSamples",
  min_pval = 1e-400
)

exp0 <- exp0[grepl( "^rs", exp0$SNP),]

save(exp0, file="exposures.RData")
