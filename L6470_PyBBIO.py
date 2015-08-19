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
      Motor Pins:
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

    def __init__():

        setup()

        G_c = GetConfig()
        G_s = GetStatus()

        SetAcc(degreePerSec2)
        SetDec(degreePerSec2)
        SetMaxSpeed(degreePerSec)
        SetMinSpeed(degreePerSec)

        i_B = isBusy()

        io(data_out)
        D_c = DecCalc(stepsPerSecPerSec)
        A_c = AccCalc(stepsPerSecPerSec)
        MaxS_c = MaxSpdCalc(stepsPerSec)
        MinS_c = MinSpdCalc(stepsPerSec)
        steps = angleToSteps(angle)
        G_a = GetAcc()
        G_d = GetDec()
        GMax_s = GetMaxSpeed()
        GMin_s = GetMinSpeed()

def setup(self):

    self._cs = cs_pin
    self._clk = clk_pin
    self._sdo = sdo_pin
    self._sdi = sdi_pin
    self._busy = busy_pin
    self._reset = reset_pin

    for i in (self._cs, self._sdi, self._clk, self._busy, self._reset): pinMode(i, OUTPUT)

    digitalWrite(cs_pin, HIGH)
    pinMode(sdo_pin, INPUT)

    digitalWrite(reset_pin, HIGH)
    delay(1)
    digitalWrite(reset_pin, LOW)
    delay(1)
    digitalWrite(reset_pin, HIGH)
    delay(1)

    SPI1.begin();
    SPI1.setClockMode(1, 3) #Mode - 3
    SPI1.setMaxFrequency(1, 2000000) #2MHz
    SPI1.setBitsPerWord(1, 8) #8 bits per word


    io(CMD_ResetDevice)
    G_s = GetStatus()
    io(CMD_SetParam or REG_StepMode)
    io(0b01110111) #SYNC_EN, SYN_SEL(3), 0, STEP_SEL(3)
    #Use Busy/Sync pin as Busy, 1/128 microstepping (3), 0, SYNC frequency set to f_{FS}
    io(CMD_SetParam or REG_FSspeed)
    io(0x03)
    io(0xff) #Do not switch to full steps.


def io(data_out):

    digitalWrite(cs_pin, LOW)
    #data_in = shiftOut(self._sdo, self._clk, msbfirst, int(data_out, 16), FALLING)
    SPI1.write(1, [int(data_out, 16)])
    digitalWrite(cs_pin, HIGH)

def Move(angle):

    n_steps = angleToSteps(angle)
    if (n_steps > 0):
        dirtn = 1
    else:
        dirtn = 0
        n_steps = 0 - n_steps
    io(CMD_Move or dirtn);
    io(bin(n_steps >> 16))
    io(bin(n_steps >> 8))
    io(bin(n_steps))

def GetConfig():

    io(CMD_GetParam or REG_Config)
    Config = io(bin(0 << 8))
    Config |= io(bin(0)) #?
    return Config

def GetStatus():

    io(CMD_GetStatus)
    Status = io(bin(0 << 8))
    Status |= io(bin(0)) #?
    return Status

def GetAcc():

    io(CMD_GetParam or REG_Acc)
    acc = io(bin(0))
    acc |= io(bin(0)) #?
    return acc

def SetAcc(degreePerSec2):
    acc = AccCalc(angleToSteps(degreePerSec2))
    io(CMD_SetParam or REG_Acc)
    io(bin(acc << 8))
    io(bin(acc))

def GetDec():

    io(CMD_GetParam or REG_Dec)
    dec = io(bin(0))
    dec |= io(bin(0)) #?
    return dec

def SetDec(degreePerSec2):

    dec = DecCalc(angleToSteps(degreePerSec2))
    io(CMD_SetParam or REG_Dec)
    io(bin(dec << 8))
    io(bin(dec))

def GetMaxSpeed():
    io(CMD_GetParam or REG_Max_Speed)
    max_speed = io(bin(0))
    max_speed |= io(bin(0)) #?
    return max_speed

def SetMaxSpeed(degreePerSec):
    max_speed = MaxSpdCalc(angleToSteps(degreePerSec))
    io(CMD_SetParam or REG_Max_Speed)
    io(bin(max_speed << 8))
    io(bin(max_speed))

def GetMinSpeed():
    io(CMD_GetParam or REG_Min_Speed)
    min_speed = io(bin(0))
    min_speed |= io(bin(0)) #?
    return min_speed;

def SetMinSpeed(degreePerSec):
    min_speed = MinSpdCalc(angleToSteps(degreePerSec)))
    io(CMD_SetParam or REG_Min_Speed)
    io(bin(min_speed << 8))
    io(bin(min_speed))

def AccCalc(stepsPerSecPerSec):
    temp = stepsPerSecPerSec * 0.137438
    return temp

def DecCalc(stepsPerSecPerSec):
    temp = stepsPerSecPerSec * 0.137438
    return temp

def MaxSpdCalc(stepsPerSec):
    temp = stepsPerSec * .065536
    return temp

def MinSpdCalc(stepsPerSec):
    temp = stepsPerSec * 4.1943
    return temp

def isBusy():
    temp = digitalRead(BUSYpin)
    return (not temp)

def angleToSteps(angle):
    return (angle*71)

def SpdCalc(stepsPerSec):
    temp = stepsPerSec * .065536
    return temp
