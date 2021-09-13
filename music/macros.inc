.macro SET_DSP_REG register, value
    mov f2,#%register
    mov f3,#%value
.endm
