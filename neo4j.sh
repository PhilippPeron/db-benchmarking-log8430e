# Install and run Neo4j
cd ~
sudo git clone https://github.com/bitnami/containers.git
cd containers/bitnami/neo4j/5/debian-11
sudo docker-compose up -d

#install Maven
cd ~
sudo apt install maven

### Install ycsb
curl -O --location https://github.com/brianfrankcooper/YCSB/releases/download/0.12.0/ycsb-0.12.0.tar.gz
tar xfvz ycsb-0.12.0.tar.gz
cd ycsb-0.12.0

git clone https://github.com/brianfrankcooper/YCSB.git
cd YCSB
mvn -pl com.yahoo.ycsb:neo4j-binding -am clean package
