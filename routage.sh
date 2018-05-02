#################################
## Call the Civilia OSRM server
##
## ./routage.sh data.txt out
##
## Input file data.txt with only long,lat
## -73.508716,45.539683
## Output json file
#################################                                                                                                                                                      

echo 

## Checks
if [[ "$1" == "" ]]; then echo "Input 1 missing: coord. file"; exit 1; fi
if [[ "$2" == "" ]]; then echo "Input 2 missing: output file"; exit 1; fi

## Input file with coordinates
IN=$1
echo "IN: "$IN
echo

## Output json file
OUT=$2
echo "OUT: "$OUT
echo

## Trip or route
SVC="trip"
#SVC="route"
echo "SVC: "$SVC
echo

## All navi details
STEPS="false"
#STEPS="true"
echo "STEPS: "$STEPS
echo

## Extract the coordinates
COORD=`awk -F"," '{print $2,",",$1}' $IN | tr "\n" ";" | sed  s/' '//g | sed 's/.$//'`
echo "COORDS: "$COORD
echo

## Build the query api
CMD="http://routing.civilia.ca/"$SVC"/v1/driving/"$COORD"?steps=${STEPS}&geometries=geojson&overview=full&approaches="

## Add the curb option, one by coord
n=`wc -l $IN | awk '{print $1}'`
echo "NB. COORD: "$n
echo
OPT="" 
for (( i=1; i<=$n; i++ )); do
    OPT=$OPT"curb;"
done
CMD=$CMD$OPT

## API ready
echo "API: "$CMD
echo

## Run the query
curl $CMD > $OUT

echo
echo "DONE."
echo

## Examples
#curl "http://localhost:5000/trip/v1/driving/-73.508716,45.539683;-73.495128,45.535568;-73.493256,45.525447;-73.502376,45.526198;-73.513712,45.535929?steps=false&geometries=geojson&overview=full&approaches=curb;curb;curb;curb;curb"
#curl "http://172.16.10.10:3030/trip/v1/driving/-73.508716,45.539683;-73.495128,45.535568;-73.493256,45.525447;-73.502376,45.526198;-73.513712,45.535929?steps=false&geometries=geojson&overview=full&approaches=curb;curb;curb;curb;curb"

