# Get mongoDB for docker
docker pull mongo

# Create a docker network cluster in which the docker containers are visible to each other
docker network create mongoCluster

# Start the Mongo docker containers
docker run -d --rm -p 27017:27017 --name mongo0 --network mongoCluster mongo:5 mongod --replSet myRS --bind_ip localhost,mongo0
docker run -d --rm -p 27018:27017 --name mongo1 --network mongoCluster mongo:5 mongod --replSet myRS --bind_ip localhost,mongo1
docker run -d --rm -p 27019:27017 --name mongo2 --network mongoCluster mongo:5 mongod --replSet myRS --bind_ip localhost,mongo2

# Init replica set
docker exec -it mongo0 mongosh --eval "rs.initiate({
 _id: 'myRS',
 members: [
   {_id: 0, host: 'mongo0:27017'},
   {_id: 1, host: 'mongo1:27017'},
   {_id: 2, host: 'mongo2:27017'}
 ]
})"
sudo mkdir sudo mkdir ~/db-benchmarking-log8430e/results_mongodb
sudo mkdir ~/db-benchmarking-log8430e/results_mongodb/workloadA
sudo mkdir ~/db-benchmarking-log8430e/results_mongodb/workloadB

# Run workloads
cd ycsb-0.17.0
for iter in {0..2}
    do
        ./bin/ycsb.sh load mongodb -s -P workloads/workloada -p mongodb.url=mongodb://127.0.0.1:27017/ycsb?w=1 > ~/db-benchmarking-log8430e/results_mongodb/workloadA/load${iter}
        ./bin/ycsb.sh run mongodb -s -P workloads/workloada -p mongodb.url=mongodb://127.0.0.1:27017/ycsb?w=1 > ~/db-benchmarking-log8430e/results_mongodb/workloadA/run${iter}
    done
for iter in {0..2}
    do
        ./bin/ycsb.sh load mongodb -s -P workloads/workloadb -p mongodb.url=mongodb://127.0.0.1:27017/ycsb?w=1 > ~/db-benchmarking-log8430e/results_mongodb/workloadB/load${iter}
        ./bin/ycsb.sh run mongodb -s -P workloads/workloadb -p mongodb.url=mongodb://127.0.0.1:27017/ycsb?w=1 > ~/db-benchmarking-log8430e/results_mongodb/workloadB/run${iter}
    done

# Stop all containers
docker stop $(docker ps -a -q)

# Delete network
docker network rm mongoCluster
