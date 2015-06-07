# -*- coding: utf-8 -*-
"""
Created on Mon Jun 01, 2015

@author: KARTHIK KC
"""

import serial, time, random

class teensyControl:
    
    def __init__(self, port):
        try:
            self._serial = serial.Serial("COM5", baudrate=115200, timeout=0.05)
            self.readall()
            time.sleep(1)
        except serial.SerialException:
            print("Failed to connect to port")
            time.sleep(1)
            
    def setDirection(self, speed_comm, direction):
        if direction in ["C"]:
            dir_comm = 0xff
        elif direction in ["CC"]:
            dir_comm = 0x00
        command = [0xcc, speed_comm, dir_comm]
        serial._write()        
        self.readall()
        
    def linPattern(self, length, amplitude, speed_comm, direction):
        
        section = length // 4
        for direction in (1, -1):
            for i in range(section):
                yield i * (amplitude / section) * direction
            for i in range(section):
                yield (amplitude - (i * (amplitude / section))) * direction
                
        self.setDirection(self, speed_comm, direction)
    
    def sinPattern(self, angle_comm, speed_comm):
        while 1<2:
            app.processEvents()
            if a < angle_comm:
                self.setDirection(self, a, speed_comm, "C")
                a++
            else:
                self.setDirection(self, a, speed_comm, "CC")
                a--
    
    def ranPattern(self, angle_comm, speed_comm):
        if angle_comm and speed_comm:
            if random.randint(0,1) == 0:
                self.setDirection(self, angle_comm, speed_comm, "C")
            else:
                self.setDirection(self, angle_comm, speed_comm, "CC")
        else:
            if random.randint(0,1) == 0:
                self.setDirection(self, (random.randint(1, 360)), hex(random.randint(1, 60)), "C")
            else:
                self.setDirection(self, hex(random.randint(1, 360)), hex(random.randint(1, 60)), "CC")
                
            
            
                
            
            
        
        
            
        
            
            