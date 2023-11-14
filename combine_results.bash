#!/bin/bash
##############################################################################
#####     Let's combine the 50 pieces that were divided into one       #######
##############################################################################

#Sort in ascending order of low p-values
#uncorrelated results
cat results0.2_uncorrel_1* | grep -v '^exposure' | sort -t$'\t' -k 7 -g | less
#correlated results
cat results0.2_correl_1* | grep -v '^exposure' | sort -t$'\t' -k 7 -g | less

cp results0.2_uncorrel_100.txt RES_UNC
cp results0.2_correl_100.txt RES_COR
cp steiger0.2_100.txt STG
cp dat_steiger0.2_100.txt DAT

#Combining into one document  
for I in {101..151}; do echo $I; cat results0.2_uncorrel_${I}.txt | 
tail -n +2 >> RES_UNC; cat dat_steiger0.2_${I}.txt | 
tail -n +2 >> DAT; cat steiger0.2_${I}.txt |
tail -n +2 >> STG; cat results0.2_correl_${I}.txt |
tail -n +2 >> RES_COR; done
