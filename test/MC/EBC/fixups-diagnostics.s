; RUN: not llvm-mc -triple=ebc -filetype=obj %s -o /dev/null 2>&1 | FileCheck %s

; FIXME: Invalid Loc
MOVRELw r1, distant ; CHECK: <unknown>:0: error: fixup must be in range [INT16_MIN, INT16_MAX]
JMP8 unaligned ; CHECK: <unknown>:0: error: fixup must be 2-byte aligned
JMP8 distant ; CHECK: <unknown>:0: error: fixup must be in range [-256, 254]
JMP64 unaligned ; CHECK: <unknown>:0: error: fixup must be 2-byte aligned
CALL64 unaligned ; CHECK: <unknown>:0: error: fixup must be 2-byte aligned

.byte 0
unaligned:
.byte 0

.space 1<<16
distant:
