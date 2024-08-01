#!/bin/bash

# Note that you may need to change the $cfchecker variable in this file to
# point to the full path location of your "cfchecks" script

outdir=tests_output.$$
mkdir $outdir

std_name_table=https://cfconventions.org/Data/cf-standard-names/79/src/cf-standard-name-table.xml
area_table=http://cfconventions.org/Data/area-type-table/10/src/area-type-table.xml


cfchecker="/Users/znicholls/mambaforge/envs/cf-checker-tests/bin/cfchecks"

failed=0

echo "Unzipping input netcdf files..."
gzip -d *.gz

cache_opts="-x --cache_dir ./cfcache-files-py3"

for file in `ls *.nc`
do
  if test $file == "badc_units.nc"
  then
    # Check --badc option (Note:  Need to set path to badc_units.txt in cfchecks.py)
    $cfchecker $cache_opts --badc $file -s $std_name_table > $outdir/$file.out 2>&1
  elif test $file == "stdName_test.nc"
  then
    # Check --cf_standard_names option
    # Test uses an older version of standard_name table so don't use table caching
    $cfchecker -s ./stdName_test_table.xml -a $area_table $file > $outdir/$file.out 2>&1
  elif [[ $file == "complex.nc" || $file == "CRM018_test1.nc" || $file == "CRM024_test1.nc" || \
          $file == "CRM028_test1.nc" || $file == "CRM032_test1.nc" || $file == "CRM033_test1.nc" || \
          $file == "CRM035.nc" || $file == "Trac022.nc" ]]
  then
    # CF-1.0
    $cfchecker $cache_opts -s $std_name_table -v 1.0 $file > $outdir/$file.out 2>&1
  else
    # Run checker using the CF version specified in the conventions attribute of the file
    $cfchecker $cache_opts -s $std_name_table -a $area_table -v auto $file > $outdir/$file.out 2>&1
  fi

  # Check the output against what is expected
  result=${file%.nc}.check
  diff $outdir/$file.out $result >/dev/null
  if test $? == 0
  then
    echo $file: Success
    rm $outdir/$file.out
  else
    diff $outdir/$file.out $result
    echo $file: Failed
    failed=`expr $failed + 1`
    exit 1
  fi
done

# Print Test Results Summary
echo ""
if [[ $failed != 0 ]]
then
  echo "****************************"
  echo "***    $failed Tests Failed    ***"
  echo "****************************"
else
  echo "****************************"
  echo "*** All Tests Successful ***"
  echo "****************************"
fi

# Check that the script options

# --cf_standard_names

# --udunits

# --coards


