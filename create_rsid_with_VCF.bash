#!/bin/bash
#########################################################
##########create index file using VCF####################
#########################################################

#Let's name the code below 'vcfRSindex.bash'

#####################################################
##################vcfRSindex.bash####################
#####################################################

#!/bin/bash

VCF=ieu-b-7.vcf.gz
echo "Creating rsid_to_coord index for the VCF file: ${VCF}"

RS=`echo ${VCF} | sed -e "s/.gz/.rs.txt/"`

#########Comment out and use according to the OS you are using (Linux or MacOS).#########
# For Linux
#zcat ${VCF} | grep -v '^#' | awk '$3 ~ /^rs/ {print substr($3,3), $1, $2}' | uniq > ${RS}
# For MacOS
gzcat ${VCF} | grep -v '^#' | awk '$3 ~ /^rs/ {print substr($3,3), $1, $2}' | uniq > ${RS}
#########################################################################################

echo "Number of lines: `wc -l ${RS}`"

RSIDX=`echo ${RS} | sed -e "s/.txt/idx/"`
[[ -e ${RSIDX} ]] && echo "${RSIDX} found, to be overwritten" && rm ${RSIDX}

sqlite3 ${RSIDX} <<EOJ 2> /dev/null
CREATE TABLE rsid_to_coord ( rsid INTEGER PRIMARY KEY, chrom TEXT NULL DEFAULT NULL, coord INTEGER NOT NULL DEFAULT 0);
.separator " "
.import ${RS} rsid_to_coord
EOJ
echo "SQLITE3 file ${RSIDX} created"

echo "Top 10 records and the total number of records"

sqlite3 ${RSIDX} <<EOJ 2> /dev/null
SELECT * FROM rsid_to_coord LIMIT 10;
SELECT COUNT(*) FROM rsid_to_coord;
EOJ

echo "${RS} is no longer necessary, removed"
rm ${RS}
#######################################################################################


#The following command is executed to change the file's status to executable.
#chmod +x vcfRSindex.bash

#Running code
#./vcfRSindex.bash
