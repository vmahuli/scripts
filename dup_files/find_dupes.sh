#!/usr/bin/env bash

# to find the list of duplicate files in a directory tree

#get list of files
find . -type f > all_files

#get md5 sum of all files into a file
for file in `cat all_files`
do
  md5value=$(md5sum ${file})
  echo "${md5value}" >> files_with_md5
done

# grep for md5sum in files_with_md5 and get those
# files which have more than one occurance
echo "Duplicate files..."
while read line
do
   md5sumoffile=$(echo ${line} | tr -s ' ' | cut -d ' ' -f1)   
   file_name=$(echo ${line} | tr -s ' ' | cut -d ' ' -f2)
   file_occurance_count=$(grep $md5sumoffile files_with_md5 | wc -l)
   if [ ${file_occurance_count} -gt 1 ]; then
       echo $file_name occurs ${file_occurance_count} times
   fi
done < files_with_md5

rm -f all_files files_with_md5
