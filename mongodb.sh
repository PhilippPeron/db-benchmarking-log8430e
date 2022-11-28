# Install and run MongoDB
cd ~

sudo git clone https://github.com/minhhungit/mongodb-cluster-docker-compose.git
cd mongodb-cluster-docker-compose
Add
sudo rm ~/mongodb-cluster-docker-compose/docker-compose.yml
sudo touch ~/mongodb-cluster-docker-compose/docker-compose.yml
sudo chmod 777 ~/mongodb-cluster-docker-compose/docker-compose.yml
sudo cat <<EOF >~/mongodb-cluster-docker-compose/docker-compose.yml
version: "3.8"

services:
  mongo1:
    image: mongo:5
    container_name: mongo1
    command: ["--replSet", "my-replica-set", "--bind_ip_all", "--port", "30001"]
    volumes:
      - ./data/mongo-1:/data/db
    ports:
      - 30001:30001
    healthcheck:
      test: test $$(echo "rs.initiate({_id:'my-replica-set',members:[{_id:0,host:\"mongo1:30001\"},{_id:1,host:\"mongo2:30002\"},{_id:2,host:\"mongo3:30003\"}]}).ok || rs.status().ok" | mongo --port 30001 --quiet) -eq 1
      interval: 10s
      start_period: 30s

  mongo2:
    image: mongo:5
    container_name: mongo2
    command: ["--replSet", "my-replica-set", "--bind_ip_all", "--port", "30002"]
    volumes:
      - ./data/mongo-2:/data/db
    ports:
      - 30002:30002

  mongo3:
    image: mongo:5
    container_name: mongo3
    command: ["--replSet", "my-replica-set", "--bind_ip_all", "--port", "30003"]
    volumes:
      - ./data/mongo-3:/data/db
    ports:
      - 30003:30003



# docker exec -it mongo1 sh -c "mongo --port 30001"

# rs.initiate(
#  {
#    _id : 'my-replica-set',
#    members: [
#      { _id : 0, host : "mongo1:30001" },
#      { _id : 1, host : "mongo2:30002" },
#      { _id : 2, host : "mongo3:30003" }
#    ]
#  }
#)

# ./bin/ycsb load mongodb -s -P workloads/workloada -p recordcount=1000 -p mongodb.upsert=true -p mongodb.url=mongodb://mongo1:30001,mongo2:30002,mongo3:30003/?replicaSet=my-replica-set
EOF

sudo docker-compose up -d

sudo docker-compose exec configsvr01 sh -c "mongosh < /scripts/init-configserver.js"
sudo docker-compose exec shard01-a sh -c "mongosh < /scripts/init-shard01.js"
sudo docker-compose exec shard02-a sh -c "mongosh < /scripts/init-shard02.js"
sudo docker-compose exec shard03-a sh -c "mongosh < /scripts/init-shard03.js"

sudo docker-compose exec router01 sh -c "mongosh < /scripts/init-router.js"

#sudo docker-compose exec router01 mongosh --port 27017
#
#// Enable sharding for database `MyDatabase`
#sh.enableSharding("MyDatabase")
#
#// Setup shardingKey for collection `MyCollection`**
#db.adminCommand( { shardCollection: "MyDatabase.MyCollection", key: { oemNumber: "hashed", zipCode: 1, supplierId: 1 } } )
#exit

cd ~
sudo apt -y install default-jre
sudo apt -y install default-jdk
wget http://ftp.heanet.ie/mirrors/www.apache.org/dist/maven/maven-3/3.1.1/binaries/apache-maven-3.1.1-bin.tar.gz
sudo tar xzf apache-maven-*-bin.tar.gz -C /usr/local
cd /usr/local
sudo ln -s apache-maven-* maven

sudo touch /etc/profile.d/maven.sh
sudo chmod 777 /etc/profile.d/maven.sh
sudo cat <<EOF >/etc/profile.d/maven.sh
export M2_HOME=/usr/local/maven
export PATH=${M2_HOME}/bin:${PATH}
EOF
source /etc/profile.d/maven.sh
sudo apt -y install python2
sudo ln -s /usr/bin/python2 /usr/bin/python

cd ~
curl -O --location https://github.com/brianfrankcooper/YCSB/releases/download/0.5.0/ycsb-0.5.0.tar.gz
tar xfvz ycsb-0.5.0.tar.gz
cd ycsb-0.5.0
sudo ./bin/ycsb load mongodb -s -P workloads/workloada -p recordcount=500000 -p mongodb.url="mongodb://ubuntu:@localhost:27017/admin"
