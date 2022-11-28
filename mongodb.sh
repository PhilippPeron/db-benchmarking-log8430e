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

# Run workloads three times and save results
cd ycsb-0.17.0
./bin/ycsb.sh load mongodb -s -P workloads/workloada -p mongodb.url=mongodb://127.0.0.1:27017/ycsb?w=1 > ../results_mongodb/workloadA_load1.txt
./bin/ycsb.sh run mongodb -s -P workloads/workloada -p mongodb.url=mongodb://127.0.0.1:27017/ycsb?w=1 > ../results_mongodb/workloadA_run1.txt
./bin/ycsb.sh load mongodb -s -P workloads/workloadb -p mongodb.url=mongodb://127.0.0.1:27017/ycsb?w=1 > ../results_mongodb/workloadB_load1.txt
./bin/ycsb.sh run mongodb -s -P workloads/workloadb -p mongodb.url=mongodb://127.0.0.1:27017/ycsb?w=1 > ../results_mongodb/workloadB_run1.txt
echo "\nRun complete (1/3). Waiting 60s before next run..."

sleep 60
./bin/ycsb.sh load mongodb -s -P workloads/workloada -p mongodb.url=mongodb://127.0.0.1:27017/ycsb?w=1 > ../results_mongodb/workloadA_load2.txt
./bin/ycsb.sh run mongodb -s -P workloads/workloada -p mongodb.url=mongodb://127.0.0.1:27017/ycsb?w=1 > ../results_mongodb/workloadA_run2.txt
./bin/ycsb.sh load mongodb -s -P workloads/workloadb -p mongodb.url=mongodb://127.0.0.1:27017/ycsb?w=1 > ../results_mongodb/workloadB_load2.txt
./bin/ycsb.sh run mongodb -s -P workloads/workloadb -p mongodb.url=mongodb://127.0.0.1:27017/ycsb?w=1 > ../results_mongodb/workloadB_run2.txt
echo "\nRun complete (2/3). Waiting 60s before next run..."

sleep 60
./bin/ycsb.sh load mongodb -s -P workloads/workloada -p mongodb.url=mongodb://127.0.0.1:27017/ycsb?w=1 > ../results_mongodb/workloadA_load3.txt
./bin/ycsb.sh run mongodb -s -P workloads/workloada -p mongodb.url=mongodb://127.0.0.1:27017/ycsb?w=1 > ../results_mongodb/workloadA_run3.txt
./bin/ycsb.sh load mongodb -s -P workloads/workloadb -p mongodb.url=mongodb://127.0.0.1:27017/ycsb?w=1 > ../results_mongodb/workloadB_load3.txt
./bin/ycsb.sh run mongodb -s -P workloads/workloadb -p mongodb.url=mongodb://127.0.0.1:27017/ycsb?w=1 > ../results_mongodb/workloadB_run3.txt
echo "Run complete (3/3)."

# Stop all containers
docker stop $(docker ps -a -q)

# Delete network
docker network rm mongoCluster
