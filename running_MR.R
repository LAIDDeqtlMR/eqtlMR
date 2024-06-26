#!/usr/bin/env Rscript

############################################
###### Run Mendelian Randomization !! ######
############################################


#Let's name the code below 'liberalRun.R'

############################################
#########    liberalRun.R       ############
############################################

# Upload gene list to be excluded
if( file.exists("EXPOSURES.exclude") ) {
	EXPOSURES.exclude <- read.delim("EXPOSURES.exclude", head=F)[,1]
	print( paste( length(EXPOSURES.exclude), "genes to be excluded in the analysis" ) )
} else {
	EXPOSURES.exclude <- NULL
}

suppressPackageStartupMessages( {
  library(ieugwasr)
  library(gwasvcf) 
  library(gwasglue)
  library(VariantAnnotation)
  library(dplyr)
  library(TwoSampleMR)
} )
source("~/TwoSampleMR_project/eqtlMR/TwoSampleMR_to_MR.R")

# Use bundled binaries in genetics.binaRies
set_bcftools()
set_plink()

eQTLfolder <- '../eqtl_data_eqtlgen'
vcfFile <- 'ieu-b-7.vcf.gz'
vcfRSidx <- sub('.gz', '.rsidx', vcfFile)

( args <- commandArgs(trailingOnly=TRUE) )
if( length(args) == 0 ) {
  message('START and END(=START) required')
  q()
} else {
  START <- args[1]
  END <- START
  if( length(args) == 2 ) {
    END <- args[2]
  }
}
print( paste( 'Splits ranging from', START, 'to', END ) )
message( paste( 'Splits ranging from', START, 'to', END ) )

