loadi 4 0x07    // r4 = 7                       PC = 0
loadi 2 0x09    // r2 = 9                       PC = 4
loadi 5 0x0F    // r5 = 15                      PC = 8

add 6 4 2       // r6 = r4 + r2 = 16            PC = 12

mov 0 6         // r0 = 16                      PC = 16

loadi 1 0x01    // r1 = 1                       PC = 20

add 5 5 1       // r5 = r5 + r1 = 16            PC = 24

beq 0x02 5 6    // if r1 == r5,                 PC = 28

loadi 3 0xEE    // r3 = 238                     PC = 32

bne 0x01 5 6    // if r1 == r5, jump            PC = 36

j 0xFB          // jump FB = -5   times         PC = 40

loadi 7 0xFF    // r7 = 255                     PC = 44