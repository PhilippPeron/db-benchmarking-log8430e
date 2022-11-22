# Install and run MongoDB
cd ~

sudo git clone https://github.com/minhhungit/mongodb-cluster-docker-compose.git
cd mongodb-cluster-docker-compose
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
