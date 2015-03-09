%%%%
% CrossSectionPanel.m         
% Michelle Flanner: 2/15/2015 
%%%%

%%%%
% CrossSectionPanel is a UI/computational tool designed to offer  
% functionality for analyzing images, or more generally, datapoints plotted
% in a regular grid in a 2D region in matlab Axes. It provides an interface
% for constructing a line through any two points on a regular grid 
% (integer delimitered axes). The points that make up the line are recorded
% where the line exits and enters each adjacent 1x1 grid square in its path.
% Using these points and the segments they divide the line into, one can 
% plot a cross section of the image (or otherwise) along any straight line
% drawn on the image. 
%%%%

% Construct the CrossSectionPanel ui component and return it as a
% positionable uipanel
function ContainerPanel = CrossSectionPanel(fig, imgAxes, axesData)
    
    %%%%                
    % UIPanel Configuration
    %%%%                
    
    % Existing line, line data, distance to points on line data
    currentZLine    = line([],[]);
    x_y_p           = [[]];
    D_Z             = [[]];
    % Uipanel for plot and btnpanel
    ContainerPanel  =   uipanel(    'Title',    'Cross Section Plot',...
                                    'BackgroundColor','white');
    % Uipanel for buttons  
    BtnPanel        =   uipanel(    'Parent'    ,ContainerPanel,...
                                    'Title'     ,'Draw ZLines',...
                                    'BackgroundColor','white',...
                                    'Units'     ,'normalized');                                    
    % Text label for ZLineEndpointsEdit feild
    ZLineEndpointText=  uicontrol(  'Parent',   BtnPanel,...
                                    'Style'     ,'text',...
                                    'String'	,'Endpoints for Zline:',...
                                    'Units'     ,'normalized');
    % Edit field for ZLineEndpoints
    ZLineEndpointEdit=  uicontrol(  'Parent'    ,BtnPanel,...
                                    'Style'   	,'edit',...
                                    'String' 	,'x1 y1 x2 y2',...
                                    'Units'  	,'normalized',...
                                    'Callback'	,@ZLineEndpointEdit_Callback);
    % Button for drawing ZLine
    DrawZLineBtn    =   uicontrol(  'Parent'    ,BtnPanel,...
                                    'Style'   	,'pushbutton',...
                                    'String' 	,'Draw ZLine',...
                                    'Units'  	,'normalized',...
                                    'Callback'  ,@DrawZLineBtn_Callback);
    % Button for deleting zlines drawn on imgView
    ClearZLinesBtn  =   uicontrol(  'Parent'    ,BtnPanel,...
                                    'Style'   	,'pushbutton',...
                                    'String'  	,'Clear Zlines',...
                                    'Units'   	,'normalized',...
                                    'Callback' 	,@ClearZLinesBtn_Callback);
    % Axes for the Zplot
    ZPlotAxes       =   axes(       'Parent'    ,ContainerPanel,...
                                    'Units'     ,'normalized',...
                                    'YAxisLocation','right',...
                                    'NextPlot'  ,'replace');
    arrangePanelContents(.6,.8);
    
    %%%%  
    % UIControl Callbacks
    %%%%
    
    % Arrange uicontrol componenents within panel 
    function arrangePanelContents(plotwidth,plotheight)
        % Plot alignment
        plotheight  = plotheight;
        vertplotpad = (1-plotheight)/2;
        plotwidth   = plotwidth;
        horzplotpad = (1-plotwidth)/6;
        % Button panel alignment
        btnpanelht  = plotheight/2;
        btnpanelw   = (1-plotwidth)/2; 
        % Button alignment
        btnnum      = 3;
        vertbtnpad  = 1/(btnnum+3);
        btnheight   = vertbtnpad;
        btnspace    = btnheight/2;
        btnwidth    = .75;
        horzbtnpad  = (1-btnwidth)/2;
        
        % Button panel position relative to container panel
        bottom  = vertplotpad+plotheight/2;
        left    = plotwidth+2*horzplotpad;
        BtnPanel.Position           = [left bottom  btnpanelw   btnpanelht];
        % ClearZLines button position (closest to bottom of button panel)
        bottom  = vertbtnpad;
        left    = horzbtnpad;
        ClearZLinesBtn.Position     = [left bottom  btnwidth    btnheight];
        % DrawZLine button position (above ClearZLines button)
        bottom  = bottom+btnspace+btnheight;
        DrawZLineBtn.Position       = [left bottom  btnwidth    btnheight];
        % ZLineEndpointEdit button position (above EndpointEdit)
        bottom  = bottom+btnspace+btnheight;
        ZLineEndpointEdit.Position  = [left bottom  btnwidth    btnheight/2];
        % ZLineEndpointText label above EndpointEdit
        bottom  = bottom+btnheight/2;
        ZLineEndpointText.Position  = [left bottom  btnwidth    btnheight/2];
        % ZPlotAxes position relative to container panel
        left    = horzplotpad;
        bottom  = vertplotpad;
        ZPlotAxes.Position          = [left bottom  plotwidth   plotheight];
    end
    
    % User enters endpoints for line in indicated order, passes to drawZLine 
    function ZLineEndpointEdit_Callback(ch,~)
        str = ch.String;
        endpoints = sscanf(str, '%d')
        currentZLine = drawZLine([endpoints(1),endpoints(3)],[endpoints(2),endpoints(4)]);
    end

    % Callback for the DrawZLineBtn. Give focus to imgAxes, ginput gets the
    % coordinates where the user clicks and passes them to drawZLine.
    function DrawZLineBtn_Callback(ch,~)

        % While the current axis is imgAxes,
        % store click points in a 2x2 matrix with x and y as column values
        endpoints1 = ginput(1)
        if gca == imgAxes
            endpoints2 = ginput(1)
        end
        if gca == imgAxes
            X=[floor(endpoints1(1,1)),floor(endpoints2(1,1))];
            Y=[floor(endpoints1(1,2)),floor(endpoints2(1,2))];
            % once ginput has collected 2 points, call drawZLine()
            % and set the line it draws to be the current zline
            currentZLine = drawZLine(X,Y)
        end
          
    end

    % Callback for the ClearZLinesBtn
    function ClearZLinesBtn_Callback(ch,~)
        delete(currentZLine);
    end 
    
    % Draw the Zline on ImgView axes. Line determined by endpoints entered in
    % ZLineEndpointEdit or by clicking on ImgView axis (AFTER clicking on
    % DrawZLineBtn). Line constructed to begin and end at the center of 
    % each endpoint pixel 
    function zLine = drawZLine(X,Y)
        
        % Given y on the line, calculate x=y/m
        function line_eval = evalX(y)
           line_eval=y/m;
        end
         
        % Given x on the line, calculate y=mx 
        function line_eval = evalY(x)
            line_eval=x*m;
        end
        
        % Calculate points on line where x,y are integer values, offset by .5
        function x_y_pts()
            for j=.5:1:abs(dy)-.5
                x_y_p(end+1,:)=[evalX(j),j];
            end
            for j=.5:1:abs(dx)-.5
                x_y_p(end+1,:)=[j,evalY(j)];
            end
        end
        
        % delta x,y, points on line, distances between points, slope 
        dx      = X(2)-X(1);
        dy      = Y(2)-Y(1); 
        x_y_p   = [[0,0];[abs(dx),abs(dy)]];
        D_Z     = [[]];
        m       = abs(dy/dx);
        
        x_y_pts();
        
        % Test for inf (vertical slope), 0 (horizontal slope)
        % Correct line offset and displacement
        if m==inf
            x_y_p(:,1)  = X(1)+x_y_p(:,1)+.5;
            x_y_p(:,2)  = Y(1)+(abs(dy)/dy)*x_y_p(:,2)+.5;
        elseif m==0
            x_y_p(:,1)  = X(1)+(abs(dx)/dx)*x_y_p(:,1)+.5;
            x_y_p(:,2)  = Y(1)+x_y_p(:,2)+.5;
        else
            x_y_p(:,1)  = X(1)+(abs(dx)/dx)*x_y_p(:,1)+.5;
            x_y_p(:,2)  = Y(1)+(abs(dy)/dy)*x_y_p(:,2)+.5;
        end
        
        % Select ImgViewAxes, replace current line
        fig.CurrentAxes = imgAxes;
        zLine = line(x_y_p(:,1)-.5,x_y_p(:,2)-.5);
        if ~isequal(zLine, currentZLine)
            delete(currentZLine);
        end
        
        % Test if data is present in imgAxes 
        if max(x_y_p(:,1)) <= length(axesData) && max(x_y_p(:,2)) <= length(axesData)
            updateZPlot();
        end
    end

    % Interpolate Z value between Z values on either side of floating point
    % 'pixel' coordinate
    function z_interpolated = interpolateZ(x,y)
        z_lower = axesData(floor(y),floor(x));
        z_upper = axesData(floor(y)+1,floor(x)+1);
        if x ~= floor(x)
            % x_delta_gt, x_delta_lt are distances from x coordinate to 
            % adjacent integers.
            x_delta_gt = floor(x)+1-x;
            x_delta_lt = x-floor(x);
            
            % Test which Z value gets more weight
            if x_delta_gt > x_delta_lt
                z_interpolated = x_delta_gt*z_lower+x_delta_lt*z_upper;
            else
                z_interpolated = x_delta_gt*z_upper+x_delta_lt*z_lower;
            end
        else
            y_delta_gt = floor(y)+1-y;
            y_delta_lt = y-floor(y);
            if y_delta_gt > y_delta_lt
                z_interpolated = y_delta_gt*z_lower+y_delta_lt*z_upper;
            else
                z_interpolated = y_delta_gt*z_upper+y_delta_lt*z_lower;
            end
        end
    end

    % Plot Z values occurring at pixel coordinates on Zline
    % vs cumulative distance along line. Called from DrawZLine 
    function updateZPlot()
        
        function d = distance_to(x,y)
            d = sqrt((x_y_p(1,1)-x).^2+(x_y_p(1,2)-y).^2);
        end
        
        D_s = zeros(1,length(x_y_p(:,1)));
        Z_s = zeros(1,length(x_y_p(:,1)));
        
        for c=1: length(x_y_p(:,1))
            D_Z(c,1)=distance_to(x_y_p(c,1),x_y_p(c,2));
            D_Z(c,2)=interpolateZ(x_y_p(c,1),x_y_p(c,2));
        end
        D_Z = sortrows(D_Z);
        D_s = D_Z(:,1);
        Z_s = D_Z(:,2);
        fig.CurrentAxes = ZPlotAxes;
        plot(D_s,Z_s);
        
    end 
end
end