for( SPLIT in START:END ) {
  message( paste( 'Processing', SPLIT ) )
  print( paste( 'Processing', SPLIT ) )
  
  EXPOSURES <- read.delim( paste0( eQTLfolder, '/SPLIT/exposures.', SPLIT ), head=F)[,1]
  if( ! is.null(EXPOSURES.exclude) ) {
	  EXPOSURES <- setdiff( EXPOSURES, EXPOSURES.exclude )
  }
  print( head(EXPOSURES) )
  load( paste( eQTLfolder, 'exposures.RData', sep='/') )
  
  exp1 <- exp0[ exp0$exposure %in% EXPOSURES, ]
  print( head(exp1) )
  
  vcf <- query_gwas( vcfFile, rsid=exp1$SNP, rsidx=vcfRSidx )
  rowRanges(vcf)
  
  out <- gwasvcf_to_TwoSampleMR(vcf, type='outcome')
  dat0 <- harmonise_data( exp1, out )
  print('harmonised')
  dat <- subset( dat0, dat0$mr_keep == TRUE )
  print( head(dat) )
  print( colnames(dat) )
  dat0.2 <- ld_clump_local( data.frame( rsid=dat$SNP, pval=dat$pval.exposure, id=dat$id.exposure ), clump_kb=10000, clump_p=0.99, clump_r2 = 0.2, bfile='../TGZ/EUR', plink_bin=getOption("tools_plink") )
  dat0.2 <- subset( dat, dat$SNP %in% dat0.2$rsid )
  print('clumped')
  dat0.2$r.outcome <- get_r_from_lor(dat0.2$beta.outcome, af=dat0.2$eaf.outcome, ncase=33674, ncontrol=449056, prevalence=0.01)
  print( summary(dat0.2$r.outcome) )
  print('got r')
  print( head(dat0.2) )
  
  steiger0.2 <- directionality_test(dat0.2)
  print('direction tested')
  steiger0.2_1 <- subset( steiger0.2, correct_causal_direction == TRUE )
  dat_steiger0.2 <- subset( dat0.2, dat0.2$exposure %in% steiger0.2_1$exposure )
  write.table(steiger0.2, file=paste0('SPLIT/steiger0.2_', SPLIT, '.txt'), col.names=T, row.names=F, sep="\t")
  write.table(dat_steiger0.2, file=paste0('SPLIT/dat_steiger0.2_', SPLIT, '.txt'), col.names=T, row.names=F, sep="\t")
  
  # MR analysis uncorrelated
  
  two_snps_or_less <- as.data.frame( table( dat_steiger0.2$exposure ) )
  dat_steiger0.2_two_snps_or_less <- subset( dat_steiger0.2, dat_steiger0.2$exposure %in% two_snps_or_less$Var1[ which( two_snps_or_less$Freq <=2 ) ] )
  
  mr_mrbase0.2 <- mr( dat_steiger0.2_two_snps_or_less )
  print(paste('mr uncorrelated done', SPLIT))
  if( plyr::empty( mr_mrbase0.2 ) == TRUE ) {
    mr_mrbase0.2_keep <- data.frame()
  } else {
    mr_mrbase0.2_keep <- mr_mrbase0.2[, c('exposure', 'outcome', 'nsnp', 'method', 'b', 'se', 'pval')]
    names( mr_mrbase0.2_keep )[5:7] <- c('beta', 'se', 'p')
    mr_mrbase0.2_keep$clump_thresh <- "0.2"
    all_res <- mr_mrbase0.2_keep
    data_for_qval <- which( all_res$method == 'IVW' | all_res$method == 'Inverse variance weighted' | all_res$method == 'Wald ratio' )
    all_res[data_for_qval, 'fdr_qval'] <- p.adjust(all_res[ data_for_qval, 'p'], method = 'fdr' )
    write.table( all_res, file=paste0('SPLIT/results0.2_uncorrel_', SPLIT, '.txt'), col.names=T, row.names=F, sep="\t", quote=F)
  }
  
  # MR analysis correlated
  dat_steiger_keep <- subset( dat_steiger0.2, dat_steiger0.2$exposure %in% two_snps_or_less$Var1[ which(two_snps_or_less$Freq > 2) ] )
  
  if( plyr::empty( dat_steiger_keep ) == TRUE ) {
    print(paste('No gene in this chunk have > 2 snps available', SPLIT))
  } else {
    unique_exposures0 <- sort( unique( dat_steiger_keep$exposure ) )
    unique_exposures <- unique_exposures0[ !is.na(unique_exposures0) ]
    corr_results <- data.frame()
    corr_egger_intercept <- data.frame()
    
    for( i in 1:length(unique_exposures) ) {
      uei <- unique_exposures[i]
      dat_steiger_keep1 <- subset( dat_steiger_keep, exposure == uei )
      dat2 <- dat2MRInput( dat_steiger_keep1, get_correlation=TRUE, bfile='../TGZ/EUR', plink_bin=getOption("tools_plink") )
      save(dat2, file='MRInput.RData')
      if( is.null(dat2[[1]]) ) stop()
      ivw <- MendelianRandomization::mr_ivw( dat2[[1]], correl=TRUE )
      egger <- MendelianRandomization::mr_egger( dat2[[1]], correl=TRUE )
      maxlik <- MendelianRandomization::mr_maxlik( dat2[[1]], correl=TRUE )
      try( temp_data <- rbind( c( ivw@Exposure, ivw@Outcome, ivw@SNPs, ivw@class[1], ivw@Estimate, ivw@StdError, ivw@Pvalue),
                               c( egger@Exposure, egger@Outcome, egger@SNPs, egger@class[1], egger@Estimate, egger@StdError.Est, egger@Pvalue.Est),
                               c( maxlik@Exposure, maxlik@Outcome, maxlik@SNPs, maxlik@class[1], maxlik@Estimate, maxlik@StdError, maxlik@Pvalue)
      ) )
      try( corr_results <- rbind( corr_results, temp_data ) )
      try( temp_data1 <- c( egger@Exposure, egger@Outcome, egger@SNPs, egger@Intercept, egger@CILower.Int, egger@CIUpper.Int, egger@Pvalue.Int, egger@Heter.Stat[1], egger@Heter.Stat[2] ) )
      try( corr_egger_intercept <- rbind( corr_egger_intercept, temp_data1 ) )
    }
    
    print(paste('mr correlated done', SPLIT))
    corr_results1 <- corr_results
    names( corr_results1 ) <- c('exposure', 'outcome', 'nsnp', 'method', 'beta', 'se', 'p')
    corr_results1[, 5:7] <- sapply( corr_results1[, 5:7], function(x) as.numeric(as.character(x)) )
    corr_results1$clump_thresh <- "0.2"
    all_res <- corr_results1
    write.table( all_res, file=paste0('SPLIT/results0.2_correl_', SPLIT, '.txt'), col.names=T, row.names=F, sep="\t", quote=F)
    
    # egger intercept and q values
    corr_egger_intercept1 <- corr_egger_intercept
    names( corr_egger_intercept1 ) <- c('exposure', 'outcome', 'nsnp', 'intercept', 'lower_ci', 'upper_ci', 'pvalue', 'q', 'q_pval')
    corr_egger_intercept1[, 3:9] <- sapply( corr_egger_intercept1[, 3:9], function(x) as.numeric(as.character(x)) )
    cochrans_q <- corr_egger_intercept1
    cochrans_q$nsnp <- as.numeric(as.character(cochrans_q$nsnp))
    cochrans_q$q_df <- cochrans_q$nsnp - 1
    QD <- which( cochrans_q$q >= cochrans_q$q_df )
    cochrans_q[QD,"i2"] <- (cochrans_q[QD,"q"]-cochrans_q[QD,"q_df"])/cochrans_q[QD,"q"]
    cochrans_q[ -QD, "i2" ] <- round(0, digits = 1)
    
    cochrans_q$conf_int <- paste( round( cochrans_q$lower_ci, digits = 4 ),
                                  round( cochrans_q$upper_ci, digits = 4 ), sep = ', ' )
    qc_write_out <- cochrans_q[, c('exposure', 'outcome', 'nsnp', 'intercept', 'conf_int', 'pvalue', 'q', 'q_pval', 'i2') ]
    names(qc_write_out)[4:8] <- c('egger_intercept', 'egger_intercept_95_ci', 'egger_intercept_pvalue', 'cochrans_q', 'cochrans_q_pval')
    
    write.table( qc_write_out, file=paste0('SPLIT/results0.2_egger_cochransq_', SPLIT, '.txt'), col.names=T, row.names=F, sep="\t", quote=F)
  }
  
}

#running MR
#./liberalRun.R  100  151  2> liberalRun.log
