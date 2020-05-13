classdef Sequence < matlab.mixin.Copyable %handle
    %Sequence Storage class for handles of pin objects
    
    properties (SetAccess = private)
        pinList = {};       % list of used pins
        pin     = struct()  % structure of pin handles for direct access
    end % properties
    
    methods
        function obj = Sequence(varargin)
            %Sequence   Default constructor which cann assign pins to sequence
            %
            %   Inputs
            %     several output pin objects

            for k = 1:nargin
                obj = obj.addPin(varargin{k});
            end
        end % sequence
        
        
        %% methods related to pins
        
        function obj = addPin(obj, p)
            %addPin    Adds pin to sequence block given output pin
            %
            %   Inputs
            %         p  Output pin object
            assert( isa(p,'Pin'), ...
                    'output pin object needed');
            
            for k=1:length(obj.pinList)
                assert( p~=obj.pinList{k}, ...
                        'pin already included in sequence object');
            end % for
            
            obj.pinList{end+1} = p;
            obj.pin.(p.toString()) = p;
        end % add
        
        function sref = subsref(obj, s)
            %subsref   Realize struct like addressing of assigned pins
            switch s(1).type
              case '.'
                  name = s.subs;
                  if isfield(obj.pin, name)
                    sref = builtin('subsref',obj.pin,s);
                    return;
                  end
            end
           
            sref = builtin('subsref',obj,s);
        end % subsref
        
        function val = countPins(obj)
            %countPins   Returns the number of pins in this sequence
            val = length(obj.pinList);
        end % countPins
        
        function obj = sortPins(obj)
            %sortPins    Sorts pin in pinList according to pin names
            
            %entries = cellfun(@(x) x.toString(), obj.pinList);
            entries = cell(1,length(obj.pinList));
            for k = 1:length(obj.pinList)
                entries{k} = obj.pinList{k}.toString;
            end
            
            [~,ind] = sort(entries);
            obj.pinList = obj.pinList(ind);
        end % sortPins
        
        
        %% methods related to time
        
        function obj = completeSequence(obj)
            %completeSequence Checks that vector pins have all their
            %waveforms
            
