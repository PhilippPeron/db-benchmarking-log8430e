sudo mkdir cassandra-cluster-docker

sudo touch /home/ubuntu/cassandra-cluster-docker-compose/docker-compose.yml
sudo chmod 777 /home/ubuntu/cassandra-cluster-docker-compose/docker-compose.yml
sudo cat <<EOF >/home/ubuntu/cassandra-cluster-docker-compose/docker-compose.yml
version: '3.9'

services:
  cassandra:
    image: cassandra:4.0
    ports:
      - 9042:9042
    volumes:
      - ~/apps/cassandra:/var/lib/cassandra
    environment:
      - CASSANDRA_CLUSTER_NAME=cloudinfra
EOF

docker-compose up -d
docker-compose exec cassandra /bin/bash
cqlsh localhost 9042
create keyspace ycsb
    WITH REPLICATION = {'class' : 'SimpleStrategy', 'replication_factor': 3 };
USE ycsb;
create table usertable (
    y_id varchar primary key,
    field0 varchar,
    field1 varchar,
    field2 varchar,
    field3 varchar,
    field4 varchar,
    field5 varchar,
    field6 varchar,
    field7 varchar,
    field8 varchar,
    field9 varchar);
exit
exit

sudo mkdir /home/ubuntu/db-benchmarking-log8430e/results_cassandra

cd ycsb-0-17-0

bin/ycsb.sh load cassandra-cql -p hosts="localhost" -s -P workloads/workloada > ../results_cassandra/workloadA_load1.txt
bin/ycsb.sh run cassandra-cql -p hosts="localhost" -s -P workloads/workloada > ../results_cassandra/workloadA_run1.txt
bin/ycsb.sh load cassandra-cql -p hosts="localhost" -s -P workloads/workloadb > ../results_cassandra/workloadB_load1.txt
bin/ycsb.sh run cassandra-cql -p hosts="localhost" -s -P workloads/workloadb > ../results_cassandra/workloadB_run1.txt
echo "\nRun complete (1/3). Waiting 60s before next run..."

sleep 60
bin/ycsb.sh load cassandra-cql -p hosts="localhost" -s -P workloads/workloada > ../results_cassandra/workloadA_load2.txt
bin/ycsb.sh run cassandra-cql -p hosts="localhost" -s -P workloads/workloada > ../results_cassandra/workloadA_run2.txt
bin/ycsb.sh load cassandra-cql -p hosts="localhost" -s -P workloads/workloadb > ../results_cassandra/workloadB_load2.txt
bin/ycsb.sh run cassandra-cql -p hosts="localhost" -s -P workloads/workloadb > ../results_cassandra/workloadB_run2.txt
echo "\nRun complete (2/3). Waiting 60s before next run..."

sleep 60
bin/ycsb.sh load cassandra-cql -p hosts="localhost" -s -P workloads/workloada > ../results_cassandra/workloadA_load3.txt
bin/ycsb.sh run cassandra-cql -p hosts="localhost" -s -P workloads/workloada > ../results_cassandra/workloadA_run3.txt
bin/ycsb.sh load cassandra-cql -p hosts="localhost" -s -P workloads/workloadb > ../results_cassandra/workloadB_load3.txt
bin/ycsb.sh run cassandra-cql -p hosts="localhost" -s -P workloads/workloadb > ../results_cassandra/workloadB_run3.txt
echo "Run complete (3/3)."

docker stop $(docker ps -a -q)
