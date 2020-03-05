curl 'https://static01.nyt.com/newsgraphics/2020/01/21/china-coronavirus/43232c77c4a0b1840abb3449a58cca018fe3e518/build/js/chunks/model.js' > model.mjs
echo "Confirmed,County" >county_count.csv ; node nyt2 | jq '.u[]."County where treated"' -r | uniq -c | tr -s ' ' | sed 's/^ //g' | sed 's/ /,/' >> county_count.csv
tr a-z A-Z < county_count.csv |csvcut -c '2,1' > county_count_upper.csv
awk 'BEGIN{FS=OFS=","}{a[$1]+=$2}END{for(i in a) print i,a[i]}' county_count_upper.csv > county_count_upper_sum.csv
awk 'BEGIN{FS=OFS=","}{a[$1]+=$2}END{for(i in a) print i,a[i]}' icu_ca.csv > icu_ca_sum.csv
echo "COUNTY,CONFIRMED,ICU BED COUNT" > california_icu_data.csv
csvjoin -c '1,1' county_count_upper_sum.csv icu_ca_sum.csv >> california_icu_data.csv 

bash nyt.sh

tr a-z A-Z < nyt_us_county.csv > nyt_us_county_upper.csv

csvjoin -c '1,1' nyt_us_county_upper.csv california_icu_data.csv | csvcut -c 'COUNTY,POPULATION_2010,CONFIRMED,DEATHS,ICU BED COUNT' > california.csv 
xsv table california.csv