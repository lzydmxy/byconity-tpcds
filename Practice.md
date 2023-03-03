# Practice of ByConity Cluster Setup and TPC-DS Benckmark

## 1. Preperation
1. Install Foundation DB to 3 physical machines. You can follow [this guide](https://github.com/ByConity/ByConity/blob/master/docker/executable_wrapper/FDB_installation.md)
2. Setup HDFS to 4+ physical machines, with 1 name node and 3+ data nodes. You can follow [this guide](https://github.com/ByConity/ByConity/blob/master/docker/executable_wrapper/HDFS_installation.md)
3. You have 2 options to deploy a ByConity Cluster, Using Docker or using package installation.

### 1.1 Docker deployment
1. Pull docker images
```
docker pull byconity/byconity-server:v0.2
```
2. 

### 1.2 Package deployment


1. Find a host that is running any byconity container, git clone this project, in the project folder, setup byconity client (TODO: tricky here)
```
mkdir bin
docker cp byconity-server:/root/app/usr/bin/clickhouse bin/
```

## 2. Run TPC-DS benchmark
Follow [this guide](https://github.com/ByConity/byconity-tpcds/blob/main/README.md) to run the TPC-DS benchmark on ByConity.


## Sharing of physical machines
If you have limited resources, you can share physical machines for this practice. 
1. You can install HDFS name node, TSO, deamon manager, and 1 ByConity Server to the same machine. 
2. 1 ByConity worker can share the machine with 1 HDFS data node, and 1 FDB node. 
3. If you are using docker, you can launch multiple ByConity workers in the same machine, once you have enough resource to allocate.
