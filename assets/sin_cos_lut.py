from math import *
import struct

sines = []
cosines = []

sin_lut = []
cos_lut = []

for i in range(360):
    d = radians(i)
    s = round(sin(d) * 1024)
    c = round(cos(d) * 1024)

    print(i, (s), (c))

    if s < 0: s = (abs(s) ^ 0xffff) + 1
    if c < 0: c = (abs(c) ^ 0xffff) + 1

    sines.append(s)
    cosines.append(c)

    s_lsb, s_msb = struct.pack('<H', s)
    c_lsb, c_msb = struct.pack('<H', c)

    sin_lut.append(s_lsb)
    sin_lut.append(s_msb)

    cos_lut.append(c_lsb)
    cos_lut.append(c_msb)


with open('sines.bin', 'wb') as out_file:
    out_file.write(bytearray(sin_lut))
with open('cosines.bin', 'wb') as out_file:
    out_file.write(bytearray(cos_lut))
