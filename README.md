# byconity-tpcds


## Run TPC-DS

### Install required packages
make sure you have following packages install in your syste: gcc, make, flex, bison, byacc, git, time
```
sudo apt-get install gcc make flex bison byacc git time
```

### Install ByConity client
You can install the package from [this page](https://github.com/ByConity/ByConity/releases). After installation you have to move the `clickhouse` binary to `bin` folder in this project.

### Setup paramters
```
cp config.sh.tpl config.sh
```
Edit config.sh to set up paramaters. Please refer to the comments in the file.

### Grant access to all scripts
```
chmod a+x *.sh
```

### Build tpcds tools
Run the command to build TPD-DS tools, the tool will be generated to `build` folder
```
./build.sh
```

### Generate data
Run the command to generated TPD-DS data files. In the command, $1 is the data size, $2 is parallel. The data file will be generated into `data_tpcds_{data_size}` folder
```
./gen_data.sh 100 16
```

### Populate data to ByConity
Run the command to populate the TPD-DS data from the data files to ByConity. $1 is the data size.
```
./populate_data.sh 100
```

### Run the benchmark
Run TPD-DS benchmark on ByConity. $1 is the data size.
```
./benchmark.sh 100
```

### Check the results
In the logs folder, check the result.csv for the result of TPC-DS, the format is ['Query ID', 'Time in ms', 'Status' (0 is normal)]
Check trace.log for the detail of queries running in the benchmark.
