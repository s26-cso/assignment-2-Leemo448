.section .rodata
filename: .string "input.txt"
mode:     .string "r"
yes_str:  .string "Yes\n"
no_str:   .string "No\n"

.section .text
.globl main

main:
    # open stack frame, save registers we'll use
    addi  sp, sp, -48
    sd    ra, 40(sp)
    sd    s0, 32(sp)
    sd    s1, 24(sp)
    sd    s2, 16(sp)
    sd    s3,  8(sp)
    # 0(sp) unused padding for 16-byte alignment

    # open the file
    la    a0, filename
    la    a1, mode
    call  fopen
    mv    s0, a0              # s0 = FILE*

    # get file size by seeking to end
    mv    a0, s0
    li    a1, 0
    li    a2, 2               # SEEK_END = 2
    call  fseek
    mv    a0, s0
    call  ftell              # a0 = file size
    addi  s2, a0, -1           # s2 = right = size - 1

    # left pointer starts at beginning
    li    s1, 0               # s1 = left

loop:
    # if pointers have crossed, it's a palindrome
    bge   s1, s2, print_yes

    # seek to left and read one character
    mv    a0, s0
    mv    a1, s1
    li    a2, 0               # SEEK_SET = 0
    call  fseek
    mv    a0, s0
    call  fgetc
    mv    s3, a0              # s3 = left char (callee saved, survives next call)

    # seek to right and read one character
    mv    a0, s0
    mv    a1, s2
    li    a2, 0               # SEEK_SET = 0
    call  fseek
    mv    a0, s0
    call  fgetc              # a0 = right char

    # if they don't match, not a palindrome
    bne   s3, a0, print_no

    # move pointers toward each other
    addi  s1, s1, 1            # left++
    addi  s2, s2, -1           # right--
    j     loop

print_yes:
    la    a0, yes_str
    call  printf
    j     done

print_no:
    la    a0, no_str
    call  printf

done:
    # close the file
    mv    a0, s0
    call  fclose

    # restore registers and return
    ld    ra, 40(sp)
    ld    s0, 32(sp)
    ld    s1, 24(sp)
    ld    s2, 16(sp)
    ld    s3,  8(sp)
    addi  sp, sp, 48
    li    a0, 0
    ret