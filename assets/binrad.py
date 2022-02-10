from math import *
import struct

sin_lut = []

scale = 0x400

for i in range(128):
    da = i * 90 / 64

    a = radians(da)

    s = round(sin(a) * scale)
    print(s)

    s_lsb, s_msb = struct.pack('<H', s)

    sin_lut.append(s_lsb)
    sin_lut.append(s_msb)

with open('binrad_sines.bin', 'wb') as out_file:
    out_file.write(bytearray(sin_lut))
