#ifndef AES_CCM_H
#define AES_CCM_H

#include "random.h"
#include <stdio.h>
#include "xtimer.h"
#include "crypto/modes/ccm.h"

void executeAesCcm(int numberOfRounds, int keySize, size_t messageLength, size_t authDataLength);

#endif
