# ByConity集群搭建与TPC-DS Benchmark实践

## 1. 准备
1.1. 根据此[指南](https://github.com/ByConity/ByConity/blob/master/docker/executable_wrapper/FDB_installation_zh.md)将Foundation DB安装部署到3台物理机上。   
1.2. 根据此[指南](https://github.com/ByConity/ByConity/blob/master/docker/executable_wrapper/HDFS_installation_zh.md)将 HDFS安装部署到4台以上物理机，具有 1 个name node和 3 个以上data node。  
1.3. 您可以使用2种方式来部署ByConity集群： Docker 或软件包。  

每个组件的资源需求。

| 组件 | CPU | 内存 | 硬盘  | 实例 | 
| :-----| :----- | :----- | :----- | :----- | 
| TSO | 2 | 500M | 5G | 1 |
| Server | 16 | 60G | 100G | >=1 |
| Write Worker | 16 | 60G | 100G | >=3 |
| Read Worker | 16 | 60G | 100G | >=3 |
| DaemonManager | 4 | 10G | 10G | 1 |
| ResourceManager | 8 | 16G | 10G | 1 |
| Client | 8+ | 16G+ | 200G | 1 |

### 1.3.1 方式一：Docker部署

1. 确保系统中安装了docker。可以参考[官方文档](https://docs.docker.com/engine/install/)安装. 
2. 转到 项目中的docker 文件夹。  
3. 配置`config/cnch_config.xml`。设置服务器 ip 地址，将 `{xxx_address}` 替换为实际服务器地址。这包括服务器、tso、deamon manager 和 resource manager。如有需要你可以调整可能导致冲突的端口。然后在`<hdfs_nnproxy>`中设置HDFS namenode的地址。  
4. 将 `config/fdb.cluster` 替换为上面 FDB 设置步骤中生成的 `fdb.cluster` 文件。  
5. 根据上面的资源需求列表和你的实际资源情况调整run.sh中的参数，尤其是要分配给每个组件的 cpu和内存数。如果你在`config/cnch_config.xml`中改了端口，这里在run.sh也要做相应的修改。  
6. 在您需要部署 ByConity 组件的每台主机上，执行以下操作：   
    1）将 docker 文件夹复制到主机。  
    2）拉取docker镜像：  
    ```
    docker pull byconity/byconity-server:stable
    ```
7. 初始化并启动ByConity组件：  
   1）在 1 台主机上启动 TSO: `./run.sh tso`.   
   2）在1台主机上启动 resource manager：`./run.sh rm`.   
   3）在1台主机上启动 deamon manager：`./run.sh dm`.   
   4）启动server，每个server运行在 1 台主机上：`./run.sh server`.    
   5）启动write workers，每个write worker运行在1台主机上：`./run.sh write_worke <worker_id>`. `worker_id` 是可选的，如果不设，会取`<hostname>-write`.   
   6）启动read workers，每个read worker运行在1台主机上：`./run.sh read_worke <worker_id>`. `worker_id` 是可选的，如果不设，会取`<hostname>-read`.   
8. 后面如果要重启 ByConity 组件，可以用以下命令：`./run.sh stop {component_name}`, 以及 `./run.sh` `start` `{component_name}`, `component_name` 与#6中的描述相同


### 1.3.2 **方式二：****软件包****部署**

1. 在[此页面](https://github.com/ByConity/ByConity/releases)上找到 ByConity 安装包。

2. 在您需要部署 ByConity 组件的每台主机上，执行以下操作：  
    1）安装 FoundationDB 客户端包，你可以在[这个页面](https://github.com/apple/foundationdb/releases)上找到。 确保安装与 FoundationDB 服务器相同的版本。 
    ```
    curl -L -o foundationdb-clients_7.1.25-1_amd64.deb https://github.com/apple/foundationdb/releases/download/7.1.25/foundationdb-clients_7.1.25-1_amd64.deb
    sudo dpkg -i foundationdb-clients_7.1.25-1_amd64.deb
    ``` 
    2）安装ByConity通用包 `byconity-common-static`。 
    ```
    sudo dpkg -i byconity-common-static_0.1.1.1_amd64.deb
    ```
    3）在 `/etc/byconity-server/cnch_config.xml`中设置服务器地址，方法与#1.3.1 中描述的相同。 可以参考本项目中 `docker/config/cncn_config.xml` 对应的部分 。  
    4）将 `/etc/byconity-server/fdb.config` 中的内容替换为为在#1.1中的 FDB 设置步骤中生成的`fdb.cluster` 文件内容。  

3. 初始化并启动 ByConity 组件：  
    1）选择1台主机运行TSO，下载byconity-tso包并安装。
    ```
    sudo dpkg -i byconity-tso_0.1.1.1_amd64.deb
    ```
    如果这是第一次安装该软件包，它不会立即启动，你必须手动启动服务。
    ```
    systemctl start byconity-tso
    ```
    2）选择1台主机运行resource manager，下载 `byconity-resource-manager` 包并安装。
    ```
    sudo dpkg -i byconity-resource-manager_0.1.1.1_amd64.deb 
    systemctl start byconity-resource-manager
    ```
    3）选择1台主机运行deamon manager，下载 `byconity-daemon-manager` 包并安装。
    ```
    sudo dpkg -i byconity-daemon-manager_0.1.1.1_amd64.deb 
    systemctl start byconity-daemon-manager
    ```
    4）选择1台主机运行server，下载 `byconity-server` 包并安装。
    ```
    sudo dpkg -i byconity-server_0.1.1.1_amd64.deb 
    systemctl start byconity-server
    ```
    5）选择3台以上主机运行read worker，下载`byconity-worker` 包并安装。由于启用了resource manager作worker的发现，这里需要设置相关的环境变量，注意`WORKER_ID`必须是唯一的。
    ```
    sudo dpkg -i byconity-worker_0.1.1.1_amd64.deb 
    systemctl start byconity-worker
    ```
    6）选择3台以上主机运行write worker，下载 `byconity-write-worker` 包并安装。由于启用了resource manager作worker的发现，这里需要设置相关的环境变量，注意`WORKER_ID`必须是唯一的。
    ```
    sudo dpkg -i byconity-worker-write_0.1.1.1_amd64.deb 
    systemctl start byconity-worker-write
    ```

### 共享物理机
如果你的机器资源有限，可以共享物理主机进行本次实践。
1. 可以在同一台主机上安装HDFS name node、TSO、deamon manager和1个ByConity Server。
2. 1个read/write worker可以和1个HDFS数据节点，1个FDB节点共享主机。如果你采用的是docker部署方式，1个read worker也可以和1个write worker共享主机，但如果是软件包部署模式则不可以共享。


## 2. **设置客户端**

1.  找到一台客户端的机器来运行 TPC-DS 。git clone byconity-tpcds 项目。
2.  需要将`clickhouse` 执行文件拷贝或者链接到本项目中的`bin` 文件夹中
    如果你是通过docker运行ByConity组件的，你可以从任何现有ByConity docker容器中复制执行文件，比如
    ```
    mkdir bin
    docker cp byconity-server:/root/app/usr/bin/clickhouse bin/
    ````
    如果你通过安装包安装了ByConity通用包，你可以把`/usr/bin/clickhouse`拷贝或者链接到bin文件夹。
3. 确保 FoundationDB 客户端安装在客户端机器上，如#1.2 中所述


## 3. 验证部署

1. 连接到ByConity server
    ```
    bin/clickhouse client --host=<your_server_host> --port=<your_server_tcp_port>  --enable_optimizer=1 --dialect_type='ANSI'
    ```
2. 运行一些基本的SQL
    ```
    CREATE DATABASE test;
    USE test;
    CREATE TABLE events (`id` UInt64, `s` String) ENGINE = CnchMergeTree ORDER BY id;
    INSERT INTO events SELECT number, toString(number) FROM numbers(10);
    SELECT * FROM events ORDER BY id;
    ```
3. 确保运行结果是正常的


## 4. 运行TPC-DS基准测试

在 ByConity 上运行 TPC-DS 基准测试并收集结果。

#### 4.1 所需安装包

确保您的系统中安装了以下软件包：gcc、make、flex、bison、byacc、git、time
```
sudo apt-get install gcc make flex bison byacc git time
```

#### 4.2 设置参数
```
cp config.sh.tpl config.sh
```

编辑 config.sh 以设置参数，请参考文件中的注释。

#### 4.3 授予对所有脚本的访问权限
```
chmod a+x *.sh
```

#### 4.4 构建 tpcds 工具
运行命令构建TPD-DS工具，工具会生成 `build` 文件夹
```
./build.sh
```

#### 4.5 生成数据
运行命令以生成 TPD-DS 数据文件。 在命令中，$1为数据大小。数据的生成会并行，依据config.sh中配置的PARALLEL。数据文件将生成到 `data_tpcds_{data_size}` 文件夹中。数据生成需要一些时间，期间工具没有信息输出，如果需要查看数据生成的进度，你可以观察`data_tpcds_{data_size}` 文件夹中的文件生成。
```
./gen_data.sh 100
```

#### 4.6 将数据写入到 ByConity
运行命令以将 TPD-DS 数据从数据文件写入到 ByConity。 $1 是数据大小(GB)。
```
./populate_data.sh 100
```

#### 4.7 运行基准测试
在 ByConity 上运行 TPD-DS 基准测试。 $1 是数据大小(GB)。
```
./benchmark.sh 100
```

#### 4.8 检查和收集结果
在logs文件夹中，查看TPC-DS的运行结果，其中：  
1）result.csv，运行结果，格式为['Query ID', 'Time in ms', 'Status' (0 为正常)]   
2）trace.log，详细的基准测试中运行的查询。  
3) output.log，运行过程的日志输出。  


## 5. 添加更多workers并重新运行
新部署 2 个以上的read worker，只需正确启动worker即可，无需重启server等共享服务，新的worker会被resource manager发现。 部署好以后重新运行 TPC-DS 基准测试，并收集结果（如4.8中所述）。
