# Install and run MongoDB
sudo apt update
sudo apt install default-jre
sudo apt install default-jdk
sudo apt update -y
sudp apt install maven -y
sudo apt install apt-transport-https ca-certificates curl software-properties-common -y
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu focal stable"
sudo apt update -y
sudo apt install docker-ce -y

#LOGIN STUFF
sudo usermod -aG docker ${USER}
#sudo su - ${USER}

curl -L "https://github.com/docker/compose/releases/download/v2.6.1/docker-compose-linux-x86_64" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose




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
