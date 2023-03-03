# byconity-tpcds


## Run TPC-DS

### Install required packages
make sure you have following packages install in your syste: gcc, make, flex, bison, byacc, git, time
```
sudo apt-get install gcc make flex bison byacc git time
```

### Install Clickhouse client
```
cd bin && curl https://clickhouse.com/ | sh && cd ..
```

### Setup paramters
```
cp config.sh.tpl config.sh
# edit config.sh to set up paramaters ...
```

### Grant access to scripts
```
chmod a+x *.sh
```

### Build tpcds tools
```
./build.sh
```

### Generate data
$1 is the data size, $2 is parallel
```
./gen_data.sh 100 16
```

### Populate data to ByConity
parameters used in this step: all parameters
```
./populate_data.sh 100
```

### Run the benchmark
parameters used in this step: all parameters
```
./benchmark.sh 100
```

### Check the results
In the logs folder, check the result.csv for the result of TPC-DS, the format is ['Query ID', 'Time in ms', 'Status' (0 is normal)]
check trace.log for the detail of queries running in the benchmark.
