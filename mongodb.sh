# Get mongoDB for docker
docker pull mongo

# Create a docker network cluster in which the docker containers are visible to each other
docker network create mongoCluster

# Start the Mongo docker containers
docker run -d --rm -p 27017:27017 --name mongo1 --network mongoCluster mongo:5 mongod --replSet myRS --bind_ip localhost,mongo1
docker run -d --rm -p 27018:27017 --name mongo2 --network mongoCluster mongo:5 mongod --replSet myRS --bind_ip localhost,mongo2
docker run -d --rm -p 27019:27017 --name mongo3 --network mongoCluster mongo:5 mongod --replSet myRS --bind_ip localhost,mongo3

# Init replica set
docker exec -it mongo1 mongosh --eval "rs.initiate({
 _id: 'myRS',
 members: [
   {_id: 0, host: 'mongo1:27017'},
   {_id: 1, host: 'mongo2:27017'},
   {_id: 2, host: 'mongo3:27017'}
 ]
})"
sudo mkdir /home/ubuntu/db-benchmarking-log8430e/results_mongodb
sudo mkdir /home/ubuntu/db-benchmarking-log8430e/results_mongodb/workloadA
sudo mkdir /home/ubuntu/db-benchmarking-log8430e/results_mongodb/workloadB

# Run workloads
cd ycsb-0.17.0
./bin/ycsb.sh load mongodb -s -P workloads/workloada -p mongodb.url=mongodb://127.0.0.1:27017/ycsb?w=1 > ../results_mongodb/workloadA/load1
./bin/ycsb.sh run mongodb -s -P workloads/workloada -p mongodb.url=mongodb://127.0.0.1:27017/ycsb?w=1 > ../results_mongodb/workloadA/run1
./bin/ycsb.sh load mongodb -s -P workloads/workloadb -p mongodb.url=mongodb://127.0.0.1:27017/ycsb?w=1 > ../results_mongodb/workloadB/load1
./bin/ycsb.sh run mongodb -s -P workloads/workloadb -p mongodb.url=mongodb://127.0.0.1:27017/ycsb?w=1 > ../results_mongodb/workloadB/run1
sleep 10
./bin/ycsb.sh load mongodb -s -P workloads/workloada -p mongodb.url=mongodb://127.0.0.1:27017/ycsb?w=1 > ../results_mongodb/workloadA/load2
./bin/ycsb.sh run mongodb -s -P workloads/workloada -p mongodb.url=mongodb://127.0.0.1:27017/ycsb?w=1 > ../results_mongodb/workloadA/run2
./bin/ycsb.sh load mongodb -s -P workloads/workloadb -p mongodb.url=mongodb://127.0.0.1:27017/ycsb?w=1 > ../results_mongodb/workloadB/load2
./bin/ycsb.sh run mongodb -s -P workloads/workloadb -p mongodb.url=mongodb://127.0.0.1:27017/ycsb?w=1 > ../results_mongodb/workloadB/run2
sleep 10
./bin/ycsb.sh load mongodb -s -P workloads/workloada -p mongodb.url=mongodb://127.0.0.1:27017/ycsb?w=1 > ../results_mongodb/workloadA/load3
./bin/ycsb.sh run mongodb -s -P workloads/workloada -p mongodb.url=mongodb://127.0.0.1:27017/ycsb?w=1 > ../results_mongodb/workloadA/run3
./bin/ycsb.sh load mongodb -s -P workloads/workloadb -p mongodb.url=mongodb://127.0.0.1:27017/ycsb?w=1 > ../results_mongodb/workloadB/load3
./bin/ycsb.sh run mongodb -s -P workloads/workloadb -p mongodb.url=mongodb://127.0.0.1:27017/ycsb?w=1 > ../results_mongodb/workloadB/run3


# Stop all containers
docker stop $(docker ps -a -q)

# Delete network
docker network rm mongoCluster
