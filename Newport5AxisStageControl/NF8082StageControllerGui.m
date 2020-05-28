classdef NF8082StageControllerGui < matlab.apps.AppBase
    
    properties (Access = private)
        Controller
        ControllerDeviceNumber
        stopPlot
        MaxNumberOfSteps
        MoveHistory = struct('Timestamps', {}, ...
                             'Moves'    , {});  
    end
    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                       matlab.ui.Figure
        TabGroup                       matlab.ui.container.TabGroup
        ControllerDeviceTab            matlab.ui.container.Tab
        Axis1Panel                     matlab.ui.container.Panel
        CurrentPositionEditField_1Label  matlab.ui.control.Label
        CurrentPositionEditField_1       matlab.ui.control.NumericEditField
        NofstepsEditField_1Label    matlab.ui.control.Label
        NofstepsEditField_1         matlab.ui.control.NumericEditField
        DropDown_1                       matlab.ui.control.DropDown
        EditField_1                      matlab.ui.control.NumericEditField
        ForwardsEditField_1Label         matlab.ui.control.Label
        ForwardsEditField_1              matlab.ui.control.NumericEditField
        BackwardsEditField_1Label        matlab.ui.control.Label
        BackwardsEditField_1             matlab.ui.control.NumericEditField
        MovePanel_1                    matlab.ui.container.Panel
        GoButton_1                     matlab.ui.control.Button
        GoButton_1Label                matlab.ui.control.Label
        GoButton_2                     matlab.ui.control.Button
        GoButton_2Label                matlab.ui.control.Label
        MaxstepsEditField_1Label       matlab.ui.control.Label
        MaxstepsEditField_1            matlab.ui.control.NumericEditField
        IgnoreCheckBox_1                 matlab.ui.control.CheckBox
        StopButton                     matlab.ui.control.Button
        MotionTypeButtonGroup_1        matlab.ui.container.ButtonGroup
        AbsoluteButton                 matlab.ui.control.RadioButton
        RelativeButton                 matlab.ui.control.RadioButton
        IndefiniteButton               matlab.ui.control.RadioButton
        MotionStatusLamp_1Label          matlab.ui.control.Label
        MotionStatusLamp_1               matlab.ui.control.Lamp
        ConnectionStatusLamp_1Label      matlab.ui.control.Label
        ConnectionStatusLamp_1           matlab.ui.control.Lamp
        ResetButton_1                  matlab.ui.control.Button
        ZeroButton_1                     matlab.ui.control.Button
        SetButton_1                      matlab.ui.control.Button
        TotalEditField_1Label            matlab.ui.control.Label
        TotalEditField_1                 matlab.ui.control.NumericEditField
        UIAxes                         matlab.ui.control.UIAxes
        ReadyStatusLampLabel           matlab.ui.control.Label
        ReadyStatusLamp                matlab.ui.control.Lamp
        AbortallmotionButton           matlab.ui.control.Button
        RefreshGUIButton               matlab.ui.control.Button
        DisconnectButton               matlab.ui.control.Button
        Axis4Panel                     matlab.ui.container.Panel
        CurrentPositionEditField_2Label matlab.ui.control.Label
        CurrentPositionEditField_2     matlab.ui.control.NumericEditField
        NofstepsEditField_2Label  matlab.ui.control.Label
        NofstepsEditField_2       matlab.ui.control.NumericEditField
        DropDown_2                     matlab.ui.control.DropDown
        EditField_2                    matlab.ui.control.NumericEditField
        ForwardsEditField_2Label       matlab.ui.control.Label
        ForwardsEditField_2            matlab.ui.control.NumericEditField
        BackwardsEditField_2Label      matlab.ui.control.Label
        BackwardsEditField_2           matlab.ui.control.NumericEditField
        MovePanel_2                    matlab.ui.container.Panel
        GoButton_3                     matlab.ui.control.Button
        GoButton_3Label                matlab.ui.control.Label
        GoButton_4                     matlab.ui.control.Button
        GoButton_4Label                matlab.ui.control.Label
        MaxstepsEditField_2Label     matlab.ui.control.Label
        MaxstepsEditField_2          matlab.ui.control.NumericEditField
        IgnoreCheckBox_2               matlab.ui.control.CheckBox
        StopButton_2                   matlab.ui.control.Button
        MotionTypeButtonGroup_2        matlab.ui.container.ButtonGroup
        AbsoluteButton_2               matlab.ui.control.RadioButton
        RelativeButton_2               matlab.ui.control.RadioButton
        IndefiniteButton_2             matlab.ui.control.RadioButton
        MotionStatusLamp_2Label        matlab.ui.control.Label
        MotionStatusLamp_2             matlab.ui.control.Lamp
        ConnectionStatusLamp_2Label    matlab.ui.control.Label
        ConnectionStatusLamp_2         matlab.ui.control.Lamp
        ResetButton_2                  matlab.ui.control.Button
        ZeroButton_2                   matlab.ui.control.Button
        SetButton_2                    matlab.ui.control.Button
        TotalEditField_2Label          matlab.ui.control.Label
        TotalEditField_2               matlab.ui.control.NumericEditField
        Axis3Panel                     matlab.ui.container.Panel
        CurrentPositionEditField_3Label  matlab.ui.control.Label
        CurrentPositionEditField_3     matlab.ui.control.NumericEditField
        NofstepsEditField_3Label  matlab.ui.control.Label
        NofstepsEditField_3       matlab.ui.control.NumericEditField
        DropDown_3                     matlab.ui.control.DropDown
        EditField_3                    matlab.ui.control.NumericEditField
        ForwardsEditField_3Label       matlab.ui.control.Label
        ForwardsEditField_3            matlab.ui.control.NumericEditField
        BackwardsEditField_3Label      matlab.ui.control.Label
        BackwardsEditField_3           matlab.ui.control.NumericEditField
        MovePanel_3                    matlab.ui.container.Panel
        GoButton_5                     matlab.ui.control.Button
        GoButton_5Label                matlab.ui.control.Label
        GoButton_6                     matlab.ui.control.Button
        GoButton_6Label                matlab.ui.control.Label
        MaxstepsEditField_3Label     matlab.ui.control.Label
        MaxstepsEditField_3          matlab.ui.control.NumericEditField
        IgnoreCheckBox_3               matlab.ui.control.CheckBox
        StopButton_3                   matlab.ui.control.Button
        MotionTypeButtonGroup_3        matlab.ui.container.ButtonGroup
        AbsoluteButton_3               matlab.ui.control.RadioButton
        RelativeButton_3               matlab.ui.control.RadioButton
        IndefiniteButton_3             matlab.ui.control.RadioButton
        MotionStatusLamp_3Label        matlab.ui.control.Label
        MotionStatusLamp_3             matlab.ui.control.Lamp
        ConnectionStatusLamp_3Label    matlab.ui.control.Label
        ConnectionStatusLamp_3         matlab.ui.control.Lamp
        ResetButton_3                  matlab.ui.control.Button
        ZeroButton_3                   matlab.ui.control.Button
        SetButton_3                    matlab.ui.control.Button
        TotalEditField_3Label          matlab.ui.control.Label
        TotalEditField_3               matlab.ui.control.NumericEditField
        Axis2Panel                     matlab.ui.container.Panel
        CurrentPositionEditField_4Label  matlab.ui.control.Label
        CurrentPositionEditField_4     matlab.ui.control.NumericEditField
        NofstepsEditField_4Label       matlab.ui.control.Label
        NofstepsEditField_4            matlab.ui.control.NumericEditField
        DropDown_4                     matlab.ui.control.DropDown
        EditField_4                    matlab.ui.control.NumericEditField
        ForwardsEditField_4Label       matlab.ui.control.Label
        ForwardsEditField_4            matlab.ui.control.NumericEditField
        BackwardsEditField_4Label      matlab.ui.control.Label
        BackwardsEditField_4           matlab.ui.control.NumericEditField
        MovePanel_4                    matlab.ui.container.Panel
        GoButton_7                     matlab.ui.control.Button
        GoButton_7Label                matlab.ui.control.Label
        GoButton_8                     matlab.ui.control.Button
        GoButton_8Label                matlab.ui.control.Label
        MaxstepsEditField_4Label       matlab.ui.control.Label
        MaxstepsEditField_4            matlab.ui.control.NumericEditField
        IgnoreCheckBox_4               matlab.ui.control.CheckBox
        StopButton_4                   matlab.ui.control.Button
        MotionTypeButtonGroup_4        matlab.ui.container.ButtonGroup
        AbsoluteButton_4               matlab.ui.control.RadioButton
        RelativeButton_4               matlab.ui.control.RadioButton
        IndefiniteButton_4             matlab.ui.control.RadioButton
        MotionStatusLamp_4Label        matlab.ui.control.Label
        MotionStatusLamp_4             matlab.ui.control.Lamp
        ConnectionStatusLamp_4Label    matlab.ui.control.Label
        ConnectionStatusLamp_4         matlab.ui.control.Lamp
        ResetButton_4                  matlab.ui.control.Button
        ZeroButton_4                   matlab.ui.control.Button
        SetButton_4                    matlab.ui.control.Button
        TotalEditField_4Label          matlab.ui.control.Label
        TotalEditField_4               matlab.ui.control.NumericEditField
        StartPlotButton                matlab.ui.control.Button
        StopPlotButton                 matlab.ui.control.Button
        ResetPlotButton                matlab.ui.control.Button
        deactivateButton_1             matlab.ui.control.Button
        deactivateButton_2             matlab.ui.control.Button
        deactivateButton_3             matlab.ui.control.Button
        deactivateButton_4             matlab.ui.control.Button
        saveButton                     matlab.ui.control.Button
    end
    
    % Callbacks that handle component events
    methods (Access = private)
         % Button pushed function: RefreshGUIButton
        function RefreshGUIButtonPushed(app, event)
            [Forwards,Backwards] = app.Controller.ControllerDevice{app.ControllerDeviceNumber}.GetTotalNumberOfSteps(1);
            set(app.ForwardsEditField_1, 'Value', Forwards);
            set(app.BackwardsEditField_1, 'Value', Backwards);
            set(app.TotalEditField_1, 'Value', Forwards - Backwards);
            set(app.CurrentPositionEditField_1, 'Value', app.Controller.ControllerDevice{app.ControllerDeviceNumber}.GetCurrentPosition(1));
            set(app.MaxstepsEditField_1, 'Value', app.MaxNumberOfSteps(1));
            
            [Forwards,Backwards] = app.Controller.ControllerDevice{app.ControllerDeviceNumber}.GetTotalNumberOfSteps(2);
            set(app.ForwardsEditField_2, 'Value', Forwards);
            set(app.BackwardsEditField_2, 'Value', Backwards);
            set(app.TotalEditField_2, 'Value', Forwards - Backwards);
            set(app.CurrentPositionEditField_2, 'Value', app.Controller.ControllerDevice{app.ControllerDeviceNumber}.GetCurrentPosition(2));
            set(app.MaxstepsEditField_2, 'Value', app.MaxNumberOfSteps(2));
            
            [Forwards,Backwards] = app.Controller.ControllerDevice{app.ControllerDeviceNumber}.GetTotalNumberOfSteps(3);
            set(app.ForwardsEditField_3, 'Value', Forwards);
            set(app.BackwardsEditField_3, 'Value', Backwards);
            set(app.TotalEditField_3, 'Value', Forwards - Backwards);
            set(app.CurrentPositionEditField_3, 'Value', app.Controller.ControllerDevice{app.ControllerDeviceNumber}.GetCurrentPosition(3));
            set(app.MaxstepsEditField_3, 'Value', app.MaxNumberOfSteps(3));
            
            [Forwards,Backwards] = app.Controller.ControllerDevice{app.ControllerDeviceNumber}.GetTotalNumberOfSteps(4);
            set(app.ForwardsEditField_4, 'Value', Forwards);
            set(app.BackwardsEditField_4, 'Value', Backwards);
            set(app.TotalEditField_4, 'Value', Forwards - Backwards);
            set(app.CurrentPositionEditField_4, 'Value', app.Controller.ControllerDevice{app.ControllerDeviceNumber}.GetCurrentPosition(4));
            set(app.MaxstepsEditField_4, 'Value', app.MaxNumberOfSteps(4));
        end
        
        % Button pushed function: DisconnectButton
        function DisconnectButtonValueChanged(app, event)
            str = get(app.DisconnectButton,'Text');
            ind = find(strcmp(str,'Disconnect'));
            if ind == 1
                app.Controller.disconnectPicomotorController(app.ControllerDeviceNumber);
                set(app.DisconnectButton,'Text', 'Reconnect');
                %set(app.DisconnectButton,'BackgroundColor', 'red');
                %set(app.DisconnectButton,'FontColor', [0.96,0.96,0.96]);
                set(app.ReadyStatusLamp, 'Color', 'red');
                set(app.RefreshGUIButton,'Enable', 0);
                set(app.AbortallmotionButton,'Enable', 0);
                app.deactivateControl(1);
                app.deactivateControl(2);
                app.deactivateControl(3);
                app.deactivateControl(4);
                axis(app.UIAxes, 'off');
                set(app.saveButton, 'Enable', 0);
                set(app.StartPlotButton, 'Enable', 0);
                set(app.StopPlotButton, 'Enable', 0);
                set(app.ResetPlotButton, 'Enable', 0);
            else
                app.Controller.reconnectPicomotorController(app.ControllerDeviceNumber);
                set(app.DisconnectButton,'Text', 'Disconnect');
                %set(app.DisconnectButton,'BackgroundColor', [0.96,0.96,0.96]);
                %set(app.DisconnectButton,'FontColor', [0,0,0]);
                set(app.ReadyStatusLamp, 'Color', 'green');
                set(app.RefreshGUIButton,'Enable', 1);
                set(app.AbortallmotionButton,'Enable', 1);
                if strcmp(get(app.deactivateButton_1,'Text'),'Deactivate')
                    set(app.deactivateButton_1, 'Text', 'Reactivate')
                end
                set(app.deactivateButton_1, 'Enable', 1)
                if strcmp(get(app.deactivateButton_2,'Text'),'Deactivate')
                    set(app.deactivateButton_2, 'Text', 'Reactivate')
                end
                set(app.deactivateButton_2, 'Enable', 1)
                if strcmp(get(app.deactivateButton_3,'Text'),'Deactivate')
                    set(app.deactivateButton_3, 'Text', 'Reactivate')
                end
                set(app.deactivateButton_3, 'Enable', 1)
                if strcmp(get(app.deactivateButton_4,'Text'),'Deactivate')
                    set(app.deactivateButton_4, 'Text', 'Reactivate')
                end
                set(app.deactivateButton_4, 'Enable', 1)
                axis(app.UIAxes, 'on');
                set(app.saveButton, 'Enable', 1);
                set(app.StartPlotButton, 'Enable', 1);
                set(app.StopPlotButton, 'Enable', 1);
                set(app.ResetPlotButton, 'Enable', 1);
            end
        end
        
         % Button pushed function: AbortallmotionButton
        function AbortallmotionButtonPushed(app, event)
            app.Controller.ControllerDevice{app.ControllerDeviceNumber}.abortMotionFlag = 1;
            app.Controller.ControllerDevice{app.ControllerDeviceNumber}.AbortMotion;
            app.Controller.ControllerDevice{app.ControllerDeviceNumber}.abortMotionFlag = 0;
        end
        
        function saveButtonPushed(app, event)
            filename = ['MovesUpto_' char(strrep(strrep(strrep(string(datetime('now', 'Format', 'yyyy-MM-dd HH:mm')), '-', ''), ' ', '_'), ':', '')) '.csv']; 
            [file, path] = uiputfile(filename);
            if ~(isequal(file,0) || isequal(path,0))
                temp_table = struct2table(app.MoveHistory);
                writetable(temp_table,[path file]);
            end
        end
        
        % Button pushed function: ResetButton
        function StartPlotButtonPushed(app, event)
            Colors2Use={[0, 0.4470, 0.7410],[0.8500, 0.3250, 0.0980],[0.9290, 0.6940, 0.1250],[0.4940, 0.1840, 0.5560],[0.4660, 0.6740, 0.1880], [0.6350, 0.0780, 0.1840]};
            refreshduration = 30; %in s
            axis1 = animatedline(app.UIAxes, 'Color', Colors2Use{1}, 'Linewidth', 1.5);
            axis2 = animatedline(app.UIAxes, 'Color', Colors2Use{2}, 'Linewidth', 1.5);
            axis3 = animatedline(app.UIAxes, 'Color', Colors2Use{3}, 'Linewidth', 1.5);
            axis4 = animatedline(app.UIAxes, 'Color', Colors2Use{4}, 'Linewidth', 1.5);
            leg = legend(app.UIAxes, 'Axis 1', 'Axis 2', 'Axis 3', 'Axis 4');
            set(leg,'Box','off');
            set(gcf,'visible','off')
            app.stopPlot = false;
            startTime = datetime('now');
            while ~app.stopPlot
                t = fix(24*3600*datenum(datetime('now') - startTime));
                addpoints(axis1, t, app.Controller.ControllerDevice{app.ControllerDeviceNumber}.GetCurrentPosition(1));  
                addpoints(axis2, t, app.Controller.ControllerDevice{app.ControllerDeviceNumber}.GetCurrentPosition(2));  
                addpoints(axis3, t, app.Controller.ControllerDevice{app.ControllerDeviceNumber}.GetCurrentPosition(3));  
                addpoints(axis4, t, app.Controller.ControllerDevice{app.ControllerDeviceNumber}.GetCurrentPosition(4));  
                if t>=refreshduration
                    app.UIAxes.XLim = [t-refreshduration t];
                end
                datetick('x', 'keeplimits');
                drawnow limitrate
            end    
        end
        
        % Button pushed function: ResetButton
        function StopPlotButtonPushed(app, event)
            app.stopPlot = true;
        end
        
        % Button pushed function: ResetButton
        function ResetPlotButtonPushed(app, event)
            app.UIAxes.cla;
            app.stopPlot = false;
        end
        
        function deactivateControl(app, axis)
            switch axis
                case 1
                    children_axis = get(app.Axis1Panel,'Children');
                    children_move = get(app.MovePanel_1,'Children');
                    set(children_axis(isprop(children_axis,'Enable')),'Enable',0)
                    set(children_move(isprop(children_move,'Enable')),'Enable',0)
                case 2
                    children_axis = get(app.Axis2Panel,'Children');
                    children_move = get(app.MovePanel_2,'Children');
                    set(children_axis(isprop(children_axis,'Enable')),'Enable',0)
                    set(children_move(isprop(children_move,'Enable')),'Enable',0)
                case 3
                    children_axis = get(app.Axis3Panel,'Children');
                    children_move = get(app.MovePanel_3,'Children');
                    set(children_axis(isprop(children_axis,'Enable')),'Enable',0)
                    set(children_move(isprop(children_move,'Enable')),'Enable',0)
                case 4
                    children_axis = get(app.Axis4Panel,'Children');
                    children_move = get(app.MovePanel_4,'Children');
                    set(children_axis(isprop(children_axis,'Enable')),'Enable',0)
                    set(children_move(isprop(children_move,'Enable')),'Enable',0) 
            end
        end
        
        function reactivateControl(app, axis)
            switch axis
                case 1
                    children_axis = get(app.Axis1Panel,'Children');
                    children_move = get(app.MovePanel_1,'Children');
                    set(children_axis(isprop(children_axis,'Enable')),'Enable',1)
                    set(children_move(isprop(children_move,'Enable')),'Enable',1)
                case 2
                    children_axis = get(app.Axis2Panel,'Children');
                    children_move = get(app.MovePanel_2,'Children');
                    set(children_axis(isprop(children_axis,'Enable')),'Enable',1)
                    set(children_move(isprop(children_move,'Enable')),'Enable',1)
                case 3
                    children_axis = get(app.Axis3Panel,'Children');
                    children_move = get(app.MovePanel_3,'Children');
                    set(children_axis(isprop(children_axis,'Enable')),'Enable',1)
                    set(children_move(isprop(children_move,'Enable')),'Enable',1)
                case 4
                    children_axis = get(app.Axis4Panel,'Children');
                    children_move = get(app.MovePanel_4,'Children');
                    set(children_axis(isprop(children_axis,'Enable')),'Enable',1)
                    set(children_move(isprop(children_move,'Enable')),'Enable',1)
            end
        end
        
        %% Axis 1
        % Value changed function: DropDown_1
        function DropDown_1ValueChanged(app, event)
            value = app.DropDown_1.Value;
            switch value
                case 'Velocity'
                    set(app.EditField_1, 'Value', app.Controller.ControllerDevice{app.ControllerDeviceNumber}.GetVelocity(1));
                case 'Acceleration'
                    set(app.EditField_1, 'Value', app.Controller.ControllerDevice{app.ControllerDeviceNumber}.GetAcceleration(1));
                case 'Motor Type'
                    set(app.EditField_1, 'Value', app.Controller.ControllerDevice{app.ControllerDeviceNumber}.GetMotorType(1));
            end
        end
        
        % Value changed function: EditField
        function EditField_1ValueChanged(app, event)
            value = app.EditField_1.Value;
            switch app.DropDown_1.Value
                case 'Velocity'
                    app.Controller.ControllerDevice{app.ControllerDeviceNumber}.SetVelocity(1, value);
                    set(app.EditField_1, 'Value', value);
                case 'Acceleration'
                    app.Controller.ControllerDevice{app.ControllerDeviceNumber}.SetAcceleration(1, value);
                    set(app.EditField_1, 'Value', value);
                case 'Motor Type'
                    app.Controller.ControllerDevice{app.ControllerDeviceNumber}.SetMotorType(1, value);
                    set(app.EditField_1, 'Value', value);
            end
        end
        
        % Button pushed function: ZeroButton_1
        function ZeroButton_1Pushed(app, event)
            app.Controller.ControllerDevice{app.ControllerDeviceNumber}.SetHome(1, app.Controller.ControllerDevice{app.ControllerDeviceNumber}.GetCurrentPosition(1));
            set(app.CurrentPositionEditField_1, 'Value', app.Controller.ControllerDevice{app.ControllerDeviceNumber}.GetCurrentPosition(1)); 
        end
        
        function NofstepsEditField_1ValueChanged(app, event)
            value = app.NofstepsEditField_1.Value;
            set(app.NofstepsEditField_1, 'Value', value);
        end
        
        % Button pushed function: GoButton_1
        function GoButton_1Pushed(app, event)
            app.deactivateControl(2);
            app.deactivateControl(3);
            app.deactivateControl(4);
            set(app.MotionStatusLamp_1, 'Color', 'green');
            error = app.Controller.ControllerDevice{app.ControllerDeviceNumber}.MoveRelative(1,app.NofstepsEditField_1.Value);
            if strcmp(get(app.deactivateButton_2,'Text'),'Deactivate')
               app.reactivateControl(2);
            else
                set(app.deactivateButton_2, 'Enable', 1)
            end
            if strcmp(get(app.deactivateButton_3,'Text'),'Deactivate')
               app.reactivateControl(3);
            else
                set(app.deactivateButton_3, 'Enable', 1)
            end
            if strcmp(get(app.deactivateButton_4,'Text'),'Deactivate')
                app.reactivateControl(4);
            else
                set(app.deactivateButton_4, 'Enable', 1)
            end
            if error.Code ~= 108
                set(app.ConnectionStatusLamp_1, 'Color', 'green');
            else
                set(app.ConnectionStatusLamp_1, 'Color', 'red');
                set(app.MotionStatusLamp_1, 'Color', [0.96,0.96,0.96]);
            end
            set(app.MotionStatusLamp_1, 'Color', [0.96,0.96,0.96]);
            app.updateNumbers_1;
            app.MoveHistory(end+1)= struct('Timestamps', char(datetime('now')), 'Moves', ['1R+' num2str(app.NofstepsEditField_1.Value)]);
        end
        
        % Button pushed function: GoButton_1
        function GoButton_2Pushed(app, event)
            app.deactivateControl(2);
            app.deactivateControl(3);
            app.deactivateControl(4);
            set(app.MotionStatusLamp_1, 'Color', 'green');
            error = app.Controller.ControllerDevice{app.ControllerDeviceNumber}.MoveRelative(1,app.NofstepsEditField_1.Value*(-1));
            if strcmp(get(app.deactivateButton_2,'Text'),'Deactivate')
               app.reactivateControl(2);
            else
                set(app.deactivateButton_2, 'Enable', 1)
            end
            if strcmp(get(app.deactivateButton_3,'Text'),'Deactivate')
               app.reactivateControl(3);
            else
                set(app.deactivateButton_3, 'Enable', 1)
            end
            if strcmp(get(app.deactivateButton_4,'Text'),'Dectivate')
                app.reactivateControl(4);
            else
                set(app.deactivateButton_4, 'Enable', 1)
            end
            if error.Code ~= 108
                set(app.ConnectionStatusLamp_1, 'Color', 'green');
            else
                set(app.ConnectionStatusLamp_1, 'Color', 'red');
                set(app.MotionStatusLamp_1, 'Color', [0.96,0.96,0.96]);
            end
            set(app.MotionStatusLamp_1, 'Color', [0.96,0.96,0.96]);
            app.updateNumbers_1;
            app.MoveHistory(end+1)= struct('Timestamps', char(datetime('now')), 'Moves', ['1R-' num2str(app.NofstepsEditField_1.Value)]);
        end
        
        function updateNumbers_1(app)
            [Forwards,Backwards] = app.Controller.ControllerDevice{app.ControllerDeviceNumber}.GetTotalNumberOfSteps(1);     
            set(app.ForwardsEditField_1, 'Value', Forwards);
            set(app.BackwardsEditField_1, 'Value', Backwards);
            set(app.TotalEditField_1, 'Value', Forwards - Backwards);
            set(app.CurrentPositionEditField_1, 'Value', app.Controller.ControllerDevice{app.ControllerDeviceNumber}.GetCurrentPosition(1)); 
        end
        
        % Button pushed function: ResetButton_1
        function ResetButton_1Pushed(app, event)
           app.refresh_1; 
        end
        
        % Value changed function: MaxstepsEditField
        function MaxstepsEditField_1ValueChanged(app, event)
            value = app.MaxstepsEditField_1.Value;
            app.Controller.ControllerDevice{app.ControllerDeviceNumber}.SetMaxNumberOfSteps(1, value);
            app.MaxNumberOfSteps = app.Controller.ControllerDevice{app.ControllerDeviceNumber}.MaxNumberOfSteps.UserDefined;
            set(app.MaxstepsEditField_1, 'Value', app.MaxNumberOfSteps(1));
        end
        
        % Value changed function: IgnoreCheckBox_1
        function IgnoreCheckBox_1ValueChanged(app, event)
            value = app.IgnoreCheckBox_1.Value;
            if value == 1
                app.Controller.ControllerDevice{app.ControllerDeviceNumber}.IgnoreMaxNumberOfSteps(1) = 1;
            else
                app.Controller.ControllerDevice{app.ControllerDeviceNumber}.IgnoreMaxNumberOfSteps(1) = 0;
            end
        end
        
        function deactivateButton_1Pushed(app, event)
            if strcmp(get(app.deactivateButton_1,'Text'),'Activate')
                app.reactivateControl(1);
                set(app.deactivateButton_1, 'Text', 'Deactivate')
            elseif strcmp(get(app.deactivateButton_1,'Text'),'Deactivate')
                app.deactivateControl(1);
                set(app.deactivateButton_1, 'Enable', 1)
                set(app.deactivateButton_1, 'Text', 'Reactivate')
            else
                app.reactivateControl(1);
                set(app.deactivateButton_1, 'Text', 'Deactivate')
            end
        end
        
        function refresh_1(app)
            [Forwards_Old,Backwards_Old] = app.Controller.ControllerDevice{app.ControllerDeviceNumber}.ResetTotalNumberOfSteps(1);
            [Forwards_New,Backwards_New] = app.Controller.ControllerDevice{app.ControllerDeviceNumber}.GetTotalNumberOfSteps(1);
            set(app.ForwardsEditField_1, 'Value', Forwards_New);
            set(app.BackwardsEditField_1, 'Value', Backwards_New);
            set(app.TotalEditField_1, 'Value', Forwards_New - Backwards_New);
            set(app.CurrentPositionEditField_1, 'Value', app.Controller.ControllerDevice{app.ControllerDeviceNumber}.GetCurrentPosition(1));
        end
        
        %% Axis 2
        % Value changed function: DropDown_2
        function DropDown_2ValueChanged(app, event)
            value = app.DropDown_2.Value;
            switch value
                case 'Velocity'
                    set(app.EditField_2, 'Value', app.Controller.ControllerDevice{app.ControllerDeviceNumber}.GetVelocity(2));
                case 'Acceleration'
                    set(app.EditField_2, 'Value', app.Controller.ControllerDevice{app.ControllerDeviceNumber}.GetAcceleration(2));
                case 'Motor Type'
                    set(app.EditField_2, 'Value', app.Controller.ControllerDevice{app.ControllerDeviceNumber}.GetMotorType(2));
            end
        end
        
        % Value changed function: EditField
        function EditField_2ValueChanged(app, event)
            value = app.EditField_2.Value;
            switch app.DropDown_2.Value
                case 'Velocity'
                    app.Controller.ControllerDevice{app.ControllerDeviceNumber}.SetVelocity(2, value);
                    set(app.EditField_2, 'Value', value);
                case 'Acceleration'
                    app.Controller.ControllerDevice{app.ControllerDeviceNumber}.SetAcceleration(2, value);
                    set(app.EditField_2, 'Value', value);
                case 'Motor Type'
                    app.Controller.ControllerDevice{app.ControllerDeviceNumber}.SetMotorType(2, value);
                    set(app.EditField_2, 'Value', value);
            end
        end
        
        % Button pushed function: ZeroButton_2
        function ZeroButton_2Pushed(app, event)
            app.Controller.ControllerDevice{app.ControllerDeviceNumber}.SetHome(2, app.Controller.ControllerDevice{app.ControllerDeviceNumber}.GetCurrentPosition(2));
            set(app.CurrentPositionEditField_2, 'Value', app.Controller.ControllerDevice{app.ControllerDeviceNumber}.GetCurrentPosition(2)); 
        end
        
        function NofstepsEditField_2ValueChanged(app, event)
            value = app.NofstepsEditField_2.Value;
            set(app.NofstepsEditField_2, 'Value', value);
        end
        
        % Button pushed function: GoButton_3
        function GoButton_3Pushed(app, event)
           app.deactivateControl(1);
           app.deactivateControl(3);
           app.deactivateControl(4);
           set(app.MotionStatusLamp_2, 'Color', 'green');
           error = app.Controller.ControllerDevice{app.ControllerDeviceNumber}.MoveRelative(2,app.NofstepsEditField_2.Value);
           if strcmp(get(app.deactivateButton_1,'Text'),'Deactivate')
               app.reactivateControl(1);
           else
                set(app.deactivateButton_1, 'Enable', 1)
           end
           if strcmp(get(app.deactivateButton_3,'Text'),'Deactivate')
               app.reactivateControl(3);
           else
                set(app.deactivateButton_3, 'Enable', 1)
           end
           if strcmp(get(app.deactivateButton_4,'Text'),'Deactivate')
               app.reactivateControl(4);
           else
                set(app.deactivateButton_4, 'Enable', 1)
           end
           if error.Code ~= 208
               set(app.ConnectionStatusLamp_2, 'Color', 'green');
           else
               set(app.ConnectionStatusLamp_2, 'Color', 'red');
               set(app.MotionStatusLamp_2, 'Color', [0.96,0.96,0.96]);
           end
           set(app.MotionStatusLamp_2, 'Color', [0.96,0.96,0.96]);
           app.updateNumbers_2;
           app.MoveHistory(end+1)= struct('Timestamps', char(datetime('now')), 'Moves', ['2R+' num2str(app.NofstepsEditField_2.Value)]); 
        end
        
        % Button pushed function: GoButton_4
        function GoButton_4Pushed(app, event)
           app.deactivateControl(1);
           app.deactivateControl(3);
           app.deactivateControl(4);
           set(app.MotionStatusLamp_2, 'Color', 'green');
           error = app.Controller.ControllerDevice{app.ControllerDeviceNumber}.MoveRelative(2,app.NofstepsEditField_2.Value*(-1));
           if strcmp(get(app.deactivateButton_1,'Text'),'Deactivate')
               app.reactivateControl(1);
           else
                set(app.deactivateButton_1, 'Enable', 1)
           end
           if strcmp(get(app.deactivateButton_3,'Text'),'Deactivate')
               app.reactivateControl(3);
           else
                set(app.deactivateButton_3, 'Enable', 1)
           end
           if strcmp(get(app.deactivateButton_4,'Text'),'Deactivate')
               app.reactivateControl(4);
           else
                set(app.deactivateButton_4, 'Enable', 1)
           end
           if error.Code ~= 208
               set(app.ConnectionStatusLamp_2, 'Color', 'green');
           else
               set(app.ConnectionStatusLamp_2, 'Color', 'red');
               set(app.MotionStatusLamp_2, 'Color', [0.96,0.96,0.96]);
           end
           set(app.MotionStatusLamp_2, 'Color', [0.96,0.96,0.96]);
           app.updateNumbers_2;
           app.MoveHistory(end+1)= struct('Timestamps', char(datetime('now')), 'Moves', ['2R-' num2str(app.NofstepsEditField_2.Value)]);  
        end
        
        function updateNumbers_2(app)
            [Forwards,Backwards] = app.Controller.ControllerDevice{app.ControllerDeviceNumber}.GetTotalNumberOfSteps(2);     
            set(app.ForwardsEditField_2, 'Value', Forwards);
            set(app.BackwardsEditField_2, 'Value', Backwards);
            set(app.TotalEditField_2, 'Value', Forwards - Backwards);
            set(app.CurrentPositionEditField_2, 'Value', app.Controller.ControllerDevice{app.ControllerDeviceNumber}.GetCurrentPosition(2)); 
        end
        
        % Button pushed function: ResetButton_2
        function ResetButton_2Pushed(app, event)
           app.refresh_2; 
        end
        
        function MaxstepsEditField_2ValueChanged(app, event)
            value = app.MaxstepsEditField_2.Value;
            app.Controller.ControllerDevice{app.ControllerDeviceNumber}.SetMaxNumberOfSteps(2, value);
            app.MaxNumberOfSteps = app.Controller.ControllerDevice{app.ControllerDeviceNumber}.MaxNumberOfSteps.UserDefined;
            set(app.MaxstepsEditField_2, 'Value', app.MaxNumberOfSteps(2));
        end
        
        % Value changed function: IgnoreCheckBox_2
        function IgnoreCheckBox_2ValueChanged(app, event)
            value = app.IgnoreCheckBox_2.Value;
            if value == 1
                app.Controller.ControllerDevice{app.ControllerDeviceNumber}.IgnoreMaxNumberOfSteps(2) = 1;
            else
                app.Controller.ControllerDevice{app.ControllerDeviceNumber}.IgnoreMaxNumberOfSteps(2) = 0;
            end
        end
        
        function deactivateButton_2Pushed(app, event)
            if strcmp(get(app.deactivateButton_2,'Text'),'Activate')
                app.reactivateControl(2);
                set(app.deactivateButton_2, 'Text', 'Deactivate')
            elseif strcmp(get(app.deactivateButton_2,'Text'),'Deactivate')
                app.deactivateControl(2);
                set(app.deactivateButton_2, 'Enable', 1)
                set(app.deactivateButton_2, 'Text', 'Reactivate')
            else
                app.reactivateControl(2);
                set(app.deactivateButton_2, 'Text', 'Deactivate')
            end
        end
        
        function refresh_2(app)
            [Forwards_Old,Backwards_Old] = app.Controller.ControllerDevice{app.ControllerDeviceNumber}.ResetTotalNumberOfSteps(2);
            [Forwards_New,Backwards_New] = app.Controller.ControllerDevice{app.ControllerDeviceNumber}.GetTotalNumberOfSteps(2);
            set(app.ForwardsEditField_2, 'Value', Forwards_New);
            set(app.BackwardsEditField_2, 'Value', Backwards_New);
            set(app.TotalEditField_2, 'Value', Forwards_New - Backwards_New);
            set(app.CurrentPositionEditField_2, 'Value', app.Controller.ControllerDevice{app.ControllerDeviceNumber}.GetCurrentPosition(2));
        end
        
        %% Axis 3
        % Value changed function: DropDown_3
        function DropDown_3ValueChanged(app, event)
            value = app.DropDown_3.Value;
            switch value
                case 'Velocity'
                    set(app.EditField_3, 'Value', app.Controller.ControllerDevice{app.ControllerDeviceNumber}.GetVelocity(3));
                case 'Acceleration'
                    set(app.EditField_3, 'Value', app.Controller.ControllerDevice{app.ControllerDeviceNumber}.GetAcceleration(3));
                case 'Motor Type'
                    set(app.EditField_3, 'Value', app.Controller.ControllerDevice{app.ControllerDeviceNumber}.GetMotorType(3));
            end
        end
        
        % Value changed function: EditField
        function EditField_3ValueChanged(app, event)
            value = app.EditField_3.Value;
            switch app.DropDown_3.Value
                case 'Velocity'
                    app.Controller.ControllerDevice{app.ControllerDeviceNumber}.SetVelocity(3, value);
                    set(app.EditField_3, 'Value', value);
                case 'Acceleration'
                    app.Controller.ControllerDevice{app.ControllerDeviceNumber}.SetAcceleration(3, value);
                    set(app.EditField_3, 'Value', value);
                case 'Motor Type'
                    app.Controller.ControllerDevice{app.ControllerDeviceNumber}.SetMotorType(3, value);
                    set(app.EditField_3, 'Value', value);
            end
        end
        
        % Button pushed function: ZeroButton_3
        function ZeroButton_3Pushed(app, event)
            app.Controller.ControllerDevice{app.ControllerDeviceNumber}.SetHome(3, app.Controller.ControllerDevice{app.ControllerDeviceNumber}.GetCurrentPosition(3));
            set(app.CurrentPositionEditField_3, 'Value', app.Controller.ControllerDevice{app.ControllerDeviceNumber}.GetCurrentPosition(3)); 
        end
        
        function NofstepsEditField_3ValueChanged(app, event)
            value = app.NofstepsEditField_3.Value;
            set(app.NofstepsEditField_3, 'Value', value);
        end
        
        % Button pushed function: GoButton_3
        function GoButton_5Pushed(app, event)
           app.deactivateControl(1);
           app.deactivateControl(2);
           app.deactivateControl(4);
           set(app.MotionStatusLamp_3, 'Color', 'green');
           error = app.Controller.ControllerDevice{app.ControllerDeviceNumber}.MoveRelative(3,app.NofstepsEditField_3.Value);
           if strcmp(get(app.deactivateButton_1,'Text'),'Deactivate')
               app.reactivateControl(1);
           else
               set(app.deactivateButton_1, 'Enable', 1)
           end
           if strcmp(get(app.deactivateButton_2,'Text'),'Deactivate')
               app.reactivateControl(2);
           else
               set(app.deactivateButton_2, 'Enable', 1)
           end
           if strcmp(get(app.deactivateButton_4,'Text'),'Deactivate')
               app.reactivateControl(4);
           else
                set(app.deactivateButton_4, 'Enable', 1)
           end
           if error.Code ~= 308
               set(app.ConnectionStatusLamp_3, 'Color', 'green');
           else
               set(app.ConnectionStatusLamp_3, 'Color', 'red');
               set(app.MotionStatusLamp_3, 'Color', [0.96,0.96,0.96]);
           end
           set(app.MotionStatusLamp_3, 'Color', [0.96,0.96,0.96]);
           app.updateNumbers_3;
           app.MoveHistory(end+1)= struct('Timestamps', char(datetime('now')), 'Moves', ['3R+' num2str(app.NofstepsEditField_3.Value)]);  
        end
        
        % Button pushed function: GoButton_4
        function GoButton_6Pushed(app, event)
            app.deactivateControl(1);
            app.deactivateControl(2);
            app.deactivateControl(4);
            set(app.MotionStatusLamp_3, 'Color', 'green');
            error = app.Controller.ControllerDevice{app.ControllerDeviceNumber}.MoveRelative(3,app.NofstepsEditField_3.Value*(-1));
            if strcmp(get(app.deactivateButton_1,'Text'),'Deactivate')
               app.reactivateControl(1);
            else
               set(app.deactivateButton_1, 'Enable', 1)
            end
            if strcmp(get(app.deactivateButton_2,'Text'),'Deactivate')
               app.reactivateControl(2);
            else
               set(app.deactivateButton_2, 'Enable', 1)
            end
            if strcmp(get(app.deactivateButton_4,'Text'),'Deactivate')
               app.reactivateControl(4);
            else
               set(app.deactivateButton_4, 'Enable', 1)
            end
            if error.Code ~= 308
                set(app.ConnectionStatusLamp_3, 'Color', 'green');
            else
                set(app.ConnectionStatusLamp_3, 'Color', 'red');
                set(app.MotionStatusLamp_3, 'Color', [0.96,0.96,0.96]);
            end
            set(app.MotionStatusLamp_3, 'Color', [0.96,0.96,0.96]);
            app.updateNumbers_3;
            app.MoveHistory(end+1)= struct('Timestamps', char(datetime('now')), 'Moves', ['3R-' num2str(app.NofstepsEditField_3.Value)]);  
        end
        
        function updateNumbers_3(app)
            [Forwards,Backwards] = app.Controller.ControllerDevice{app.ControllerDeviceNumber}.GetTotalNumberOfSteps(3);     
            set(app.ForwardsEditField_3, 'Value', Forwards);
            set(app.BackwardsEditField_3, 'Value', Backwards);
            set(app.TotalEditField_3, 'Value', Forwards - Backwards);
            set(app.CurrentPositionEditField_3, 'Value', app.Controller.ControllerDevice{app.ControllerDeviceNumber}.GetCurrentPosition(3)); 
        end
        
        % Button pushed function: ResetButton_3
        function ResetButton_3Pushed(app, event)
           app.refresh_3; 
        end
        
        function MaxstepsEditField_3ValueChanged(app, event)
            value = app.MaxstepsEditField_3.Value;
            app.Controller.ControllerDevice{app.ControllerDeviceNumber}.SetMaxNumberOfSteps(3, value);
            app.MaxNumberOfSteps = app.Controller.ControllerDevice{app.ControllerDeviceNumber}.MaxNumberOfSteps.UserDefined;
            set(app.MaxstepsEditField_3, 'Value', app.MaxNumberOfSteps(3));
        end
        
        % Value changed function: IgnoreCheckBox_3
        function IgnoreCheckBox_3ValueChanged(app, event)
            value = app.IgnoreCheckBox_3.Value;
            if value == 1
                app.Controller.ControllerDevice{app.ControllerDeviceNumber}.IgnoreMaxNumberOfSteps(3) = 1;
            else
                app.Controller.ControllerDevice{app.ControllerDeviceNumber}.IgnoreMaxNumberOfSteps(3) = 0;
            end
        end
        
        function deactivateButton_3Pushed(app, event)
            if strcmp(get(app.deactivateButton_3,'Text'),'Activate')
                app.reactivateControl(3);
                set(app.deactivateButton_3, 'Text', 'Deactivate')
            elseif strcmp(get(app.deactivateButton_3,'Text'),'Deactivate')
                app.deactivateControl(3);
                set(app.deactivateButton_3, 'Enable', 1)
                set(app.deactivateButton_3, 'Text', 'Reactivate')
            else
                app.reactivateControl(3);
                set(app.deactivateButton_3, 'Text', 'Deactivate')
            end
        end
        
        function refresh_3(app)
            [Forwards_Old,Backwards_Old] = app.Controller.ControllerDevice{app.ControllerDeviceNumber}.ResetTotalNumberOfSteps(3);
            [Forwards_New,Backwards_New] = app.Controller.ControllerDevice{app.ControllerDeviceNumber}.GetTotalNumberOfSteps(3);
            set(app.ForwardsEditField_3, 'Value', Forwards_New);
            set(app.BackwardsEditField_3, 'Value', Backwards_New);
            set(app.TotalEditField_3, 'Value', Forwards_New - Backwards_New);
            set(app.CurrentPositionEditField_3, 'Value', app.Controller.ControllerDevice{app.ControllerDeviceNumber}.GetCurrentPosition(3));
        end
            
        %% Axis 4
        % Value changed function: DropDown_4
        function DropDown_4ValueChanged(app, event)
            value = app.DropDown_4.Value;
            switch value
                case 'Velocity'
                    set(app.EditField_4, 'Value', app.Controller.ControllerDevice{app.ControllerDeviceNumber}.GetVelocity(4));
                case 'Acceleration'
                    set(app.EditField_4, 'Value', app.Controller.ControllerDevice{app.ControllerDeviceNumber}.GetAcceleration(4));
                case 'Motor Type'
                    set(app.EditField_4, 'Value', app.Controller.ControllerDevice{app.ControllerDeviceNumber}.GetMotorType(4));
            end
        end
        
        % Value changed function: EditField
        function EditField_4ValueChanged(app, event)
            value = app.EditField_4.Value;
            switch app.DropDown_4.Value
                case 'Velocity'
                    app.Controller.ControllerDevice{app.ControllerDeviceNumber}.SetVelocity(4, value);
                    set(app.EditField_4, 'Value', value);
                case 'Acceleration'
                    app.Controller.ControllerDevice{app.ControllerDeviceNumber}.SetAcceleration(4, value);
                    set(app.EditField_4, 'Value', value);
                case 'Motor Type'
                    app.Controller.ControllerDevice{app.ControllerDeviceNumber}.SetMotorType(4, value);
                    set(app.EditField_4, 'Value', value);
            end
        end
        
        % Button pushed function: ZeroButton_4
        function ZeroButton_4Pushed(app, event)
            app.Controller.ControllerDevice{app.ControllerDeviceNumber}.SetHome(4, app.Controller.ControllerDevice{app.ControllerDeviceNumber}.GetCurrentPosition(4));
            set(app.CurrentPositionEditField_4, 'Value', app.Controller.ControllerDevice{app.ControllerDeviceNumber}.GetCurrentPosition(4)); 
        end
        
        function NofstepsEditField_4ValueChanged(app, event)
            value = app.NofstepsEditField_4.Value;
            set(app.NofstepsEditField_4, 'Value', value);
        end
        
        % Button pushed function: GoButton_4
        function GoButton_7Pushed(app, event)
           app.deactivateControl(1);
           app.deactivateControl(2);
           app.deactivateControl(3); 
           set(app.MotionStatusLamp_4, 'Color', 'green');
           error = app.Controller.ControllerDevice{app.ControllerDeviceNumber}.MoveRelative(4,app.NofstepsEditField_4.Value);
           if strcmp(get(app.deactivateButton_1,'Text'),'Deactivate') 
                app.reactivateControl(1);
           else
               set(app.deactivateButton_1, 'Enable', 1)
           end
           if strcmp(get(app.deactivateButton_2,'Text'),'Deactivate')
               app.reactivateControl(2);
           else
               set(app.deactivateButton_2, 'Enable', 1)
           end
           if strcmp(get(app.deactivateButton_3,'Text'),'Deactivate')
               app.reactivateControl(3);
           else
               set(app.deactivateButton_3, 'Enable', 1)
           end
           if error.Code ~= 408
               set(app.ConnectionStatusLamp_4, 'Color', 'green');
           else
               set(app.ConnectionStatusLamp_4, 'Color', 'red');
               set(app.MotionStatusLamp_4, 'Color', [0.96,0.96,0.96]);
           end
           set(app.MotionStatusLamp_4, 'Color', [0.96,0.96,0.96]);
           app.updateNumbers_4;
           app.MoveHistory(end+1)= struct('Timestamps', char(datetime('now')), 'Moves', ['4R+' num2str(app.NofstepsEditField_4.Value)]);  
        end
        
        % Button pushed function: GoButton_4
        function GoButton_8Pushed(app, event)
            app.deactivateControl(1);
            app.deactivateControl(2);
            app.deactivateControl(3);
            set(app.MotionStatusLamp_4, 'Color', 'green');
            error = app.Controller.ControllerDevice{app.ControllerDeviceNumber}.MoveRelative(4,app.NofstepsEditField_4.Value*(-1));
            if strcmp(get(app.deactivateButton_1,'Text'),'Deactivate') 
                app.reactivateControl(1);
            else
                set(app.deactivateButton_1, 'Enable', 1)
            end
            if strcmp(get(app.deactivateButton_2,'Text'),'Deactivate')
                app.reactivateControl(2);
            else
                set(app.deactivateButton_2, 'Enable', 1)
            end
            if strcmp(get(app.deactivateButton_3,'Text'),'Deactivate')
                app.reactivateControl(3);
            else
                set(app.deactivateButton_3, 'Enable', 1)
            end
            if error.Code ~= 408
                set(app.ConnectionStatusLamp_4, 'Color', 'green');
            else
                set(app.ConnectionStatusLamp_4, 'Color', 'red');
                set(app.MotionStatusLamp_4, 'Color', [0.96,0.96,0.96]);
            end
            set(app.MotionStatusLamp_4, 'Color', [0.96,0.96,0.96]);
            app.updateNumbers_4;
            app.MoveHistory(end+1)= struct('Timestamps', char(datetime('now')), 'Moves', ['4R-' num2str(app.NofstepsEditField_4.Value)]);  
        end
        
        function updateNumbers_4(app)
            [Forwards,Backwards] = app.Controller.ControllerDevice{app.ControllerDeviceNumber}.GetTotalNumberOfSteps(4);     
            set(app.ForwardsEditField_4, 'Value', Forwards);
            set(app.BackwardsEditField_4, 'Value', Backwards);
            set(app.TotalEditField_4, 'Value', Forwards - Backwards);
            set(app.CurrentPositionEditField_4, 'Value', app.Controller.ControllerDevice{app.ControllerDeviceNumber}.GetCurrentPosition(4)); 
        end
        
        % Button pushed function: ResetButton_4
        function ResetButton_4Pushed(app, event)
            app.refresh_4;
        end
        
        function MaxstepsEditField_4ValueChanged(app, event)
            value = app.MaxstepsEditField_4.Value;
            app.Controller.ControllerDevice{app.ControllerDeviceNumber}.SetMaxNumberOfSteps(4, value);
            app.MaxNumberOfSteps = app.Controller.ControllerDevice{app.ControllerDeviceNumber}.MaxNumberOfSteps.UserDefined;
            set(app.MaxstepsEditField_4, 'Value', app.MaxNumberOfSteps(4));
        end
        
        % Value changed function: IgnoreCheckBox_4
        function IgnoreCheckBox_4ValueChanged(app, event)
            value = app.IgnoreCheckBox_4.Value;
            if value == 1
                app.Controller.ControllerDevice{app.ControllerDeviceNumber}.IgnoreMaxNumberOfSteps(4) = 1;
            else
                app.Controller.ControllerDevice{app.ControllerDeviceNumber}.IgnoreMaxNumberOfSteps(4) = 0;
            end
        end
        
        function deactivateButton_4Pushed(app, event)
            if strcmp(get(app.deactivateButton_4,'Text'),'Activate')
                app.reactivateControl(4);
                set(app.deactivateButton_4, 'Text', 'Deactivate')
            elseif strcmp(get(app.deactivateButton_4,'Text'),'Deactivate')
                app.deactivateControl(4);
                set(app.deactivateButton_4, 'Enable', 1)
                set(app.deactivateButton_4, 'Text', 'Reactivate')
            else
                app.reactivateControl(4);
                set(app.deactivateButton_4, 'Text', 'Deactivate')
            end
        end
        
        function refresh_4(app)
            [Forwards_Old,Backwards_Old] = app.Controller.ControllerDevice{app.ControllerDeviceNumber}.ResetTotalNumberOfSteps(4);
            [Forwards_New,Backwards_New] = app.Controller.ControllerDevice{app.ControllerDeviceNumber}.GetTotalNumberOfSteps(4);
            set(app.ForwardsEditField_4, 'Value', Forwards_New);
            set(app.BackwardsEditField_4, 'Value', Backwards_New);
            set(app.TotalEditField_4, 'Value', Forwards_New - Backwards_New);
            set(app.CurrentPositionEditField_4, 'Value', app.Controller.ControllerDevice{app.ControllerDeviceNumber}.GetCurrentPosition(4));
        end
        
    end
    
    % Component initialization
    methods (Access = private)
        
        function createAxis1(app, Alias)
            % Create Axis1Panel
            app.Axis1Panel = uipanel(app.ControllerDeviceTab);
            app.Axis1Panel.Title = ['Channel 1: ' Alias];
            app.Axis1Panel.Position = [35 380 323 293];
            
            % Create DropDown_1
            app.DropDown_1 = uidropdown(app.Axis1Panel);
            app.DropDown_1.Items = {'Velocity', 'Acceleration', 'Motor Type'};
            app.DropDown_1.ValueChangedFcn = createCallbackFcn(app, @DropDown_1ValueChanged, true);
            app.DropDown_1.Position = [11 242 100 22];
            app.DropDown_1.Value = 'Velocity';

            % Create EditField_1
            app.EditField_1 = uieditfield(app.Axis1Panel, 'numeric');
            app.EditField_1.HorizontalAlignment = 'center';
            app.EditField_1.Position = [121 242 69 22];
            set(app.EditField_1, 'Value', app.Controller.ControllerDevice{app.ControllerDeviceNumber}.GetVelocity(1));
            app.EditField_1.ValueChangedFcn = createCallbackFcn(app, @EditField_1ValueChanged, true);
            
            % Create SetButton_1
            app.SetButton_1 = uibutton(app.Axis1Panel, 'push');
            app.SetButton_1.ButtonPushedFcn = createCallbackFcn(app, @EditField_1ValueChanged, true);
            app.SetButton_1.Position = [203 242 99 22];
            app.SetButton_1.Text = 'Set';   

            % Create CurrentPositionEditField_1Label
            app.CurrentPositionEditField_1Label = uilabel(app.Axis1Panel);
            app.CurrentPositionEditField_1Label.HorizontalAlignment = 'right';
            app.CurrentPositionEditField_1Label.Position = [14 210 92 22];
            app.CurrentPositionEditField_1Label.Text = 'Current Position';

            % Create CurrentPositionEditField_1
            app.CurrentPositionEditField_1 = uieditfield(app.Axis1Panel, 'numeric');
            app.CurrentPositionEditField_1.HorizontalAlignment = 'center';
            app.CurrentPositionEditField_1.Position = [121 210 69 22];
            set(app.CurrentPositionEditField_1, 'Value', app.Controller.ControllerDevice{app.ControllerDeviceNumber}.GetCurrentPosition(1)); 
            
            % Create ZeroButton_1
            app.ZeroButton_1 = uibutton(app.Axis1Panel, 'push');
            app.ZeroButton_1.ButtonPushedFcn = createCallbackFcn(app, @ZeroButton_1Pushed, true);
            app.ZeroButton_1.Position = [203 210 99 22];
            app.ZeroButton_1.Text = 'Zero';
            
             % Create MovePanel_1
            app.MovePanel_1 = uipanel(app.Axis1Panel);
            app.MovePanel_1.Title = 'Move';
            app.MovePanel_1.Position = [18 43 285 158];
            
            % Create NofstepsEditField_1Label
            app.NofstepsEditField_1Label = uilabel(app.MovePanel_1);
            app.NofstepsEditField_1Label.HorizontalAlignment = 'right';
            app.NofstepsEditField_1Label.Position = [12 94 58 22];
            app.NofstepsEditField_1Label.Text = '# of steps';

            % Create NofstepsEditField_1
            app.NofstepsEditField_1 = uieditfield(app.MovePanel_1, 'numeric');
            app.NofstepsEditField_1.ValueChangedFcn = createCallbackFcn(app, @NofstepsEditField_1ValueChanged, true);
            app.NofstepsEditField_1.HorizontalAlignment = 'center';
            app.NofstepsEditField_1.Position = [85 94 58 22];

            % Create ForwardsEditField_1
            app.ForwardsEditField_1 = uieditfield(app.MovePanel_1, 'numeric');
            app.ForwardsEditField_1.HorizontalAlignment = 'center';
            app.ForwardsEditField_1.Position = [149 65 58 22];
            [Forwards,Backwards] = app.Controller.ControllerDevice{1}.GetTotalNumberOfSteps(1);     
            set(app.ForwardsEditField_1, 'Value', Forwards);

            % Create BackwardsEditField_1
            app.BackwardsEditField_1 = uieditfield(app.MovePanel_1, 'numeric');
            app.BackwardsEditField_1.HorizontalAlignment = 'center';
            app.BackwardsEditField_1.Position = [217 65 58 22];
            set(app.BackwardsEditField_1, 'Value', Backwards);
            
            % Create TotalEditField_1Label
            app.TotalEditField_1Label = uilabel(app.MovePanel_1);
            app.TotalEditField_1Label.HorizontalAlignment = 'right';
            app.TotalEditField_1Label.Position = [39 65 31 22];
            app.TotalEditField_1Label.Text = 'Total';

            % Create TotalEditField_1
            app.TotalEditField_1 = uieditfield(app.MovePanel_1, 'numeric');
            app.TotalEditField_1.HorizontalAlignment = 'center';
            app.TotalEditField_1.Position = [85 65 58 22];
            set(app.TotalEditField_1, 'Value', Forwards - Backwards);

            % Create GoButton_1
            app.GoButton_1 = uibutton(app.MovePanel_1, 'push');
            app.GoButton_1.ButtonPushedFcn = createCallbackFcn(app, @GoButton_1Pushed, true);
            app.GoButton_1.Position = [149 93 58 25];
            app.GoButton_1.Text = 'Go';
            
            %Create GoButton_1Label
            app.GoButton_1Label = uilabel(app.MovePanel_1);
            app.GoButton_1Label.HorizontalAlignment = 'right';
            app.GoButton_1Label.Position = [144 115 58 25];
            app.GoButton_1Label.Text = 'Forwards';
            app.GoButton_1Label.FontSize = 11;
            
            % Create GoButton_2
            app.GoButton_2 = uibutton(app.MovePanel_1, 'push');
            app.GoButton_2.ButtonPushedFcn = createCallbackFcn(app, @GoButton_2Pushed, true);
            app.GoButton_2.Position = [217 93 58 25];
            app.GoButton_2.Text = 'Go';
            
            %Create GoButton_2Label
            app.GoButton_2Label = uilabel(app.MovePanel_1);
            app.GoButton_2Label.HorizontalAlignment = 'right';
            app.GoButton_2Label.Position = [214 115 58 25];
            app.GoButton_2Label.Text = 'Backwards';
            app.GoButton_2Label.FontSize = 11;

            % Create MaxstepsEditField_1Label
            app.MaxstepsEditField_1Label = uilabel(app.MovePanel_1);
            app.MaxstepsEditField_1Label.HorizontalAlignment = 'right';
            app.MaxstepsEditField_1Label.Position = [1 36 70 22];
            app.MaxstepsEditField_1Label.Text = 'Max # steps';

            % Create MaxstepsEditField_1
            app.MaxstepsEditField_1 = uieditfield(app.MovePanel_1, 'numeric');
            app.MaxstepsEditField_1.ValueChangedFcn = createCallbackFcn(app, @MaxstepsEditField_1ValueChanged, true);
            app.MaxstepsEditField_1.HorizontalAlignment = 'center';
            app.MaxstepsEditField_1.Position = [86 36 58 22];
            set(app.MaxstepsEditField_1, 'Value', app.MaxNumberOfSteps(1));

            % Create IgnoreCheckBox_1
            app.IgnoreCheckBox_1 = uicheckbox(app.MovePanel_1);
            app.IgnoreCheckBox_1.ValueChangedFcn = createCallbackFcn(app, @IgnoreCheckBox_1ValueChanged, true);
            app.IgnoreCheckBox_1.Text = 'Ignore';
            app.IgnoreCheckBox_1.Position = [151 36 56 22];
            if app.Controller.ControllerDevice{app.ControllerDeviceNumber}.IgnoreMaxNumberOfSteps(1)
                set(app.IgnoreCheckBox_1, 'Value', 1)
            else
                set(app.IgnoreCheckBox_1, 'Value', 0)
            end
            
            % Create deactivateButton_1
            app.deactivateButton_1 = uibutton(app.MovePanel_1, 'push');
            app.deactivateButton_1.ButtonPushedFcn = createCallbackFcn(app, @deactivateButton_1Pushed, true);
            app.deactivateButton_1.Position = [10 8 74 23];
            app.deactivateButton_1.Text = 'Activate';
            
            % Create ResetButton_1
            app.ResetButton_1 = uibutton(app.MovePanel_1, 'push');
            app.ResetButton_1.ButtonPushedFcn = createCallbackFcn(app, @ResetButton_1Pushed, true);
            app.ResetButton_1.Position = [201 8 74 23];
            app.ResetButton_1.Text = 'Reset #';

            % Create MotionStatusLamp_1Label
            app.MotionStatusLamp_1Label = uilabel(app.Axis1Panel);
            app.MotionStatusLamp_1Label.HorizontalAlignment = 'right';
            app.MotionStatusLamp_1Label.Position = [176 11 79 22];
            app.MotionStatusLamp_1Label.Text = 'Motion Status';

            % Create MotionStatusLamp
            app.MotionStatusLamp_1 = uilamp(app.Axis1Panel);
            app.MotionStatusLamp_1.Position = [270 11 20 20];
            set(app.MotionStatusLamp_1, 'Color', [0.96,0.96,0.96]);

            % Create ConnectionStatusLamp_1Label
            app.ConnectionStatusLamp_1Label = uilabel(app.Axis1Panel);
            app.ConnectionStatusLamp_1Label.HorizontalAlignment = 'right';
            app.ConnectionStatusLamp_1Label.Position = [25 11 104 22];
            app.ConnectionStatusLamp_1Label.Text = 'Connection Status';

            % Create ConnectionStatusLamp_1
            app.ConnectionStatusLamp_1 = uilamp(app.Axis1Panel);
            app.ConnectionStatusLamp_1.Position = [144 11 20 20];
            set(app.ConnectionStatusLamp_1, 'Color', [0.96,0.96,0.96]);
        end
        
        function createAxis2(app, Alias)
            % Create Axis2Panel
            app.Axis2Panel = uipanel(app.ControllerDeviceTab);
            app.Axis2Panel.Title = ['Channel 2: ' Alias];
            app.Axis2Panel.Position = [390 380 323 293];
            
            % Create DropDown_2
            app.DropDown_2 = uidropdown(app.Axis2Panel);
            app.DropDown_2.Items = {'Velocity', 'Acceleration', 'Motor Type'};
            app.DropDown_2.ValueChangedFcn = createCallbackFcn(app, @DropDown_2ValueChanged, true);
            app.DropDown_2.Position = [11 242 100 22];
            app.DropDown_2.Value = 'Velocity';

            % Create EditField_2
            app.EditField_2 = uieditfield(app.Axis2Panel, 'numeric');
            app.EditField_2.HorizontalAlignment = 'center';
            app.EditField_2.Position = [121 242 69 22];
            set(app.EditField_2, 'Value', app.Controller.ControllerDevice{app.ControllerDeviceNumber}.GetVelocity(2));
            app.EditField_2.ValueChangedFcn = createCallbackFcn(app, @EditField_2ValueChanged, true);
            
            % Create SetButton_2
            app.SetButton_2 = uibutton(app.Axis2Panel, 'push');
            app.SetButton_2.ButtonPushedFcn = createCallbackFcn(app, @EditField_2ValueChanged, true);
            app.SetButton_2.Position = [203 242 99 22];
            app.SetButton_2.Text = 'Set';   

            % Create CurrentPositionEditField_2Label
            app.CurrentPositionEditField_2Label = uilabel(app.Axis2Panel);
            app.CurrentPositionEditField_2Label.HorizontalAlignment = 'right';
            app.CurrentPositionEditField_2Label.Position = [14 210 92 22];
            app.CurrentPositionEditField_2Label.Text = 'Current Position';

            % Create CurrentPositionEditField_2
            app.CurrentPositionEditField_2 = uieditfield(app.Axis2Panel, 'numeric');
            app.CurrentPositionEditField_2.HorizontalAlignment = 'center';
            app.CurrentPositionEditField_2.Position = [121 210 69 22];
            set(app.CurrentPositionEditField_2, 'Value', app.Controller.ControllerDevice{app.ControllerDeviceNumber}.GetCurrentPosition(2)); 
            
            % Create ZeroButton_2
            app.ZeroButton_2 = uibutton(app.Axis2Panel, 'push');
            app.ZeroButton_2.ButtonPushedFcn = createCallbackFcn(app, @ZeroButton_2Pushed, true);
            app.ZeroButton_2.Position = [203 210 99 22];
            app.ZeroButton_2.Text = 'Zero';
            
             % Create MovePanel_2
            app.MovePanel_2 = uipanel(app.Axis2Panel);
            app.MovePanel_2.Title = 'Move';
            app.MovePanel_2.Position = [18 43 285 158];
            
            % Create NofstepsEditField_2Label
            app.NofstepsEditField_2Label = uilabel(app.MovePanel_2);
            app.NofstepsEditField_2Label.HorizontalAlignment = 'right';
            app.NofstepsEditField_2Label.Position = [12 94 58 22];
            app.NofstepsEditField_2Label.Text = '# of steps';

            % Create NofstepsEditField_2
            app.NofstepsEditField_2 = uieditfield(app.MovePanel_2, 'numeric');
            app.NofstepsEditField_2.ValueChangedFcn = createCallbackFcn(app, @NofstepsEditField_2ValueChanged, true);
            app.NofstepsEditField_2.HorizontalAlignment = 'center';
            app.NofstepsEditField_2.Position = [85 94 58 22];

            % Create ForwardsEditField_2
            app.ForwardsEditField_2 = uieditfield(app.MovePanel_2, 'numeric');
            app.ForwardsEditField_2.HorizontalAlignment = 'center';
            app.ForwardsEditField_2.Position = [149 65 58 22];
            [Forwards,Backwards] = app.Controller.ControllerDevice{1}.GetTotalNumberOfSteps(2);     
            set(app.ForwardsEditField_2, 'Value', Forwards);

            % Create BackwardsEditField_2
            app.BackwardsEditField_2 = uieditfield(app.MovePanel_2, 'numeric');
            app.BackwardsEditField_2.HorizontalAlignment = 'center';
            app.BackwardsEditField_2.Position = [217 65 58 22];
            set(app.BackwardsEditField_2, 'Value', Backwards);
            
            % Create TotalEditField_2Label
            app.TotalEditField_2Label = uilabel(app.MovePanel_2);
            app.TotalEditField_2Label.HorizontalAlignment = 'right';
            app.TotalEditField_2Label.Position = [39 65 31 22];
            app.TotalEditField_2Label.Text = 'Total';

            % Create TotalEditField_2
            app.TotalEditField_2 = uieditfield(app.MovePanel_2, 'numeric');
            app.TotalEditField_2.HorizontalAlignment = 'center';
            app.TotalEditField_2.Position = [85 65 58 22];
            set(app.TotalEditField_2, 'Value', Forwards - Backwards);

            % Create GoButton_3
            app.GoButton_3 = uibutton(app.MovePanel_2, 'push');
            app.GoButton_3.ButtonPushedFcn = createCallbackFcn(app, @GoButton_3Pushed, true);
            app.GoButton_3.Position = [149 93 58 25];
            app.GoButton_3.Text = 'Go';
            
            %Create GoButton_3Label
            app.GoButton_3Label = uilabel(app.MovePanel_2);
            app.GoButton_3Label.HorizontalAlignment = 'right';
            app.GoButton_3Label.Position = [144 115 58 25];
            app.GoButton_3Label.Text = 'Forwards';
            app.GoButton_3Label.FontSize = 11;
            
            % Create GoButton_4
            app.GoButton_4 = uibutton(app.MovePanel_2, 'push');
            app.GoButton_4.ButtonPushedFcn = createCallbackFcn(app, @GoButton_4Pushed, true);
            app.GoButton_4.Position = [217 93 58 25];
            app.GoButton_4.Text = 'Go';
            
            %Create GoButton_4Label
            app.GoButton_4Label = uilabel(app.MovePanel_2);
            app.GoButton_4Label.HorizontalAlignment = 'right';
            app.GoButton_4Label.Position = [214 115 58 25];
            app.GoButton_4Label.Text = 'Backwards';
            app.GoButton_4Label.FontSize = 11;

            % Create MaxstepsEditField_2Label
            app.MaxstepsEditField_2Label = uilabel(app.MovePanel_2);
            app.MaxstepsEditField_2Label.HorizontalAlignment = 'right';
            app.MaxstepsEditField_2Label.Position = [1 36 70 22];
            app.MaxstepsEditField_2Label.Text = 'Max # steps';

            % Create MaxstepsEditField_2
            app.MaxstepsEditField_2 = uieditfield(app.MovePanel_2, 'numeric');
            app.MaxstepsEditField_2.ValueChangedFcn = createCallbackFcn(app, @MaxstepsEditField_2ValueChanged, true);
            app.MaxstepsEditField_2.HorizontalAlignment = 'center';
            app.MaxstepsEditField_2.Position = [86 36 58 22];
            set(app.MaxstepsEditField_2, 'Value', app.MaxNumberOfSteps(2));

            % Create IgnoreCheckBox_2
            app.IgnoreCheckBox_2 = uicheckbox(app.MovePanel_2);
            app.IgnoreCheckBox_2.ValueChangedFcn = createCallbackFcn(app, @IgnoreCheckBox_2ValueChanged, true);
            app.IgnoreCheckBox_2.Text = 'Ignore';
            app.IgnoreCheckBox_2.Position = [151 36 56 22];
            if app.Controller.ControllerDevice{app.ControllerDeviceNumber}.IgnoreMaxNumberOfSteps(2)
                set(app.IgnoreCheckBox_2, 'Value', 1)
            else
                set(app.IgnoreCheckBox_2, 'Value', 0)
            end
            
            % Create deactivateButton_2
            app.deactivateButton_2 = uibutton(app.MovePanel_2, 'push');
            app.deactivateButton_2.ButtonPushedFcn = createCallbackFcn(app, @deactivateButton_2Pushed, true);
            app.deactivateButton_2.Position = [10 8 74 23];
            app.deactivateButton_2.Text = 'Activate';
            
            % Create ResetButton_2
            app.ResetButton_2 = uibutton(app.MovePanel_2, 'push');
            app.ResetButton_2.ButtonPushedFcn = createCallbackFcn(app, @ResetButton_2Pushed, true);
            app.ResetButton_2.Position = [201 8 74 23];
            app.ResetButton_2.Text = 'Reset #';

            % Create MotionStatusLamp_2Label
            app.MotionStatusLamp_2Label = uilabel(app.Axis2Panel);
            app.MotionStatusLamp_2Label.HorizontalAlignment = 'right';
            app.MotionStatusLamp_2Label.Position = [176 11 79 22];
            app.MotionStatusLamp_2Label.Text = 'Motion Status';

            % Create MotionStatusLamp
            app.MotionStatusLamp_2 = uilamp(app.Axis2Panel);
            app.MotionStatusLamp_2.Position = [270 11 20 20];
            set(app.MotionStatusLamp_2, 'Color', [0.96,0.96,0.96]);

            % Create ConnectionStatusLamp_2Label
            app.ConnectionStatusLamp_2Label = uilabel(app.Axis2Panel);
            app.ConnectionStatusLamp_2Label.HorizontalAlignment = 'right';
            app.ConnectionStatusLamp_2Label.Position = [25 11 104 22];
            app.ConnectionStatusLamp_2Label.Text = 'Connection Status';

            % Create ConnectionStatusLamp_2
            app.ConnectionStatusLamp_2 = uilamp(app.Axis2Panel);
            app.ConnectionStatusLamp_2.Position = [144 11 20 20];
            set(app.ConnectionStatusLamp_2, 'Color', [0.96,0.96,0.96]);
        end
        
        function createAxis3(app, Alias)
            % Create Axis3Panel
            app.Axis3Panel = uipanel(app.ControllerDeviceTab);
            app.Axis3Panel.Title = ['Channel 3: ' Alias];
            app.Axis3Panel.Position = [745 380 323 293];
            
            % Create DropDown_3
            app.DropDown_3 = uidropdown(app.Axis3Panel);
            app.DropDown_3.Items = {'Velocity', 'Acceleration', 'Motor Type'};
            app.DropDown_3.ValueChangedFcn = createCallbackFcn(app, @DropDown_3ValueChanged, true);
            app.DropDown_3.Position = [11 242 100 22];
            app.DropDown_3.Value = 'Velocity';

            % Create EditField_3
            app.EditField_3 = uieditfield(app.Axis3Panel, 'numeric');
            app.EditField_3.HorizontalAlignment = 'center';
            app.EditField_3.Position = [121 242 69 22];
            set(app.EditField_3, 'Value', app.Controller.ControllerDevice{app.ControllerDeviceNumber}.GetVelocity(3));
            app.EditField_3.ValueChangedFcn = createCallbackFcn(app, @EditField_3ValueChanged, true);
            
            % Create SetButton_3
            app.SetButton_3 = uibutton(app.Axis3Panel, 'push');
            app.SetButton_3.ButtonPushedFcn = createCallbackFcn(app, @EditField_3ValueChanged, true);
            app.SetButton_3.Position = [203 242 99 22];
            app.SetButton_3.Text = 'Set';   

            % Create CurrentPositionEditField_3Label
            app.CurrentPositionEditField_3Label = uilabel(app.Axis3Panel);
            app.CurrentPositionEditField_3Label.HorizontalAlignment = 'right';
            app.CurrentPositionEditField_3Label.Position = [14 210 92 22];
            app.CurrentPositionEditField_3Label.Text = 'Current Position';

            % Create CurrentPositionEditField_3
            app.CurrentPositionEditField_3 = uieditfield(app.Axis3Panel, 'numeric');
            app.CurrentPositionEditField_3.HorizontalAlignment = 'center';
            app.CurrentPositionEditField_3.Position = [121 210 69 22];
            set(app.CurrentPositionEditField_3, 'Value', app.Controller.ControllerDevice{app.ControllerDeviceNumber}.GetCurrentPosition(3)); 
            
            % Create ZeroButton_3
            app.ZeroButton_3 = uibutton(app.Axis3Panel, 'push');
            app.ZeroButton_3.ButtonPushedFcn = createCallbackFcn(app, @ZeroButton_3Pushed, true);
            app.ZeroButton_3.Position = [203 210 99 22];
            app.ZeroButton_3.Text = 'Zero';
            
             % Create MovePanel_3
            app.MovePanel_3 = uipanel(app.Axis3Panel);
            app.MovePanel_3.Title = 'Move';
            app.MovePanel_3.Position = [18 43 285 158];
            
            % Create deactivateButton_3
            app.deactivateButton_3 = uibutton(app.MovePanel_3, 'push');
            app.deactivateButton_3.ButtonPushedFcn = createCallbackFcn(app, @deactivateButton_3Pushed, true);
            app.deactivateButton_3.Position = [10 8 74 23];
            app.deactivateButton_3.Text = 'Activate';
            
            % Create ResetButton_3
            app.ResetButton_3 = uibutton(app.MovePanel_3, 'push');
            app.ResetButton_3.ButtonPushedFcn = createCallbackFcn(app, @ResetButton_3Pushed, true);
            app.ResetButton_3.Position = [201 8 74 23];
            app.ResetButton_3.Text = 'Reset #';
            
            % Create NofstepsEditField_3Label
            app.NofstepsEditField_3Label = uilabel(app.MovePanel_3);
            app.NofstepsEditField_3Label.HorizontalAlignment = 'right';
            app.NofstepsEditField_3Label.Position = [12 94 58 22];
            app.NofstepsEditField_3Label.Text = '# of steps';

            % Create NofstepsEditField_3
            app.NofstepsEditField_3 = uieditfield(app.MovePanel_3, 'numeric');
            app.NofstepsEditField_3.ValueChangedFcn = createCallbackFcn(app, @NofstepsEditField_3ValueChanged, true);
            app.NofstepsEditField_3.HorizontalAlignment = 'center';
            app.NofstepsEditField_3.Position = [85 94 58 22];

            % Create ForwardsEditField_3
            app.ForwardsEditField_3 = uieditfield(app.MovePanel_3, 'numeric');
            app.ForwardsEditField_3.HorizontalAlignment = 'center';
            app.ForwardsEditField_3.Position = [149 65 58 22];
            [Forwards,Backwards] = app.Controller.ControllerDevice{1}.GetTotalNumberOfSteps(3);     
            set(app.ForwardsEditField_3, 'Value', Forwards);

            % Create BackwardsEditField_3
            app.BackwardsEditField_3 = uieditfield(app.MovePanel_3, 'numeric');
            app.BackwardsEditField_3.HorizontalAlignment = 'center';
            app.BackwardsEditField_3.Position = [217 65 58 22];
            set(app.BackwardsEditField_3, 'Value', Backwards);
            
            % Create TotalEditField_3Label
            app.TotalEditField_3Label = uilabel(app.MovePanel_3);
            app.TotalEditField_3Label.HorizontalAlignment = 'right';
            app.TotalEditField_3Label.Position = [39 65 31 22];
            app.TotalEditField_3Label.Text = 'Total';

            % Create TotalEditField_3
            app.TotalEditField_3 = uieditfield(app.MovePanel_3, 'numeric');
            app.TotalEditField_3.HorizontalAlignment = 'center';
            app.TotalEditField_3.Position = [85 65 58 22];
            set(app.TotalEditField_3, 'Value', Forwards - Backwards);

            % Create GoButton_5
            app.GoButton_5 = uibutton(app.MovePanel_3, 'push');
            app.GoButton_5.ButtonPushedFcn = createCallbackFcn(app, @GoButton_5Pushed, true);
            app.GoButton_5.Position = [149 93 58 25];
            app.GoButton_5.Text = 'Go';
            
            %Create GoButton_5Label
            app.GoButton_5Label = uilabel(app.MovePanel_3);
            app.GoButton_5Label.HorizontalAlignment = 'right';
            app.GoButton_5Label.Position = [144 115 58 25];
            app.GoButton_5Label.Text = 'Forwards';
            app.GoButton_5Label.FontSize = 11;
            
            % Create GoButton_6
            app.GoButton_6 = uibutton(app.MovePanel_3, 'push');
            app.GoButton_6.ButtonPushedFcn = createCallbackFcn(app, @GoButton_6Pushed, true);
            app.GoButton_6.Position = [217 93 58 25];
            app.GoButton_6.Text = 'Go';
            
            %Create GoButton_6Label
            app.GoButton_6Label = uilabel(app.MovePanel_3);
            app.GoButton_6Label.HorizontalAlignment = 'right';
            app.GoButton_6Label.Position = [214 115 58 25];
            app.GoButton_6Label.Text = 'Backwards';
            app.GoButton_6Label.FontSize = 11;

            % Create MaxstepsEditField_3Label
            app.MaxstepsEditField_3Label = uilabel(app.MovePanel_3);
            app.MaxstepsEditField_3Label.HorizontalAlignment = 'right';
            app.MaxstepsEditField_3Label.Position = [1 36 70 22];
            app.MaxstepsEditField_3Label.Text = 'Max # steps';

            % Create MaxstepsEditField_3
            app.MaxstepsEditField_3 = uieditfield(app.MovePanel_3, 'numeric');
            app.MaxstepsEditField_3.ValueChangedFcn = createCallbackFcn(app, @MaxstepsEditField_3ValueChanged, true);
            app.MaxstepsEditField_3.HorizontalAlignment = 'center';
            app.MaxstepsEditField_3.Position = [86 36 58 22];
            set(app.MaxstepsEditField_3, 'Value', app.MaxNumberOfSteps(3));

            % Create IgnoreCheckBox_3
            app.IgnoreCheckBox_3 = uicheckbox(app.MovePanel_3);
            app.IgnoreCheckBox_3.ValueChangedFcn = createCallbackFcn(app, @IgnoreCheckBox_3ValueChanged, true);
            app.IgnoreCheckBox_3.Text = 'Ignore';
            app.IgnoreCheckBox_3.Position = [151 36 56 22];
            if app.Controller.ControllerDevice{app.ControllerDeviceNumber}.IgnoreMaxNumberOfSteps(3)
                set(app.IgnoreCheckBox_3, 'Value', 1)
            else
                set(app.IgnoreCheckBox_3, 'Value', 0)
            end

            % Create MotionStatusLamp_3Label
            app.MotionStatusLamp_3Label = uilabel(app.Axis3Panel);
            app.MotionStatusLamp_3Label.HorizontalAlignment = 'right';
            app.MotionStatusLamp_3Label.Position = [176 11 79 22];
            app.MotionStatusLamp_3Label.Text = 'Motion Status';

            % Create MotionStatusLamp
            app.MotionStatusLamp_3 = uilamp(app.Axis3Panel);
            app.MotionStatusLamp_3.Position = [270 11 20 20];
            set(app.MotionStatusLamp_3, 'Color', [0.96,0.96,0.96]);

            % Create ConnectionStatusLamp_3Label
            app.ConnectionStatusLamp_3Label = uilabel(app.Axis3Panel);
            app.ConnectionStatusLamp_3Label.HorizontalAlignment = 'right';
            app.ConnectionStatusLamp_3Label.Position = [25 11 104 22];
            app.ConnectionStatusLamp_3Label.Text = 'Connection Status';

            % Create ConnectionStatusLamp_3
            app.ConnectionStatusLamp_3 = uilamp(app.Axis3Panel);
            app.ConnectionStatusLamp_3.Position = [144 11 20 20];
            set(app.ConnectionStatusLamp_3, 'Color', [0.96,0.96,0.96]);
        end
        
        function createAxis4(app, Alias)
        
            % Create Axis4Panel
            app.Axis4Panel = uipanel(app.ControllerDeviceTab);
            app.Axis4Panel.Title = ['Channel 4: ' Alias];
            app.Axis4Panel.Position = [35 57 323 293];
            
            % Create DropDown_4
            app.DropDown_4 = uidropdown(app.Axis4Panel);
            app.DropDown_4.Items = {'Velocity', 'Acceleration', 'Motor Type'};
            app.DropDown_4.ValueChangedFcn = createCallbackFcn(app, @DropDown_4ValueChanged, true);
            app.DropDown_4.Position = [11 242 100 22];
            app.DropDown_4.Value = 'Velocity';

            % Create EditField_4
            app.EditField_4 = uieditfield(app.Axis4Panel, 'numeric');
            app.EditField_4.HorizontalAlignment = 'center';
            app.EditField_4.Position = [121 242 69 22];
            set(app.EditField_4, 'Value', app.Controller.ControllerDevice{app.ControllerDeviceNumber}.GetVelocity(4));
            app.EditField_4.ValueChangedFcn = createCallbackFcn(app, @EditField_4ValueChanged, true);
            
            % Create SetButton_4
            app.SetButton_4 = uibutton(app.Axis4Panel, 'push');
            app.SetButton_4.ButtonPushedFcn = createCallbackFcn(app, @EditField_4ValueChanged, true);
            app.SetButton_4.Position = [203 242 99 22];
            app.SetButton_4.Text = 'Set';   

            % Create CurrentPositionEditField_4Label
            app.CurrentPositionEditField_4Label = uilabel(app.Axis4Panel);
            app.CurrentPositionEditField_4Label.HorizontalAlignment = 'right';
            app.CurrentPositionEditField_4Label.Position = [14 210 92 22];
            app.CurrentPositionEditField_4Label.Text = 'Current Position';

            % Create CurrentPositionEditField_4
            app.CurrentPositionEditField_4 = uieditfield(app.Axis4Panel, 'numeric');
            app.CurrentPositionEditField_4.HorizontalAlignment = 'center';
            app.CurrentPositionEditField_4.Position = [121 210 69 22];
            set(app.CurrentPositionEditField_4, 'Value', app.Controller.ControllerDevice{app.ControllerDeviceNumber}.GetCurrentPosition(4)); 
            
            % Create ZeroButton_4
            app.ZeroButton_4 = uibutton(app.Axis4Panel, 'push');
            app.ZeroButton_4.ButtonPushedFcn = createCallbackFcn(app, @ZeroButton_4Pushed, true);
            app.ZeroButton_4.Position = [203 210 99 22];
            app.ZeroButton_4.Text = 'Zero';
            
             % Create MovePanel_4
            app.MovePanel_4 = uipanel(app.Axis4Panel);
            app.MovePanel_4.Title = 'Move';
            app.MovePanel_4.Position = [18 43 285 158];
            
            % Create NofstepsEditField_4Label
            app.NofstepsEditField_4Label = uilabel(app.MovePanel_4);
            app.NofstepsEditField_4Label.HorizontalAlignment = 'right';
            app.NofstepsEditField_4Label.Position = [12 94 58 22];
            app.NofstepsEditField_4Label.Text = '# of steps';

            % Create NofstepsEditField_4
            app.NofstepsEditField_4 = uieditfield(app.MovePanel_4, 'numeric');
            app.NofstepsEditField_4.ValueChangedFcn = createCallbackFcn(app, @NofstepsEditField_4ValueChanged, true);
            app.NofstepsEditField_4.HorizontalAlignment = 'center';
            app.NofstepsEditField_4.Position = [85 94 58 22];

            % Create ForwardsEditField_4
            app.ForwardsEditField_4 = uieditfield(app.MovePanel_4, 'numeric');
            app.ForwardsEditField_4.HorizontalAlignment = 'center';
            app.ForwardsEditField_4.Position = [149 65 58 22];
            [Forwards,Backwards] = app.Controller.ControllerDevice{1}.GetTotalNumberOfSteps(4);     
            set(app.ForwardsEditField_4, 'Value', Forwards);

            % Create BackwardsEditField_4
            app.BackwardsEditField_4 = uieditfield(app.MovePanel_4, 'numeric');
            app.BackwardsEditField_4.HorizontalAlignment = 'center';
            app.BackwardsEditField_4.Position = [217 65 58 22];
            set(app.BackwardsEditField_4, 'Value', Backwards);
            
            % Create TotalEditField_4Label
            app.TotalEditField_4Label = uilabel(app.MovePanel_4);
            app.TotalEditField_4Label.HorizontalAlignment = 'right';
            app.TotalEditField_4Label.Position = [39 65 31 22];
            app.TotalEditField_4Label.Text = 'Total';

            % Create TotalEditField_4
            app.TotalEditField_4 = uieditfield(app.MovePanel_4, 'numeric');
            app.TotalEditField_4.HorizontalAlignment = 'center';
            app.TotalEditField_4.Position = [85 65 58 22];
            set(app.TotalEditField_4, 'Value', Forwards - Backwards);

            % Create GoButton_7
            app.GoButton_7 = uibutton(app.MovePanel_4, 'push');
            app.GoButton_7.ButtonPushedFcn = createCallbackFcn(app, @GoButton_7Pushed, true);
            app.GoButton_7.Position = [149 93 58 25];
            app.GoButton_7.Text = 'Go';
            
            %Create GoButton_7Label
            app.GoButton_7Label = uilabel(app.MovePanel_4);
            app.GoButton_7Label.HorizontalAlignment = 'right';
            app.GoButton_7Label.Position = [144 115 58 25];
            app.GoButton_7Label.Text = 'Forwards';
            app.GoButton_7Label.FontSize = 11;
            
            % Create GoButton_8
            app.GoButton_8 = uibutton(app.MovePanel_4, 'push');
            app.GoButton_8.ButtonPushedFcn = createCallbackFcn(app, @GoButton_8Pushed, true);
            app.GoButton_8.Position = [217 93 58 25];
            app.GoButton_8.Text = 'Go';
            
            %Create GoButton_8Label
            app.GoButton_8Label = uilabel(app.MovePanel_4);
            app.GoButton_8Label.HorizontalAlignment = 'right';
            app.GoButton_8Label.Position = [214 115 58 25];
            app.GoButton_8Label.Text = 'Backwards';
            app.GoButton_8Label.FontSize = 11;

            % Create MaxstepsEditField_4Label
            app.MaxstepsEditField_4Label = uilabel(app.MovePanel_4);
            app.MaxstepsEditField_4Label.HorizontalAlignment = 'right';
            app.MaxstepsEditField_4Label.Position = [1 36 70 22];
            app.MaxstepsEditField_4Label.Text = 'Max # steps';

            % Create MaxstepsEditField_4
            app.MaxstepsEditField_4 = uieditfield(app.MovePanel_4, 'numeric');
            app.MaxstepsEditField_4.ValueChangedFcn = createCallbackFcn(app, @MaxstepsEditField_4ValueChanged, true);
            app.MaxstepsEditField_4.HorizontalAlignment = 'center';
            app.MaxstepsEditField_4.Position = [86 36 58 22];
            set(app.MaxstepsEditField_4, 'Value', app.MaxNumberOfSteps(4));

            % Create IgnoreCheckBox_4
            app.IgnoreCheckBox_4 = uicheckbox(app.MovePanel_4);
            app.IgnoreCheckBox_4.ValueChangedFcn = createCallbackFcn(app, @IgnoreCheckBox_4ValueChanged, true);
            app.IgnoreCheckBox_4.Text = 'Ignore';
            app.IgnoreCheckBox_4.Position = [151 36 56 22];
            if app.Controller.ControllerDevice{app.ControllerDeviceNumber}.IgnoreMaxNumberOfSteps(4)
                set(app.IgnoreCheckBox_4, 'Value', 1)
            else
                set(app.IgnoreCheckBox_4, 'Value', 0)
            end
            
            % Create deactivateButton_4
            app.deactivateButton_4 = uibutton(app.MovePanel_4, 'push');
            app.deactivateButton_4.ButtonPushedFcn = createCallbackFcn(app, @deactivateButton_4Pushed, true);
            app.deactivateButton_4.Position = [10 8 74 23];
            app.deactivateButton_4.Text = 'Activate';
            
            % Create ResetButton_4
            app.ResetButton_4 = uibutton(app.MovePanel_4, 'push');
            app.ResetButton_4.ButtonPushedFcn = createCallbackFcn(app, @ResetButton_4Pushed, true);
            app.ResetButton_4.Position = [201 8 74 23];
            app.ResetButton_4.Text = 'Reset #';

            % Create MotionStatusLamp_4Label
            app.MotionStatusLamp_4Label = uilabel(app.Axis4Panel);
            app.MotionStatusLamp_4Label.HorizontalAlignment = 'right';
            app.MotionStatusLamp_4Label.Position = [176 11 79 22];
            app.MotionStatusLamp_4Label.Text = 'Motion Status';

            % Create MotionStatusLamp
            app.MotionStatusLamp_4 = uilamp(app.Axis4Panel);
            app.MotionStatusLamp_4.Position = [270 11 20 20];
            set(app.MotionStatusLamp_4, 'Color', [0.96,0.96,0.96]);

            % Create ConnectionStatusLamp_4Label
            app.ConnectionStatusLamp_4Label = uilabel(app.Axis4Panel);
            app.ConnectionStatusLamp_4Label.HorizontalAlignment = 'right';
            app.ConnectionStatusLamp_4Label.Position = [25 11 104 22];
            app.ConnectionStatusLamp_4Label.Text = 'Connection Status';

            % Create ConnectionStatusLamp_4
            app.ConnectionStatusLamp_4 = uilamp(app.Axis4Panel);
            app.ConnectionStatusLamp_4.Position = [144 11 20 20];
            set(app.ConnectionStatusLamp_4, 'Color', [0.96,0.96,0.96]);
        end

        % Create components
        function createComponents(app, controllerdevice, picomotorscrews)
            % Create TabGroup
            app.TabGroup = uitabgroup(app.UIFigure);
            app.TabGroup.Position = [1 1 1092 758];

            % Create ControllerDevice Tabs
            app.ControllerDeviceTab = uitab(app.TabGroup);
            app.ControllerDeviceTab.Title = controllerdevice.Alias;

            activeAxes = find(contains(string(vertcat(picomotorscrews(1:end).ControllerDeviceKey)), controllerdevice.deviceKey));

            for j = reshape(activeAxes, [1,length(activeAxes)])
                if picomotorscrews(j).MotorProperties.ChannelNumber == 1
                    app.createAxis1(picomotorscrews(j).Alias)
                    app.deactivateControl(1);
                    set(app.deactivateButton_1, 'Enable', 1)
                elseif picomotorscrews(j).MotorProperties.ChannelNumber == 2
                    app.createAxis2(picomotorscrews(j).Alias)
                    app.deactivateControl(2);
                    set(app.deactivateButton_2, 'Enable', 1)
                elseif picomotorscrews(j).MotorProperties.ChannelNumber == 3
                    app.createAxis3(picomotorscrews(j).Alias)
                    app.deactivateControl(3);
                    set(app.deactivateButton_3, 'Enable', 1)
                elseif picomotorscrews(j).MotorProperties.ChannelNumber == 4
                    app.createAxis4(picomotorscrews(j).Alias)
                    app.deactivateControl(4);
                    set(app.deactivateButton_4, 'Enable', 1)
                end
            end        

            if length(activeAxes) < 4
                a = vertcat(picomotorscrews(activeAxes));
                b = vertcat(a.MotorProperties);
                c = setdiff(1:4,vertcat(b.ChannelNumber));
                if ~isempty(c)
                    for k = reshape(c, [1,length(c)])
                        if k == 1
                            app.createAxis1('Axis 1')
                            app.deactivateControl(1);
                            
                        elseif k == 2
                            app.createAxis2('Axis 2')
                            app.deactivateControl(2);
                            
                        elseif k == 3
                            app.createAxis3('Axis 3')
                            app.deactivateControl(3);
                            
                        else
                            app.createAxis4('Axis 4')
                            app.deactivateControl(4);
                            
                        end
                    end
                end
            end
            
            % Create SavePlotButton
            app.saveButton = uibutton(app.ControllerDeviceTab, 'push');
            app.saveButton.ButtonPushedFcn = createCallbackFcn(app, @saveButtonPushed, true);
            app.saveButton.Position = [184 693 147 22];
            app.saveButton.Text = 'Save History';
            
            % Create RefreshGUIButton
            app.RefreshGUIButton = uibutton(app.ControllerDeviceTab, 'push');
            app.RefreshGUIButton.ButtonPushedFcn = createCallbackFcn(app, @RefreshGUIButtonPushed, true);
            app.RefreshGUIButton.Position = [344 693 147 22];
            app.RefreshGUIButton.Text = 'Refresh GUI';

            % Create DisconnectButton
            app.DisconnectButton = uibutton(app.ControllerDeviceTab, 'push');
            app.DisconnectButton.ButtonPushedFcn = createCallbackFcn(app, @DisconnectButtonValueChanged, true);
            app.DisconnectButton.Position = [504 693 147 22];
            app.DisconnectButton.Text = 'Disconnect';

             % Create ReadyStatusLampLabel
            app.ReadyStatusLampLabel = uilabel(app.ControllerDeviceTab);
            app.ReadyStatusLampLabel.HorizontalAlignment = 'right';
            app.ReadyStatusLampLabel.Position = [672 693 78 22];
            app.ReadyStatusLampLabel.Text = 'Ready Status';

            % Create ReadyStatusLamp
            app.ReadyStatusLamp = uilamp(app.ControllerDeviceTab);
            app.ReadyStatusLamp.Position = [765 693 20 20];

            % Create AbortallmotionButton
            app.AbortallmotionButton = uibutton(app.ControllerDeviceTab, 'push');
            app.AbortallmotionButton.ButtonPushedFcn = createCallbackFcn(app, @AbortallmotionButtonPushed, true);
            app.AbortallmotionButton.Position = [813 692 100 22];
            app.AbortallmotionButton.Text = 'Abort all motion';

            % Create UIAxes
            app.UIAxes = uiaxes(app.ControllerDeviceTab);
            title(app.UIAxes, 'Live Plot of Axis Position')
            xlabel(app.UIAxes, 'Time(seconds)')
            ylabel(app.UIAxes, 'Position (steps)')
            app.UIAxes.Position = [390 57 668 283];
            
            % Create StartPlotButton
            app.StartPlotButton = uibutton(app.ControllerDeviceTab, 'push');
            app.StartPlotButton.ButtonPushedFcn = createCallbackFcn(app, @StartPlotButtonPushed, true);
            %app.StartPlotButton.Position = [616 17 111 22];
            app.StartPlotButton.Position = [550 17 111 22];
            app.StartPlotButton.Text = 'Start';
            
            % Create StopPlotButton
            app.StopPlotButton = uibutton(app.ControllerDeviceTab, 'push');
            app.StopPlotButton.ButtonPushedFcn = createCallbackFcn(app, @StopPlotButtonPushed, true);
            %app.StopPlotButton.Position = [750 17 111 22];
            app.StopPlotButton.Position = [685 17 111 22];
            app.StopPlotButton.Text = 'Stop';

            % Create ResetPlotButton
            app.ResetPlotButton = uibutton(app.ControllerDeviceTab, 'push');
            app.ResetPlotButton.ButtonPushedFcn = createCallbackFcn(app, @ResetPlotButtonPushed, true);
            %app.ResetPlotButton.Position = [884 17 111 22];
            app.ResetPlotButton.Position = [819 17 111 22];
            app.ResetPlotButton.Text = 'Reset';

            % Show the figure after all components are created
            % app.UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = NF8082StageControllerGui(ControllerDeviceNumber)
            % Create UIFigure and hide until all components are created
            app.UIFigure = uifigure('Visible', 'on');
            app.UIFigure.Position = [100 100 1092 758];
            app.UIFigure.Name = 'NF 8082 Five-Axis Stage Controller';
            dialogbox = uiprogressdlg(app.UIFigure,'Title','Loading...', 'Indeterminate','on');            
            app.Controller = Devices.NP_PicomotorController.getInstance();
            if app.Controller.ControllerDeviceInfo(ControllerDeviceNumber).IsConnected2PCViaUSB || app.Controller.ControllerDeviceInfo(ControllerDeviceNumber).IsConnected2PCViaETHERNET 
                app.ControllerDeviceNumber = ControllerDeviceNumber;
                app.MaxNumberOfSteps = app.Controller.ControllerDevice{app.ControllerDeviceNumber}.MaxNumberOfSteps.UserDefined;
                % Create UIFigure and components
                createComponents(app, app.Controller.ControllerDeviceInfo(ControllerDeviceNumber), app.Controller.PicomotorScrewsInfo) 
            end    
            close(dialogbox);
            % Register the app with App Designer
            registerApp(app, app.UIFigure)
            if nargout == 0
                clear app
            end
        end
        
        % Code that executes before app deletion
        function delete(app)

            % Delete UIFigure when app is deleted
            delete(app.UIFigure)
        end
    end
end