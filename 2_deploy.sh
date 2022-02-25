#Must be executed on SSH Frontend on IoT-Lab, otherwise serial_aggregator won't work!

#Uppercase variables correspond to the benchmark constants from 1_compile.sh.
#If set, then only firmwares with configurations that match the set variables will be deployed.
#Otherwise all possible configurations will be deployed.
#E.g. with BOARD_SINGLE="iotlab-m3" and ROUNDS=(1000), the script will only look for firmwares matching the pattern "iotlab-m3_1000_*_*_*_*.elf"
#Variables are purposefully kept separate in both scripts to enable parallel execution with different configurations
BOARDS_ALL=("iotlab-m3", "iotlab-a8-m3", "arduino-zero", "dwm1001", "firefly", "frdm-kw41z", "microbit", "nrf51dk", "nrf52832-mdk", "nrf52840-mdk", "nrf52840dk", "nrf52dk", "nucleo-f070rb", "nucleo-wl55jc", "samd21-xpro", "samr21-xpro", "samr30-xpro", "samr34-xpro", "zigduino")
BOARD_SINGLE="iotlab-m3"                # for testing purposes replace with BOARDS_ALL
ROUNDS=(1000)
MESSAGE_LENGTHS=(128 256 512 1024)      # in bytes
AUTH_DATA_LENGTHS=(16 32 64 128)        # in bytes
KEY_SIZES=(16 24 32)                    # in bytes
BENCHMODES=(0 1 2 3 4)                  # 0 = ECB, 1 = CBC, 2 = CTR, 3 = OCB, 4 = CCM

#Lowercase variables are exclusive for this script
archi="m3:at86rf231"                    # for testing purposes use m3:at86rf231
site="grenoble"                         # [grenoble, lille, lyon, paris, saclay, strasbourg], must match the site you are executing this script on
path="elfs"                             # path to firmwares
output="experiments"                    # csv output path
expdate=$(date +"%m_%d_%Y_%H_%M_%S")    # custom date format
duration=1                              # experiment duration in mins

nodes=""

#because IoTLab doesn't have enough capacity for few experiments with a large number of nodes, we have to deploy more experiments with fewer nodes
#these for-loops will only deploy 1 experiment with 1 node at a time. In order to deploy more nodes with different configurations in the same experiment, comment one or more loops
for BOARD in ${BOARDS_ALL[@]}; do
    #experiment results will be grouped according to node architecture
    echo "Timestamp;Node;Print;Round;Encryption time;Decryption time;ROUNDS;MESSAGE_LENGTH;AUTH_DATA_LENGTH;KEY_SIZE;BENCHMODE" > "$output"/"$BOARD"_"$site"_"$expdate".csv
    for ROUND in ${ROUNDS[@]}; do
        for MESSAGE_LENGTH in ${MESSAGE_LENGTHS[@]}; do
            for AUTH_DATA_LENGTH in ${AUTH_DATA_LENGTHS[@]}; do
                for KEY_SIZE in ${KEY_SIZES[@]}; do
                    for BENCHMODE in ${BENCHMODES[@]}; do
                        #concatenate node configurations into a large string
                        firmware=${BOARD:-*}_${ROUND:-*}_${MESSAGE_LENGTH:-*}_${AUTH_DATA_LENGTH:-*}_${KEY_SIZE:-*}_${BENCHMODE:-*}
                        for f in $(find $path -iname "$firmware".elf); do
                            nodes=${nodes}"-l 1,archi=$archi+site=$site,firmware=$f "
                        done
                        echo $nodes;
                        #store experiment id after successful creation into variable
                        id=$(eval "iotlab experiment submit -d $duration " $nodes | grep -P '\d{6}' -o)
                        echo $id
                        #serial_aggregator only works on running experiments
                        iotlab-experiment wait -i $id
                        echo "$id is Running"
                        #just making sure
                        sleep 2
                        #usually the nodes start directly after the experiment is running. But serial_aggregator can't keep up so we have to reset them manually
                        #so far, the parameters --stop and --start only work with iotlab-m3. With arduino-zero and samr21 use --reset instead.
                        iotlab-node -i $id --stop
                        #aggregate node output into a file
                        #see also https://iot-lab.github.io/docs/tools/serial-aggregator/
                        serial_aggregator -i $id >> "$output"/"$BOARD"_"$site"_"$expdate".csv
                        iotlab-node -i $id --start
                        #clear conacatenated string after each loop
                        nodes=
                    done
                done
            done
        done
    done
done
