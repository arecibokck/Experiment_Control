classdef Pin < matlab.mixin.Copyable    %like handle but copyable
    %Pin   Base class for pins and their time evolution
    
    properties (SetAccess = protected)
        times = [];     %containing absolute time values in seconds (list ordered)
        values = [];    %containing values (might be nx2 array, e.g. VectorOut)
        timeOffset = 0; %last synchronized time in seconds
        name = '';      %name of pin: should be unique (case sensitive) for each type, typically assigned by AdwinParser object
        userName = '';  %user defined name
    end % properties
    
    methods
        function obj = Pin(c, varargin)
            %Pin   Default constructor
            %f
            %   Inputs:
            %         c    Pin name (default constructor)
            %              or existing pin (copy constructor)
            %  userName   (optional) user defined name, set in default
            %              constructor mode
            if nargin>2
                error('Too many Input arguments. Two expected.')
            end
            
            if ischar(c)           %required pin name
                if ~isvarname(c)
                    error('Pin Name is expected to be valid variable name.');
                end
                obj.name = c;
                if nargin==2        %check for user name
                    if ischar(varargin{1})
                        obj.userName = varargin{1};
                    else
                        error('char string required for user pin name');
                    end
                else
                    obj.userName = '';
                end
            elseif isa(c, 'Pin')    %copy names from given pin
                obj.name = c.name;
                obj.userName = c.userName;
            else
                error('char string required for pin name');
            end
        end % Pin
        
        function val = eq(obj1, obj2)
            %eq  This function checks whether two pin objects refer to the same pin
            %
            %   Inputs:
            %      obj2  Pin object
            if ~isa(obj2,'Pin')
                error('Pin objects required');
            end
            val = strcmp(obj1.name,obj2.name);
        end % eq
        
        function plot(obj, varargin)
            %plot    This function plots the time evolution
            %
            %    Inputs:
            %      (opional) alone   argument controls whether plotting
            %                        alone (1) or with hold on (0)
            
            plotAlone = 1;
            
            if nargin>1
                if ~any([0,1]==varargin{1})
                    warning('wrong input parameter. will be ignored.');
                else
                    plotAlone = ~varargin{1};
                end
            end
            
            if plotAlone
            
                if ~isempty(obj.times)
                    [xx,yy] = stairs([0 obj.times],[0 obj.values]);
                    patch([0 xx' obj.timeOffset obj.timeOffset],[0 yy' yy(end) 0],'c');
                    line([obj.timeOffset obj.timeOffset],[min(obj.values) max(obj.values)],'LineWidth',4,'Color',[0 1 0]);
                    hold on
                    stairs([0 obj.times],[0 obj.values],'r');
                    hold off
                    if min([obj.times obj.timeOffset])~=max([obj.times obj.timeOffset])
                        xlim([0 max([obj.times obj.timeOffset])]);
                    end
                else
                    plot(0,0);
                    line([obj.timeOffset obj.timeOffset],[0 1],'LineWidth',4,'Color',[1 0 0]);
                end
                ylabel(strcat(obj.getName(),' [',obj.toString(),']'));
                xlabel('time (s)');
                
            else
                
                if ~isempty(obj.times)
                    %[xx,yy] = stairs(obj.times,obj.values);
                    %patch([0 xx' obj.timeOffset obj.timeOffset],[0 yy' yy(end) 0],'c');
                    %hold on
                    stairs([0 obj.times obj.timeOffset],[0 obj.values obj.values(end)],varargin{2:end});
                else
                    plot(0,0,varargin{2:end});
                    %line([obj.timeOffset obj.timeOffset],[0 1],'LineWidth',4,'Color',[1 0 0]);
                end
                
