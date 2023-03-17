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
| Read Worker     | 16  | 60G | 100G  | >=3    |
| DaemonManager   | 4   | 10G  | 10G  | 1      |
| ResourceManager | 8   | 16G  | 10G  | 1      |
| Client         | 8+   | 16G+  | 200G  | 1     |

### 1.3.1 Option 1: Docker deployment
1. Make sure docker is installed in your system. You can follow the [official guide](https://docs.docker.com/engine/install/) to install.
2. Go to the docker folder in this project. 
3. Configure the `config/cnch_config.xml`. Setup host addresses in `<service_discovery>`, replace the `{xxx_address}` with your actual host address. This includes xml sections of server, tso, deamon manager and resource manager. You can optional adjust the ports that could cause conflicts on your environment. Setup hdfs namenode address in `<hdfs_nnproxy>`.
4. Replace the `config/fdb.cluster` with the `fdb.cluster` file generated in the FDB setup step above.
5. Adjust the parameters in the `run.sh`. especially the cpus and memeory you want to allocate to each component, according to the requirements table described above. If you changed any port in `config/cnch_config.xml`, you also have to make corresponding changes here in `run.sh`.
6. On every host that you need you deploy ByConity components, do the following:  
    1). Copy the docker folder to the host.  
    2). Pull docker images:  
    ```
    docker pull byconity/byconity-server:stable
    ```
7. Initial and start the ByConity components:  
    1). Start TSO on 1 host: `./run.sh tso`.   
    2). Start the resource manager on 1 host: `./run.sh rm`.   
    3). Start the deamon manager on 1 host: `./run.sh dm`.     
    4). Start servers, each server on 1 host: `./run.sh server`.  
    5). Start write workers, each write worker on 1 host: `./run.sh write_worker <woker_id>`. `worker_id` is optional, if not specified, `<hostname>-write` will be used.
    6). Start read workers, each read worker on 1 host: `./run.sh read_worker <woker_id>`. `worker_id` is optional, if not specified, `<hostname>-read` will be used.
8. You can restart the ByConity components by: `./run.sh stop {component_name}`, and `./run.sh stop {component_name}`, the `component_name` is the same as described in #6.

### 1.3.2 Option 2: Package deployment
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
    4). Replace the content of `/etc/byconity-server/fdb.config` with the content of `fdb.cluster` file generated in the FDB setup step above.
3. Initial and start the ByConity components:
    1). Choose 1 host to run TSO, download the `byconity-tso` package and install.
    ```
    sudo dpkg -i byconity-tso_0.1.1.1_amd64.deb
    ```
    If this is the first time the package is installed, it won't start immediately but in next reboot. So you have to manually start the service.
    ```
    systemctl start byconity-tso
    ```
    2). Choose 1 host to run resource manager, download the `byconity-resource-manager` package and install.
    ```
    sudo dpkg -i byconity-resource-manager_0.1.1.1_amd64.deb 
    systemctl start byconity-resource-manager
    ```
    3). Choose 1 host to run deamon manager, download the `byconity-daemon-manager` package and install.
    ```
    sudo dpkg -i byconity-daemon-manager_0.1.1.1_amd64.deb 
    systemctl start byconity-daemon-manager
    ```
    4). Choose 1 host to run server, download the `byconity-server` package and install.
    ```
    sudo dpkg -i byconity-server_0.1.1.1_amd64.deb 
    systemctl start byconity-server
    ```
    5). Choose 3+ hosts to run read worker, download the `byconity-worker` package and install. Before starting the service, export the environment variables for resource manager discovery. `WORKER_ID` has to be unique.
    ```
    sudo dpkg -i byconity-worker_0.1.1.1_amd64.deb 
    systemctl start byconity-worker
    ```
    6). Choose 3+ hosts to run write worker, download the `byconity-write-worker` package and install. Before starting the service, export the environment variables for resource manager discovery. `WORKER_ID` has to be unique.
    ```
    sudo dpkg -i byconity-worker-write_0.1.1.1_amd64.deb 
    systemctl start byconity-worker-write
    ```

### Sharing of physical machines
If you have limited resources, you can share physical machines for this practice. 
1. You can install HDFS name node, TSO, deamon manager, and 1 ByConity Server to the same host. 
2. 1 read / write worker can share the host with 1 HDFS data node, and 1 FDB node. For docker mode, 1 read worker can also share with 1 write worker, but for pkg installation mode, it can't.

## 2. Setup client
1. Find a machine that you want to setup as the client to run TPC-DS. Git clone byconity-tpcds project.
2. Copy the clickhouse binary or make links to the `bin` folder in this project.  
    If you are running ByConity using docker, you can copy it from any existing ByConity docker container.
    ```
    mkdir bin
    docker cp byconity-server:/root/app/usr/bin/clickhouse bin/
    ````
    If you package installed ByConity common package. You can copy or link `/usr/bin/clickhouse` to the `bin` folder in this project.
3. Make sure FoundationDB client is install on the client machine, as described in #1.2

## 3. Verify your deployment
1. Connect to the ByConity server
    ```
    bin/clickhouse client --host=<your_server_host> --port=<your_server_tcp_port>  --enable_optimizer=1 --dialect_type='ANSI'
    ```
2. Run some basic queries
    ```
    CREATE DATABASE test;
    USE test;
    CREATE TABLE events (`id` UInt64, `s` String) ENGINE = CnchMergeTree ORDER BY id;
    INSERT INTO events SELECT number, toString(number) FROM numbers(10);
    SELECT * FROM events ORDER BY id;
    ```
3. Make sure you get the results with no exceptions.

## 4. Run TPC-DS benchmark
Follow [this guide](https://github.com/ByConity/byconity-tpcds/blob/main/README.md) to run the TPC-DS benchmark on ByConity. Collect the results. 

## 5. Add more workers and rerun
Deploy 2+ new read workers. You only need to init and launch the new workers. They can be automatically discovered by the resource manager. There is no need to restart the shared services like server, dm, etc. After finishing, rerun the TPC-DS benchmark, and then collect the results.

