# Install and run MongoDB
sudo apt update --quiet
sudo apt install default-jre -y
sudo apt install default-jdk -y
sudo apt update -y
sudo apt install maven -y
sudo apt install apt-transport-https ca-certificates curl software-properties-common -y
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu focal stable"
sudo apt update -y
sudo apt install docker-ce -y
sudo apt -y install python2
sudo ln -s /usr/bin/python2 /usr/bin/python

#Login stuff
sudo usermod -aG docker ${USER}
sudo su - ${USER}

# Install docker
sudo curl -L "https://github.com/docker/compose/releases/download/v2.6.1/docker-compose-linux-x86_64" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Download and unpack YCSB
sudo curl -O --location https://github.com/brianfrankcooper/YCSB/releases/download/0.17.0/ycsb-0.17.0.tar.gz
tar xfvz ycsb-0.17.0.tar.gz

# Get mongo for docker
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
sudo docker stop $(docker ps -a -q)

# Delete network
sudo docker network rm mongoCluster
