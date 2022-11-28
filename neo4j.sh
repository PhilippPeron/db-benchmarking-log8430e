sudo apt -y install python2
sudo ln -s /usr/bin/python2 /usr/bin/python

cd /ycsb-0.17.0
./bin/ycsb load mongodb -s -P workloads/workloada -p recordcount=1000 -p mongodb.upsert=true -p mongodb.url=mongodb://mongo1:30001,mongo2:30002,mongo3:30003/?replicaSet=my-replica-set
./bin/ycsb load mongodb -s -P workloads/workloada -p recordcount=1000 -p mongodb.upsert=true -p mongodb.url=mongodb://mongo1:30001,mongo2:30002,mongo3:30003/?replicaSet=my-replica-set > loadMongo.txt
./bin/ycsb run mongodb -s -P workloads/workloada -p recordcount=1000 -p mongodb.upsert=true -p mongodb.url=mongodb://mongo1:30001,mongo2:30002,mongo3:30003/?replicaSet=my-replica-set > runMongo2.txt