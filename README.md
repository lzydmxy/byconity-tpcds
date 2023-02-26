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

### Generate 100GB data
parameters used in this step: PARALLEL
```
./gen_data.sh 100
```

### Populate data to ByConity
parameters used in this step: all parameters
```
./populate_data.sh 100
```

