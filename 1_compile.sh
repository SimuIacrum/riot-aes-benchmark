BOARDS_ALL=("iotlab-m3", "iotlab-a8-m3", "arduino-zero", "dwm1001", "firefly", "frdm-kw41z", "microbit", "nrf51dk", "nrf52832-mdk", "nrf52840-mdk", "nrf52840dk", "nrf52dk", "nucleo-f070rb", "nucleo-wl55jc", "samd21-xpro", "samr21-xpro", "samr30-xpro", "samr34-xpro", "zigduino")
BOARD_SINGLE="iotlab-m3"                #for testing purposes replace with BOARDS_ALL
ROUNDS=(1000)
MESSAGE_LENGTHS=(128 256 512 1024)      #in bytes
AUTH_DATA_LENGTHS=(16 32 64 128)        #in bytes
KEY_SIZES=(16 24 32)                    #in bytes
BENCHMODES=(0 1 2 3 4)                  #0 = ECB, 1 = CBC, 2 = CTR, 3 = OCB, 4 = CCM

for BOARD in ${BOARDS_ALL[@]}; do 
    for ROUND in ${ROUNDS[@]}; do
        for MESSAGE_LENGTH in ${MESSAGE_LENGTHS[@]}; do
            for AUTH_DATA_LENGTH in ${AUTH_DATA_LENGTHS[@]}; do
                for KEY_SIZE in ${KEY_SIZES[@]}; do
                    for BENCHMODE in ${BENCHMODES[@]}; do
                        if [ ! -f "bin"/"$BOARD"/"$BOARD"_"$ROUND"_"$MESSAGE_LENGTH"_"$AUTH_DATA_LENGTH"_"$KEY_SIZE"_"$BENCHMODE".elf ]; then
                            CFLAGS="-DROUNDS=$ROUND -DMESSAGE_LENGTH=$MESSAGE_LENGTH -DAUTH_DATA_LENGTH=$AUTH_DATA_LENGTH -DKEY_SIZE=$KEY_SIZE -DBENCHMODE=$BENCHMODE" APPLICATION="$BOARD"_"$ROUND"_"$MESSAGE_LENGTH"_"$AUTH_DATA_LENGTH"_"$KEY_SIZE"_"$BENCHMODE" BOARD=$BOARD make
                        fi
                    done
                done
            done
        done
    done
done