%             for k = fieldnames(obj.pins.VectorOut)'
%                 obj.pins.(k).state(obj.pins.(k).getLastState());
%             end
        end % completeSequence
        
        function obj = sync(obj)
            %sync   Synchronizes all pins to the latest time            
            ma = obj.getLength();
            for k=1:length(obj.pinList)
                [~, tmp2] = obj.pinList{k}.getLastState();
                if tmp2 ~= ma
                    obj.pinList{k} = obj.pinList{k}.wait(ma-tmp2);
                end
            end % for
        end % sync
        
        function obj = wait(obj, t) % increases obj.time
            %wait      Wait for a given time
            %
            %   Input
            %        t   time in s
            assert( isnumeric(t) && isscalar(t) && t>=0, ...
                    'waiting time must be non-negative value');
            if isempty(obj.pinList)
                warning('no pin assigned to this sequence, wait does not have any effect');
            end
            
            obj = obj.sync();
            for k=1:length(obj.pinList)
                obj.pinList{k} = obj.pinList{k}.wait(t);
            end % for
        end % wait
        
        function obj = wait_ms(obj, t)
            %wait_ms    Wait for a given time
            %
            %   Input
            %        t   time in ms
            assert( isnumeric(t), ...
                    'waiting time must be numeric value');
            obj = obj.wait(t*10^-3);
        end % wait_ms
        
        function obj = wait_us(obj, t)
            %wait_us    Wait for a given time
            %
            %   Input
            %        t   time in ?s
            assert( isnumeric(t), ...
                    'waiting time must be numeric value');
            obj = obj.wait(t*10^-6);
        end % wait_us
        
        function val = getLength(obj)
            %getLength   Returns the length of the sequence in same
            ma = 0;
            for k=1:length(obj.pinList)
                [~, tmp2] = obj.pinList{k}.getLastState();
                ma = max([ma tmp2]);
            end % for
            
            val = ma;
        end % getLength
        
        
        %% methods related to combining sequences
        
        function obj = horzcat(varargin)
            %horzcat    Concateneates several sequence objects in time
            %
            %   Note:  Time offsets are syncronized.
            %          This function is NOT commutative.
            %          Makes full copy of sequence and pins.
            %
            %   Inputs
            %       several Sequence objects
            for k = 1:nargin
                assert( isa(varargin{k},'Sequence'), ...
                        'sequence objects needed');
            end
            
            obj = Sequence();
            for k = 1:nargin
                obj = obj.sync();
                t = obj.getLength();
                
                for l = 1:length(varargin{k}.pinList)
                    if isempty(obj.pinList)
                        obj.pinList{end+1} = varargin{k}.pinList{l}.copy();
                    else
                        inList = 0;
                        for m = 1:length(obj.pinList)
                            if varargin{k}.pinList{l}==obj.pinList{m}
                                obj.pinList{m} = [obj.pinList{m} varargin{k}.pinList{l}.copy()];
                                inList = 1;
                            end
                        end % for
                        
                        if ~inList
                            obj.pinList{end+1} = varargin{k}.pinList{l}.copy().shiftTime(t);
                        end
                    end % if
                end % for
            end % for
            obj = obj.sync();
        end % horzcat
        
        function obj = plus(obj1, obj2)
            %plus    Combines two sequence objects by collecting all pins
            %
            %   Note:  Time offsets = 0.
            %          This function is commutative.
            %          Makes full copy of sequence and pins.
            %          Both sequences must contain a distinct set of pins.
            %
            %   Inputs
            %       obj2  Sequence object to be added
            assert( isa(obj2,'Sequence'), ...
                    'Sequence objects needed');
            
            %test for orthogonality
            for k = 1:length(obj1.pinList)
                for l = 1:length(obj2.pinList)
                    if obj1.pinList{k}==obj2.pinList{l}
                        error('Sequences are not orthogonal: at least one pin used in both sequences');
                    end
                end
            end % for
            
            %check for same length
            t1 = obj1.getLength();
            t2 = obj2.getLength();
            if t1~=t2
                warning('Sequences are of different length');
            end
            
            %create new combined Sequence object
            obj = Sequence;
            obj.pinList = cell(1,length(obj1.pinList)+length(obj2.pinList));
            for k=1:length(obj1.pinList)
                obj.pinList{k} = obj1.pinList{k}.copy();
            end
            for k=1:length(obj2.pinList)
                obj.pinList{k+length(obj1.pinList)} = obj2.pinList{k}.copy();
            end
            obj = obj.sync();
        end % plus
        
        
        %% methods related to visualizing
        
        function plot(obj)
            %plot   Plots the time evolution of all pins
            %
            %   Note:  plot function calls sync first.
            obj = obj.sortPins();
            obj.sync();
            
            colors = colormap('lines');
            
            clf;
            
            
            %% analog pins
            subplot(2,3,[1 4]);
            set(gca, 'Position', [0.015, 0.06, 0.31, 0.90]);
            hold on
            num = 1;
            for k=1:length(obj.pinList)
                if isa(obj.pinList{k}, 'AnalogOut')
                    [x,y] =  stairs([obj.pinList{k}.times obj.pinList{k}.timeOffset], [obj.pinList{k}.values obj.pinList{k}.values(end)]);
                    x = [0; x; x(end)]; %#ok
                    y = [0; y; 0]*0.09 + num-1;
                    text(obj.getLength()/100, num-1+0.2, obj.pinList{k}.toString(), 'Clipping','on');
                    patch(x,y, colors(num,:), 'FaceAlpha',0.5);
                    plot(x,y,'*', 'Color',colors(num,:));
                    num = num + 1;
                end
            end % for
            title('analog pins');
            ylim([-0.6 num-0.4]);
            xlim([0 obj.getLength()]);
            xlabel('time (s)');
            yticks([]);
            ax(1) = gca;
            
            
            %% digital pins
            subplot(2,3,[2 5]);
            set(gca, 'Position', [0.345, 0.06, 0.31, 0.90]);
            hold on
            num = 1;
            for k=1:length(obj.pinList)
                if isa(obj.pinList{k}, 'DigitalOut')
                    [x,y] =  stairs([obj.pinList{k}.times obj.pinList{k}.timeOffset], [obj.pinList{k}.values obj.pinList{k}.values(end)]);
                    x = [0; x; x(end)]; %#ok
                    y = [0; y; 0]*0.9 + num-1;
                    text(obj.getLength()/100, num-1+0.2, obj.pinList{k}.toString(), 'Clipping','on');
                    patch(x,y, colors(num,:), 'FaceAlpha',0.5);
                    plot(x,y,'*', 'Color',colors(num,:));
                    num = num + 1;
                end
            end % for
            title('digital pins');
            ylim([-0.1 num-0.9]);
            xlim([0 obj.getLength()]);
            xlabel('time (s)');
            yticks([]);
            ax(2) = gca;
            
            
            %% sample vector pins
            alltimes = cell(1,length(obj.pinList));
            allvalues = cell(1,length(obj.pinList));
            for k=1:length(obj.pinList)
                if isa(obj.pinList{k}, 'VectorOut')
                    [allvalues{k}, alltimes{k}] = obj.pinList{k}.sampleAllWaveforms(100);
                end
            end % for
            
            %% vector pins amplitude
            subplot(2,3,3);
            set(gca, 'Position', [0.675, 0.56, 0.31, 0.40]);
            hold all
            num = 1;
            for k=1:length(obj.pinList)
                if isa(obj.pinList{k}, 'VectorOut')
                    [x,y] =  stairs([alltimes{k} obj.pinList{k}.timeOffset], [allvalues{k}(1,:) allvalues{k}(1,end)]);
                    x = [0; x; x(end)]; %#ok
                    y = [0; y; 0]*0.9 + (num-1);
                    text(obj.getLength()/100, num-1+0.2, obj.pinList{k}.toString(), 'Clipping','on');
                    patch(x,y, colors(num,:), 'FaceAlpha',0.5);
                    plot(x,y,'*', 'Color',colors(num,:));
                    num = num + 1;
                end
            end % for
            title('amplitude of vector pins');
            ylim([-0.1 num-0.9]);
            xlim([0 obj.getLength()]);
            xlabel('time (s)');
            yticks([]);
            ax(3) = gca;
            
            
            %% vector pins phase
            subplot(2,3,6);
            set(gca, 'Position', [0.675, 0.06, 0.31, 0.40]);
            hold all
            num = 1;
            for k=1:length(obj.pinList)
                if isa(obj.pinList{k}, 'VectorOut')
                    [x,y] =  stairs([alltimes{k} obj.pinList{k}.timeOffset], [allvalues{k}(2,:) allvalues{k}(2,end)]);
                    x = [0; x; x(end)]; %#ok
                    y = [0; y; 0]*0.45 + 1*(num-1)+0.5;
                    text(obj.getLength()/100, 1*(num-1)+0.7, obj.pinList{k}.toString(), 'Clipping','on');
                    patch(x,y, colors(num,:), 'FaceAlpha',0.5);
                    plot(x,y,'*', 'Color',colors(num,:));
                    num = num + 1;
                end
            end % for
            title('phase of vector pins');
            ylim([-0.1 num-0.9]);
            xlim([0 obj.getLength()]);
            xlabel('time (s)');
            yticks([]);
            ax(4) = gca;

            
            %% set other figure properties
            linkaxes(ax,'x');
            dcm_obj = datacursormode(gcf);
            dcm_obj.Enable = 'on';
            dcm_obj.UpdateFcn = @(~,event) obj.datacursorUpdateFunction(event);
            
        end % plot
        
        function output_txt = datacursorUpdateFunction(obj, event)
            %datacursorUpdateFunction this function updating the cursor
            %                         text in plot to show the values
            
            switch event.Target.Parent.Title.String
                case 'analog pins'
                    idx = event.Target.YData(1)+1;
                    
                    num = 0;
                    apin = [];
                    for k=1:length(obj.pinList)
                        if isa(obj.pinList{k}, 'AnalogOut')
                            num = num + 1;
                            if idx==num
                                apin = obj.pinList{k};
                            end
                        end
                    end % for
                    
                    yval = (event.Position(2)-floor(event.Position(2)))/0.09;
                    
                    if ~isempty(apin) || apin.hasCalibration()
                        try
                        output_txt = sprintf('time: %.6f s\nanalog value: %.3f V\ncalibrated value: %.3f %s', ...
                                              event.Position(1), ...
                                              yval, ...
                                              apin.calibration.inverseInterpolate(yval), ...
                                              apin.calibration.unit);
                        catch
                            output_txt = sprintf('time: %.6f s\nanalog value: %.3f V\ncalibrated value: -- %s', ...
                                              event.Position(1), ...
                                              yval, ...
                                              apin.calibration.unit);
                        end
                    else
                        output_txt = sprintf('time: %.6f s\nanalog value: %.3f V', event.Position(1), yval);
                    end
                
                case 'digital pins'
                    output_txt = sprintf('time: %.6f s\nstate: %i', event.Position(1), round((event.Position(2)-floor(event.Position(2)))/0.9));
                    
                case 'amplitude of vector pins'
                    output_txt = sprintf('time: %.6f s\namplitude: %.3f', event.Position(1), (event.Position(2)-floor(event.Position(2)))/0.9);
                    
                case 'phase of vector pins'
                    output_txt = sprintf('time: %.6f s\nphase: %.3f', event.Position(1), (event.Position(2)-floor(event.Position(2)))/0.9);
                    
                otherwise
                    output_txt = '';
            end
        end %datacursorUpdateFunction
        
        function disp(obj)
            %display    Displays all pins which are assigned to this
            %           sequence
            
            disp('Assigned pins to this sequence:');
            
            if isempty(fieldnames(obj.pin))
                disp('  <no pins assigned>');
            else
                disp(obj.pin);
            end
        end % display
        
    end % methods
    
end % classdef

