# Modified to reduce memory usage and correct some errors

#########################################################
########## read exposure data and preparation ###########
#########################################################



library("dplyr")
library("readr")



# load druggable genome
druggable <- read_tsv("druggable_genome_new.txt", col_types=cols(.default="c"))

dim(druggable)

# load eqtlgen data
eqtlgen <- read_tsv(gzfile("2019-12-11-cis-eQTLsFDR0.05-ProbeLevel-CohortInfoRemoved-BonferroniAdded.txt.gz"), col_types=cols(.default="c"))
eqtlgen$new_gene_id <- eqtlgen$Gene

dim(eqtlgen)

# keep eqtls for druggable genes
eqtlgen_druggable <- subset(eqtlgen, eqtlgen$new_gene_id %in% druggable$ensembl_gene_id)

dim(eqtlgen_druggable)

### select SNPs within 5kb upstream/downstream of gene

# read in genes positions from druggable genome
genes_id0 <- distinct(druggable[, c("ensembl_gene_id", "hgnc_names", "chr_b37", "start_b37", "end_b37" )])

dim(genes_id0)

# keep autosome only
genes_id01 <- genes_id0[which(genes_id0$"chr_b37" %in% 1:22),]
genes_id01[,3:5] <- sapply(genes_id01[,3:5], as.numeric)

dim(genes_id01)

# renames columns
names(genes_id01) <- c("exposure","gene.exposure","chromosome_name","start_position","end_position")



# keep genes that have an eqtl eqtlgen data
genes_id <- subset(genes_id01, genes_id01$exposure %in% eqtlgen_druggable$new_gene_id)

dim(genes_id)

# format eqtlgen to suit loop
dat <- eqtlgen_druggable
dat[, c("SNPChr", "SNPPos")] <- sapply(dat[, c("SNPChr", "SNPPos")], as.numeric)

dim(dat)

# create empty data frame
genes_data <- data.frame()



# loop to keep snps within 5kb of gene start/end positions # from 1382626 eQTLs for 2918 genes to 280216 eQTLs for 2791 genes
for (i in 1:length(unique(genes_id$gene.exposure))) {

  dat1 <- dat[which(dat$new_gene_id==genes_id$exposure[i] & dat$SNPChr==genes_id$chromosome_name[i] & dat$SNPPos >= (genes_id$start_position[i]-5000) & dat$SNPPos <= (genes_id$end_position[i]+5000)),]

  genes_data <- rbind(genes_data,dat1)
  if( i %% 100 == 0 ) print(i)
}


# remove unnccessary objects
rm(eqtlgen, eqtlgen_druggable)
gc()


# alt allele == effect allele
alleles <- read_tsv(gzfile("2018-07-18_SNP_AF_for_AlleleB_combined_allele_counts_and_MAF_pos_added.txt.gz"), col_types=cols(.default="c"))

dim(alleles)

# add allele data
alleles_keep <- subset(alleles, alleles$SNP %in% genes_data$SNP)

dim(alleles_keep)

# AlleleB_all ==  Allele frequency of Allele B
full <- left_join(genes_data, alleles_keep[, c("SNP", "AlleleB", "AlleleB_all")], by = "SNP")

dim(full)

#switch allele frequencies where appropriate
mismatch <- which(full$AssessedAllele != full$AlleleB)
mismatch2 <- which(full$OtherAllele == full$AlleleB)
sum(mismatch - mismatch2) # should be 0

full$eaf <- full$AlleleB_all
full$eaf[mismatch] <- 1 - as.numeric(full$eaf[mismatch])

dim(full)

# calculate beta and standard error
full$beta <- as.numeric(full$Zscore) / sqrt(2 * as.numeric(full$eaf) *
                                                      (1- as.numeric(full$eaf)) *
                                                      (as.numeric(full$NrSamples) + as.numeric(full$Zscore)^2))

full$se = 1 / sqrt(2 * as.numeric(full$eaf) *
                         (1- as.numeric(full$eaf)) *
                         (as.numeric(full$NrSamples) + as.numeric(full$Zscore)^2))



# add gene names
# full_with_names <- left_join(full, genes_id[, c("exposure", "gene.exposure")], by = c("new_gene_id" = "exposure"))

write.table(full, "eqtlgen_exposure_dat_snps_5kb_window.txt", sep = "\t", row.names = F, quote = F)


print("mission complete")
