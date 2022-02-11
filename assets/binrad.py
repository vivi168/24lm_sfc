from math import *
import struct

sin_lut = []

m7_sin_lut = []
lam_lut = [255, 243, 232, 221, 212, 203, 196, 188, 181, 175, 169, 164, 159, 154, 149, 145, 141, 137, 133, 130, 127, 124, 121, 118, 115, 113, 110, 108, 105, 103, 101, 99, 97, 95, 94, 92, 90, 89, 87, 86, 84, 83, 82, 80, 79, 78, 77, 75, 74, 73, 72, 71, 70, 69, 68, 67, 66, 66, 65, 64, 63, 62, 62, 61, 60, 59, 59, 58, 57, 57, 56, 55, 55, 54, 54, 53, 53, 52, 52, 51, 50, 50, 49, 49, 49, 48, 48, 47, 47, 46, 46, 45, 45, 45, 44, 44, 44, 43, 43, 42, 42, 42, 41, 41, 41, 40, 40, 40, 39, 39, 39, 39, 38, 38, 38, 37, 37, 37, 37, 36, 36, 36, 36, 35, 35, 35, 35, 34, 34, 34, 34, 33, 33, 33, 33, 33, 32, 32, 32, 32, 32, 31, 31, 31, 31, 31]

scale = 0x400
m7_scale = 0xff

for i in range(128):
    da = i * 90 / 64

    a = radians(da)

    s = round(sin(a) * scale)
    m7_s = round(sin(a) * m7_scale)
    print(s, m7_s)

    s_lsb, s_msb = struct.pack('<H', s)

    sin_lut.append(s_lsb)
    sin_lut.append(s_msb)

    m7_sin_lut.append(m7_s)
    m7_sin_lut.append(0)

with open('binrad_sines.bin', 'wb') as out_file:
    out_file.write(bytearray(sin_lut))

with open('m7_sines.bin', 'wb') as out_file:
    out_file.write(bytearray(m7_sin_lut))

with open('lambda_lut.bin', 'wb') as out_file:
    out_file.write(bytearray(lam_lut))
