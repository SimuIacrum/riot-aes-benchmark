#include <stdio.h>
#include "od.h"
#include "crypto/aes.h"
#include "aes-ccm.h"

static const uint8_t mac_len = 8;
static const size_t nonce_and_len_encoding_size = 15;

void executeAesCcm(int numberOfRounds, int keySize, size_t messageLength, size_t authDataLength){
    for(int round = 1; round <= numberOfRounds; round++){
        uint8_t* input = malloc(messageLength);
        uint8_t* auth_data = malloc(authDataLength);
        random_bytes(input, messageLength);
        random_bytes(auth_data, authDataLength);
        uint8_t* decryptBuffer = malloc(messageLength);
        uint8_t* iv = malloc(AES_BLOCK_SIZE);
        random_bytes(iv, AES_BLOCK_SIZE);
        cipher_t cipher;
        int requiredBlocks = messageLength / AES_BLOCK_SIZE;
        if(messageLength % AES_BLOCK_SIZE) {
            requiredBlocks++;
        }
        size_t total = requiredBlocks * AES_BLOCK_SIZE;
        uint8_t* output = calloc(requiredBlocks, AES_BLOCK_SIZE);
        uint8_t* key = malloc(keySize);
        random_bytes(key, keySize);
        cipher_init(&cipher, CIPHER_AES, key, keySize);
        uint32_t _benchmark_time_encryption = xtimer_now_usec();
        cipher_encrypt_ccm(&cipher, auth_data, authDataLength, mac_len, nonce_and_len_encoding_size - sizeof(iv), iv, sizeof(iv), input, total, output);
        _benchmark_time_encryption = (xtimer_now_usec() - _benchmark_time_encryption);
        //printf("Plaintext: \t");
        //od_hex_dump(input, AES_BLOCK_SIZE, 0);
        //printf("Ciphertext: \t");
        //od_hex_dump(output, AES_BLOCK_SIZE, 0);
        //printf("Decrypted text: \t");
        uint32_t _benchmark_time_decryption = xtimer_now_usec();
        cipher_decrypt_ccm(&cipher, auth_data, authDataLength, mac_len, nonce_and_len_encoding_size - sizeof(iv), iv, sizeof(iv), output, total, decryptBuffer);
        _benchmark_time_decryption = (xtimer_now_usec() - _benchmark_time_decryption);
        //od_hex_dump(decryptBuffer, AES_BLOCK_SIZE, 0);
        uint32_t benchmarkResults[2];
        benchmarkResults[0] = _benchmark_time_encryption;
        benchmarkResults[1] = _benchmark_time_decryption;
        printf(";%d;%lu;%lu\n", round, benchmarkResults[0], benchmarkResults[1]);
        free(input);
        free(output);
        free(key);
        free(decryptBuffer);
    }
}
