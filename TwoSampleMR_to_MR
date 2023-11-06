

###############################################################
##Convert TwoSampleMR format to MendelianRandomization format##
###############################################################

# The Mendelian Randomization package offers MR methods that can be used with the same data used in the TwoSampleMR package.
# This function converts from the TwoSampleMR format to the MRInput class.
#
# @param dat Output from the [harmonise_data()] function.
# @param get_correlations Default `FALSE`. If `TRUE` then extract the LD matrix for the SNPs from the European 1000 genomes data on the MR-Base server.
# @param pop If `get_correlations` is `TRUE` then use the following 
#
# @export
# @return List of MRInput objects for each exposure/outcome combination

dat2MRInput <- function(dat, get_correlations=FALSE, pop="EUR", bfile=NULL, plink_bin=NULL)
{
  out <- plyr::dlply(dat, c("exposure", "outcome"), function(x)
  {
    x <- plyr::mutate(x)
    message("Converting:")
    message(" - exposure: ", x$exposure[1])
    message(" - outcome: ", x$outcome[1])
    if(get_correlations)
    {message(" - obtaining LD matrix")
      ld <- ieugwasr::ld_matrix(variants=unique(x$SNP), with_alleles=TRUE, pop=pop, bfile=bfile, plink_bin=plink_bin)
      save(ld, file='plink_ld_matrix.RData')
      save(x, file='plink_ld_snps.RData')
      # If all alleles are "T", read.table in R guess it as a logical column
      if( any( grepl( 'TRUE', rownames(ld) ) ) ) {
        colnames(ld) <- rownames(ld) <- sub('TRUE', 'T', rownames(ld))
      }


      # plink reorders the SNPs
      snpnames <- do.call(rbind, strsplit(rownames(ld), split="_"))[,1]
      MD <- match( x$SNP, snpnames )
      ld <- ld[ MD, MD ]
      out <- Harmonize_LD_dat(x, ld)
      if(is.null(out))
      {
        return(NULL)
      }
      x <- out$x
      ld <- out$ld
      if( nrow(x) == 0 ) {
        message( 'Nothing left. Skipping this exposure')
        return(NULL)
      }
      
      MendelianRandomization::mr_input(
        bx = x$beta.exposure,
        bxse = x$se.exposure,
        by = x$beta.outcome,
        byse = x$se.outcome,
        exposure = x$exposure[1],
        outcome = x$outcome[1],
        snps = x$SNP,
        effect_allele=x$effect_allele.exposure,
        other_allele=x$other_allele.exposure,
        eaf = x$eaf.exposure,
        correlation = ld
      )
      
    } else {
      MendelianRandomization::mr_input(
        bx = x$beta.exposure,
        bxse = x$se.exposure,
        by = x$beta.outcome,
        byse = x$se.outcome,
        exposure = x$exposure[1],
        outcome = x$outcome[1],
        snps = x$SNP,
        effect_allele=x$effect_allele.exposure,
        other_allele=x$other_allele.exposure,
        eaf = x$eaf.exposure
      )
    }
  })
  return(out)
}


#Allele harmonization
Harmonise_LD_dat <- function(x, ld) {
  snpnames <- do.call('rbind', strsplit( rownames(ld), split='_' ))
  keep <- ( snpnames[,2] == x$effect_allele.exposure & snpnames[,3] == x$other_allele.exposure ) |
    ( snpnames[,3] == x$effect_allele.exposure & snpnames[,2] == x$other_allele.exposure )
  if( sum(keep) == 0 ) {
    save(ld, file='harmony_ld.RData')
    message(" - none of the SNPs could be aligned to the LD reference panel")
    message("LD matrix dimension ", dim(ld))
    message("LD matrix rownames ", paste( rownames(ld), sep=' ' ))
    message("exposure SNP names ", paste( x$SNP, x$effect_allele.exposure, x$other_allele.exposure, sep='_', collapse=' ' ))
    return(NULL)
  }
  
  if( any( !keep ) ) {
    message(" - the following ", sum(!keep), " SNPs could not be aligned to the LD reference panel:\n- ", paste(snpnames[!keep,1], collapse="\n - "))
    ld <- ld[keep, keep]
    x <- x[keep]
    snpnames <- snpnames[keep,]
  }
  flip <- which( snpnames[,2] != x$effect_allele.exposure )
  x$beta.exposure[flip] <- -x$beta.exposure[flip]
  x$beta.outcome[flip] <- -x$beta.outcome[flip]
  temp <- x$effect_allele.exposure[flip]
  x$effect_allele.exposure[flip] <- x$other_allele.exposure[flip]
  x$other_allele.exposure[flip] <- temp
  return( list( x=x, ld=ld ) )
}
