; CPU Registers
.define TEST                    f0     ;SPC700 testing functions
.define CONTROL                 f1     ;Timer, I/O and ROM Control

.define DSPADDR                 f2     ;DSP register address
.define DSPDATA                 f3     ;DSP register data read/write

.define CPUIO0                  f4     ;SNES CPU Communication Port 0
.define CPUIO1                  f5     ;SNES CPU Communication Port 1
.define CPUIO2                  f6     ;SNES CPU Communication Port 2
.define CPUIO3                  f7     ;SNES CPU Communication Port 3

.define T0DIV                   fa     ;Timer 0 divider
.define T1DIV                   fb     ;Timer 1 divider
.define T2DIV                   fc     ;Timer 2 divider
.define T0OUT                   fd     ;Timer 0 output
.define T1OUT                   fe     ;Timer 1 output
.define T2OUT                   ff     ;Timer 2 output

; IPL entry points
.define IPL_INIT                ffc0   ;Clear zero page and wait
.define IPL_WAIT                ffc9   ;Wait for new transfer

; S-DSP Registers
.define MVOLL                   0c     ;Left channel master volume
.define MVOLR                   1c     ;Right channel master volume
.define EVOLL                   2c     ;Left channel echo volume
.define EVOLR                   3c     ;Right channel echo volume
.define KON                     4c     ;Key On Flags for Voice 0..7
.define KOF                     5c     ;Key Off Flags for Voice 0..7
.define FLG                     6c     ;Reset, Mute, Echo-Write Flags + Noise Clock
.define ENDX                    7c     ;Voice End Flags for Voice 0..7
.define EFB                     0d     ;Echo feedback volume
.define PMON                    2d     ;Pitch Modulation Enable Flags for Voice 1..7
.define NON                     3d     ;Noise Enable Flags for Voice 0..7
.define EON                     4d     ;Echo Enable Flags for Voice 0..7
.define DIR                     5d     ;Sample directory offset address
.define ESA                     6d     ;Echo buffer offset address
.define EDL                     7d     ;Echo delay (ring buffer size)
.define FIR0                    0f     ;Echo FIR filter coefficient 0
.define FIR1                    1f     ;Echo FIR filter coefficient 1
.define FIR2                    2f     ;Echo FIR filter coefficient 2
.define FIR3                    3f     ;Echo FIR filter coefficient 3
.define FIR4                    4f     ;Echo FIR filter coefficient 4
.define FIR5                    5f     ;Echo FIR filter coefficient 5
.define FIR6                    6f     ;Echo FIR filter coefficient 6
.define FIR7                    7f     ;Echo FIR filter coefficient 7

; Voice Control (n 0-7)
.define V0VOLL                  00     ;Left volume
.define V0VOLR                  01     ;Right volume
.define V0PITCHL                02     ;Pitch (LSB)
.define V0PITCHH                03     ;Pitch (MSB)
.define V0SRCN                  04     ;Source number
.define V0ADSR1                 05     ;ADSR settings 1
.define V0ADSR2                 06     ;ADSR settings 2
.define V0GAIN                  07     ;Gain settings
.define V0ENVX                  08     ;Current envelope value
.define V0OUTX                  09     ;Current sample value

.define V1VOLL                  10     ;Left volume
.define V1VOLR                  11     ;Right volume
.define V1PITCHL                12     ;Pitch (LSB)
.define V1PITCHH                13     ;Pitch (MSB)
.define V1SRCN                  14     ;Source number
.define V1ADSR1                 15     ;ADSR settings 1
.define V1ADSR2                 16     ;ADSR settings 2
.define V1GAIN                  17     ;Gain settings
.define V1ENVX                  18     ;Current envelope value
.define V1OUTX                  19     ;Current sample value

.define V2VOLL                  20     ;Left volume
.define V2VOLR                  21     ;Right volume
.define V2PITCHL                22     ;Pitch (LSB)
.define V2PITCHH                23     ;Pitch (MSB)
.define V2SRCN                  24     ;Source number
.define V2ADSR1                 25     ;ADSR settings 1
.define V2ADSR2                 26     ;ADSR settings 2
.define V2GAIN                  27     ;Gain settings
.define V2ENVX                  28     ;Current envelope value
.define V2OUTX                  29     ;Current sample value

.define V3VOLL                  30     ;Left volume
.define V3VOLR                  31     ;Right volume
.define V3PITCHL                32     ;Pitch (LSB)
.define V3PITCHH                33     ;Pitch (MSB)
.define V3SRCN                  34     ;Source number
.define V3ADSR1                 35     ;ADSR settings 1
.define V3ADSR2                 36     ;ADSR settings 2
.define V3GAIN                  37     ;Gain settings
.define V3ENVX                  38     ;Current envelope value
.define V3OUTX                  39     ;Current sample value

.define V4VOLL                  40     ;Left volume
.define V4VOLR                  41     ;Right volume
.define V4PITCHL                42     ;Pitch (LSB)
.define V4PITCHH                43     ;Pitch (MSB)
.define V4SRCN                  44     ;Source number
.define V4ADSR1                 45     ;ADSR settings 1
.define V4ADSR2                 46     ;ADSR settings 2
.define V4GAIN                  47     ;Gain settings
.define V4ENVX                  48     ;Current envelope value
.define V4OUTX                  49     ;Current sample value

.define V5VOLL                  50     ;Left volume
.define V5VOLR                  51     ;Right volume
.define V5PITCHL                52     ;Pitch (LSB)
.define V5PITCHH                53     ;Pitch (MSB)
.define V5SRCN                  54     ;Source number
.define V5ADSR1                 55     ;ADSR settings 1
.define V5ADSR2                 56     ;ADSR settings 2
.define V5GAIN                  57     ;Gain settings
.define V5ENVX                  58     ;Current envelope value
.define V5OUTX                  59     ;Current sample value

.define V6VOLL                  60     ;Left volume
.define V6VOLR                  61     ;Right volume
.define V6PITCHL                62     ;Pitch (LSB)
.define V6PITCHH                63     ;Pitch (MSB)
.define V6SRCN                  64     ;Source number
.define V6ADSR1                 65     ;ADSR settings 1
.define V6ADSR2                 66     ;ADSR settings 2
.define V6GAIN                  67     ;Gain settings
.define V6ENVX                  68     ;Current envelope value
.define V6OUTX                  69     ;Current sample value

.define V7VOLL                  70     ;Left volume
.define V7VOLR                  71     ;Right volume
.define V7PITCHL                72     ;Pitch (LSB)
.define V7PITCHH                73     ;Pitch (MSB)
.define V7SRCN                  74     ;Source number
.define V7ADSR1                 75     ;ADSR settings 1
.define V7ADSR2                 76     ;ADSR settings 2
.define V7GAIN                  77     ;Gain settings
.define V7ENVX                  78     ;Current envelope value
.define V7OUTX                  79     ;Current sample value
