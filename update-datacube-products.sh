
#!/usr/bin/env bash

echo "Script execution date $(date)"

# get the actual folder from where the script is executed
#SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
SCRIPT_DIR=/home/maesbri/Documents/development/atos/flexigrobots/opendatacube/datacube-config

# bounding box (spanish pilot)
BBOX="-10,41,-9,42"
# when updating the database with new satellite scenes from the STAC catalogue, indicate begin date as TODAY - 2 days and end date as TODAY + 1 day
DATETIME="$(date --date="2 days ago" +"%Y-%m-%d")/$(date --date="1 day" +"%Y-%m-%d")"

# update the database
echo "Indexing the latest tiles for BBOX=${BBOX} and DATETIME=${DATETIME}"
docker exec -it datacube-config_products-tester_1 stac-to-dc --bbox=${BBOX} --catalog-href='https://earth-search.aws.element84.com/v0/' --collections='sentinel-s2-l2a-cogs' --datetime=${DATETIME}
sleep 15

# update the corresponding tables for the OWS OGC services
echo "Updating OWS metadata"
docker exec -it datacube-config_ows_1 /bin/bash -c "datacube-ows-update --schema --role postgres && sleep 5 && datacube-ows-update --views && sleep 5 && datacube-ows-update"
sleep 15

# stop and relaunch again the ows container so it is aware of the changes
echo "Restarting OWS container"
docker-compose -f ${SCRIPT_DIR}/docker-compose.ows.yaml down 
sleep 15
docker-compose -f ${SCRIPT_DIR}/docker-compose.ows.yaml up -d

echo "END."