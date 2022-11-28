
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

# run orientdb three times on workload a - save output in directory results/orientdb/workload_A
for iter in {1..3}
    do
        bin/ycsb.sh load orientdb -P workloads/workloada -p orientdb.url=plocal:localhost:2480 -p orientdb.password=admin > ../../results/orientdb/workload_A/output_load${iter}
        bin/ycsb.sh run orientdb -P workloads/workloada -p orientdb.url=plocal:localhost:2480 -p orientdb.password=admin > ../../results/orientdb/workload_A/output_run${iter}
    done

# run orientdb three times on workload b – save output in directory results/orientdb/workload_B
for iter in {1..3}
    do
        bin/ycsb.sh load orientdb -P workloads/workloadb -p orientdb.url=plocal:localhost:2480 -p orientdb.password=admin > ../../results/orientdb/workload_B/output_load${iter}
        bin/ycsb.sh run orientdb -P workloads/workloadb -p orientdb.url=plocal:localhost:2480 -p orientdb.password=admin > ../../results/orientdb/workload_B/output_run${iter}
    done

cd ../../targetDB/data

# stop services defined in docker-compose-orientdb.yml
docker-compose -f docker-compose-orientdb.yml down