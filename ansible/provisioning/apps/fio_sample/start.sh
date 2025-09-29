#!/usr/bin/env bash
cd "{{ bind_dir_on_container }}"

scriptDir=$(dirname -- "$(readlink -f -- "$BASH_SOURCE")")

TEST_DIR=${scriptDir}/test_dir
OUTPUT_DIR="{{ bind_dir_on_container }}/"

app_log="$OUTPUT_DIR/app_log_fio_`date +%d-%m-%y--%H-%M-%S`"

## Benchmark config
NUMJOBS=1
O_DIRECT=1
BLOCK_SIZE=1M  # for seq
#BLOCK_SIZE=4k # for random

WRITE_SIZE=5G
READ_SIZE=1G

SLEEP_RUNTIME="0,60,1"

base_delay=30
cont_name=`hostname`
cont_number=$(echo $cont_name | grep -Eo '[0-9]+$')
actual_delay=$( echo "$base_delay * $cont_number" | bc -l )

sleep $actual_delay

mkdir -p $TEST_DIR

for i in $SLEEP_RUNTIME
do
    IFS=","
    set -- $i
    SLEEP=$1
    RUNTIME=$2
    READ=$3
    
    sleep $SLEEP

    if [ $READ -gt 0 ]
    then
        NAME=read_throughput
        RW=read
        #RW=randread
        READONLY=
        SIZE=$READ_SIZE
    else
        NAME=write_throughput
        RW=write
        #RW=randwrite
        READONLY=
        SIZE=$WRITE_SIZE
    fi

    fio --name=$NAME --directory=$TEST_DIR --numjobs=$NUMJOBS \
        --size=$SIZE --time_based --runtime=$RUNTIME --ramp_time=2s --ioengine=libaio \
        --direct=$O_DIRECT --bs=$BLOCK_SIZE  --rw=$RW \
        --iodepth=64 --iodepth_batch_submit=64 --iodepth_batch_complete_max=64 \
        --group_reporting=1 >> $app_log
done
