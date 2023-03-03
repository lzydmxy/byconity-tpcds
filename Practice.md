# Practice of ByConity Cluster Setup and TPC-DS Benckmark

## 1. Preperation
1. Install Foundation DB to 3 physical machines. You can follow [this guide](https://github.com/ByConity/ByConity/blob/master/docker/executable_wrapper/FDB_installation.md)
2. Setup HDFS to 4+ physical machines, with 1 name node and 3+ data nodes. You can follow [this guide](https://github.com/ByConity/ByConity/blob/master/docker/executable_wrapper/HDFS_installation.md)
3. You have 2 options to deploy a ByConity Cluster, Using Docker or using package installation.

Resource requirements of each components.

| Component        | CPU | Memory | Disk | Instances |
| :-------------- | :-- | :--- | :--- | :----- |
| TSO             | 2   | 500M | 5G   | 1      |
| Server          | 16  | 60G  | 100G   | >=1   |
| Write Worker    | 16  | 60G  | 100G  | >=3    |
| Read Worker     | 24  | 120G | 100G  | >=3    |
| DaemonManager   | 4   | 10G  | 10G  | 1      |
| ResourceManager | 8   | 16G  | 10G  | 1      |

### 1.1 Docker deployment
1. Pull docker images
```
docker pull byconity/byconity-server:v0.2
```
2. Setup server ip addresses in the config/cnch_config.xml, replace the {xxx_address} with your actual server address. This includes server, tso, deamon manager, read worker and write worker. You may need to adjust the xml sections of nodes according to the actual number of nodes you want to run for the servers and write/read workers. You may also need to adjust the ports that could cause conflicts on your environment.
3. Replace the config/fdb.cluster with the fdb.cluster file generated in the FDB setup step above.
4. Adjust the parameters in the run.sh. especially the cpus and memeory you want to allocate to each component, according to the requirements table described above.
5. Initial and start the ByConity cluster:
    1). Start TSO in 1 machine: ./run.sh tso
    2). Start servers, each server in 1 machine: ./run.sh server
    3). Start the Deamon Manager in 1 machine: ./run.sh dm
    4). Start write workers, each write worker in 1 machine: ./run.sh write_worker
    5). Start read workers, each read worker in 1 machine: ./run.sh read_worker
6. You can restart the ByConity components by: ./run.sh stop {component_name}, and ./run.sh stop {component_name}, the component_name is the same as described in #5.

### 1.2 Package deployment

## Sharing of physical machines
If you have limited resources, you can share physical machines for this practice. 
1. You can install HDFS name node, TSO, deamon manager, and 1 ByConity Server to the same machine. 
2. 1 ByConity worker can share the machine with 1 HDFS data node, and 1 FDB node. 
3. If you are using docker, you can launch multiple ByConity workers in the same machine, once you have enough resource to allocate.

## 2. Setup client
1. Find a host and git clone byconity-tpcds project.
2. In the project folder, setup byconity client, you can install the client package from [this page](https://github.com/ByConity/ByConity/releases) and copy the clickhouse binary to project bin/. Or if you host has byconity container, you can copy the binary out.
```
mkdir bin
docker cp byconity-server:/root/app/usr/bin/clickhouse bin/
```
3. Install FDB client
```
curl -L -o foundationdb-clients_7.1.25-1_amd64.deb https://github.com/apple/foundationdb/releases/download/7.1.25/foundationdb-clients_7.1.25-1_amd64.deb
sudo dpkg -i foundationdb-clients_7.1.27-1_amd64.deb
```

## 3. Run TPC-DS benchmark
Follow [this guide](https://github.com/ByConity/byconity-tpcds/blob/main/README.md) to run the TPC-DS benchmark on ByConity. Collect the results. 

## 4. Add more workers and rerun
Mofity config/cnch_config.xml to add 2+ more read workers. Deploy the config to server node and restart server.
Rerun the TPC-DS benchmark. Collect the results.

