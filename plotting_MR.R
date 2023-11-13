##################################
#####      Plotting MR        ####
##################################

library(TwoSampleMR)
library(ggplot2)
library(dplyr)

#input file loading
resUnc <- read.delim("RES_UNC")
head(resUnc)
resCor <- read.delim("RES_COR")
head(resCor)
dat <- read.delim("DAT")
head(dat)

#select exposure from p-value (0.05)
resUnc_pval <- resUnc %>% filter(p <= 0.05 ) 
resUnc_pval
table(resUnc_pval$exposure)
resCor_pval <- resCor %>% filter(p <= 0.05 ) 
resCor_pval
table(resCor_pval$exposure)

#create function
pick<-function(gene,res,dat){
res1<-subset(res,exposure==gene)
dat1<-subset(dat,exposure==gene)
res1$id.exposure<-dat1$id.exposure[1]
res1$id.outcome<-dat1$id.outcome[1]
res1$b<-res1$beta
list(res=res1,dat=dat1)}

#data visualization 
(one<-pick('JAK2',resCor,dat))
mr_scatter_plot(one$res,one$dat)[[1]]->p1
(single<-mr_singlesnp(one$dat))
p2 <- mr_forest_plot(single)[[1]]
p3 <- mr_funnel_plot(single)[[1]]
pdf('JAK2.pdf')
print(p1)
print(p2)
print(p3)
dev.off()
