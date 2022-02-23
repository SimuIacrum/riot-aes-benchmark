#include "algorithms/aes-ecb.h"
#include "algorithms/aes-cbc.h"
#include "algorithms/aes-ctr.h"
#include "algorithms/aes-ocb.h"
#include "algorithms/aes-ccm.h"
#include <stdio.h>
#include <stdint.h>
#include "time.h"
#include "string.h"

int main(void)
{
    printf("Starting Benchmark ...\n");
    switch(BENCHMODE) {
        case 0:
            executeAesEcb(ROUNDS, KEY_SIZE, MESSAGE_LENGTH);
            break;
        case 1:
            executeAesCbc(ROUNDS, KEY_SIZE, MESSAGE_LENGTH);
            break;
        case 2:
            executeAesCtr(ROUNDS, KEY_SIZE, MESSAGE_LENGTH);
            break;
        case 3:
            executeAesOcb(ROUNDS, KEY_SIZE, MESSAGE_LENGTH, AUTH_DATA_LENGTH);
            break;
        case 4:
            executeAesCcm(ROUNDS, KEY_SIZE, MESSAGE_LENGTH, AUTH_DATA_LENGTH);
            break;
    }
    printf("Benchmark done!\n");
    return 0;
}
