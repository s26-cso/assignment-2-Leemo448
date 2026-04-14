.section .rodata
fmt_int:   .string "%d"
fmt_space: .string " "
fmt_newl:  .string "\n"

.section .text
.globl main

main:
    # prologue herewe save ra and s0-s6
    addi  sp, sp, -64
    sd    ra, 56(sp)
    sd    s0, 48(sp)
    sd    s1, 40(sp)
    sd    s2, 32(sp)
    sd    s3, 24(sp)
    sd    s4, 16(sp)
    sd    s5, 8(sp)
    sd    s6, 0(sp)

    addi  s0, a0, -1          # s0 = n = argc - 1
    mv    s5, a1              # s5 = argv

    # malloc arr (n * 4 bytes)
    slli  a0, s0, 2
    call  malloc
    mv    s1, a0              # s1 = arr

    # malloc result (n * 4 bytes)
    slli  a0, s0, 2
    call  malloc
    mv    s2, a0              # s2 = result

    # malloc stack (n * 4 bytes)
    slli  a0, s0, 2
    call  malloc
    mv    s3, a0              # s3 = stack

    li    s4, -1              # s4 = top = -1 (stack empty)

    # loop 1: parse argv[1..n] into arr using atoi
    li    s6, 0               # s6 = i = 0
parse_loop:
    bge   s6, s0, parse_done   # if i >= n, exit
    addi  t0, s6, 1            # t0 = i + 1
    slli  t0, t0, 3            # t0 = (i+1) * 8 (pointer size)
    add   t0, t0, s5           # t0 = &argv[i+1]
    ld    a0, 0(t0)            # a0 = argv[i+1] (string pointer)
    call  atoi                # a0 = integer value
    slli  t0, s6, 2            # t0 = i * 4 (int size)
    add   t0, t0, s1           # t0 = &arr[i]
    sw    a0, 0(t0)            # arr[i] = atoi result
    addi  s6, s6, 1            # i++
    j     parse_loop
parse_done:

    # loop 2: initialize result array to -1
    li    s6, 0               # i = 0
init_loop:
    bge   s6, s0, init_done    # if i >= n, exit
    slli  t0, s6, 2            # t0 = i * 4
    add   t0, t0, s2           # t0 = &result[i]
    li    t1, -1
    sw    t1, 0(t0)            # result[i] = -1
    addi  s6, s6, 1            # i++
    j     init_loop
init_done:

    # loop 3: next greater element algorithm (iterate right to left)
    mv    s6, s0
    addi  s6, s6, -1           # i = n - 1

outer_loop:
    bltz  s6, outer_done      # if i < 0, exit

    # while loop: pop stack while top element is <= arr[i]
while_loop:
    bltz  s4, while_done      # if top == -1, stack empty, exit while
    slli  t0, s4, 2            # t0 = top * 4
    add   t0, t0, s3           # t0 = &stack[top]
    lw    t0, 0(t0)            # t0 = stack[top] (an index into arr)
    slli  t0, t0, 2            # t0 = stack[top] * 4
    add   t0, t0, s1           # t0 = &arr[stack[top]]
    lw    t0, 0(t0)            # t0 = arr[stack[top]]
    slli  t1, s6, 2            # t1 = i * 4
    add   t1, t1, s1           # t1 = &arr[i]
    lw    t1, 0(t1)            # t1 = arr[i]
    bgt   t0, t1, while_done   # if arr[stack[top]] > arr[i], stop popping
    addi  s4, s4, -1           # top-- (pop)
    j     while_loop

while_done:
    # if stack not empty, record next greater index in result
    bltz  s4, skip_store      # if top == -1, no next greater element
    slli  t0, s4, 2            # t0 = top * 4
    add   t0, t0, s3           # t0 = &stack[top]
    lw    t0, 0(t0)            # t0 = stack[top] (index of next greater)
    slli  t1, s6, 2            # t1 = i * 4
    add   t1, t1, s2           # t1 = &result[i]
    sw    t0, 0(t1)            # result[i] = stack[top]

skip_store:
    # push current index onto stack
    addi  s4, s4, 1            # top++
    slli  t0, s4, 2            # t0 = top * 4
    add   t0, t0, s3           # t0 = &stack[top]
    sw    s6, 0(t0)            # stack[top] = i
    addi  s6, s6, -1           # i--
    j     outer_loop
outer_done:

    # loop 4: print results space-separated
    li    s6, 0               # i = 0
print_loop:
    bge   s6, s0, print_done   # if i >= n, exit
    beqz  s6, skip_space       # no space before first element
    la    a0, fmt_space
    call  printf              # print " "
skip_space:
    slli  t0, s6, 2            # t0 = i * 4
    add   t0, t0, s2           # t0 = &result[i]
    lw    a1, 0(t0)            # a1 = result[i]
    la    a0, fmt_int
    call  printf              # print result[i]
    addi  s6, s6, 1            # i++
    j     print_loop
print_done:
    la    a0, fmt_newl
    call  printf              # print newline

    # epilogue restore ra and s0-s6
    ld    ra, 56(sp)
    ld    s0, 48(sp)
    ld    s1, 40(sp)
    ld    s2, 32(sp)
    ld    s3, 24(sp)
    ld    s4, 16(sp)
    ld    s5, 8(sp)
    ld    s6, 0(sp)
    addi  sp, sp, 64
    ret