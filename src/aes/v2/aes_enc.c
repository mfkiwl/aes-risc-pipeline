
/*!
@addtogroup crypto_block_aes_zscrypto_v2 AES ZSCrypto V2
@ingroup crypto_block_aes
@{
*/

#include "aes.h"
#include "intrinsics.h"

//! AES Round constants
static const uint8_t round_const[11] = {
  0x8d, 0x01, 0x02, 0x04, 0x08, 0x10, 0x20, 0x40, 0x80, 0x1b, 0x36 
};

/*!
*/
void    aes_enc_key_schedule (
    uint32_t    rk [16],
    uint8_t     ck [16],
    const int   Nk , //!< Number of words in the key.
    const int   Nr   //!< Number of rounds.
){
    const int        Nb =  4;

    for(int i = 0; i < Nb; i ++) {
        
        U8_TO_U32_LE(rk[i], ck,  4*i);

    }
    
    for(int i = 4; i < Nk*(Nr+1); i += 1) {

        uint32_t temp = rk[i-1];

        if( i % Nk == 0 ) {

            temp  = ROTR32(temp, 8);
            temp  = _saes_v2_sub_enc(temp,temp);
            temp ^= round_const[i/Nk];

        } else if ( (Nk > 6) && (i % Nk == 4)) {
            
            temp  = _saes_v2_sub_enc(temp,temp);

        }

        rk[i] = rk[i-Nk] ^ temp;
    }
}


void    aes_192_enc_key_schedule (
    uint32_t    rk [AES_128_RK_WORDS],
    uint8_t     ck [AES_128_CK_BYTES] 
){
    aes_enc_key_schedule(rk, ck, AES_192_NK, AES_192_NR);
}

void    aes_256_enc_key_schedule (
    uint32_t    rk [AES_128_RK_WORDS],
    uint8_t     ck [AES_128_CK_BYTES] 
){
    aes_enc_key_schedule(rk, ck, AES_256_NK, AES_256_NR);
}

void    aes_128_enc_block(
    uint8_t     ct [              16],
    uint8_t     pt [              16],
    uint32_t    rk [AES_128_RK_WORDS] 
){
    aes_enc_block (ct, pt, rk, AES_128_NR);
}

void    aes_192_enc_block(
    uint8_t     ct [              16],
    uint8_t     pt [              16],
    uint32_t    rk [AES_192_RK_WORDS] 
){
    aes_enc_block (ct, pt, rk, AES_192_NR);
}

void    aes_256_enc_block(
    uint8_t     ct [              16],
    uint8_t     pt [              16],
    uint32_t    rk [AES_256_RK_WORDS] 
){
    aes_enc_block (ct, pt, rk, AES_256_NR);
}

//!@}
