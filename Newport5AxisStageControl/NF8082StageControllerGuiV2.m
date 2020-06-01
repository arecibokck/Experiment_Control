classdef NF8082StageControllerGuiV2 < matlab.apps.AppBase
    
    properties (Access = private)
        Controller;
        Axis1;Axis2;Axis3;Axis4;Axis5;
        ControllerDeviceNumbers;
        MoveHistory = struct('Timestamps', {}, ...
                             'Moves'    , {}); 
        MoveHistoryDisplayText;
    end
    
    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                       matlab.ui.Figure
        AbortallmotionButton           matlab.ui.control.Button
        DisconnectButton               matlab.ui.control.Button
        RefreshGUIButton               matlab.ui.control.Button
        ReadyStatusLampLabel           matlab.ui.control.Label
        ReadyStatusLamp                matlab.ui.control.Lamp
        SaveHistoryButton              matlab.ui.control.Button
        MoveHistoryTextAreaLabel    matlab.ui.control.Label
        MoveHistoryTextArea         matlab.ui.control.TextArea
        Axis1Panel
        CurrentPositionEditField_1Label
        CurrentPositionEditField_1
        DropDown_1
        EditField_1 
        MovePanel_1
        GoButton_1 
        GoButton_1Label
        ForwardsEditField_1 
        BackwardsEditField_1
        TotalEditField_1Label
        TotalEditField_1 
        NofstepsEditField_1Label 
        NofstepsEditField_1 
        GoButton_2 
        GoButton_2Label
        IgnoreCheckBox_1 
        MaxstepsEditField_1Label
        MaxstepsEditField_1 
        ResetButton_1 
        DeactivateButton_1
        MotionStatusLamp_1Label 
        MotionStatusLamp_1 
        ConnectionStatusLamp_1Label
        ConnectionStatusLamp_1 
        ZeroButton_1
        SetButton_1 
        Axis2Panel                  matlab.ui.container.Panel
        CurrentPositionEditField_2Label  matlab.ui.control.Label
        CurrentPositionEditField_2     matlab.ui.control.NumericEditField
        DropDown_2                     matlab.ui.control.DropDown
        EditField_2                    matlab.ui.control.NumericEditField
        MovePanel_2                    matlab.ui.container.Panel
        GoButton_3                     matlab.ui.control.Button
        GoButton_3Label
        ForwardsEditField_2            matlab.ui.control.NumericEditField
        BackwardsEditField_2           matlab.ui.control.NumericEditField
        TotalEditField_2Label          matlab.ui.control.Label
        TotalEditField_2               matlab.ui.control.NumericEditField
        NofstepsEditField_2Label        matlab.ui.control.Label
        NofstepsEditField_2             matlab.ui.control.NumericEditField
        GoButton_4                     matlab.ui.control.Button
        GoButton_4Label
        IgnoreCheckBox_2               matlab.ui.control.CheckBox
        MaxstepsEditField_2Label       matlab.ui.control.Label
        MaxstepsEditField_2            matlab.ui.control.NumericEditField
        ResetButton_2                  matlab.ui.control.Button
        DeactivateButton_2             matlab.ui.control.Button
        MotionStatusLamp_2Label        matlab.ui.control.Label
        MotionStatusLamp_2             matlab.ui.control.Lamp
        ConnectionStatusLamp_2Label    matlab.ui.control.Label
        ConnectionStatusLamp_2         matlab.ui.control.Lamp
        ZeroButton_2                   matlab.ui.control.Button
        SetButton_2                    matlab.ui.control.Button
        Axis3Panel                  matlab.ui.container.Panel
        CurrentPositionEditField_3Label  matlab.ui.control.Label
        CurrentPositionEditField_3     matlab.ui.control.NumericEditField
        DropDown_3                     matlab.ui.control.DropDown
        EditField_3                    matlab.ui.control.NumericEditField
        MovePanel_3                    matlab.ui.container.Panel
        GoButton_5                     matlab.ui.control.Button
        GoButton_5Label
        ForwardsEditField_3            matlab.ui.control.NumericEditField
        BackwardsEditField_3           matlab.ui.control.NumericEditField
        TotalEditField_3Label          matlab.ui.control.Label
        TotalEditField_3               matlab.ui.control.NumericEditField
        NofstepsEditField_3Label        matlab.ui.control.Label
        NofstepsEditField_3             matlab.ui.control.NumericEditField
        GoButton_6                     matlab.ui.control.Button
        GoButton_6Label
        IgnoreCheckBox_3               matlab.ui.control.CheckBox
        MaxstepsEditField_3Label       matlab.ui.control.Label
        MaxstepsEditField_3            matlab.ui.control.NumericEditField
        ResetButton_3                  matlab.ui.control.Button
        DeactivateButton_3             matlab.ui.control.Button
        MotionStatusLamp_3Label        matlab.ui.control.Label
        MotionStatusLamp_3             matlab.ui.control.Lamp
        ConnectionStatusLamp_3Label    matlab.ui.control.Label
        ConnectionStatusLamp_3         matlab.ui.control.Lamp
        ZeroButton_3                   matlab.ui.control.Button
        SetButton_3                    matlab.ui.control.Button
        Axis4Panel                  matlab.ui.container.Panel
        CurrentPositionEditField_4Label  matlab.ui.control.Label
        CurrentPositionEditField_4     matlab.ui.control.NumericEditField
        DropDown_4                     matlab.ui.control.DropDown
        EditField_4                    matlab.ui.control.NumericEditField
        MovePanel_4                    matlab.ui.container.Panel
        GoButton_7                     matlab.ui.control.Button
        GoButton_7Label
        ForwardsEditField_4            matlab.ui.control.NumericEditField
        BackwardsEditField_4           matlab.ui.control.NumericEditField
        TotalEditField_4Label          matlab.ui.control.Label
        TotalEditField_4               matlab.ui.control.NumericEditField
        NofstepsEditField_4Label        matlab.ui.control.Label
        NofstepsEditField_4             matlab.ui.control.NumericEditField
        GoButton_8                     matlab.ui.control.Button
        GoButton_8Label
        IgnoreCheckBox_4               matlab.ui.control.CheckBox
        MaxstepsEditField_4Label       matlab.ui.control.Label
        MaxstepsEditField_4            matlab.ui.control.NumericEditField
        ResetButton_4                  matlab.ui.control.Button
        DeactivateButton_4             matlab.ui.control.Button
        MotionStatusLamp_4Label        matlab.ui.control.Label
        MotionStatusLamp_4             matlab.ui.control.Lamp
        ConnectionStatusLamp_4Label    matlab.ui.control.Label
        ConnectionStatusLamp_4         matlab.ui.control.Lamp
        ZeroButton_4                   matlab.ui.control.Button
        SetButton_4                    matlab.ui.control.Button
        Axis5Panel                  matlab.ui.container.Panel
        CurrentPositionEditField_5Label  matlab.ui.control.Label
        CurrentPositionEditField_5     matlab.ui.control.NumericEditField
        DropDown_5                     matlab.ui.control.DropDown
        EditField_5                    matlab.ui.control.NumericEditField
        MovePanel_5                    matlab.ui.container.Panel
        GoButton_9                     matlab.ui.control.Button
        GoButton_9Label
        ForwardsEditField_5            matlab.ui.control.NumericEditField
        BackwardsEditField_5           matlab.ui.control.NumericEditField
        TotalEditField_5Label          matlab.ui.control.Label
        TotalEditField_5               matlab.ui.control.NumericEditField
        NofstepsEditField_5Label        matlab.ui.control.Label
        NofstepsEditField_5             matlab.ui.control.NumericEditField
        GoButton_10                    matlab.ui.control.Button
        GoButton_10Label
        IgnoreCheckBox_5               matlab.ui.control.CheckBox
        MaxstepsEditField_5Label       matlab.ui.control.Label
        MaxstepsEditField_5            matlab.ui.control.NumericEditField
        ResetButton_5                  matlab.ui.control.Button
        DeactivateButton_5             matlab.ui.control.Button
        MotionStatusLamp_5Label        matlab.ui.control.Label
        MotionStatusLamp_5             matlab.ui.control.Lamp
        ConnectionStatusLamp_5Label    matlab.ui.control.Label
        ConnectionStatusLamp_5         matlab.ui.control.Lamp
        ZeroButton_5                   matlab.ui.control.Button
        SetButton_5                    matlab.ui.control.Button
    end

    % Callbacks that handle component events
    methods (Access = private)
        function RefreshGUIButtonPushed(app, event)
            if ~isempty(app.Axis1)
                [Forwards,Backwards] = app.Axis1.GetTotalNumberOfSteps;
                set(app.ForwardsEditField_1, 'Value', Forwards);
                set(app.BackwardsEditField_1, 'Value', Backwards);
                set(app.TotalEditField_1, 'Value', Forwards - Backwards);
                set(app.CurrentPositionEditField_1, 'Value', app.Axis1.GetCurrentPosition);
                set(app.MaxstepsEditField_1, 'Value', app.Axis1.GetMaxNumberOfSteps);
            end
            
            if ~isempty(app.Axis2) 
                [Forwards,Backwards] = app.Axis2.GetTotalNumberOfSteps;
                set(app.ForwardsEditField_2, 'Value', Forwards);
                set(app.BackwardsEditField_2, 'Value', Backwards);
                set(app.TotalEditField_2, 'Value', Forwards - Backwards);
                set(app.CurrentPositionEditField_2, 'Value', app.Axis2.GetCurrentPosition);
                set(app.MaxstepsEditField_2, 'Value', app.Axis2.GetMaxNumberOfSteps);
            end
            
            if ~isempty(app.Axis3) 
                [Forwards,Backwards] = app.Axis3.GetTotalNumberOfSteps;
                set(app.ForwardsEditField_3, 'Value', Forwards);
                set(app.BackwardsEditField_3, 'Value', Backwards);
                set(app.TotalEditField_3, 'Value', Forwards - Backwards);
                set(app.CurrentPositionEditField_3, 'Value', app.Axis3.GetCurrentPosition);
                set(app.MaxstepsEditField_3, 'Value', app.Axis3.GetMaxNumberOfSteps);
            end
            
            if ~isempty(app.Axis4)
                [Forwards,Backwards] = app.Axis4.GetTotalNumberOfSteps;
                set(app.ForwardsEditField_4, 'Value', Forwards);
                set(app.BackwardsEditField_4, 'Value', Backwards);
                set(app.TotalEditField_4, 'Value', Forwards - Backwards);
                set(app.CurrentPositionEditField_4, 'Value', app.Axis4.GetCurrentPosition);
                set(app.MaxstepsEditField_4, 'Value', app.Axis4.GetMaxNumberOfSteps);
            end
            
            if  ~isempty(app.Axis5)
                [Forwards,Backwards] = app.Axis5.GetTotalNumberOfSteps;
                set(app.ForwardsEditField_5, 'Value', Forwards);
                set(app.BackwardsEditField_5, 'Value', Backwards);
                set(app.TotalEditField_5, 'Value', Forwards - Backwards);
                set(app.CurrentPositionEditField_5, 'Value', app.Axis5.GetCurrentPosition);
                set(app.MaxstepsEditField_5, 'Value', app.Axis5.GetMaxNumberOfSteps);
            end
        end
        
        % Button pushed function: DisconnectButton
        function DisconnectButtonValueChanged(app, event)
            str = get(app.DisconnectButton,'Text');
            ind = find(strcmp(str,'Disconnect'));
            if ind == 1
                arrayfun(@(x) app.Controller.disconnectPicomotorController(x), app.ControllerDeviceNumbers); 
                app.deactivateControl(1);
                app.deactivateControl(2);
                app.deactivateControl(3);
                app.deactivateControl(4);
                app.deactivateControl(5);
                set(app.DisconnectButton,'Text', 'Reconnect');
                set(app.ReadyStatusLamp, 'Color', 'red');
                set(app.RefreshGUIButton,'Enable', 0);
                set(app.AbortallmotionButton,'Enable', 0);
                set(app.SaveHistoryButton, 'Enable', 0);
            else
                arrayfun(@(x) app.Controller.reconnectPicomotorController(x), app.ControllerDeviceNumbers); 
                if ~isempty(app.Axis1)
                    if strcmp(get(app.DeactivateButton_1,'Text'),'Deactivate')
                        set(app.DeactivateButton_1, 'Text', 'Reactivate')
                    end
                    set(app.DeactivateButton_1, 'Enable', 1)
                end
                if ~isempty(app.Axis2) 
                    if strcmp(get(app.DeactivateButton_2,'Text'),'Deactivate')
                        set(app.DeactivateButton_2, 'Text', 'Reactivate')
                    end
                    set(app.DeactivateButton_2, 'Enable', 1)
                end
                if ~isempty(app.Axis3)
                    if strcmp(get(app.DeactivateButton_3,'Text'),'Deactivate')
                        set(app.DeactivateButton_3, 'Text', 'Reactivate')
                    end
                    set(app.DeactivateButton_3, 'Enable', 1)
                end
                if ~isempty(app.Axis4)
                    if strcmp(get(app.DeactivateButton_4,'Text'),'Deactivate')
                        set(app.DeactivateButton_4, 'Text', 'Reactivate')
                    end
                    set(app.DeactivateButton_4, 'Enable', 1)
                end
                if ~isempty(app.Axis5)
                    if strcmp(get(app.DeactivateButton_5,'Text'),'Deactivate')
                        set(app.DeactivateButton_5, 'Text', 'Reactivate')
                    end
                    set(app.DeactivateButton_5, 'Enable', 1)
                end
                set(app.DisconnectButton,'Text', 'Disconnect');
                set(app.ReadyStatusLamp, 'Color', 'green');
                set(app.RefreshGUIButton,'Enable', 1);
                set(app.AbortallmotionButton,'Enable', 1);
                set(app.SaveHistoryButton, 'Enable', 1);
            end
        end
        
         % Button pushed function: AbortallmotionButton
        function AbortallmotionButtonPushed(app, event)
            for i = 1:length(app.ControllerDeviceNumbers)
                app.Controller.ControllerDevice{app.ControllerDeviceNumbers(i)}.abortMotionFlag = 1;
                app.Controller.ControllerDevice{app.ControllerDeviceNumbers(i)}.AbortMotion;
                app.Controller.ControllerDevice{app.ControllerDeviceNumbers(i)}.abortMotionFlag = 0; 
            end
        end
        
        function SaveHistoryButtonPushed(app, event)
            filename = ['MovesUpto_' char(strrep(strrep(strrep(string(datetime('now', 'Format', 'yyyy-MM-dd HH:mm')), '-', ''), ' ', '_'), ':', '')) '.csv']; 
            [file, path] = uiputfile(filename);
            if ~(isequal(file,0) || isequal(path,0))
                temp_table = struct2table(app.MoveHistory);
                writetable(temp_table,[path file]);
            end
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
                case 5
                    children_axis = get(app.Axis5Panel,'Children');
                    children_move = get(app.MovePanel_5,'Children');
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
                case 5
                    children_axis = get(app.Axis5Panel,'Children');
                    children_move = get(app.MovePanel_5,'Children');
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
                    set(app.EditField_1, 'Value', app.Axis1.GetVelocity);
                case 'Acceleration'
                    set(app.EditField_1, 'Value', app.Axis1.GetAcceleration);
                case 'Motor Type'
                    set(app.EditField_1, 'Value', app.Axis1.GetMotorType);
            end
        end
        
        % Value changed function: EditField
        function EditField_1ValueChanged(app, event)
            value = app.EditField_1.Value;
            switch app.DropDown_1.Value
                case 'Velocity'
                    app.Axis1.SetVelocity(value);
                    set(app.EditField_1, 'Value', value);
                case 'Acceleration'
                    app.Axis1.SetAcceleration(value);
                    set(app.EditField_1, 'Value', value);
                case 'Motor Type'
                    app.Axis1.SetMotorType(value);
                    set(app.EditField_1, 'Value', value);
            end
        end
        
        % Button pushed function: ZeroButton_1
        function ZeroButton_1Pushed(app, event)
            app.Axis1.SetHome(app.Axis1.GetCurrentPosition);
            set(app.CurrentPositionEditField_1, 'Value', app.Axis1.GetCurrentPosition - app.Axis1.GetHome); 
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
            app.deactivateControl(5);
            set(app.MotionStatusLamp_1, 'Color', 'green');
            error = app.Axis1.MoveRelative(app.NofstepsEditField_1.Value);
            if strcmp(get(app.DeactivateButton_2,'Text'),'Deactivate')
               if ~isempty(app.Axis2)
                   app.reactivateControl(2);
               end
            else
                if ~isempty(app.Axis2)
                    set(app.DeactivateButton_2, 'Enable', 1)
                end
            end
            if strcmp(get(app.DeactivateButton_3,'Text'),'Deactivate')
                if ~isempty(app.Axis3)
                    app.reactivateControl(3);
                end
            else
                if ~isempty(app.Axis3)
                    set(app.DeactivateButton_3, 'Enable', 1)
                end
            end
            if strcmp(get(app.DeactivateButton_4,'Text'),'Deactivate')
                if ~isempty(app.Axis4)
                    app.reactivateControl(4);
                end
            else
                if ~isempty(app.Axis4)
                    set(app.DeactivateButton_4, 'Enable', 1)
                end
            end
            if strcmp(get(app.DeactivateButton_5,'Text'),'Deactivate')
                if ~isempty(app.Axis5)
                    app.reactivateControl(5);
                end
            else
                if ~isempty(app.Axis5)
                    set(app.DeactivateButton_5, 'Enable', 1)
                end
            end
            if error.Code ~= 108
                set(app.ConnectionStatusLamp_1, 'Color', 'green');
            else
                set(app.ConnectionStatusLamp_1, 'Color', 'red');
                set(app.MotionStatusLamp_1, 'Color', [0.96,0.96,0.96]);
            end
            set(app.MotionStatusLamp_1, 'Color', [0.96,0.96,0.96]);
            app.updateNumbers_1;
            [warnMsg, ~] = lastwarn;
            if ~strcmp(warnMsg, 'Number of steps exceeds user-defined limit. Axis will not be moved in either direction.')
                app.MoveHistory(end+1)= struct('Timestamps', char(datetime('now')), 'Moves', ['1R+' num2str(app.NofstepsEditField_1.Value)]);
                Temp_MH = table2cell(struct2table(app.MoveHistory));
                app.MoveHistoryDisplayText{end+1} = sprintf('%s, %s', Temp_MH{end,1}, Temp_MH{end,2});
                set(app.MoveHistoryTextArea, 'Value', app.MoveHistoryDisplayText);
            end
            lastwarn(''); 
        end
        
        % Button pushed function: GoButton_1
        function GoButton_2Pushed(app, event)
            app.deactivateControl(2);
            app.deactivateControl(3);
            app.deactivateControl(4);
            app.deactivateControl(5);
            set(app.MotionStatusLamp_1, 'Color', 'green');
            error = app.Axis1.MoveRelative(app.NofstepsEditField_1.Value*(-1));
            if strcmp(get(app.DeactivateButton_2,'Text'),'Deactivate')
               if ~isempty(app.Axis2)
                   app.reactivateControl(2);
               end
            else
                if ~isempty(app.Axis2)
                    set(app.DeactivateButton_2, 'Enable', 1)
                end
            end
            if strcmp(get(app.DeactivateButton_3,'Text'),'Deactivate')
                if ~isempty(app.Axis3)
                    app.reactivateControl(3);
                end
            else
                if ~isempty(app.Axis3)
                    set(app.DeactivateButton_3, 'Enable', 1)
                end
            end
            if strcmp(get(app.DeactivateButton_4,'Text'),'Deactivate')
                if ~isempty(app.Axis4)
                    app.reactivateControl(4);
                end
            else
                if ~isempty(app.Axis4)
                    set(app.DeactivateButton_4, 'Enable', 1)
                end
            end
            if strcmp(get(app.DeactivateButton_5,'Text'),'Deactivate')
                if ~isempty(app.Axis5)
                    app.reactivateControl(5);
                end
            else
                if ~isempty(app.Axis5)
                    set(app.DeactivateButton_5, 'Enable', 1)
                end
            end
            if error.Code ~= 108
                set(app.ConnectionStatusLamp_1, 'Color', 'green');
            else
                set(app.ConnectionStatusLamp_1, 'Color', 'red');
                set(app.MotionStatusLamp_1, 'Color', [0.96,0.96,0.96]);
            end
            set(app.MotionStatusLamp_1, 'Color', [0.96,0.96,0.96]);
            app.updateNumbers_1;
            [warnMsg, ~] = lastwarn;
            if ~strcmp(warnMsg, 'Number of steps exceeds user-defined limit. Axis will not be moved in either direction.')
                app.MoveHistory(end+1)= struct('Timestamps', char(datetime('now')), 'Moves', ['1R-' num2str(app.NofstepsEditField_1.Value)]);
                Temp_MH = table2cell(struct2table(app.MoveHistory));
                app.MoveHistoryDisplayText{end+1} = sprintf('%s, %s', Temp_MH{end,1}, Temp_MH{end,2});
                set(app.MoveHistoryTextArea, 'Value', app.MoveHistoryDisplayText);
            end
            lastwarn('');
        end
        
        function updateNumbers_1(app)
            [Forwards,Backwards] = app.Axis1.GetTotalNumberOfSteps;     
            set(app.ForwardsEditField_1, 'Value', Forwards);
            set(app.BackwardsEditField_1, 'Value', Backwards);
            set(app.TotalEditField_1, 'Value', Forwards - Backwards);
            set(app.CurrentPositionEditField_1, 'Value', app.Axis1.GetCurrentPosition - app.Axis1.GetHome); 
        end
        
        % Button pushed function: ResetButton_1
        function ResetButton_1Pushed(app, event)
           [Forwards_Old,Backwards_Old] = app.Axis1.ResetTotalNumberOfSteps;
           [Forwards_New,Backwards_New] = app.Axis1.GetTotalNumberOfSteps;
           set(app.ForwardsEditField_1, 'Value', Forwards_New);
           set(app.BackwardsEditField_1, 'Value', Backwards_New);
           set(app.TotalEditField_1, 'Value', Forwards_New - Backwards_New);
           set(app.CurrentPositionEditField_1, 'Value', app.Axis1.GetCurrentPosition);
        end
        
        % Value changed function: MaxstepsEditField
        function MaxstepsEditField_1ValueChanged(app, event)
            value = app.MaxstepsEditField_1.Value;
            app.Axis1.SetMaxNumberOfSteps(value);
            set(app.MaxstepsEditField_1, 'Value', app.Axis1.GetMaxNumberOfSteps);
        end
        
        % Value changed function: IgnoreCheckBox_1
        function IgnoreCheckBox_1ValueChanged(app, event)
            value = app.IgnoreCheckBox_1.Value;
            if value == 1
                app.Axis1.IgnoreMaxNumberOfSteps = 1;
            else
                app.Axis1.IgnoreMaxNumberOfSteps = 0;
            end
        end
        
        function DeactivateButton_1Pushed(app, event)
            if strcmp(get(app.DeactivateButton_1,'Text'),'Activate')
                app.reactivateControl(1);
                set(app.DeactivateButton_1, 'Text', 'Deactivate')
            elseif strcmp(get(app.DeactivateButton_1,'Text'),'Deactivate')
                app.deactivateControl(1);
                set(app.DeactivateButton_1, 'Enable', 1)
                set(app.DeactivateButton_1, 'Text', 'Reactivate')
            else
                app.reactivateControl(1);
                set(app.DeactivateButton_1, 'Text', 'Deactivate')
            end
        end
        
        %% Axis 2
        % Value changed function: DropDown_2
        function DropDown_2ValueChanged(app, event)
            value = app.DropDown_2.Value;
            switch value
                case 'Velocity'
                    set(app.EditField_2, 'Value', app.Axis2.GetVelocity);
                case 'Acceleration'
                    set(app.EditField_2, 'Value', app.Axis2.GetAcceleration);
                case 'Motor Type'
                    set(app.EditField_2, 'Value', app.Axis2.GetMotorType);
            end
        end
        
        % Value changed function: EditField
        function EditField_2ValueChanged(app, event)
            value = app.EditField_2.Value;
            switch app.DropDown_2.Value
                case 'Velocity'
                    app.Axis2.SetVelocity(value);
                    set(app.EditField_2, 'Value', value);
                case 'Acceleration'
                    app.Axis2.SetAcceleration(value);
                    set(app.EditField_2, 'Value', value);
                case 'Motor Type'
                    app.Axis2.SetMotorType(value);
                    set(app.EditField_2, 'Value', value);
            end
        end
        
        % Button pushed function: ZeroButton_2
        function ZeroButton_2Pushed(app, event)
            app.Axis2.SetHome(app.Axis2.GetCurrentPosition);
            set(app.CurrentPositionEditField_2, 'Value', app.Axis2.GetCurrentPosition - app.Axis2.GetHome); 
        end
        
        function NofstepsEditField_2ValueChanged(app, event)
            value = app.NofstepsEditField_2.Value;
            set(app.NofstepsEditField_2, 'Value', value);
        end
        
        % Button pushed function: GoButton_2
        function GoButton_3Pushed(app, event)
            app.deactivateControl(1);
            app.deactivateControl(3);
            app.deactivateControl(4);
            app.deactivateControl(5);
            set(app.MotionStatusLamp_2, 'Color', 'green');
            error = app.Axis2.MoveRelative(app.NofstepsEditField_2.Value);
            if strcmp(get(app.DeactivateButton_1,'Text'),'Deactivate')
               if ~isempty(app.Axis1)
                   app.reactivateControl(1);
               end
            else
                if ~isempty(app.Axis1)
                    set(app.DeactivateButton_1, 'Enable', 1)
                end
            end
            if strcmp(get(app.DeactivateButton_3,'Text'),'Deactivate')
                if ~isempty(app.Axis3)
                    app.reactivateControl(3);
                end
            else
                if ~isempty(app.Axis3)
                    set(app.DeactivateButton_3, 'Enable', 1)
                end
            end
            if strcmp(get(app.DeactivateButton_4,'Text'),'Deactivate')
                if ~isempty(app.Axis4)
                    app.reactivateControl(4);
                end
            else
                if ~isempty(app.Axis4)
                    set(app.DeactivateButton_4, 'Enable', 1)
                end
            end
            if strcmp(get(app.DeactivateButton_5,'Text'),'Deactivate')
                if ~isempty(app.Axis5)
                    app.reactivateControl(5);
                end
            else
                if ~isempty(app.Axis5)
                    set(app.DeactivateButton_5, 'Enable', 1)
                end
            end
            if error.Code ~= 208
                set(app.ConnectionStatusLamp_2, 'Color', 'green');
            else
                set(app.ConnectionStatusLamp_2, 'Color', 'red');
                set(app.MotionStatusLamp_2, 'Color', [0.96,0.96,0.96]);
            end
            set(app.MotionStatusLamp_2, 'Color', [0.96,0.96,0.96]);
            app.updateNumbers_2;
            [warnMsg, ~] = lastwarn;
            if ~strcmp(warnMsg, 'Number of steps exceeds user-defined limit. Axis will not be moved in either direction.')
                app.MoveHistory(end+1)= struct('Timestamps', char(datetime('now')), 'Moves', ['2R+' num2str(app.NofstepsEditField_2.Value)]);
                Temp_MH = table2cell(struct2table(app.MoveHistory));
                app.MoveHistoryDisplayText{end+1} = sprintf('%s, %s', Temp_MH{end,1}, Temp_MH{end,2});
                set(app.MoveHistoryTextArea, 'Value', app.MoveHistoryDisplayText);
            end
            lastwarn('');
        end
        
        % Button pushed function: GoButton_2
        function GoButton_4Pushed(app, event)
            app.deactivateControl(1);
            app.deactivateControl(3);
            app.deactivateControl(4);
            app.deactivateControl(5);
            set(app.MotionStatusLamp_2, 'Color', 'green');
            error = app.Axis2.MoveRelative(app.NofstepsEditField_2.Value*(-1));
            if strcmp(get(app.DeactivateButton_1,'Text'),'Deactivate')
               if ~isempty(app.Axis1)
                   app.reactivateControl(1);
               end
            else
                if ~isempty(app.Axis1)
                    set(app.DeactivateButton_1, 'Enable', 1)
                end
            end
            if strcmp(get(app.DeactivateButton_3,'Text'),'Deactivate')
                if ~isempty(app.Axis3)
                    app.reactivateControl(3);
                end
            else
                if ~isempty(app.Axis3)
                    set(app.DeactivateButton_3, 'Enable', 1)
                end
            end
            if strcmp(get(app.DeactivateButton_4,'Text'),'Deactivate')
                if ~isempty(app.Axis4)
                    app.reactivateControl(4);
                end
            else
                if ~isempty(app.Axis4)
                    set(app.DeactivateButton_4, 'Enable', 1)
                end
            end
            if strcmp(get(app.DeactivateButton_5,'Text'),'Deactivate')
                if ~isempty(app.Axis5)
                    app.reactivateControl(5);
                end
            else
                if ~isempty(app.Axis5)
                    set(app.DeactivateButton_5, 'Enable', 1)
                end
            end
            if error.Code ~= 208
                set(app.ConnectionStatusLamp_2, 'Color', 'green');
            else
                set(app.ConnectionStatusLamp_2, 'Color', 'red');
                set(app.MotionStatusLamp_2, 'Color', [0.96,0.96,0.96]);
            end
            set(app.MotionStatusLamp_2, 'Color', [0.96,0.96,0.96]);
            app.updateNumbers_2;
            [warnMsg, ~] = lastwarn;
            if ~strcmp(warnMsg, 'Number of steps exceeds user-defined limit. Axis will not be moved in either direction.')
                app.MoveHistory(end+1)= struct('Timestamps', char(datetime('now')), 'Moves', ['2R-' num2str(app.NofstepsEditField_2.Value)]);
                Temp_MH = table2cell(struct2table(app.MoveHistory));
                app.MoveHistoryDisplayText{end+1} = sprintf('%s, %s', Temp_MH{end,1}, Temp_MH{end,2});
                set(app.MoveHistoryTextArea, 'Value', app.MoveHistoryDisplayText);
            end
            lastwarn('');
        end
        
        function updateNumbers_2(app)
            [Forwards,Backwards] = app.Axis2.GetTotalNumberOfSteps;     
            set(app.ForwardsEditField_2, 'Value', Forwards);
            set(app.BackwardsEditField_2, 'Value', Backwards);
            set(app.TotalEditField_2, 'Value', Forwards - Backwards);
            set(app.CurrentPositionEditField_2, 'Value', app.Axis2.GetCurrentPosition - app.Axis2.GetHome); 
        end
        
        % Button pushed function: ResetButton_2
        function ResetButton_2Pushed(app, event)
           [Forwards_Old,Backwards_Old] = app.Axis2.ResetTotalNumberOfSteps;
           [Forwards_New,Backwards_New] = app.Axis2.GetTotalNumberOfSteps;
           set(app.ForwardsEditField_2, 'Value', Forwards_New);
           set(app.BackwardsEditField_2, 'Value', Backwards_New);
           set(app.TotalEditField_2, 'Value', Forwards_New - Backwards_New);
           set(app.CurrentPositionEditField_2, 'Value', app.Axis2.GetCurrentPosition);
        end
        
        % Value changed function: MaxstepsEditField
        function MaxstepsEditField_2ValueChanged(app, event)
            value = app.MaxstepsEditField_2.Value;
            app.Axis2.SetMaxNumberOfSteps(value);
            set(app.MaxstepsEditField_2, 'Value', app.Axis2.GetMaxNumberOfSteps);
        end
        
        % Value changed function: IgnoreCheckBox_2
        function IgnoreCheckBox_2ValueChanged(app, event)
            value = app.IgnoreCheckBox_2.Value;
            if value == 1
                app.Axis2.IgnoreMaxNumberOfSteps = 1;
            else
                app.Axis2.IgnoreMaxNumberOfSteps = 0;
            end
        end
        
        function DeactivateButton_2Pushed(app, event)
            if strcmp(get(app.DeactivateButton_2,'Text'),'Activate')
                app.reactivateControl(2);
                set(app.DeactivateButton_2, 'Text', 'Deactivate')
            elseif strcmp(get(app.DeactivateButton_2,'Text'),'Deactivate')
                app.deactivateControl(2);
                set(app.DeactivateButton_2, 'Enable', 1)
                set(app.DeactivateButton_2, 'Text', 'Reactivate')
            else
                app.reactivateControl(2);
                set(app.DeactivateButton_2, 'Text', 'Deactivate')
            end
        end
        
        %% Axis 3
        % Value changed function: DropDown_3
        function DropDown_3ValueChanged(app, event)
            value = app.DropDown_3.Value;
            switch value
                case 'Velocity'
                    set(app.EditField_3, 'Value', app.Axis3.GetVelocity);
                case 'Acceleration'
                    set(app.EditField_3, 'Value', app.Axis3.GetAcceleration);
                case 'Motor Type'
                    set(app.EditField_3, 'Value', app.Axis3.GetMotorType);
            end
        end
        
        % Value changed function: EditField
        function EditField_3ValueChanged(app, event)
            value = app.EditField_3.Value;
            switch app.DropDown_3.Value
                case 'Velocity'
                    app.Axis3.SetVelocity(value);
                    set(app.EditField_3, 'Value', value);
                case 'Acceleration'
                    app.Axis3.SetAcceleration(value);
                    set(app.EditField_3, 'Value', value);
                case 'Motor Type'
                    app.Axis3.SetMotorType(value);
                    set(app.EditField_3, 'Value', value);
            end
        end
        
        % Button pushed function: ZeroButton_3
        function ZeroButton_3Pushed(app, event)
            app.Axis3.SetHome(app.Axis3.GetCurrentPosition);
            set(app.CurrentPositionEditField_3, 'Value', app.Axis3.GetCurrentPosition - app.Axis3.GetHome); 
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
            app.deactivateControl(5);
            set(app.MotionStatusLamp_3, 'Color', 'green');
            error = app.Axis3.MoveRelative(app.NofstepsEditField_3.Value);
            if strcmp(get(app.DeactivateButton_1,'Text'),'Deactivate')
               if ~isempty(app.Axis1)
                   app.reactivateControl(1);
               end
            else
                if ~isempty(app.Axis1)
                    set(app.DeactivateButton_1, 'Enable', 1)
                end
            end
            if strcmp(get(app.DeactivateButton_2,'Text'),'Deactivate')
                if ~isempty(app.Axis2)
                    app.reactivateControl(2);
                end
            else
                if ~isempty(app.Axis2)
                    set(app.DeactivateButton_2, 'Enable', 1)
                end
            end
            if strcmp(get(app.DeactivateButton_4,'Text'),'Deactivate')
                if ~isempty(app.Axis4)
                    app.reactivateControl(4);
                end
            else
                if ~isempty(app.Axis4)
                    set(app.DeactivateButton_4, 'Enable', 1)
                end
            end
            if strcmp(get(app.DeactivateButton_5,'Text'),'Deactivate')
                if ~isempty(app.Axis5)
                    app.reactivateControl(5);
                end
            else
                if ~isempty(app.Axis5)
                    set(app.DeactivateButton_5, 'Enable', 1)
                end
            end
            if error.Code ~= 308
                set(app.ConnectionStatusLamp_3, 'Color', 'green');
            else
                set(app.ConnectionStatusLamp_3, 'Color', 'red');
                set(app.MotionStatusLamp_3, 'Color', [0.96,0.96,0.96]);
            end
            set(app.MotionStatusLamp_3, 'Color', [0.96,0.96,0.96]);
            app.updateNumbers_3;
            [warnMsg, ~] = lastwarn;
            if ~strcmp(warnMsg, 'Number of steps exceeds user-defined limit. Axis will not be moved in either direction.')
                app.MoveHistory(end+1)= struct('Timestamps', char(datetime('now')), 'Moves', ['3R+' num2str(app.NofstepsEditField_3.Value)]);
                Temp_MH = table2cell(struct2table(app.MoveHistory));
                app.MoveHistoryDisplayText{end+1} = sprintf('%s, %s', Temp_MH{end,1}, Temp_MH{end,2});
                set(app.MoveHistoryTextArea, 'Value', app.MoveHistoryDisplayText);
            end
            lastwarn('');
        end
        
        % Button pushed function: GoButton_3
        function GoButton_6Pushed(app, event)
            app.deactivateControl(1);
            app.deactivateControl(2);
            app.deactivateControl(4);
            app.deactivateControl(5);
            set(app.MotionStatusLamp_3, 'Color', 'green');
            error = app.Axis3.MoveRelative(app.NofstepsEditField_3.Value*(-1));
            if strcmp(get(app.DeactivateButton_1,'Text'),'Deactivate')
                if ~isempty(app.Axis1)
                    app.reactivateControl(1);
                end
            else
                if ~isempty(app.Axis1)
                    set(app.DeactivateButton_1, 'Enable', 1)
                end
            end
            if strcmp(get(app.DeactivateButton_2,'Text'),'Deactivate')
               if ~isempty(app.Axis2)
                   app.reactivateControl(2);
               end
            else
                if ~isempty(app.Axis2)
                    set(app.DeactivateButton_2, 'Enable', 1)
                end
            end
            if strcmp(get(app.DeactivateButton_4,'Text'),'Deactivate')
                if ~isempty(app.Axis4)
                    app.reactivateControl(4);
                end
            else
                if ~isempty(app.Axis4)
                    set(app.DeactivateButton_4, 'Enable', 1)
                end
            end
            if strcmp(get(app.DeactivateButton_5,'Text'),'Deactivate')
                if ~isempty(app.Axis5)
                    app.reactivateControl(5);
                end
            else
                if ~isempty(app.Axis5)
                    set(app.DeactivateButton_5, 'Enable', 1)
                end
            end
            if error.Code ~= 308
                set(app.ConnectionStatusLamp_3, 'Color', 'green');
            else
                set(app.ConnectionStatusLamp_3, 'Color', 'red');
                set(app.MotionStatusLamp_3, 'Color', [0.96,0.96,0.96]);
            end
            set(app.MotionStatusLamp_3, 'Color', [0.96,0.96,0.96]);
            app.updateNumbers_3;
            [warnMsg, ~] = lastwarn;
            if ~strcmp(warnMsg, 'Number of steps exceeds user-defined limit. Axis will not be moved in either direction.')
                app.MoveHistory(end+1)= struct('Timestamps', char(datetime('now')), 'Moves', ['3R-' num2str(app.NofstepsEditField_3.Value)]);
                Temp_MH = table2cell(struct2table(app.MoveHistory));
                app.MoveHistoryDisplayText{end+1} = sprintf('%s, %s', Temp_MH{end,1}, Temp_MH{end,2});
                set(app.MoveHistoryTextArea, 'Value', app.MoveHistoryDisplayText);
            end
            lastwarn('');
        end
        
        function updateNumbers_3(app)
            [Forwards,Backwards] = app.Axis3.GetTotalNumberOfSteps;     
            set(app.ForwardsEditField_3, 'Value', Forwards);
            set(app.BackwardsEditField_3, 'Value', Backwards);
            set(app.TotalEditField_3, 'Value', Forwards - Backwards);
            set(app.CurrentPositionEditField_3, 'Value', app.Axis3.GetCurrentPosition - app.Axis3.GetHome); 
        end
        
        % Button pushed function: ResetButton_3
        function ResetButton_3Pushed(app, event)
           [Forwards_Old,Backwards_Old] = app.Axis3.ResetTotalNumberOfSteps;
           [Forwards_New,Backwards_New] = app.Axis3.GetTotalNumberOfSteps;
           set(app.ForwardsEditField_3, 'Value', Forwards_New);
           set(app.BackwardsEditField_3, 'Value', Backwards_New);
           set(app.TotalEditField_3, 'Value', Forwards_New - Backwards_New);
           set(app.CurrentPositionEditField_3, 'Value', app.Axis3.GetCurrentPosition);
        end
        
        % Value changed function: MaxstepsEditField
        function MaxstepsEditField_3ValueChanged(app, event)
            value = app.MaxstepsEditField_3.Value;
            app.Axis3.SetMaxNumberOfSteps(value);
            set(app.MaxstepsEditField_3, 'Value', app.Axis3.GetMaxNumberOfSteps);
        end
        
        % Value changed function: IgnoreCheckBox_3
        function IgnoreCheckBox_3ValueChanged(app, event)
            value = app.IgnoreCheckBox_3.Value;
            if value == 1
                app.Axis3.IgnoreMaxNumberOfSteps = 1;
            else
                app.Axis3.IgnoreMaxNumberOfSteps = 0;
            end
        end
        
        function DeactivateButton_3Pushed(app, event)
            if strcmp(get(app.DeactivateButton_3,'Text'),'Activate')
                app.reactivateControl(3);
                set(app.DeactivateButton_3, 'Text', 'Deactivate')
            elseif strcmp(get(app.DeactivateButton_3,'Text'),'Deactivate')
                app.deactivateControl(3);
                set(app.DeactivateButton_3, 'Enable', 1)
                set(app.DeactivateButton_3, 'Text', 'Reactivate')
            else
                app.reactivateControl(3);
                set(app.DeactivateButton_3, 'Text', 'Deactivate')
            end
        end
        
        %% Axis 4
        % Value changed function: DropDown_4
        function DropDown_4ValueChanged(app, event)
            value = app.DropDown_4.Value;
            switch value
                case 'Velocity'
                    set(app.EditField_4, 'Value', app.Axis4.GetVelocity);
                case 'Acceleration'
                    set(app.EditField_4, 'Value', app.Axis4.GetAcceleration);
                case 'Motor Type'
                    set(app.EditField_4, 'Value', app.Axis4.GetMotorType);
            end
        end
        
        % Value changed function: EditField
        function EditField_4ValueChanged(app, event)
            value = app.EditField_4.Value;
            switch app.DropDown_4.Value
                case 'Velocity'
                    app.Axis4.SetVelocity(value);
                    set(app.EditField_4, 'Value', value);
                case 'Acceleration'
                    app.Axis4.SetAcceleration(value);
                    set(app.EditField_4, 'Value', value);
                case 'Motor Type'
                    app.Axis4.SetMotorType(value);
                    set(app.EditField_4, 'Value', value);
            end
        end
        
        % Button pushed function: ZeroButton_4
        function ZeroButton_4Pushed(app, event)
            app.Axis4.SetHome(app.Axis4.GetCurrentPosition);
            set(app.CurrentPositionEditField_4, 'Value', app.Axis4.GetCurrentPosition - app.Axis4.GetHome); 
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
            app.deactivateControl(5);
            set(app.MotionStatusLamp_4, 'Color', 'green');
            error = app.Axis4.MoveRelative(app.NofstepsEditField_4.Value);
            if strcmp(get(app.DeactivateButton_1,'Text'),'Deactivate')
               if ~isempty(app.Axis1)
                   app.reactivateControl(1);
               end
            else
                if ~isempty(app.Axis1)
                    set(app.DeactivateButton_1, 'Enable', 1)
                end
            end
            if strcmp(get(app.DeactivateButton_2,'Text'),'Deactivate')
                if ~isempty(app.Axis2)
                    app.reactivateControl(2);
                end
            else
                if ~isempty(app.Axis2)
                    set(app.DeactivateButton_2, 'Enable', 1)
                end
            end
            if strcmp(get(app.DeactivateButton_3,'Text'),'Deactivate')
                if ~isempty(app.Axis3)
                    app.reactivateControl(3);
                end
            else
                if ~isempty(app.Axis3)
                    set(app.DeactivateButton_3, 'Enable', 1)
                end
            end
            if strcmp(get(app.DeactivateButton_5,'Text'),'Deactivate')
                if ~isempty(app.Axis5)
                    app.reactivateControl(5);
                end
            else
                if ~isempty(app.Axis5)
                    set(app.DeactivateButton_5, 'Enable', 1)
                end
            end
            if error.Code ~= 408
                set(app.ConnectionStatusLamp_4, 'Color', 'green');
            else
                set(app.ConnectionStatusLamp_4, 'Color', 'red');
                set(app.MotionStatusLamp_4, 'Color', [0.96,0.96,0.96]);
            end
            set(app.MotionStatusLamp_4, 'Color', [0.96,0.96,0.96]);
            app.updateNumbers_4;
            [warnMsg, ~] = lastwarn;
            if ~strcmp(warnMsg, 'Number of steps exceeds user-defined limit. Axis will not be moved in either direction.')
                app.MoveHistory(end+1)= struct('Timestamps', char(datetime('now')), 'Moves', ['4R+' num2str(app.NofstepsEditField_4.Value)]);
                Temp_MH = table2cell(struct2table(app.MoveHistory));
                app.MoveHistoryDisplayText{end+1} = sprintf('%s, %s', Temp_MH{end,1}, Temp_MH{end,2});
                set(app.MoveHistoryTextArea, 'Value', app.MoveHistoryDisplayText);
            end
            lastwarn('');
        end
        
        % Button pushed function: GoButton_4
        function GoButton_8Pushed(app, event)
            app.deactivateControl(1);
            app.deactivateControl(2);
            app.deactivateControl(3);
            app.deactivateControl(5);
            set(app.MotionStatusLamp_4, 'Color', 'green');
            error = app.Axis4.MoveRelative(app.NofstepsEditField_4.Value*(-1));
            if strcmp(get(app.DeactivateButton_1,'Text'),'Deactivate')
                if ~isempty(app.Axis1)
                    app.reactivateControl(1);
                end
            else
                if ~isempty(app.Axis1)
                    set(app.DeactivateButton_1, 'Enable', 1)
                end
            end
            if strcmp(get(app.DeactivateButton_2,'Text'),'Deactivate')
               if ~isempty(app.Axis2)
                   app.reactivateControl(2);
               end
            else
                if ~isempty(app.Axis2)
                    set(app.DeactivateButton_2, 'Enable', 1)
                end
            end
            if strcmp(get(app.DeactivateButton_3,'Text'),'Deactivate')
                if ~isempty(app.Axis4)
                    app.reactivateControl(3);
                end
            else
                if ~isempty(app.Axis3)
                    set(app.DeactivateButton_3, 'Enable', 1)
                end
            end
            if strcmp(get(app.DeactivateButton_5,'Text'),'Deactivate')
                if ~isempty(app.Axis5)
                    app.reactivateControl(5);
                end
            else
                if ~isempty(app.Axis5)
                    set(app.DeactivateButton_5, 'Enable', 1)
                end
            end
            if error.Code ~= 408
                set(app.ConnectionStatusLamp_4, 'Color', 'green');
            else
                set(app.ConnectionStatusLamp_4, 'Color', 'red');
                set(app.MotionStatusLamp_4, 'Color', [0.96,0.96,0.96]);
            end
            set(app.MotionStatusLamp_4, 'Color', [0.96,0.96,0.96]);
            app.updateNumbers_4;
            [warnMsg, ~] = lastwarn;
            if ~strcmp(warnMsg, 'Number of steps exceeds user-defined limit. Axis will not be moved in either direction.')
                app.MoveHistory(end+1)= struct('Timestamps', char(datetime('now')), 'Moves', ['4R-' num2str(app.NofstepsEditField_4.Value)]);
                Temp_MH = table2cell(struct2table(app.MoveHistory));
                app.MoveHistoryDisplayText{end+1} = sprintf('%s, %s', Temp_MH{end,1}, Temp_MH{end,2});
                set(app.MoveHistoryTextArea, 'Value', app.MoveHistoryDisplayText);
            end
            lastwarn('');
        end
        
        function updateNumbers_4(app)
            [Forwards,Backwards] = app.Axis4.GetTotalNumberOfSteps;     
            set(app.ForwardsEditField_4, 'Value', Forwards);
            set(app.BackwardsEditField_4, 'Value', Backwards);
            set(app.TotalEditField_4, 'Value', Forwards - Backwards);
            set(app.CurrentPositionEditField_4, 'Value', app.Axis4.GetCurrentPosition - app.Axis4.GetHome); 
        end
        
        % Button pushed function: ResetButton_4
        function ResetButton_4Pushed(app, event)
           [Forwards_Old,Backwards_Old] = app.Axis4.ResetTotalNumberOfSteps;
           [Forwards_New,Backwards_New] = app.Axis4.GetTotalNumberOfSteps;
           set(app.ForwardsEditField_4, 'Value', Forwards_New);
           set(app.BackwardsEditField_4, 'Value', Backwards_New);
           set(app.TotalEditField_4, 'Value', Forwards_New - Backwards_New);
           set(app.CurrentPositionEditField_4, 'Value', app.Axis4.GetCurrentPosition);
        end
        
        % Value changed function: MaxstepsEditField
        function MaxstepsEditField_4ValueChanged(app, event)
            value = app.MaxstepsEditField_4.Value;
            app.Axis4.SetMaxNumberOfSteps(value);
            set(app.MaxstepsEditField_4, 'Value', app.Axis4.GetMaxNumberOfSteps);
        end
        
        % Value changed function: IgnoreCheckBox_4
        function IgnoreCheckBox_4ValueChanged(app, event)
            value = app.IgnoreCheckBox_4.Value;
            if value == 1
                app.Axis4.IgnoreMaxNumberOfSteps = 1;
            else
                app.Axis4.IgnoreMaxNumberOfSteps = 0;
            end
        end
        
        function DeactivateButton_4Pushed(app, event)
            if strcmp(get(app.DeactivateButton_4,'Text'),'Activate')
                app.reactivateControl(4);
                set(app.DeactivateButton_4, 'Text', 'Deactivate')
            elseif strcmp(get(app.DeactivateButton_4,'Text'),'Deactivate')
                app.deactivateControl(4);
                set(app.DeactivateButton_4, 'Enable', 1)
                set(app.DeactivateButton_4, 'Text', 'Reactivate')
            else
                app.reactivateControl(4);
                set(app.DeactivateButton_4, 'Text', 'Deactivate')
            end
        end
        
        %% Axis 5
        % Value changed function: DropDown_5
        function DropDown_5ValueChanged(app, event)
            value = app.DropDown_5.Value;
            switch value
                case 'Velocity'
                    set(app.EditField_5, 'Value', app.Axis5.GetVelocity);
                case 'Acceleration'
                    set(app.EditField_5, 'Value', app.Axis5.GetAcceleration);
                case 'Motor Type'
                    set(app.EditField_5, 'Value', app.Axis5.GetMotorType);
            end
        end
        
        % Value changed function: EditField
        function EditField_5ValueChanged(app, event)
            value = app.EditField_5.Value;
            switch app.DropDown_5.Value
                case 'Velocity'
                    app.Axis5.SetVelocity(value);
                    set(app.EditField_5, 'Value', value);
                case 'Acceleration'
                    app.Axis5.SetAcceleration(value);
                    set(app.EditField_5, 'Value', value);
                case 'Motor Type'
                    app.Axis5.SetMotorType(value);
                    set(app.EditField_5, 'Value', value);
            end
        end
        
        % Button pushed function: ZeroButton_5
        function ZeroButton_5Pushed(app, event)
            app.Axis5.SetHome(app.Axis5.GetCurrentPosition);
            set(app.CurrentPositionEditField_5, 'Value', app.Axis5.GetCurrentPosition - app.Axis5.GetHome); 
        end
        
        function NofstepsEditField_5ValueChanged(app, event)
            value = app.NofstepsEditField_5.Value;
            set(app.NofstepsEditField_5, 'Value', value);
        end
        
        % Button pushed function: GoButton_5
        function GoButton_9Pushed(app, event)
            app.deactivateControl(1);
            app.deactivateControl(2);
            app.deactivateControl(3);
            app.deactivateControl(5);
            set(app.MotionStatusLamp_5, 'Color', 'green');
            error = app.Axis5.MoveRelative(app.NofstepsEditField_5.Value);
            if strcmp(get(app.DeactivateButton_1,'Text'),'Deactivate')
               if ~isempty(app.Axis1)
                   app.reactivateControl(1);
               end
            else
                if ~isempty(app.Axis1)
                    set(app.DeactivateButton_1, 'Enable', 1)
                end
            end
            if strcmp(get(app.DeactivateButton_2,'Text'),'Deactivate')
                if ~isempty(app.Axis2)
                    app.reactivateControl(2);
                end
            else
                if ~isempty(app.Axis2)
                    set(app.DeactivateButton_2, 'Enable', 1)
                end
            end
            if strcmp(get(app.DeactivateButton_3,'Text'),'Deactivate')
                if ~isempty(app.Axis3)
                    app.reactivateControl(3);
                end
            else
                if ~isempty(app.Axis3)
                    set(app.DeactivateButton_3, 'Enable', 1)
                end
            end
            if strcmp(get(app.DeactivateButton_5,'Text'),'Deactivate')
                if ~isempty(app.Axis5)
                    app.reactivateControl(5);
                end
            else
                if ~isempty(app.Axis5)
                    set(app.DeactivateButton_5, 'Enable', 1)
                end
            end
            if error.Code ~= 508
                set(app.ConnectionStatusLamp_5, 'Color', 'green');
            else
                set(app.ConnectionStatusLamp_5, 'Color', 'red');
                set(app.MotionStatusLamp_5, 'Color', [0.96,0.96,0.96]);
            end
            set(app.MotionStatusLamp_5, 'Color', [0.96,0.96,0.96]);
            app.updateNumbers_5;
            [warnMsg, ~] = lastwarn;
            if ~strcmp(warnMsg, 'Number of steps exceeds user-defined limit. Axis will not be moved in either direction.')
                app.MoveHistory(end+1)= struct('Timestamps', char(datetime('now')), 'Moves', ['5R+' num2str(app.NofstepsEditField_5.Value)]);
                Temp_MH = table2cell(struct2table(app.MoveHistory));
                app.MoveHistoryDisplayText{end+1} = sprintf('%s, %s', Temp_MH{end,1}, Temp_MH{end,2});
                set(app.MoveHistoryTextArea, 'Value', app.MoveHistoryDisplayText);
            end
            lastwarn('');
        end
        
        % Button pushed function: GoButton_5
        function GoButton_10Pushed(app, event)
            app.deactivateControl(1);
            app.deactivateControl(2);
            app.deactivateControl(3);
            app.deactivateControl(5);
            set(app.MotionStatusLamp_5, 'Color', 'green');
            error = app.Axis5.MoveRelative(app.NofstepsEditField_5.Value*(-1));
            if strcmp(get(app.DeactivateButton_1,'Text'),'Deactivate')
                if ~isempty(app.Axis1)
                    app.reactivateControl(1);
                end
            else
                if ~isempty(app.Axis1)
                    set(app.DeactivateButton_1, 'Enable', 1)
                end
            end
            if strcmp(get(app.DeactivateButton_2,'Text'),'Deactivate')
               if ~isempty(app.Axis2)
                   app.reactivateControl(2);
               end
            else
                if ~isempty(app.Axis2)
                    set(app.DeactivateButton_2, 'Enable', 1)
                end
            end
            if strcmp(get(app.DeactivateButton_3,'Text'),'Deactivate')
                if ~isempty(app.Axis5)
                    app.reactivateControl(3);
                end
            else
                if ~isempty(app.Axis3)
                    set(app.DeactivateButton_3, 'Enable', 1)
                end
            end
            if strcmp(get(app.DeactivateButton_5,'Text'),'Deactivate')
                if ~isempty(app.Axis5)
                    app.reactivateControl(5);
                end
            else
                if ~isempty(app.Axis5)
                    set(app.DeactivateButton_5, 'Enable', 1)
                end
            end
            if error.Code ~= 508
                set(app.ConnectionStatusLamp_5, 'Color', 'green');
            else
                set(app.ConnectionStatusLamp_5, 'Color', 'red');
                set(app.MotionStatusLamp_5, 'Color', [0.96,0.96,0.96]);
            end
            set(app.MotionStatusLamp_5, 'Color', [0.96,0.96,0.96]);
            app.updateNumbers_5;
            [warnMsg, ~] = lastwarn;
            if ~strcmp(warnMsg, 'Number of steps exceeds user-defined limit. Axis will not be moved in either direction.')
                app.MoveHistory(end+1)= struct('Timestamps', char(datetime('now')), 'Moves', ['5R-' num2str(app.NofstepsEditField_5.Value)]);
                Temp_MH = table2cell(struct2table(app.MoveHistory));
                app.MoveHistoryDisplayText{end+1} = sprintf('%s, %s', Temp_MH{end,1}, Temp_MH{end,2});
                set(app.MoveHistoryTextArea, 'Value', app.MoveHistoryDisplayText);
            end
            lastwarn('');
        end
        
        function updateNumbers_5(app)
            [Forwards,Backwards] = app.Axis5.GetTotalNumberOfSteps;     
            set(app.ForwardsEditField_5, 'Value', Forwards);
            set(app.BackwardsEditField_5, 'Value', Backwards);
            set(app.TotalEditField_5, 'Value', Forwards - Backwards);
            set(app.CurrentPositionEditField_5, 'Value', app.Axis5.GetCurrentPosition - app.Axis5.GetHome); 
        end
        
        % Button pushed function: ResetButton_5
        function ResetButton_5Pushed(app, event)
           [Forwards_Old,Backwards_Old] = app.Axis5.ResetTotalNumberOfSteps;
           [Forwards_New,Backwards_New] = app.Axis5.GetTotalNumberOfSteps;
           set(app.ForwardsEditField_5, 'Value', Forwards_New);
           set(app.BackwardsEditField_5, 'Value', Backwards_New);
           set(app.TotalEditField_5, 'Value', Forwards_New - Backwards_New);
           set(app.CurrentPositionEditField_5, 'Value', app.Axis5.GetCurrentPosition);
        end
        
        % Value changed function: MaxstepsEditField
        function MaxstepsEditField_5ValueChanged(app, event)
            value = app.MaxstepsEditField_5.Value;
            app.Axis5.SetMaxNumberOfSteps(value);
            set(app.MaxstepsEditField_5, 'Value', app.Axis5.GetMaxNumberOfSteps);
        end
        
        % Value changed function: IgnoreCheckBox_5
        function IgnoreCheckBox_5ValueChanged(app, event)
            value = app.IgnoreCheckBox_5.Value;
            if value == 1
                app.Axis5.IgnoreMaxNumberOfSteps = 1;
            else
                app.Axis5.IgnoreMaxNumberOfSteps = 0;
            end
        end
        
        function DeactivateButton_5Pushed(app, event)
            if strcmp(get(app.DeactivateButton_5,'Text'),'Activate')
                app.reactivateControl(5);
                set(app.DeactivateButton_5, 'Text', 'Deactivate')
            elseif strcmp(get(app.DeactivateButton_5,'Text'),'Deactivate')
                app.deactivateControl(5);
                set(app.DeactivateButton_5, 'Enable', 1)
                set(app.DeactivateButton_5, 'Text', 'Reactivate')
            else
                app.reactivateControl(5);
                set(app.DeactivateButton_5, 'Text', 'Deactivate')
            end
        end
    end

    % Component initialization
    methods (Access = private)
        
        function createAxis1(app)
            % Create Axis1Panel
            app.Axis1Panel = uipanel(app.UIFigure);
            if ~isempty(app.Axis1)
                app.Axis1Panel.Title = ['Axis 1: ' app.Axis1.Alias];
            else
                app.Axis1Panel.Title = 'Axis 1: Not Connected';
            end
            app.Axis1Panel.Position = [35 365 323 293];
            
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
            if ~isempty(app.Axis1)
                set(app.EditField_1, 'Value', app.Axis1.GetVelocity);
            else
                set(app.EditField_1, 'Value', 0);
            end
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
            if ~isempty(app.Axis1)
                set(app.CurrentPositionEditField_1, 'Value', app.Axis1.GetCurrentPosition); 
            else
                set(app.CurrentPositionEditField_1, 'Value', 0);
            end
            
            % Create ZeroButton_1
            app.ZeroButton_1 = uibutton(app.Axis1Panel, 'push');
            app.ZeroButton_1.ButtonPushedFcn = createCallbackFcn(app, @ZeroButton_1Pushed, true);
            app.ZeroButton_1.Position = [203 210 99 22];
            app.ZeroButton_1.Text = 'Zero';
            
             % Create MovePanel_1
            app.MovePanel_1 = uipanel(app.Axis1Panel);
            app.MovePanel_1.Title = 'Move';
            app.MovePanel_1.Position = [18 43 285 158];
            
            % Create Deac1Label
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
            if ~isempty(app.Axis1)
                [Forwards,Backwards] = app.Axis1.GetTotalNumberOfSteps;     
            else
                Forwards = 0; Backwards = 0;
            end
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
            if ~isempty(app.Axis1)
                set(app.MaxstepsEditField_1, 'Value', app.Axis1.GetMaxNumberOfSteps);
            else
                set(app.MaxstepsEditField_1, 'Value',0);
            end

            % Create IgnoreCheckBox_1
            app.IgnoreCheckBox_1 = uicheckbox(app.MovePanel_1);
            app.IgnoreCheckBox_1.ValueChangedFcn = createCallbackFcn(app, @IgnoreCheckBox_1ValueChanged, true);
            app.IgnoreCheckBox_1.Text = 'Ignore';
            app.IgnoreCheckBox_1.Position = [151 36 56 22];
            if ~isempty(app.Axis1) && app.Axis1.IgnoreMaxNumberOfSteps
                set(app.IgnoreCheckBox_1, 'Value', 1);
            else
                set(app.IgnoreCheckBox_1, 'Value', 0);
            end
            
            % Create DeactivateButton_1
            app.DeactivateButton_1 = uibutton(app.MovePanel_1, 'push');
            app.DeactivateButton_1.ButtonPushedFcn = createCallbackFcn(app, @DeactivateButton_1Pushed, true);
            app.DeactivateButton_1.Position = [10 8 74 23];
            app.DeactivateButton_1.Text = 'Activate';
            
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
        
        function createAxis2(app)
            % Create Axis2Panel
            app.Axis2Panel = uipanel(app.UIFigure);
            if ~isempty(app.Axis2)
                app.Axis2Panel.Title = ['Axis 2: ' app.Axis2.Alias];
            else
                app.Axis2Panel.Title = ['Axis 2: Not Connected'];
            end
            app.Axis2Panel.Position = [385 365 323 293];

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
            if ~isempty(app.Axis2)
                set(app.EditField_2, 'Value', app.Axis2.GetVelocity);
            else
                set(app.EditField_2, 'Value', 0);
            end
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
            if ~isempty(app.Axis2)
                set(app.CurrentPositionEditField_2, 'Value', app.Axis2.GetCurrentPosition); 
            else
                set(app.CurrentPositionEditField_2, 'Value', 0);
            end
            
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
            if ~isempty(app.Axis2)
                [Forwards,Backwards] = app.Axis2.GetTotalNumberOfSteps;     
            else
                Forwards = 0; Backwards = 0;
            end
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
            if ~isempty(app.Axis2)
                set(app.MaxstepsEditField_2, 'Value', app.Axis2.GetMaxNumberOfSteps);
            else
                set(app.MaxstepsEditField_2, 'Value', 0);
            end

            % Create IgnoreCheckBox_2
            app.IgnoreCheckBox_2 = uicheckbox(app.MovePanel_2);
            app.IgnoreCheckBox_2.ValueChangedFcn = createCallbackFcn(app, @IgnoreCheckBox_2ValueChanged, true);
            app.IgnoreCheckBox_2.Text = 'Ignore';
            app.IgnoreCheckBox_2.Position = [151 36 56 22];
            if ~isempty(app.Axis2) && app.Axis2.IgnoreMaxNumberOfSteps
                set(app.IgnoreCheckBox_2, 'Value', 1);
            else
                set(app.IgnoreCheckBox_2, 'Value', 0);
            end
            
            % Create DeactivateButton_2
            app.DeactivateButton_2 = uibutton(app.MovePanel_2, 'push');
            app.DeactivateButton_2.ButtonPushedFcn = createCallbackFcn(app, @DeactivateButton_2Pushed, true);
            app.DeactivateButton_2.Position = [10 8 74 23];
            app.DeactivateButton_2.Text = 'Activate';
            
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
        
        function createAxis3(app)
            % Create Axis3Panel
            app.Axis3Panel = uipanel(app.UIFigure);
            if ~isempty(app.Axis3)
                app.Axis3Panel.Title = ['Axis 3: ' app.Axis3.Alias];
            else
                app.Axis3Panel.Title = 'Axis 3: Not Connected';
            end
            app.Axis3Panel.Position = [739 365 323 293];

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
            if ~isempty(app.Axis3)
                set(app.EditField_3, 'Value', app.Axis3.GetVelocity);
            else
                set(app.EditField_3, 'Value', 0);
            end
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
            if ~isempty(app.Axis3)
                set(app.CurrentPositionEditField_3, 'Value', app.Axis3.GetCurrentPosition); 
            else
                set(app.CurrentPositionEditField_3, 'Value', 0); 
            end
            
            % Create ZeroButton_3
            app.ZeroButton_3 = uibutton(app.Axis3Panel, 'push');
            app.ZeroButton_3.ButtonPushedFcn = createCallbackFcn(app, @ZeroButton_3Pushed, true);
            app.ZeroButton_3.Position = [203 210 99 22];
            app.ZeroButton_3.Text = 'Zero';
            
             % Create MovePanel_3
            app.MovePanel_3 = uipanel(app.Axis3Panel);
            app.MovePanel_3.Title = 'Move';
            app.MovePanel_3.Position = [18 43 285 158];
            
            % Create DeactivateButton_3
            app.DeactivateButton_3 = uibutton(app.MovePanel_3, 'push');
            app.DeactivateButton_3.ButtonPushedFcn = createCallbackFcn(app, @DeactivateButton_3Pushed, true);
            app.DeactivateButton_3.Position = [10 8 74 23];
            app.DeactivateButton_3.Text = 'Activate';
            
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
            if ~isempty(app.Axis3)
                [Forwards,Backwards] = app.Axis3.GetTotalNumberOfSteps;     
            else
                Forwards = 0; Backwards = 0;
            end
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
            if ~isempty(app.Axis3)
                set(app.MaxstepsEditField_3, 'Value', app.Axis3.GetMaxNumberOfSteps);
            else
                set(app.MaxstepsEditField_3, 'Value',0);
            end

            % Create IgnoreCheckBox_3
            app.IgnoreCheckBox_3 = uicheckbox(app.MovePanel_3);
            app.IgnoreCheckBox_3.ValueChangedFcn = createCallbackFcn(app, @IgnoreCheckBox_3ValueChanged, true);
            app.IgnoreCheckBox_3.Text = 'Ignore';
            app.IgnoreCheckBox_3.Position = [151 36 56 22];
            if ~isempty(app.Axis3) && app.Axis3.IgnoreMaxNumberOfSteps
                set(app.IgnoreCheckBox_3, 'Value', 1);
            else
                set(app.IgnoreCheckBox_3, 'Value', 0);
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
        
        function createAxis4(app)
            % Create Axis4Panel
            app.Axis4Panel = uipanel(app.UIFigure);
            if ~isempty(app.Axis4)
                app.Axis4Panel.Title = ['Axis 4: ' app.Axis4.Alias];
            else
                app.Axis4Panel.Title = 'Axis 4: Not Connected';
            end
            app.Axis4Panel.Position = [34 38 323 293];

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
            if ~isempty(app.Axis4)
                set(app.EditField_4, 'Value', app.Axis4.GetVelocity);
            else
                set(app.EditField_4, 'Value', 0);
            end
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
            if ~isempty(app.Axis4)
                set(app.CurrentPositionEditField_4, 'Value', app.Axis4.GetCurrentPosition); 
            else
                set(app.CurrentPositionEditField_4, 'Value', 0); 
            end
            
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
            if ~isempty(app.Axis4)
                [Forwards,Backwards] = app.Axis4.GetTotalNumberOfSteps;     
            else
                Forwards = 0; Backwards = 0;
            end
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
            if ~isempty(app.Axis4)
                set(app.MaxstepsEditField_4, 'Value', app.Axis4.GetMaxNumberOfSteps);
            else
                set(app.MaxstepsEditField_4, 'Value',0);
            end

            % Create IgnoreCheckBox_4
            app.IgnoreCheckBox_4 = uicheckbox(app.MovePanel_4);
            app.IgnoreCheckBox_4.ValueChangedFcn = createCallbackFcn(app, @IgnoreCheckBox_4ValueChanged, true);
            app.IgnoreCheckBox_4.Text = 'Ignore';
            app.IgnoreCheckBox_4.Position = [151 36 56 22];
            if ~isempty(app.Axis4) && app.Axis4.IgnoreMaxNumberOfSteps
                set(app.IgnoreCheckBox_4, 'Value', 1)
            else
                set(app.IgnoreCheckBox_4, 'Value', 0)
            end
            
            % Create DeactivateButton_4
            app.DeactivateButton_4 = uibutton(app.MovePanel_4, 'push');
            app.DeactivateButton_4.ButtonPushedFcn = createCallbackFcn(app, @DeactivateButton_4Pushed, true);
            app.DeactivateButton_4.Position = [10 8 74 23];
            app.DeactivateButton_4.Text = 'Activate';
            
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
        
        function createAxis5(app)
            % Create Axis5Panel
            app.Axis5Panel = uipanel(app.UIFigure);
            if ~isempty(app.Axis5)
                app.Axis5Panel.Title = ['Axis 5: ' app.Axis5.Alias];
            else
                app.Axis5Panel.Title = 'Axis 5: Not connected';
            end
            app.Axis5Panel.Position = [385 38 323 293];

            % Create DropDown_5
            app.DropDown_5 = uidropdown(app.Axis5Panel);
            app.DropDown_5.Items = {'Velocity', 'Acceleration', 'Motor Type'};
            app.DropDown_5.ValueChangedFcn = createCallbackFcn(app, @DropDown_5ValueChanged, true);
            app.DropDown_5.Position = [11 242 100 22];
            app.DropDown_5.Value = 'Velocity';

            % Create EditField_5
            app.EditField_5 = uieditfield(app.Axis5Panel, 'numeric');
            app.EditField_5.HorizontalAlignment = 'center';
            app.EditField_5.Position = [121 242 69 22];
            if ~isempty(app.Axis5)
                set(app.EditField_5, 'Value', app.Axis5.GetVelocity);
            else
                set(app.EditField_5, 'Value', 0);
            end
            app.EditField_5.ValueChangedFcn = createCallbackFcn(app, @EditField_5ValueChanged, true);
            
            % Create SetButton_5
            app.SetButton_5 = uibutton(app.Axis5Panel, 'push');
            app.SetButton_5.ButtonPushedFcn = createCallbackFcn(app, @EditField_5ValueChanged, true);
            app.SetButton_5.Position = [203 242 99 22];
            app.SetButton_5.Text = 'Set';   

            % Create CurrentPositionEditField_5Label
            app.CurrentPositionEditField_5Label = uilabel(app.Axis5Panel);
            app.CurrentPositionEditField_5Label.HorizontalAlignment = 'right';
            app.CurrentPositionEditField_5Label.Position = [14 210 92 22];
            app.CurrentPositionEditField_5Label.Text = 'Current Position';

            % Create CurrentPositionEditField_5
            app.CurrentPositionEditField_5 = uieditfield(app.Axis5Panel, 'numeric');
            app.CurrentPositionEditField_5.HorizontalAlignment = 'center';
            app.CurrentPositionEditField_5.Position = [121 210 69 22];
            if ~isempty(app.Axis5)
                set(app.CurrentPositionEditField_5, 'Value', app.Axis5.GetCurrentPosition); 
            else
                set(app.CurrentPositionEditField_5, 'Value', 0); 
            end
            
            % Create ZeroButton_5
            app.ZeroButton_5 = uibutton(app.Axis5Panel, 'push');
            app.ZeroButton_5.ButtonPushedFcn = createCallbackFcn(app, @ZeroButton_5Pushed, true);
            app.ZeroButton_5.Position = [203 210 99 22];
            app.ZeroButton_5.Text = 'Zero';
            
             % Create MovePanel_5
            app.MovePanel_5 = uipanel(app.Axis5Panel);
            app.MovePanel_5.Title = 'Move';
            app.MovePanel_5.Position = [18 43 285 158];
            
            % Create NofstepsEditField_5Label
            app.NofstepsEditField_5Label = uilabel(app.MovePanel_5);
            app.NofstepsEditField_5Label.HorizontalAlignment = 'right';
            app.NofstepsEditField_5Label.Position = [12 94 58 22];
            app.NofstepsEditField_5Label.Text = '# of steps';

            % Create NofstepsEditField_5
            app.NofstepsEditField_5 = uieditfield(app.MovePanel_5, 'numeric');
            app.NofstepsEditField_5.ValueChangedFcn = createCallbackFcn(app, @NofstepsEditField_5ValueChanged, true);
            app.NofstepsEditField_5.HorizontalAlignment = 'center';
            app.NofstepsEditField_5.Position = [85 94 58 22];

            % Create ForwardsEditField_5
            app.ForwardsEditField_5 = uieditfield(app.MovePanel_5, 'numeric');
            app.ForwardsEditField_5.HorizontalAlignment = 'center';
            app.ForwardsEditField_5.Position = [149 65 58 22];
            if ~isempty(app.Axis5)
                [Forwards,Backwards] = app.Axis5.GetTotalNumberOfSteps;     
            else
                Forwards = 0; Backwards=0;
            end
            set(app.ForwardsEditField_5, 'Value', Forwards);

            % Create BackwardsEditField_5
            app.BackwardsEditField_5 = uieditfield(app.MovePanel_5, 'numeric');
            app.BackwardsEditField_5.HorizontalAlignment = 'center';
            app.BackwardsEditField_5.Position = [217 65 58 22];
            set(app.BackwardsEditField_5, 'Value', Backwards);
            
            % Create TotalEditField_5Label
            app.TotalEditField_5Label = uilabel(app.MovePanel_5);
            app.TotalEditField_5Label.HorizontalAlignment = 'right';
            app.TotalEditField_5Label.Position = [39 65 31 22];
            app.TotalEditField_5Label.Text = 'Total';

            % Create TotalEditField_5
            app.TotalEditField_5 = uieditfield(app.MovePanel_5, 'numeric');
            app.TotalEditField_5.HorizontalAlignment = 'center';
            app.TotalEditField_5.Position = [85 65 58 22];
            set(app.TotalEditField_5, 'Value', Forwards - Backwards);

            % Create GoButton_7
            app.GoButton_7 = uibutton(app.MovePanel_5, 'push');
            app.GoButton_7.ButtonPushedFcn = createCallbackFcn(app, @GoButton_7Pushed, true);
            app.GoButton_7.Position = [149 93 58 25];
            app.GoButton_7.Text = 'Go';
            
            %Create GoButton_7Label
            app.GoButton_7Label = uilabel(app.MovePanel_5);
            app.GoButton_7Label.HorizontalAlignment = 'right';
            app.GoButton_7Label.Position = [144 115 58 25];
            app.GoButton_7Label.Text = 'Forwards';
            app.GoButton_7Label.FontSize = 11;
            
            % Create GoButton_8
            app.GoButton_8 = uibutton(app.MovePanel_5, 'push');
            app.GoButton_8.ButtonPushedFcn = createCallbackFcn(app, @GoButton_8Pushed, true);
            app.GoButton_8.Position = [217 93 58 25];
            app.GoButton_8.Text = 'Go';
            
            %Create GoButton_8Label
            app.GoButton_8Label = uilabel(app.MovePanel_5);
            app.GoButton_8Label.HorizontalAlignment = 'right';
            app.GoButton_8Label.Position = [214 115 58 25];
            app.GoButton_8Label.Text = 'Backwards';
            app.GoButton_8Label.FontSize = 11;

            % Create MaxstepsEditField_5Label
            app.MaxstepsEditField_5Label = uilabel(app.MovePanel_5);
            app.MaxstepsEditField_5Label.HorizontalAlignment = 'right';
            app.MaxstepsEditField_5Label.Position = [1 36 70 22];
            app.MaxstepsEditField_5Label.Text = 'Max # steps';

            % Create MaxstepsEditField_5
            app.MaxstepsEditField_5 = uieditfield(app.MovePanel_5, 'numeric');
            app.MaxstepsEditField_5.ValueChangedFcn = createCallbackFcn(app, @MaxstepsEditField_5ValueChanged, true);
            app.MaxstepsEditField_5.HorizontalAlignment = 'center';
            app.MaxstepsEditField_5.Position = [86 36 58 22];
            if ~isempty(app.Axis5)
                set(app.MaxstepsEditField_5, 'Value', app.Axis5.GetMaxNumberOfSteps);
            else
                set(app.MaxstepsEditField_5, 'Value', 0);
            end

            % Create IgnoreCheckBox_5
            app.IgnoreCheckBox_5 = uicheckbox(app.MovePanel_5);
            app.IgnoreCheckBox_5.ValueChangedFcn = createCallbackFcn(app, @IgnoreCheckBox_5ValueChanged, true);
            app.IgnoreCheckBox_5.Text = 'Ignore';
            app.IgnoreCheckBox_5.Position = [151 36 56 22];
            if ~isempty(app.Axis5) && app.Axis5.IgnoreMaxNumberOfSteps
                set(app.IgnoreCheckBox_5, 'Value', 1)
            else
                set(app.IgnoreCheckBox_5, 'Value', 0)
            end
            
            % Create DeactivateButton_5
            app.DeactivateButton_5 = uibutton(app.MovePanel_5, 'push');
            app.DeactivateButton_5.ButtonPushedFcn = createCallbackFcn(app, @DeactivateButton_5Pushed, true);
            app.DeactivateButton_5.Position = [10 8 74 23];
            app.DeactivateButton_5.Text = 'Activate';
            
            % Create ResetButton_5
            app.ResetButton_5 = uibutton(app.MovePanel_5, 'push');
            app.ResetButton_5.ButtonPushedFcn = createCallbackFcn(app, @ResetButton_5Pushed, true);
            app.ResetButton_5.Position = [201 8 74 23];
            app.ResetButton_5.Text = 'Reset #';

            % Create MotionStatusLamp_5Label
            app.MotionStatusLamp_5Label = uilabel(app.Axis5Panel);
            app.MotionStatusLamp_5Label.HorizontalAlignment = 'right';
            app.MotionStatusLamp_5Label.Position = [176 11 79 22];
            app.MotionStatusLamp_5Label.Text = 'Motion Status';

            % Create MotionStatusLamp
            app.MotionStatusLamp_5 = uilamp(app.Axis5Panel);
            app.MotionStatusLamp_5.Position = [270 11 20 20];
            set(app.MotionStatusLamp_5, 'Color', [0.96,0.96,0.96]);

            % Create ConnectionStatusLamp_5Label
            app.ConnectionStatusLamp_5Label = uilabel(app.Axis5Panel);
            app.ConnectionStatusLamp_5Label.HorizontalAlignment = 'right';
            app.ConnectionStatusLamp_5Label.Position = [25 11 104 22];
            app.ConnectionStatusLamp_5Label.Text = 'Connection Status';

            % Create ConnectionStatusLamp_5
            app.ConnectionStatusLamp_5 = uilamp(app.Axis5Panel);
            app.ConnectionStatusLamp_5.Position = [144 11 20 20];
            set(app.ConnectionStatusLamp_5, 'Color', [0.96,0.96,0.96]);
        end
            
        
        % Create UIFigure and components
        function createComponents(app)
            
            fields = fieldnames(app.Controller.PicomotorScrews);
            createSuccessFlag = [0;0;0;0;0];
            for i = 1:length(fields)
                if ~isempty(app.Controller.PicomotorScrews.(fields{i})) && ~isnan(app.Controller.PicomotorScrews.(fields{i}).ControllerDeviceChannelNumber)
                    ControllerDeviceNumber = app.Controller.PicomotorScrews.(fields{i}).ControllerDeviceNumber;
                    ControllerDeviceChannelNumber = app.Controller.PicomotorScrews.(fields{i}).ControllerDeviceChannelNumber;
                    if app.Controller.ControllerDeviceInfo(ControllerDeviceNumber).IsConnected2PCViaUSB || ...
                        app.Controller.ControllerDeviceInfo(ControllerDeviceNumber).IsConnected2PCViaETHERNET
                        switch ControllerDeviceChannelNumber    
                            case 1
                                app.Axis1 = app.Controller.PicomotorScrews.(fields{i});
                                app.createAxis1
                                app.deactivateControl(1);
                                set(app.DeactivateButton_1, 'Enable', 1)
                                createSuccessFlag(ControllerDeviceChannelNumber) = 1;
                            case 2
                                app.Axis2 = app.Controller.PicomotorScrews.(fields{i});
                                app.createAxis2
                                app.deactivateControl(2);
                                set(app.DeactivateButton_2, 'Enable', 1)
                                createSuccessFlag(ControllerDeviceChannelNumber) = 1;
                            case 3
                                app.Axis3 = app.Controller.PicomotorScrews.(fields{i});
                                app.createAxis3
                                app.deactivateControl(3);
                                set(app.DeactivateButton_3, 'Enable', 1)
                                createSuccessFlag(ControllerDeviceChannelNumber) = 1;
                            case 4
                                app.Axis4 = app.Controller.PicomotorScrews.(fields{i});
                                app.createAxis4
                                app.deactivateControl(4);
                                set(app.DeactivateButton_4, 'Enable', 1)
                                createSuccessFlag(ControllerDeviceChannelNumber) = 1;
                            case 5
                                app.Axis5 = app.Controller.PicomotorScrews.(fields{i});
                                app.createAxis5
                                app.deactivateControl(5);
                                set(app.DeactivateButton_5, 'Enable', 1)
                                createSuccessFlag(ControllerDeviceChannelNumber) = 1;
                        end
                    end    
                end
                if all(createSuccessFlag)
                    break;
                end
            end
            
            inactiveAxes = find(createSuccessFlag==0);
            if ~isempty(inactiveAxes)
                for j = 1:length(inactiveAxes)
                    switch inactiveAxes(j)
                        case 1
                            app.createAxis1
                            app.deactivateControl(1);
                        case 2
                            app.createAxis2
                            app.deactivateControl(2);
                        case 3
                            app.createAxis3
                            app.deactivateControl(3);
                        case 4
                            app.createAxis4
                            app.deactivateControl(4);
                        case 5
                            app.createAxis5
                            app.deactivateControl(5);
                    end
                end
            end
                        
            % Create MoveHistoryTextAreaLabel
            app.MoveHistoryTextAreaLabel = uilabel(app.UIFigure);
            app.MoveHistoryTextAreaLabel.HorizontalAlignment = 'right';
            app.MoveHistoryTextAreaLabel.Position = [710 310 102 22];
            app.MoveHistoryTextAreaLabel.Text = 'Move History';

            % Create MoveHistoryTextArea
            app.MoveHistoryTextArea = uitextarea(app.UIFigure);
            app.MoveHistoryTextArea.Position = [738 217 324 92];
            set(app.MoveHistoryTextArea, 'Editable', 'off');
            
            % Create DisconnectButton
            app.DisconnectButton = uibutton(app.UIFigure, 'push');
            app.DisconnectButton.ButtonPushedFcn = createCallbackFcn(app, @DisconnectButtonValueChanged, true);
            app.DisconnectButton.Position = [765 175 147 22];
            app.DisconnectButton.Text = 'Disconnect';
            
            % Create ReadyStatusLampLabel
            app.ReadyStatusLampLabel = uilabel(app.UIFigure);
            app.ReadyStatusLampLabel.HorizontalAlignment = 'right';
            app.ReadyStatusLampLabel.Position = [928 175 78 22];
            app.ReadyStatusLampLabel.Text = 'Ready Status';
            
            % Create ReadyStatusLamp
            app.ReadyStatusLamp = uilamp(app.UIFigure);
            app.ReadyStatusLamp.Position = [1021 175 20 20];
            
            % Create AbortallmotionButton
            app.AbortallmotionButton = uibutton(app.UIFigure, 'push');
            app.AbortallmotionButton.ButtonPushedFcn = createCallbackFcn(app, @AbortallmotionButtonPushed, true);
            app.AbortallmotionButton.Position = [840 132 147 22];
            app.AbortallmotionButton.Text = 'Abort all motion';
            
            % Create RefreshGUIButton
            app.RefreshGUIButton = uibutton(app.UIFigure, 'push');
            app.RefreshGUIButton.ButtonPushedFcn = createCallbackFcn(app, @RefreshGUIButtonPushed, true);
            app.RefreshGUIButton.Position = [840 90 147 22];
            app.RefreshGUIButton.Text = 'Refresh GUI';
            
            % Create SaveHistoryButton
            app.SaveHistoryButton = uibutton(app.UIFigure, 'push');
            app.SaveHistoryButton.ButtonPushedFcn = createCallbackFcn(app, @SaveHistoryButtonPushed, true);
            app.SaveHistoryButton.Position = [840 50 147 22];
            app.SaveHistoryButton.Text = 'Save History';

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = NF8082StageControllerGuiV2
            
            % Create UIFigure and hide until all components are created
            app.UIFigure = uifigure('Visible', 'on');
            app.UIFigure.Position = [100 100 1093 691];
            app.UIFigure.Name = 'NF 8082 Five-Axis Stage Controller';
            dialogbox = uiprogressdlg(app.UIFigure,'Title','Loading...', 'Indeterminate','on');
            
            app.Controller = Devices.NP_PicomotorController.getInstance();
            
            % Create UIFigure and components
            createComponents(app)
            if ~isempty(app.Axis1)
                app.ControllerDeviceNumbers = [app.ControllerDeviceNumbers app.Axis1.ControllerDeviceNumber];
            end
            if ~isempty(app.Axis2)
                app.ControllerDeviceNumbers = [app.ControllerDeviceNumbers app.Axis2.ControllerDeviceNumber];
            end
            if ~isempty(app.Axis3)
                app.ControllerDeviceNumbers = [app.ControllerDeviceNumbers app.Axis3.ControllerDeviceNumber];
            end
            if ~isempty(app.Axis4) 
                app.ControllerDeviceNumbers = [app.ControllerDeviceNumbers app.Axis4.ControllerDeviceNumber];
            end
            if ~isempty(app.Axis5)
                app.ControllerDeviceNumbers = [app.ControllerDeviceNumbers app.Axis5.ControllerDeviceNumber];
            end
            
            app.ControllerDeviceNumbers = unique(app.ControllerDeviceNumbers);
            
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