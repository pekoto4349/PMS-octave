#!/bin/bash
mkdir /models/$modelID
mkdir /models/$modelID/fromoctave
echo $modelID
echo $1

while [ "$1" == 'model' ]
do
  if [ "$(ls -A /models/$modelID/inputfile.csv)" ]; then
  #if [ -f "$(/models/$modelID/inputfile.csv)" ]; then
    	ls /models/$modelID
    	echo "Data found.."
	break
  else
	sleep 10 
    echo "Waiting for dir to populate with data..."
  fi
done

echo "Data populated, proceeding..."
if [ "$1" == 'model' ]; then

    #http://bigdatastack-tasks.ds.unipi.gr/gkousiou/adw/-/raw/master/adwdocker/modelling/modeldata/inputfile.csv

    echo "[Entrypoint] Starting modelling process"
    
    octave /home/joe/modelauncher $NUMINPUTS $modelID $NUMOUTPUTS
    
    
    chmod +r /models/$modelID/quality.txt
    export CLIOUT=`cat /models/$modelID/quality.txt`
    export CURLINPUT=$ADWRESULTS$modelID/$CLIOUT
    #curl -u admin:bigds -X POST -H 'Content-Type: text/csv' -d @/sync/testout.csv $ADW_RESULTS
    echo $CURLINPUT
    
    curl -u admin:bigds -X POST $CURLINPUT
    
    chmod +r /models/images/$modelID.jpg
    chmod +r /models/images/$modelID.svg
    
    #./mc cp --recursive /models/$modelID/ minio/models/$modelID/
    #./mc cp /models/images/$modelID.jpg minio/models/$modelID/$modelID.jpg
    #./mc cp /models/images/$modelID.svg minio/models/$modelID/$modelID.svg


elif [ "$1" == "prediction" ]; then
	echo "[Entrypoint] Starting prediction process"
	
	#retrieve models from bucket
	#./mc cp minio/models/$modelID/bestmodel.mat /models/$modelID/bestmodel.mat
	#./mc cp minio/models/$modelID/config.mat /models/$modelID/config.mat
	#./mc cp minio/models/$modelID/estimation_$TIMESTAMP.csv /models/$modelID/estimation_$TIMESTAMP.csv
	

    octave predlauncher.m $modelID $TIMESTAMP $NUMINPUTS
    #need to have a convention on where to store/return the output: /models/modelID/estimation_timestamp.csv
    #echo "Estimation created, finishing..."
    #echo "Uploading prediction to bucket..."
    #./mc cp /models/$modelID/out_$TIMESTAMP.csv minio/models/$modelID/predictions/out_$TIMESTAMP.csv
    
fi


