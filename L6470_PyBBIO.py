from bbio import *

class L6470():

    #case-sensitive declaration for mode 3
    cs_pin = spi1_cs0 #P9_28
    sdo_pin = spi1_d0 #P9_29
    sdi_pin = spi1_d1 #P9_30
    clk_pin = spi1_sclk #P9_31
    busy_pin = GPIO1_17 # P9.23
    reset_pin = GPIO3_21 # P9.25

    """
      Mot| Pins:
        Red:2A
        Blue:1A
        Green:1B
        Black:1A
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
        self.cs = cs
        self._cs = cs_pin
        self._clk = clk_pin
        self._sdo = sdo_pin
        self._sdi = sdi_pin
        self._busy = busy_pin
        self._reset = reset_pin

        for i in (self._cs, self._sdi, self._clk, self._busy, self._reset): pinMode(i, OUTPUT)

        digitalWrite(self.cs, HIGH)
        pinMode(self.sdo, INPUT)

        digitalWrite(self._reset, HIGH)
        delay(1)
        digitalWrite(self._reset, LOW)
        delay(1)
        digitalWrite(self._reset, HIGH)
        delay(1)

        self._spi.begin()
        self._spi.setClockMode(self.cs, 3) #Mode - 3
        self._spi.setMaxFrequency(self.cs, 2000000) #2MHz
        self._spi.setBitsPerWord(self.cs, 8)  #8 bits per word
        self._io([self.CMD_RESET_DEVICE])
        self._io([self.CMD_SET_PARAM | self.REG_STEP_MODE])
        self._io([0b01110111]) #SYNC_EN, SYN_SEL(3), 0, STEP_SEL(3)
        #Use Busy/Sync pin as Busy, 1/128 microstepping (3), 0, SYNC frequency set to f_{FS}
        self._io([self.CMD_SET_PARAM | self.REG_FS_SPEED])
        self._io([0x03,0xff]) #Do not switch to full steps.

        self.G_c = self._getConfig()
        self.G_s = self._getStatus()

        self._setAcc(degreePerSec2)
        self._setDec(degreePerSec2)
        self._setMaxSpeed(degreePerSec)
        self._setMinSpeed(degreePerSec)

        self.i_B = isBusy()

        self._io(data_out)
        self.D_c = self._decCalc(stepsPerSecPerSec)
        self.A_c = self._accCalc(stepsPerSecPerSec)
        self.MaxS_c = self._maxSpdCalc(stepsPerSec)
        self.MinS_c = self._minSpdCalc(stepsPerSec)
        self.steps = self._angleToSteps(angle)
        self.G_a = self._getAcc()
        self.G_d = self._getDec()
        self.GMax_s = self._getMaxSpeed()
        self.GMin_s = self._getMinSpeed()

        def _io(self, data_out):

            digitalWrite(self._cs, LOW)
            #data_in = shiftOut(self._sdo, self._clk, msbfirst, int(data_out, 16), FALLING)
            self._spi.transfer(self.cs, data_out)
            digitalWrite(self._cs, HIGH)

        def _getConfig(self):

            self._io([self.CMD_GetParam | self.REG_Config])
            config_0 = self._io([0])
            config_1 = self._io([0])
            return ((config_0[0] << 8) | (config_1[0]))

        def _getStatus(self):

            self._io(self.CMD_GetStatus)
            status_0 = self._io([0])
            status_1 = self._io([0])
            return ((status_0[0] << 8) | (status_1[0]))

        def _move(self, angle):

            n_steps = self._angleToSteps(angle)
            if (n_steps > 0):
                dirtn = 1
            else:
                dirtn = 0
                n_steps = 0 - n_steps
            self._io(self.CMD_Move | dirtn);
            self._io(bin(n_steps >> 16))
            self._io(bin(n_steps >> 8))
            self._io(bin(n_steps))

        def _getAcc(self):

            self._io(self.CMD_GetParam | self.REG_Acc)
            acc_0 = self._io([0])
            acc_1 = self._io([0])
            return ((acc_0[0] << 8) | (acc_1[0]))

        def _setAcc(self, degreePerSec2):
            acc = self._accCalc(self._angleToSteps(degreePerSec2))
            self._io(self.CMD_SetParam | self.REG_Acc)
            self._io(bin(acc << 8))
            self._io(bin(acc))

        def _getDec():

            self._io(self.CMD_GetParam | self.REG_Dec)
            dec_0 = self._io([0])
            dec_1 = self._io([0])
            return ((dec_0[0] << 8) | (dec_1[0]))

        def _setDec(self, degreePerSec2):

            dec = self.DecCalc(self._angleToSteps(degreePerSec2))
            self._io(self.CMD_SetParam | self.REG_Dec)
            self._io(bin(dec << 8))
            self._io(bin(dec))

        def _getMaxSpeed():
            self._io(self.CMD_GetParam | self.REG_Max_Speed)
            max_speed_0 = self._io([0])
            max_speed_1 = self._io([0])
            return ((max_speed_0[0] << 8) | (max_speed_1[0]))

        def _getMaxSpeed(self, degreePerSec):
            max_speed = self._maxSpdCalc(self._angleToSteps(degreePerSec))
            self._io(self.CMD_SetParam | self.REG_Max_Speed)
            self._io(bin(max_speed << 8))
            self._io(bin(max_speed))

        def _getMinSpeed():
            self._io(self.CMD_GetParam | self.REG_Min_Speed)
            min_speed_0 = self._io([0])
            min_speed_1 |= self._io([0])
            return ((min_speed_0[0] << 8) | (min_speed_1[0]))

        def _setMinSpeed(self, degreePerSec):
            min_speed = self._minSpdCalc(angleToSteps(degreePerSec)))
            self._io(self.CMD_SetParam | self.REG_Min_Speed)
            self._io(bin(min_speed << 8))
            self._io(bin(min_speed))

        def _accCalc(self, stepsPerSecPerSec):
            temp = stepsPerSecPerSec * 0.137438
            return temp

        def _decCalc(self, stepsPerSecPerSec):
            temp = stepsPerSecPerSec * 0.137438
            return temp

        def _maxSpdCalc(self, stepsPerSec):
            temp = stepsPerSec * .065536
            return temp

        def _minSpdCalc(self, stepsPerSec):
            temp = stepsPerSec * 4.1943
            return temp

        def _isBusy(self):
            temp = digitalRead(BUSYpin)
            return (not temp)

        def _angleToSteps(self, angle):
            return (angle*71)

        def _spdCalc(self, stepsPerSec):
            temp = stepsPerSec * .065536
            return temp
