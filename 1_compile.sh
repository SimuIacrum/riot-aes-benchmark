# for BOARD in iotlab-a8-m3 iotlab-m3 arduino-zero dwm1001 firefly frdm-kw41z microbit nrf51dk nrf52832-mdk nrf52840-mdk nrf52840dk nrf52dk nucleo-f070rb nucleo-wl55jc samd21-xpro samr21-xpro samr30-xpro samr34-xpro zigduino; do
for BOARD in iotlab-m3; do  #for testing purposes
    for ROUNDS in 1000; do
        for MESSAGE_LENGTH in 128 256 512 1024; do
            for AUTH_DATA_LENGTH in 16 32 64 128; do
                for KEY_SIZE in 16 24 32; do
                    for BENCHMODE in 0 1 2 3 4; do
                        CFLAGS="-DROUNDS=$ROUNDS -DMESSAGE_LENGTH=$MESSAGE_LENGTH -DAUTH_DATA_LENGTH=$AUTH_DATA_LENGTH -DKEY_SIZE=$KEY_SIZE -DBENCHMODE=$BENCHMODE" APPLICATION="$BOARD"_"$ROUNDS"_"$MESSAGE_LENGTH"_"$AUTH_DATA_LENGTH"_"$KEY_SIZE"_"$BENCHMODE" BOARD=$BOARD make
                    done
                done
            done
        done
    done
done