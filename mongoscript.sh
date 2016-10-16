#!/bin/bash
echo $(docker inspect --format '{{ .NetworkSettings.IPAddress }}' cntr1) " mongo1.server " > addr.txt
echo $(docker inspect --format '{{ .NetworkSettings.IPAddress }}' cntr2) " mongo2.server " >> addr.txt

docker cp addr.txt cntr1:/etc
docker cp addr.txt cntr2:/etc

echo "#!/bin/bash
cat /etc/hosts > /etc/hoststmp
sed -i '/server/d' /etc/hoststmp
cat /etc/addr.txt >> /etc/hoststmp
cat /etc/hoststmp > /etc/hosts" > addhost.sh
 
chmod +x addhost.sh
docker cp addhost.sh cntr1:/etc
docker cp addhost.sh cntr2:/etc

docker exec -it cntr1 chmod +x /etc/addhost.sh
docker exec -it cntr2 chmod +x /etc/addhost.sh
 

docker exec -it cntr1 /etc/addhost.sh
docker exec -it cntr2 /etc/addhost.sh

docker exec -it cntr1 mongo --eval "rs.status()"
exit
docker exec -it	cntr1 mongo --eval "db"
docker exec -it cntr1 mongo --eval "rs.initiate()"
sleep 100
docker exec -it cntr1 mongo --eval "rs.add(\"mongo2.server:27017\")"

docker exec -it cntr2 mongo --eval "rs.slaveOk()"

