from bbio import *

def intToByteArray(int_, length=1):
    if length == 3:
        return [((int_ >> 16) & 0xff), ((int_ >> 8) & 0xff), (int_ & 0xff)]
    elif length == 2:
        return [((int_ >> 8) & 0xff), (int_ & 0xff)]
    elif length == 1:
        return [(int_ & 0xff)]

def byteArrayToInt(byte_array):
    int_ = 0
    for i in range(len(byte_array)):
        int_ |= byte_array[i] << (8 * i)
    return int_

class L6470():

    busy_pin = GPIO1_17 # P9.23
    reset_pin = GPIO3_21 # P9.25

    """
      Motor Pins:
        Red:2A
        Blue:1A
        Green:1B
        Black:2B
    """

    REG_FSspeed = 0b00010101 #0x15
    REG_StepMode = 0b00010110 #0x16
    REG_Config = 0b00011000 #0x18
    REG_Acc = 0b00000101 #0x05
    REG_Dec = 0b00000110 #0x06
    REG_Max_Speed = 0b00000111 #0x07
    REG_Min_Speed = 0b00001000 #0x08

    CMD_SetParam = 0b00000000 #0x00
    CMD_Move = 0b01000000 #0x40
    CMD_GetParam = 0b00100000 #0x20
    CMD_ResetDevice = 0b11000000 #0xc0
    CMD_GetStatus = 0b11010000 #0xd0

    def __init__(self, spi = SPI1, cs=0):

        self._spi = spi
        self._cs = cs
        self._busy = busy_pin
        self._reset = reset_pin

        pinMode(self._busy, OUTPUT)
        pinMode(self._reset, INPUT)

        digitalWrite(self._reset, HIGH)
        delay(1)
        digitalWrite(self._reset, LOW)
        delay(1)
        digitalWrite(self._reset, HIGH)
        delay(1)

        self._spi.begin()
        self._spi.setClockMode(self._cs, 3) #Mode - 3
        self._spi.setMaxFrequency(self._cs, 2000000) #2MHz
        self._spi.setBitsPerWord(self._cs, 8)  #8 bits per word
        self._io(self.CMD_RESET_DEVICE)
        self._io(self.CMD_SET_PARAM | self.REG_STEP_MODE)
        self._io(0b01110111) #SYNC_EN, SYN_SEL(3), 0, STEP_SEL(3)
        #Use Busy/Sync pin as Busy, 1/128 microstepping (3), 0, SYNC frequency set to f_{FS}
        self._io(self.CMD_SET_PARAM | self.REG_FS_SPEED)
        self._io(0x03ff, length=2) #Do not switch to full steps.


        def _io(self, data_out):

            return byteArrayToInt(self._spi.transfer(self.cs, intToByteArray(data_out, length)))

        def getConfig(self):

            self._io(self.CMD_GetParam | self.REG_Config)
            self_io(0, length=2)

        def getStatus(self):

            self._io(self.CMD_GetStatus)
            return self._io(0, length=2)

        def move(self, angle):

            n_steps = self._angleToSteps(angle)
            if (n_steps > 0):
                direction = 1
            else:
                direction = 0
                n_steps = 0 - n_steps
            self._io(self.CMD_Move | direction);
            self._io(n_steps, length=3)

        def getAcc(self):

            self._io(self.CMD_GetParam | self.REG_Acc)
            return self._io(0, length=2)

        def setAcc(self, degreePerSec2):
            acc = self.accCalc(self.angleToSteps(degreePerSec2))
            self._io(self.CMD_SetParam | self.REG_Acc)
            self._io(acc, length=2)

        def getDec():

            self._io(self.CMD_GetParam | self.REG_Dec)
            return self._io(0, length=2)

        def setDec(self, degreePerSec2):

            dec = self.decCalc(self.angleToSteps(degreePerSec2))
            self._io(self.CMD_SetParam | self.REG_Dec)
            self._io(dec, length=2)

        def getMaxSpeed():
            self._io(self.CMD_GetParam | self.REG_Max_Speed)
            return self._io(0, length=2)


        def setMaxSpeed(self, degreePerSec):
            max_speed = self.maxSpdCalc(self.angleToSteps(degreePerSec))
            self._io(self.CMD_SetParam | self.REG_Max_Speed)
            return self._io(max_speed, length=2)

        def getMinSpeed():
            self._io(self.CMD_GetParam | self.REG_Min_Speed)
            return self._io(0, length=2)

        def setMinSpeed(self, degreePerSec):
            min_speed = self.minSpdCalc(angleToSteps(degreePerSec)))
            self._io(self.CMD_SetParam | self.REG_Min_Speed)
            self._io(min_speed, length=2)

        def accCalc(self, stepsPerSecPerSec):
            temp = stepsPerSecPerSec * 0.137438
            return temp

        def decCalc(self, stepsPerSecPerSec):
            temp = stepsPerSecPerSec * 0.137438
            return temp

        def maxSpdCalc(self, stepsPerSec):
            temp = stepsPerSec * .065536
            return temp

        def minSpdCalc(self, stepsPerSec):
            temp = stepsPerSec * 4.1943
            return temp

        def isBusy(self):
            temp = digitalRead(BUSYpin)
            return (not temp)

        def angleToSteps(self, angle):
            return (angle*71)

        def spdCalc(self, stepsPerSec):
            temp = stepsPerSec * .065536
            return temp
