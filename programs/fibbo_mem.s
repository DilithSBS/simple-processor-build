// fibbo_mem.s
// Calculates the n-th Fibonacci number using a memory stack.
// F(0) = 0, F(1) = 1, F(n) = F(n-1) + F(n-2)
// n is given in R0. The result will be stored in R1.
// Stack Pointer (SP) is stored in R7. Intermediate Fibonacci values are pushed to/popped from memory stack.

// Initialization
loadi 0 0x08    // R0 = 8  (n = 8)                                      pc = 0
loadi 6 0x00    // R6 = 0  (Zero register)                              pc = 4
loadi 5 0x01    // R5 = 1  (Constant 1)                                 pc = 8

// Handle base case: n == 0
mov 1 6         // R1 = 0 (Assume F(n) = 0)                             pc = 12
beq 0x10 0 6    // If R0 == R6 (n == 0), jump to END (offset +16)       pc = 16

// Handle base case: n == 1
mov 1 5         // R1 = 1 (Assume F(n) = 1)                             pc = 20
beq 0x0E 0 5    // If R0 == R5 (n == 1), jump to END (offset +14)       pc = 24

// Initialize Stack & Memory with F(0) and F(1)
loadi 7 0x01    // R7 = 1  (SP = 1, points to top of stack: Mem[0x01])   pc = 28
swi 6 0x00      // Mem[0x00] = 0 (Push F_0 = 0 to stack base)           pc = 32
swd 5 7         // Mem[0x01] = 1 (Push F_1 = 1 to top of stack)         pc = 36

// Set up for loop (n >= 2)
mov 4 5         // R4 = 1 (Loop counter i = 1)                          pc = 40

// Loop Check
beq 0x09 4 0    // If R4 == R0 (i == n), jump to END (offset +9)        pc = 44

// Loop Body (Access memory stack for F_prev1 and F_prev2)
lwd 2 7         // R2 = Mem[SP]     (F_prev1 from top of stack)         pc = 48
sub 7 7 5       // R7 = SP - 1      (Move SP to F_prev2 location)       pc = 52
lwd 3 7         // R3 = Mem[SP]     (F_prev2 from stack)                pc = 56
add 1 2 3       // R1 = R2 + R3     (F_curr = F_prev1 + F_prev2)        pc = 60
add 7 7 5       // R7 = SP + 1      (Restore SP to prev top)            pc = 64
add 7 7 5       // R7 = SP + 1      (Advance SP to new top location)    pc = 68
swd 1 7         // Mem[SP] = R1     (Push F_curr onto stack)            pc = 72
add 4 4 5       // R4 = R4 + R5     (i = i + 1)                         pc = 76

// Loop Back
j 0xF6          // Jump to Loop Check (offset -10)                      pc = 80

// END (Infinite loop to halt the program)
j 0xFF          // Jump to self (offset -1)                             pc = 84


// 8th fibonacci number is 21
// It is in register R1 when pc = 44 (and stored in memory stack Mem[0x08])

// F_0 = 0, F_1 = 1, F_2 = 1, F_3 = 2, F_4 = 3, F_5 = 5, F_6 = 8, F_7 = 13, F_8 = 21
