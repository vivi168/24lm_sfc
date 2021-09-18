from math import *

sines = []
cosines = []

for i in range(360):
    d = radians(i)
    s = round(sin(d) * 127)
    c = round(cos(d) * 127)

    print(i, (s), (c))

    if s < 0: s = (abs(s) ^ 0xff) + 1
    if c < 0: c = (abs(c) ^ 0xff) + 1

    sines.append(s)
    cosines.append(c)


sin_lut = bytearray(sines)
cos_lut = bytearray(cosines)


with open('sines.bin', 'wb') as out_file:
    out_file.write(sin_lut)
with open('cosines.bin', 'wb') as out_file:
    out_file.write(cos_lut)



