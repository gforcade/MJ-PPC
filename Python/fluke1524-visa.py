import serial
import io

ser = serial.Serial('COM1',timeout=0.15)
sio = io.TextIOWrapper(io.BufferedRWPair(ser, ser), newline='\n')

sio.write(unicode('*IDN?\n'))
sio.flush()
print ser.readline()
i=0
while i < 10:
    i+=1
    sio.write(unicode('READ? 1\n'))
    sio.flush()
    a = float(sio.readline())
    sio.write(unicode('READ? 2\n'))
    sio.flush()
    b = float(sio.readline())
    print i, b-a
ser.close()
