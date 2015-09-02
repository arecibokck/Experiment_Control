from L6470_PyBBIO import *

def setup():

    speed = 100
    acc = 2000
    dec = 600
    move = 90
    motor = L6470()
    print("Setup begun")

    delay(1000)

    print("Got motor config:")
    print(motor.getConfig())

    print("Got motor status:")
    print(motor.getStatus())

    motor.move(10000)
    motor.setAcc(acc)
    motor.setDec(dec)
    motor.setMaxSpeed(speed)
    motor.setMinSpeed(0)
    print("\n\nSetup done")

def loop():

    delay(1)
    motor.move(move)
    print("\nMove+")
    delay(1)
    motor.move(-move)
    print("Move-")

run(setup, loop)
