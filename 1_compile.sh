#for testing purposes use iotlab-m3 as BOARD
for BOARD in arduino-zero; do 
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