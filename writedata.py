from PIL import Image
import os
import sys
import random

def itoxy(i):
    ipage = i&1023
    x = ipage/8
    y = 7-ipage&7
    y += (i//1024)*8
    if y >= 16:
        y += 2
    x += 2
    return (x,y)

f = open('vid.bin', 'w+b')
random.seed("ksk2020")
frame_multiplier = 4 # 30 -> 120
frame_skip_every = 6 # 120 -> 100
frame_limit = -1
fcnt = 0
scnt = 0
for filename in os.listdir("vidframes"):
    if filename.endswith(".png"):
        sys.stdout.write(filename+"\n")
        fi = Image.open(os.path.join("vidframes", filename)).convert("RGB")
        px = fi.load()
        for fm in range(frame_multiplier):
            scnt = (scnt + 1) % frame_skip_every
            if scnt == 0:
                continue
            byte_arr = [0]*1024
            for i in range(1024):
                byte = 0
                for j in range(8):
                    k = i*8+j
                    pv = px[itoxy(k)][1]
                    pv /= 255
                    pv = (pv * 1.04) - 0.02
                    #pv = 0.5
                    pv = 1 if pv >= random.random() else 0
                    byte += byte + pv
                byte_arr[i] = byte
            binary_format = bytearray(byte_arr)
            f.write(binary_format)
        fcnt += 1
        if fcnt == frame_limit:
            break
f.close()
