IN=$1

COORD=`awk -F"," '{print $2,",",$1}' $IN | tr "\n" ";" | sed  s/' '//g | sed 's/.$//'`
echo $COORD

SVC="trip"
#SVC="route"

#STEPS="false"
STEPS="true"

CMD="http://localhost:5000/"$SVC"/v1/driving/"$COORD"?steps=${STEPS}&geometries=geojson&overview=full&approaches="
n=`wc -l $IN | awk '{print $1}'`
OPT=`printf '%.scurb;\n' {1..1000} | head -n $n | tr -d "\n" | sed 's/.$//'`
CMD=$CMD$OPT

curl $CMD

#curl "http://localhost:5000/trip/v1/driving/-73.508716,45.539683;-73.495128,45.535568;-73.493256,45.525447;-73.502376,45.526198;-73.513712,45.535929?steps=false&geometries=geojson&overview=full&approaches=curb;curb;curb;curb;curb"

#curl "http://172.16.10.10:3030/trip/v1/driving/-73.508716,45.539683;-73.495128,45.535568;-73.493256,45.525447;-73.502376,45.526198;-73.513712,45.535929?steps=false&geometries=geojson&overview=full&approaches=curb;curb;curb;curb;curb"

