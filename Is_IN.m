function Is_IN(mWV_Struct, spike_times, IN_Stat)
%% Figure for GUI
hFig = figure('Toolbar','none',...
    'NumberTitle','Off',...
    'color',[1 1 1],...
    'position',[59 200 750 450],... 
    'Name','Interneuron Status');

hFigAx1 = axes('Units','normalized',...
             'position',[0.05 0.6 0.3 0.375]);
set(hFigAx1,'XTickLabel',[],'YTickLabel',[],'ticklength',[0 0]);
hFigAx2 = axes('Units','normalized',...
             'position',[0.45 0.6 0.3 0.375]);
set(hFigAx2,'XTickLabel',[],'YTickLabel',[],'ticklength',[0 0]);
hFigAx3 = axes('Units','normalized',...
             'position',[0.05 0.15 0.3 0.375]);
set(hFigAx3,'XTickLabel',[],'YTickLabel',[],'ticklength',[0 0]);
hFigAx4 = axes('Units','normalized',...
             'position',[0.45 0.15 0.3 0.375]);
set(hFigAx4,'XTickLabel',[],'YTickLabel',[],'ticklength',[0 0]);  

%% Globals
v.IN_Status = false;
v.await_input = false;
v.iCell = 1;
v.dset_size = size(spike_times,1);
IN_Stat = false(size(spike_times,1),1);

num_cells = size(spike_times,1);
NC_str_array = ['/  ' mat2str(num_cells)];

%% GUI controls

%Is IN Text
h_Is_IN_Text = uicontrol('Style','text','fontweight', 'bold',...
    'Units','normalized',...
    'position',[0.05 0.025 0.9 0.075],...
    'HorizontalAlignment','left',...
    'FontSize', 14,...
    'String','Is this an Interneuron? ');

%YES Button
hYES = uicontrol('Style', 'pushbutton', 'String', 'YES',...
    'Units','Normalized',...
    'Position', [0.375 0.035 0.2 0.05],...
    'Enable', 'off',...
    'Callback', @YES);
%NO Button
hNO = uicontrol('Style', 'pushbutton', 'String', 'NO',...
    'Units','Normalized',...
    'Position', [0.6 0.035 0.2 0.05],...
    'Enable', 'off',...
    'Callback', @NO);
%Back Button
hBack = uicontrol('Style', 'pushbutton', 'String', 'Back',...
    'Units','Normalized',...
    'Position', [0.85 0.0375 0.075 0.045],...
    'Enable', 'off',...
    'Callback', @Back);

%Cell Number
h_Cell_Num = uicontrol('Style','text','fontweight', 'bold',...
    'Units','normalized',...
    'position',[0.775 0.15 0.2 0.2],...
    'HorizontalAlignment','center',...
    'FontSize', 14,...
    'String','Cell Number: ');

h_Number = uicontrol('Style','text','fontweight', 'bold',...
    'Units','normalized',...
    'position',[0.83 0.15 0.1 0.1],...
    'HorizontalAlignment','left',...
    'FontSize', 14,...
    'String',mat2str(v.iCell));
h_NumCells = uicontrol('Style','text','fontweight', 'bold',...
    'Units','normalized',...
    'position',[0.875 0.15 0.075 0.1],...
    'HorizontalAlignment','left',...
    'FontSize', 14,...
    'String', NC_str_array);

%Firing Rate
h_FR_Box = uicontrol('Style','text','fontweight', 'bold',...
    'Units','normalized',...
    'position',[0.775 0.45 0.2 0.4],...
    'HorizontalAlignment','center',...
    'FontSize', 14,...
    'String','Firing Rate (Hz)');
h_FR = uicontrol('Style','text','fontweight', 'bold',...
    'Units','normalized',...
    'position',[0.85 0.6 0.1 0.1],...
    'HorizontalAlignment','left',...
    'FontSize', 14,...
    'String', '0');

%%
f_st = spike_times(find(~cellfun(@isempty, spike_times)));
max_length = max(cellfun(@max, f_st));
min_length = min(cellfun(@min,f_st));
rec_length = max_length - min_length;

Plot_IN();
%% Nested Functions

    function YES(hObject, eventdata, handles)
        set(hYES, 'Enable','off')
        set(hNO, 'Enable','off')
        set(hBack, 'Enable', 'off')
        v.IN_Status = true;
        IN_Stat(v.iCell,1) = v.IN_Status;
        v.iCell = v.iCell + 1;
        axes(hFigAx1)
        cla
        axes(hFigAx2)
        cla
        axes(hFigAx3)
        cla
        axes(hFigAx4)
        cla 
        Plot_IN();
    end
    function NO(hObject, eventdata, handles)
        set(hYES, 'Enable','off')
        set(hNO, 'Enable','off')
        set(hBack, 'Enable', 'off')
        v.IN_Status = false;
        IN_Stat(v.iCell,1) = v.IN_Status;
        v.iCell = v.iCell + 1;
        axes(hFigAx1)
        cla
        axes(hFigAx2)
        cla
        axes(hFigAx3)
        cla
        axes(hFigAx4)
        cla 
        Plot_IN();
    end
    function Back(hObject, eventdata, handles)
        set(hYES, 'Enable', 'off')
        set(hNO, 'Enable', 'off')
        set(hBack, 'Enable', 'off')
        v.iCell = v.iCell - 1;
        axes(hFigAx1)
        cla
        axes(hFigAx2)
        cla
        axes(hFigAx3)
        cla
        axes(hFigAx4)
        cla 
        Plot_IN();
    end
    function Plot_IN()
        
        if v.iCell > v.dset_size
            close()
            save IN_Stat IN_Stat
            return 
        else
            h_Number.String = mat2str(v.iCell);
            h_FR.String = mat2str(size(spike_times{v.iCell,1},2) / rec_length,3);

            axes(hFigAx1)
            plot(mWV_Struct{v.iCell,1}(:,1))
            set(hFigAx1,'XTickLabel',[],'YTickLabel',[],'ticklength',[0 0]);
            axes(hFigAx2)
            plot(mWV_Struct{v.iCell,1}(:,2))
            set(hFigAx2,'XTickLabel',[],'YTickLabel',[],'ticklength',[0 0]);
            axes(hFigAx3)
            plot(mWV_Struct{v.iCell,1}(:,3))
            set(hFigAx3,'XTickLabel',[],'YTickLabel',[],'ticklength',[0 0]);
            axes(hFigAx4)
            plot(mWV_Struct{v.iCell,1}(:,4))
            set(hFigAx4,'XTickLabel',[],'YTickLabel',[],'ticklength',[0 0]); 

            set(hYES, 'Enable','on')
            set(hNO, 'Enable','on') 
            set(hBack, 'Enable', 'on')
        end
        
    end

end
