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
| Read Worker     | 16  | 100G | 100G  | >=3    |
| DaemonManager   | 4   | 10G  | 10G  | 1      |
| ResourceManager | 8   | 16G  | 10G  | 1      |
| Client | 8+   | 16G+  | 200G  | 1      |

### 1.1 Option 1: Docker deployment
1. Make sure docker is installed in your system. You can follow the [official guide](https://docs.docker.com/engine/install/) to install.
2. Go to the docker folder in this project. 
3. Setup server ip addresses in the `config/cnch_config.xml`, replace the `{xxx_address}` with your actual server address. This includes server, tso, deamon manager, read worker and write worker. You may need to adjust the xml sections of nodes according to the actual number of nodes you want to run for the servers and write/read workers. You may also need to adjust the ports that could cause conflicts on your environment.
4. Replace the `config/fdb.cluster` with the `fdb.cluster` file generated in the FDB setup step above.
5. Adjust the parameters in the run.sh. especially the cpus and memeory you want to allocate to each component, according to the requirements table described above.
6. On every host that you need you deploy ByConity components, do the following:  
    1). Copy the docker folder to the host.  
    2). Pull docker images:  
    ```
    docker pull byconity/byconity-server:stable
    ```
7. Initial and start the ByConity components:  
    1). Start TSO on 1 host: `./run.sh tso`.   
    2). Start servers, each server on 1 host: `./run.sh server`.  
    3). Start the Deamon Manager on 1 host: `./run.sh dm`.  
    4). Start write workers, each write worker on 1 host: `./run.sh write_worker`.  
    5). Start read workers, each read worker on 1 host: `./run.sh read_worker`.  
8. You can restart the ByConity components by: `./run.sh stop {component_name}`, and `./run.sh stop {component_name}`, the `component_name` is the same as described in #6.

### 1.2 Option 2: Package deployment
1. Find the ByConity releases on [this page](https://github.com/ByConity/ByConity/releases)
2. On every host that you need you deploy ByConity components, do the following:  
    1). Install FoundationDB client package, you can find the releases on [this page](https://github.com/apple/foundationdb/releases). Make sure you install the same version as the FoundationDB server which described above.
    ```
    curl -L -o foundationdb-clients_7.1.25-1_amd64.deb https://github.com/apple/foundationdb/releases/download/7.1.25/foundationdb-clients_7.1.25-1_amd64.deb
    sudo dpkg -i foundationdb-clients_7.1.25-1_amd64.deb
    ```
    2). Install the ByConity common package `byconity-common-static`.
    ```
    sudo dpkg -i byconity-common-static_0.1.1.1_amd64.deb
    ```
    3). Setup server addresses in the `/etc/byconity-server/cnch_config.xml`, the same way as described in #1.1. You can refer to the sections in `docker/config/cncn_config.xml` file in this project. 
    4). Replace the `/etc/byconity-server/fdb.config` with the `fdb.cluster` file generated in the FDB setup step above.
3. Initial and start the ByConity components:
    1). Choose 1 host to run TSO, download the `byconity-tso` package and install.
    ```
    sudo dpkg -i byconity-tso_0.1.1.1_amd64.deb
    ```
    If this is the first time the package is installed, it won't start immediately but in next reboot. So you have to manually start the service.
    ```
    systemctl start byconity-tso
    ```
    2). Choose 1 host to run server, download the `byconity-server` package and install.
    ```
    sudo dpkg -i byconity-server_0.1.1.1_amd64.deb 
    ```
    3). Choose 1 host to run deamon manager, download the `byconity-daemon-manager` package and install.
    ```
    sudo dpkg -i byconity-daemon-manager_0.1.1.1_amd64.deb 
    ```
    4). Choose 3+ hosts to run read worker, download the `byconity-worker` package and install.
    ```
    sudo dpkg -i byconity-worker_0.1.1.1_amd64.deb 
    ```
    5). Choose 3+ hosts to run write worker, download the `byconity-write-worker` package and install.
    ```
    sudo dpkg -i byconity-worker-write_0.1.1.1_amd64.deb 
    ```

### Sharing of physical machines
If you have limited resources, you can share physical machines for this practice. 
1. You can install HDFS name node, TSO, deamon manager, and 1 ByConity Server to the same machine. 
2. 1 ByConity worker can share the machine with 1 HDFS data node, and 1 FDB node. 
3. If you are using docker, you can launch multiple ByConity workers in the same machine, once you have enough resource to allocate.

## 2. Setup client
1. Find a machine that you want to setup as the client to run TPC-DS. Git clone byconity-tpcds project.
2. You can install the package from [this page](https://github.com/ByConity/ByConity/releases), and then find  `clickhouse` binary and copy it to `bin` folder in the project. Or you can copy the binary from any existing installations. E.g. an existing ByConity docker container.
    ```
    mkdir bin
    docker cp byconity-server:/root/app/usr/bin/clickhouse bin/
    ````
3. Make sure FoundationDB client is install on the client machine, as described in #1.2

## 3. Run TPC-DS benchmark
Follow [this guide](https://github.com/ByConity/byconity-tpcds/blob/main/README.md) to run the TPC-DS benchmark on ByConity. Collect the results. 

## 4. Add more workers and rerun
Mofity config/cnch_config.xml to add 2+ more read workers. Deploy the config to server node and restart server.
Rerun the TPC-DS benchmark. Collect the results.

