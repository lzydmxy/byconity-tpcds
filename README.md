# byconity-tpcds

## Run TPC-DS

### Install required packages
Make sure you have following packages install in your system: gcc, make, flex, bison, byacc, git, time
```
sudo apt-get install gcc make flex bison byacc git time
```

### Install ByConity client
Make sure the ByConity client are installed. You can install the package from [this page](https://github.com/ByConity/ByConity/releases), and then find  `clickhouse` binary and move it to `bin` folder in the project. Or you can copy the binary from any existing installations. E.g. an existing ByConity docker container.

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

<br/>

THE SOFTWARE “byconity-tpcds” PROVIDED TO YOU BY TRANSACTION PROCESSING PERFORMANCE COUNCIL ("TPC") WILL BE SUBJECT TO THE TERMS AND CONDITIONS OF THIS [EULA](https://github.com/ByConity/byconity-tpcds/blob/main/tpcds-v2.13.0rc1/EULA.txt)
