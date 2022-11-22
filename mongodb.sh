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

sudo docker-compose exec router01 mongosh --port 27017

// Enable sharding for database `MyDatabase`
sh.enableSharding("MyDatabase")

// Setup shardingKey for collection `MyCollection`**
db.adminCommand( { shardCollection: "MyDatabase.MyCollection", key: { oemNumber: "hashed", zipCode: 1, supplierId: 1 } } )