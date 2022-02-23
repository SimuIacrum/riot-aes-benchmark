#Must be executed on SSH Frontend on IoT-Lab, otherwise serial_aggregator won't work!

#Uppercase variables correspond to the benchmark constants from 1_compile.sh.
#If set, then only firmwares with configurations that match the set variables will be deployed.
#Otherwise all possible configurations will be deployed.
#E.g. with BOARD="iotlab-m3" and ROUNDS=1000, the script will look for firmwares matching the pattern "iotlab-m3_1000_*_*_*_*.elf"
BOARD="iotlab-m3"                       #for testing purposes use iotlab-m3
ROUNDS=1000
MESSAGE_LENGTH=
AUTH_DATA_LENGTH=
KEY_SIZE=
BENCHMODE=

#Lowercase variables are exclusive for this script
archi="m3:at86rf231"                    # for testing purposes use m3:at86rf231
site="grenoble"                         # [grenoble, lille, lyon, paris, saclay, strasbourg], must match the site you are executing this script on
path="elfs"                             # path to firmwares
output="experiments"                    # csv output path
expdate=$(date +"%m_%d_%Y_%H_%M_%S")    # custom date format
duration=1                              # experiment duration in mins

nodes=""
echo "Timestamp;Node;Print;Round;Encryption time;Decryption time;ROUNDS;MESSAGE_LENGTH;AUTH_DATA_LENGTH;KEY_SIZE;BENCHMODE" > "$output"/"$BOARD"_"$site"_"$expdate".csv

#because IoTLab doesn't have enough capacity for few experiments with a large number of nodes, we have to deploy more experiments with fewer nodes
for MESSAGE_LENGTH in 128 256 512 1024; do
    for AUTH_DATA_LENGTH in 16 32 64 128; do
        #concatenate node configurations into a large string
        firmware=${BOARD:-*}_${ROUNDS:-*}_${MESSAGE_LENGTH:-*}_${AUTH_DATA_LENGTH:-*}_${KEY_SIZE:-*}_${BENCHMODE:-*}
        for f in $(find $path -iname "$firmware".elf); do
            nodes=${nodes}"-l 1,archi=$archi+site=$site,firmware=$f "
        done
        echo $nodes;
        #store experiment id after successful creation into variable
        id=$(eval "iotlab experiment submit -d $duration " $nodes | grep -P '\d{6}' -o)
        echo $id
        #serial_aggregator only works on running experiments
        iotlab-experiment wait
        echo "$id is Running"
        #just making sure
        sleep 2
        #usually the nodes start directly after the experiment is running. But serial_aggregator can't keep up so we have to stop them manually
        iotlab-node -i $id -sto
        serial_aggregator -i $id >> "$output"/"$BOARD"_"$site"_"$expdate".csv
        iotlab-node -i $id -sta
        #clear conacatenated string after each loop
        nodes=
    done
done