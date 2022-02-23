#ifndef AES_OCB_H
#define AES_OCB_H

#include "random.h"
#include <stdio.h>
#include "xtimer.h"
#include "crypto/modes/ocb.h"

void executeAesOcb(int numberOfRounds, int keySize, size_t messageLength, size_t authDataLength);

#endif