%                 if obj.type.isAnalog()
%                     ylabel('voltage');
%                     %legend(obj.toString());
%                 elseif obj.type.isDigital()
%                     ylabel('value');
%                     %legend(obj.toString());
%                     %set(legend(gca),strcat(get(legend(gca),'String'),obj.toString()));
%                 else
%                     ylabel(strcat(obj.getName(),' [',obj.toString(),']'));
%                 end
                ylabel('value');
                xlabel('time (s)');
                
            end
        end % plot
        
        
        %% methods related to setting states
        
        function obj = horzcat(varargin)
            %horzcat   This function concatenates the time evolution of a given pin
            %
            %    Note:  Time offsets syncronized. Function is NOT commutative!
            %
            %    Inputs
            %      varying number of pin objects to be concatenated
            if nargin<2
               error('insufficient number of parameters'); 
            end
            for k = 1:length(varargin)
                if ~isa(varargin{k},'Pin')
                    error('Pin objects needed');
                end
                if k>1 && ~(varargin{k}==varargin{k-1})
                    error('Pin objects are for different pins');
                end
            end
            
            obj = varargin{1}.copy();
            
            for k = 2:length(varargin)
                obj.times = [obj.times, varargin{k}.times + obj.timeOffset];
                obj.values = [obj.values varargin{k}.values];
                obj.timeOffset = obj.timeOffset + varargin{k}.timeOffset;
            end % for
            
            if length(obj.times)>1 && any(obj.times(2:end)<=0)
                warning('Some values of the sequence will be ignored due to zero delay conditions.'); 
            end
        end % horzcat
        
        function obj = state(obj, x, varargin)
            %state   Set a new state in time evolution of this pin
            %
            %   Inputs
            %       x            state value(s) or array of states to be added
            %       t(optional)  corresponding time vector with time differences
            %                    to earlier state / time offset
            if islogical(x)
                x = +x; % convert logicals to double
            end
            if nargin>2
                %time value pairs
                if ~isnumeric(x) || ~isnumeric(varargin{1}) ...
                        || size(x,2)~=numel(varargin{1}) ...
                        || ~any([1 2]==size(x,1))
                    error('State and Time vectors need to be numeric arrays of the same size');
                end
                t = cumsum(varargin{1}) + obj.timeOffset;
            else
                %simple state value
                if ~isnumeric(x) || ~any([1 2] == size(x,1))
                    error('state needs to be scalar value');
                end
                t = obj.timeOffset;
            end
            
            %TODO improve check that no time delay of 0 appears
            if ~isempty(obj.times) && any(t==0)
                warning('zero delay times found.');
            end
            
            obj.times  = [obj.times  t(:)'];  % t(:) to orientate correctly
            obj.values = [obj.values x];      % x needs to be correctly oriented            
            obj.timeOffset = obj.times(end);
        end % state
        
        
        %% methods to getting states / times 
        
        function [y,x] = getState(obj, t)
            %getState    This function returns the state at a given time
            %
            %   Inputs
            %        t   Time value
            if ~isscalar(t) || t<0
                error('non-negative number required for time variable');
            end
            
            if isempty(obj.values)
                x = [];
                y = [];
                return;
            end
            
            ind = find(obj.times<=t,1,'last');
            
            y = obj.values(:,ind);
            x = obj.times(ind);
        end % getState
        
        function [y,x] = getFirstState(obj)
            %getFirstState   This function returns the first state of the
            %                time evolution
            if isempty(obj.values)
                x = [];
                y = [];
                return;
            end
            
            y = obj.values(:,1);
            x = obj.times(1);
        end % getFirstState
        
        function [y,x] = getLastState(obj)
            %getLastState    This function returns the last state of the
            %                time evolution
            if isempty(obj.values)
                x = [];
                y = [];
                return;
            end
                
            y = obj.values(:,end);
            
            if obj.timeOffset>obj.times(end)
                x = obj.timeOffset;
            else
                x = obj.times(end);
            end
        end % getLastState
        
        %% methods retlated to time
    
        function obj = wait(obj, t)
            %wait      Wait for a given time
            %
            %   Input
            %        t   time in s
            if ~isnumeric(t) || ~isscalar(t) || t<0
                error('waiting time must be non-negative value');
            end
            obj.timeOffset = obj.timeOffset + t;
        end % wait
            
        function obj = wait_ms(obj, t)
            %wait_ms    Wait for a given time
            %
            %   Input
            %        t   time in ms
            if ~isnumeric(t) || ~isscalar(t) || t<0
                error('waiting time must be non-negative value');
            end
            obj.timeOffset = obj.timeOffset + t*1e-3;
        end % wait_ms
        
        function obj = wait_us(obj, t)
            %wait_us    Wait for a given time
            %
            %   Input
            %        t   time in us
            if ~isnumeric(t) || ~isscalar(t) || t<0
                error('waiting time must be non-negative value');
            end
            obj.timeOffset = obj.timeOffset + t*1e-6;
        end % wait_us
        
        function obj = shiftTime(obj, dt)
            %shiftTime   This function shifts the hole time vector by a
            %            given value
            %
            %   Inputs
            %       dt   Time in s for shifting
            if ~isnumeric(dt) || ~isscalar(dt) || dt<0
                error('waiting time must be non-negative value');
            end
            
            obj.times = obj.times + dt;
            obj.timeOffset = obj.timeOffset + dt;
        end % shiftTime
        
        function t = getLastUpdateTime(obj)
            %getLastUpdateTime   Returns last time in time vector
            %
            %   Note:   This function differs from time given by getLastState!
            %           It just returns the last time in time vector.
            %           An additional waiting time by timeOffset is neglected.
            if isempty(obj.values)
                error('No assignment has been done yet');
            end
                
            t = obj.times(end);
        end % getLastUpdateTime
        
        
        %% methods related to setting names
        
        function str = toString(obj)
            %toString  Return unique Pin Name
            str = obj.name;
        end % toString
        
        function str = getName(obj)
            %getName    Ths function return the user-defined name of the pin
            str = obj.userName;
        end % getName
        
        function obj = setName(obj, name)
            %setName    This function sets the user-defined name for this pin
            %
            %   Input
            %     name  Pin name
            if ~isa(name,'char')
                error('string type required for user-defined pin name');
            end
            obj.userName = name;
        end % getName
        
    end % methods
    
    
    %% protected methods
    
    methods (Access = protected)        
        function cpObj = copyElement(obj)
            %copyElement   Make a shallow copy of all properties
            cpObj = copyElement@matlab.mixin.Copyable(obj);
        end % copyElement
    end % methods
    
end %classdef
