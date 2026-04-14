.globl make_node
.globl insert
.globl get
.globl getAtMost


make_node:
    addi  sp, sp, -32
    sd    ra, 24(sp)
    sd    s0, 16(sp)
    sd    s1,  8(sp)
    mv    s1, a0         # s1 = val
    li    a0, 24
    call  malloc
    mv    s0, a0         # s0 = pointer
    sw    s1,  0(s0)     # node->val = val  using sw cuz int
    sd    zero, 8(s0)    # node->left = NULL
    sd    zero,16(s0)    # node->right = NULL
    mv    a0, s0         # return pointer
    ld    ra, 24(sp)
    ld    s0, 16(sp)
    ld    s1,  8(sp)
    addi  sp, sp, 32
    ret



get:                        # a0 = root, a1 = val
    beqz  a0, get_done      # if root == NULL, return NULL (a0 already 0)
    lw    t0, 0(a0)         # t0 = root->val
    beq   a1, t0, get_done  # if val == root->val, return root (a0)
    blt   a1, t0, get_left  # if val < root->val, go left
    ld    a0, 16(a0)        # root = root->right
    j     get
get_left:
    ld    a0, 8(a0)         # root = root->left
    j     get
get_done:
    ret

insert:                     # a0 = root, a1 = val
    addi  sp, sp, -32
    sd    ra, 24(sp)
    sd    s0, 16(sp)
    sd    s1,  8(sp)
    mv    s0, a0            # s0 = root
    mv    s1, a1            # s1 = val

    beqz  s0, ins_null      # if root == NULL  make new node

    lw    t0, 0(s0)         # t0 = root->val
    beq   s1, t0, ins_done  # duplicate so return root (a0 = s0 set below)

    blt   s1, t0, ins_left  # if val < root->val, go left

ins_right:
    ld    a0, 16(s0)        # a0 = root->right
    mv    a1, s1            # a1 = val
    call  insert
    sd    a0, 16(s0)        # root->right = result
    mv    a0, s0            # return root
    j     ins_done

ins_left:
    ld    a0, 8(s0)         # a0 = root->left
    mv    a1, s1            # a1 = val
    call  insert
    sd    a0, 8(s0)         # root->left = result
    mv    a0, s0            # return root
    j     ins_done

ins_null:
    mv    a0, s1            # a0 = val
    call  make_node         # a0 = new node pointer
    j     ins_done

ins_done:
    ld    ra, 24(sp)
    ld    s0, 16(sp)
    ld    s1,  8(sp)
    addi  sp, sp, 32
    ret


getAtMost:                  # a0 = val, a1 = root
    li    t0, -1             # t0 = best candidate so far = -1

gam_loop:
    beqz  a1, gam_exit       # if root == NULL, return best found
    lw    t1, 0(a1)          # t1 = root->val
    beq   t1, a0, gam_exact   # exact match
    blt   a0, t1, gam_left    # val < root->val, go left
    mv    t0, t1             # root->val < val: new best candidate
    ld    a1, 16(a1)         # go right
    j     gam_loop

gam_left:
    ld    a1, 8(a1)          # go left
    j     gam_loop

gam_exact:
    mv    a0, t1             # return exact value
    ret

gam_exit:
    mv    a0, t0             # return best candidate (-1 if none)
    ret