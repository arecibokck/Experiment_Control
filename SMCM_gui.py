# -*- coding: utf-8 -*-
"""
Created on Fri May 22, 2015

@author: KARTHIK KC
"""

from PyQt4.QtCore import *
from PyQt4.QtGui import *
# from SMCM_control import *
import sys


class StepperMotor(QDialog):

    def __init__(self):
        QDialog.__init__(self)
        layout1 = QVBoxLayout()
        label1 = QLabel("Stepper Motor Control")
        label1.setAlignment(Qt.AlignCenter)
        label2 = QLabel(u"\u00a9"+" Flightlab, Dr Sanjay Sane")
        label2.setAlignment(Qt.AlignCenter)
        self.angle = QLineEdit()
        self.speed = QLineEdit()
        self.angle.setPlaceholderText("Enter Angle")
        self.speed.setPlaceholderText("Enter Speed in RPM")
        layout1.addWidget(label1)
        layout1.addWidget(self.angle)
        layout1.addWidget(self.speed)
        layout2 = QHBoxLayout()
        layout3 = QHBoxLayout()
        layout4 = QHBoxLayout()
        layout5 = QHBoxLayout()
        self.labelx = QLabel("Type")
        self.labelx.setAlignment(Qt.AlignCenter)
        self.cb1 = QCheckBox()
        self.cb1.setText("Position")
        layout2.addWidget(self.cb1)
        self.cb2 = QCheckBox()
        self.cb2.setText("Linear")
        layout2.addWidget(self.cb2)
        self.cb3 = QCheckBox()
        self.cb3.setText("Sinusoidal")
        layout2.addWidget(self.cb3)
        self.cbl = QCheckBox()
        self.cbl.setText("Randomized")
        layout2.addWidget(self.cbl)
        layout2.setAlignment(Qt.AlignCenter)
        self.labely = QLabel("Direction")
        self.labely.setAlignment(Qt.AlignCenter)
        self.labely.setEnabled(False)
        self.cb4 = QRadioButton()
        self.cb4.setText("Clockwise")
        self.cb5 = QRadioButton()
        self.cb5.setText("Counter-Clockwise")
        layout3.setAlignment(Qt.AlignCenter)
        layout3.addWidget(self.cb4)
        layout3.addWidget(self.cb5)
        self.group = QButtonGroup()
        self.group.addButton(self.cb4)
        self.group.addButton(self.cb5)
        self.cb4.setEnabled(False)
        self.cb5.setEnabled(False)
        self.btn1 = QPushButton("Start")
        self.btn1.clicked[bool].connect(self.onStart)
        self.btn1.setCheckable(False)
        self.btn2 = QPushButton("Cancel")
        self.btn2.clicked.connect(self.close)
        self.label3 = QLabel()
        self.label3.setGeometry(0, 0, 10, 10)
        self.label3.setPixmap(QPixmap("SMC.png"))
        self.label3.setAlignment(Qt.AlignCenter)
        self.label4 = QLabel()
        self.label4.setGeometry(0, 0, 100, 10)
        self.label4.setPixmap(QPixmap("NCBS.png"))
        self.label4.setAlignment(Qt.AlignCenter)
        layout1.addWidget(self.labelx)
        layout1.addLayout(layout2)
        layout1.addWidget(self.labely)
        layout1.addLayout(layout3)
        layout1.addLayout(layout4)
        layout1.addLayout(layout5)
        layout1.addWidget(label2)
        layout4.addWidget(self.btn1)
        layout4.addWidget(self.btn2)
        layout5.addWidget(self.label3)
        layout5.addWidget(self.label4)
        self.setLayout(layout1)
        qr = self.frameGeometry()
        cp = QDesktopWidget().availableGeometry().center()
        qr.moveCenter(cp)
        self.setWindowTitle("SMCM")
        self.setWindowIcon(QIcon("SMC.ico"))
        self.setFocus()
        self.cb1.stateChanged.connect(self.statusCheck1)
        self.cb2.stateChanged.connect(self.statusCheck2)
        self.cb3.stateChanged.connect(self.statusCheck3)
        self.cbl.stateChanged.connect(self.statusCheck4)

    def onStart(self, status):
        if status:
            self.btn1.setText("Start")
            self.stop()
        else:
            self.btn1.setText("Stop")
            self.btn1.setCheckable(True)
            self.start()

    def statusCheck1(self):

        if self.cb1.isChecked() :
            self.cb2.setEnabled(False)
            self.cb3.setEnabled(False)
            self.cbl.setEnabled(False)
            self.cb4.setEnabled(True)
            self.cb5.setEnabled(True)
            self.labely.setEnabled(True)

        elif self.cb2.isChecked() or self.cb3.isChecked() :
            self.cb4.setChecked(False)
            self.cb5.setChecked(False)
            self.cb4.setEnabled(False)
            self.cb5.setEnabled(False)
            self.labely.setEnabled(False)

        else:
            self.group.setExclusive(False)
            self.cb4.setChecked(False)
            self.cb5.setChecked(False)
            self.group.setExclusive(True)
            self.cb2.setEnabled(True)
            self.cb3.setEnabled(True)
            self.cbl.setEnabled(True)
            self.cb4.setEnabled(False)
            self.cb5.setEnabled(False)
            self.labely.setEnabled(False)

    def statusCheck2(self):

        if self.cb2.isChecked() :
            self.cb1.setEnabled(False)
            self.cb3.setEnabled(False)
            self.cbl.setEnabled(False)

        else:
            self.cb1.setEnabled(True)
            self.cb3.setEnabled(True)
            self.cbl.setEnabled(True)

    def statusCheck3(self):

        if self.cb3.isChecked() :
            self.cb1.setEnabled(False)
            self.cb2.setEnabled(False)
            self.cbl.setEnabled(False)
        else:
            self.cb1.setEnabled(True)
            self.cb2.setEnabled(True)
            self.cbl.setEnabled(True)

    def statusCheck4(self):

        if self.cbl.isChecked():
            self.cb1.setEnabled(False)
            self.cb2.setEnabled(False)
            self.cb3.setEnabled(False)

        else:
            self.cb1.setEnabled(True)
            self.cb2.setEnabled(True)
            self.cb3.setEnabled(True)




    def event(self, event):

        if event.type() == QEvent.EnterWhatsThisMode:
            QWhatsThis.leaveWhatsThisMode()
            QMessageBox.information(self, "Information", "This is a Python-based control module for a stepper motor. \n\n\tAngle must be between 0 and 360"+u"\u00B0"
        +". \n\tSpeed should be within 60 rpm. \n\tOnly one type can be selected. \n\tUncheck one type to select another. \n\tLinear type alone enables direction toggle."
        +"\n\nPOSITION - Moves stepper shaft through specified angle and direction in one sweeping motion.\n\nLINEAR - Moves stepper shaft through specified angle and direction incrementally over time. \n\nSINUSOIDAL - Oscillates the stepper shaft through the specified angle."
        + "\n\nRANDOMIZED - If no angle is specified, moves stepper shaft through arbitrarily determined angles and direction."
        +" If angle is specified, moves the shaft through arbitrary direction in steps of the specified angle."
        +"\n\nABOUT \nThis program was written to conduct experiments studying head stabilization in moths when subjected to roll perturbation."
        + "\n"+"\nFlightlab, Dr Sanjay Sane, NCBS")
            return True
        return QDialog.event(self, event)

    def start(self):

        self.angle.setEnabled(False)
        self.speed.setEnabled(False)
        a = self.angle.text()
        s = self.speed.text()
        try:

            if (float(a)>0.0 and float(a)<=360.0 and float(s)>0.0 and float(s)<=60.0 ):

                if (self.cb1.isChecked()):

                    self.cb1.setEnabled(False)
                    self.labely.setEnabled(False)
                    self.labelx.setEnabled(False)
                    self.cb4.setEnabled(False)
                    self.cb5.setEnabled(False)
                    if(self.cb4.isChecked()):
                        float(a), float(s), "C"
                        self.btn1.setText("Start")
                        self.stop()
                    elif(self.cb5.isChecked()):
                        float(a), float(s), "CC"
                        self.btn1.setText("Start")
                        self.stop()
                    else:
                        QMessageBox.warning(self, "Error", "     Incomplete. \n  Specify Direction.", QMessageBox.Ok, QMessageBox.NoButton)
                        self.btn1.setText("Start")
                        self.btn1.setCheckable(False)
                        self.stop()

                elif(self.cb2.isChecked()):
                    self.cb2.setEnabled(False)

                elif(self.cb3.isChecked()):
                    self.cb3.setEnabled(False)

                elif(self.cbl.ischecked()):
                    self.cbl.setEnabled(False)

                else:
                    QMessageBox.warning(self, "Error", "You need to select a type.", QMessageBox.Ok, QMessageBox.NoButton)
                    self.btn1.setText("Start")
                    self.btn1.setCheckable(False)
                    self.stop()

            else:
                QMessageBox.warning(self, "Error", "Incorrect Parameters. \n  Enter within range.", QMessageBox.Ok, QMessageBox.NoButton)
                self.btn1.setText("Start")
                self.btn1.setCheckable(False)
                self.stop()


        except ValueError:

            if (self.cb1.isChecked() and (not a or not s)):
                self.cb1.setEnabled(False)
                self.labely.setEnabled(False)
                self.labelx.setEnabled(False)
                self.cb4.setEnabled(False)
                self.cb5.setEnabled(False)
                if not a and not s:

                    if(self.cb4.isChecked()):
                        QMessageBox.warning(self, "Warning", "   Angle and Speed has not been entered. \nDefault values of 90"+u"\u00B0"+" and 20 rpm will be given.", QMessageBox.Ok, QMessageBox.NoButton)
                        #linPattern(self, 90.0, 20.0, "C")
                        self.btn1.setText("Start")
                        self.btn1.setCheckable(False)
                        self.stop()

                    elif(self.cb5.isChecked()):
                        QMessageBox.warning(self, "Warning", "   Angle and Speed has not been entered. \nDefault values of 90"+u"\u00B0"+" and 20 rpm will be given.", QMessageBox.Ok, QMessageBox.NoButton)
                        #linPattern(self, 90.0, 20.0, "CC")
                        self.btn1.setText("Start")
                        self.btn1.setCheckable(False)
                        self.stop()

                    else:
                        QMessageBox.warning(self, "Error", "      Incomplete. \nSpecify Direction.", QMessageBox.Ok, QMessageBox.NoButton)
                        self.btn1.setText("Start")
                        self.btn1.setCheckable(False)
                        self.stop()


                elif (not a) and (float(s)>0.0 and float(s)<=60.0):

                    if(self.cb4.isChecked()):
                        QMessageBox.warning(self, "Warning", "   Angle has not been entered. \nDefault value of 90"+u"\u00B0"+" will be given.", QMessageBox.Ok, QMessageBox.NoButton)
                        #sinPattern(self, 90.0, float(s))
                        self.btn1.setText("Start")
                        self.btn1.setCheckable(False)
                        self.stop()

                    elif(self.cb5.isChecked()):
                        QMessageBox.warning(self, "Warning", "   Angle has not been entered. \nDefault value of 90"+u"\u00B0"+" will be given.", QMessageBox.Ok, QMessageBox.NoButton)
                        #print "90", s.append(".0")
                        self.btn1.setText("Start")
                        self.btn1.setCheckable(False)
                        self.stop()

                    else:
                        QMessageBox.warning(self, "Error", "      Incomplete. \nSpecify Direction.", QMessageBox.Ok, QMessageBox.NoButton)
                        self.btn1.setText("Start")
                        self.btn1.setCheckable(False)
                        self.btn1.setCheckable(False)
                        self.stop()


                elif (not s) and (float(a)>0.0 and float(a)<=360.0):

                    if(self.cb4.isChecked()):
                        QMessageBox.warning(self, "Warning", "     Speed has not been entered. \nDefault value of 20 rpm will be given.", QMessageBox.Ok, QMessageBox.NoButton)
                        #print a.append(".0"), "20.0"
                        self.btn1.setText("Start")
                        self.btn1.setCheckable(False)
                        self.stop()
                    elif(self.cb5.isChecked()):
                        QMessageBox.warning(self, "Warning", "     Speed has not been entered. \nDefault value of 20 rpm will be given.", QMessageBox.Ok, QMessageBox.NoButton)
                        #print a.append(".0"), "20.0"
                        self.btn1.setText("Start")
                        self.btn1.setCheckable(False)
                        self.stop()
                    else:
                        QMessageBox.warning(self, "Error", "      Incomplete. \nSpecify Direction.", QMessageBox.Ok, QMessageBox.NoButton)
                        self.btn1.setText("Start")
                        self.btn1.setCheckable(False)
                        self.stop()


                else:
                    QMessageBox.warning(self, "Error", "Incorrect Parameters. \n  Enter within range.", QMessageBox.Ok, QMessageBox.NoButton)
                    self.btn1.setText("Start")
                    self.btn1.setCheckable(False)
                    self.stop()


            elif(self.cb2.isChecked() and (not a or not s)):

                if not a and not s:
                    QMessageBox.warning(self, "Warning", "   Angle and Speed has not been entered. \nDefault values of 90"+u"\u00B0"+" and 20 rpm have been given.", QMessageBox.Ok, QMessageBox.NoButton)
                    self.cb2.setEnabled(False)
                elif (not a) and (float(s)>0.0 and float(s)<=60.0):
                    QMessageBox.warning(self, "Warning", "   Angle has not been entered. \nDefault value of 90"+u"\u00B0"+" will be given.", QMessageBox.Ok, QMessageBox.NoButton)
                    self.cb2.setEnabled(False)
                elif (not s) and (float(a)>0.0 and float(a)<=360.0):
                    QMessageBox.warning(self, "Warning", "    Speed has not been entered. \nDefault value of 20 rpm will be given.", QMessageBox.Ok, QMessageBox.NoButton)
                    self.cb2.setEnabled(False)
                else:
                    QMessageBox.warning(self, "Error", "Incorrect Parameters. \n  Enter within range.", QMessageBox.Ok, QMessageBox.NoButton)
                    self.btn1.setText("Start")
                    self.btn1.setCheckable(False)
                    self.stop()

            elif(self.cb3.isChecked() and (not a or not s)):

                if not a and not s:
                    QMessageBox.warning(self, "Warning", "   Angle and Speed has not been entered. \nDefault values of 90"+u"\u00B0"+" and 20 rpm have been given.", QMessageBox.Ok, QMessageBox.NoButton)
                    self.cb3.setEnabled(False)
                elif (not a) and (float(s)>0.0 and float(s)<=60.0):
                    QMessageBox.warning(self, "Warning", "   Angle has not been entered. \nDefault value of 90"+u"\u00B0"+"will be given.", QMessageBox.Ok, QMessageBox.NoButton)
                    self.cb3.setEnabled(False)
                elif (not s) and (float(a)>0.0 and float(a)<=360.0):
                    QMessageBox.warning(self, "Warning", "    Speed has not been entered. \nDefault value of 20 rpm will be given.", QMessageBox.Ok, QMessageBox.NoButton)
                    self.cb3.setEnabled(False)
                else:
                    QMessageBox.warning(self, "Error", "Incorrect Parameters. \n  Enter within range.", QMessageBox.Ok, QMessageBox.NoButton)
                    self.btn1.setText("Start")
                    self.btn1.setCheckable(False)
                    self.stop()

            elif(self.cbl.isChecked() and (not a or not s)):

                if not a and not s:
                    QMessageBox.warning(self, "Warning", "   Angle and Speed has not been entered. \nDefault values of 90"+u"\u00B0"+" and 20 rpm have been given.", QMessageBox.Ok, QMessageBox.NoButton)
                    self.cbl.setEnabled(False)
                elif (not a) and (float(s)>0.0 and float(s)<=60.0):
                    QMessageBox.warning(self, "Warning", "   Angle has not been entered. \nDefault value of 90"+u"\u00B0"+"will be given.", QMessageBox.Ok, QMessageBox.NoButton)
                    self.cbl.setEnabled(False)
                elif (not s) and (float(a)>0.0 and float(a)<=360.0):
                    QMessageBox.warning(self, "Warning", "    Speed has not been entered. \nDefault value of 20 rpm will be given.", QMessageBox.Ok, QMessageBox.NoButton)
                    self.cbl.setEnabled(False)
                else:
                    QMessageBox.warning(self, "Error", "Incorrect Parameters. \n  Enter within range.", QMessageBox.Ok, QMessageBox.NoButton)
                    self.btn1.setText("Start")
                    self.btn1.setCheckable(False)
                    self.stop()

            else:
                QMessageBox.warning(self, "Error", "You need to select a type.", QMessageBox.Ok, QMessageBox.NoButton)
                self.btn1.setText("Start")
                self.btn1.setCheckable(False)
                self.stop()



    def stop(self):
        self.angle.setEnabled(True)
        self.speed.setEnabled(True)
        if(self.cb1.isChecked()):
            self.cb1.setEnabled(True)
            self.labely.setEnabled(True)
            self.labelx.setEnabled(True)
            self.cb4.setEnabled(True)
            self.cb5.setEnabled(True)
        elif(self.cb2.isChecked()):
            self.cb2.setEnabled(True)
        elif(self.cb3.isChecked()):
            self.cb3.setEnabled(True)
        elif(self.cbl.isChecked()):
            self.cbl.setEnabled(True)















if __name__ == "__main__":
    app = QApplication(sys.argv)
    dialog = StepperMotor()
    dialog.show()
    sys.exit(app.exec_())
