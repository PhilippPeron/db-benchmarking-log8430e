
docker pull orientdb

mkdir database
cd database/
sudo touch docker-compose.orientdb.yml
sudo chmod 777 docker-compose.orientdb.yml
sudo cat <<EOF >docker-compose.orientdb.yml
version: "2"
services:
  orient-node-0:
    image: orientdb:2.2.30
    command: dserver.sh
    environment:
      ORIENTDB_ROOT_PASSWORD: admin
    ports:
      - 2480:2480

  orient-node-1:
    image: orientdb:2.2.30
    command: dserver.sh
    environment:
      ORIENTDB_ROOT_PASSWORD: admin
    depends_on:
      - orient-node-0

  orient-node-2:
      image: orientdb:2.2.30
      command: dserver.sh
      environment:
        ORIENTDB_ROOT_PASSWORD: admin
      depends_on:
        - orient-node-0
EOF


# start services defined in docker-compose-orientdb.yml
docker-compose -f docker-compose.orientdb.yml up -d

cd ..
cd ycsb-0.17.0


./bin/ycsb.sh load orientdb -P workloads/workloada -p orientdb.url=plocal:localhost:2480 -p orientdb.password=admin > ../results_orientdb/workloadA_load1.txt
./bin/ycsb.sh run orientdb -P workloads/workloada -p orientdb.url=plocal:localhost:2480 -p orientdb.password=admin > ../results_orientdb/workloadB_run1.txt
./bin/ycsb.sh load orientdb -P workloads/workloadb -p orientdb.url=plocal:localhost:2480 -p orientdb.password=admin > ../results_orientdb/workloadA_load1.txt
./bin/ycsb.sh run orientdb -P workloads/workloadb -p orientdb.url=plocal:localhost:2480 -p orientdb.password=admin > ../results_orientdb/workloadB_run1.txt
echo "\nRun complete (1/3). Waiting 60s before next run..."
sleep 60

./bin/ycsb.sh load orientdb -P workloads/workloada -p orientdb.url=plocal:localhost:2480 -p orientdb.password=admin > ../results_orientdb/workloadA_load2.txt
./bin/ycsb.sh run orientdb -P workloads/workloada -p orientdb.url=plocal:localhost:2480 -p orientdb.password=admin > ../results_orientdb/workloadB_run2.txt
./bin/ycsb.sh load orientdb -P workloads/workloadb -p orientdb.url=plocal:localhost:2480 -p orientdb.password=admin > ../results_orientdb/workloadA_load2.txt
./bin/ycsb.sh run orientdb -P workloads/workloadb -p orientdb.url=plocal:localhost:2480 -p orientdb.password=admin > ../results_orientdb/workloadA_run2.txt
echo "\nRun complete (2/3). Waiting 60s before next run..."
sleep 60

./bin/ycsb.sh load orientdb -P workloads/workloada -p orientdb.url=plocal:localhost:2480 -p orientdb.password=admin > ../results_orientdb/workloadA_load3.txt
./bin/ycsb.sh run orientdb -P workloads/workloada -p orientdb.url=plocal:localhost:2480 -p orientdb.password=admin > ../results_orientdb/workloadB_run3.txt
./bin/ycsb.sh load orientdb -P workloads/workloadb -p orientdb.url=plocal:localhost:2480 -p orientdb.password=admin > ../results_orientdb/workloadA_load3.txt
./bin/ycsb.sh run orientdb -P workloads/workloadb -p orientdb.url=plocal:localhost:2480 -p orientdb.password=admin > ../results_orientdb/workloadA_run3.txt
echo "\Run Complete"


# stop services defined in docker-compose-orientdb.yml
docker-compose -f docker-compose-orientdb.yml down