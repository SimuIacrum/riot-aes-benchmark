#include <stdio.h>
#include "od.h"
#include "crypto/aes.h"
#include "aes-ecb.h"

void executeAesEcb(int numberOfRounds, int keySize, size_t messageLength) {
    for(int round = 1; round <= numberOfRounds; round++){
        uint8_t* input = malloc(messageLength);
        random_bytes(input, messageLength);
        uint8_t* decryptBuffer = malloc(messageLength);
        cipher_t cipher;
        int requiredBlocks = messageLength / AES_BLOCK_SIZE;
        if(messageLength % AES_BLOCK_SIZE) {
            requiredBlocks++;
        }
        uint8_t* output = calloc(requiredBlocks, AES_BLOCK_SIZE);
        uint8_t* key = malloc(keySize);
        random_bytes(key, keySize);
        cipher_init(&cipher, CIPHER_AES, key, keySize);
        uint32_t _benchmark_time_encryption = xtimer_now_usec();
        cipher_encrypt(&cipher, input, output);
        _benchmark_time_encryption = (xtimer_now_usec() - _benchmark_time_encryption);
        /*printf("Plaintext: \t");
        od_hex_dump(input, AES_BLOCK_SIZE, 0);
        printf("Ciphertext: \t");
        od_hex_dump(output, AES_BLOCK_SIZE, 0);
        printf("Decrypted text: \t");*/
        uint32_t _benchmark_time_decryption = xtimer_now_usec();
        cipher_decrypt(&cipher, output, decryptBuffer);
        _benchmark_time_decryption = (xtimer_now_usec() - _benchmark_time_decryption);
        //od_hex_dump(input, AES_BLOCK_SIZE, 0);
        uint32_t benchmarkResults[2];
        benchmarkResults[0] = _benchmark_time_encryption;
        benchmarkResults[1] = _benchmark_time_decryption;
        printf(";%d;%u;%u\n", round, benchmarkResults[0], benchmarkResults[1]);
        free(input);
        free(output);
        free(key);
    }
}
