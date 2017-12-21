
function varargout = Live_Segmentation(varargin)
% LIVE_SEGMENTATION MATLAB code for Live_Segmentation.fig
%      LIVE_SEGMENTATION, by itself, creates a new LIVE_SEGMENTATION or raises the existing
%      singleton*.
%
%      H = LIVE_SEGMENTATION returns the handle to a new LIVE_SEGMENTATION or the handle to
%      the existing singleton*.
%
%      LIVE_SEGMENTATION('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in LIVE_SEGMENTATION.M with the given input arguments.
%
%      LIVE_SEGMENTATION('Property','Value',...) creates a new LIVE_SEGMENTATION or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Live_Segmentation_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Live_Segmentation_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help Live_Segmentation

% Last Modified by GUIDE v2.5 19-May-2015 11:18:06

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Live_Segmentation_OpeningFcn, ...
                   'gui_OutputFcn',  @Live_Segmentation_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT

% --- Executes just before Live_Segmentation is made visible.
function Live_Segmentation_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Live_Segmentation (see VARARGIN)

% Choose default command line output for Live_Segmentation
handles.output = hObject;

imaqreset;

global counter;
counter = 0;
handles.videoL = 20;
handles.filename_file = 'filename';
global interupt_flag;
interupt_flag = 0;

% Remove all figures that are currently being displayed
%close all

% Create video object
%   Putting the object into manual trigger mode and then
%   starting the object will make GETSNAPSHOT return faster
%   since the connection to the camera will already have
%   been established.
handles.video = videoinput('qimaging', 1, 'MONO8_696x520');
%handles.video = videoinput('winvideo', 1, 'RGB24_800x600');

handles.src = getselectedsource(handles.video);
%handles.video.ReturnedColorspace = 'grayscale';

%handles.src.ExposureMode = 'manual';
%handles.src.Exposure = -1;
handles.counter = 0;
%set(handles.video,'TimerPeriod', 0.5, ...
      %'TimerFcn',@readCamera);
%triggerconfig(handles.video,'manual');
set(handles.startAcquisition,'Enable','off');
set(handles.captureImage,'Enable','off');
%handles.video.FramesPerTrigger = Inf; % Capture frames until we manually stop it

%set background
axes(handles.background);
uistack(handles.background,'bottom');
I=imread('background.jpeg');
position = get(handles.background,'Position');
I = imresize(I,[position(4),position(3)]);
imshow(I);
set(handles.background,'handlevisibility','off','visible','off');

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes Live_Segmentation wait for user response (see UIRESUME)
uiwait(handles.Live_Segmentation);


% --- Outputs from this function are returned to the command line.
function varargout = Live_Segmentation_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Get default command line output from handles structure
handles.output = hObject;
varargout{1} = handles.output;


% --- Executes when user attempts to close Live_Segmentation.
function Live_Segmentation_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to myCameraGUI (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: delete(hObject) closes the figure
delete(hObject);
delete(imaqfind);


% --- Executes on button press in startStopCamera.
function startStopCamera_Callback(hObject, eventdata, handles)
% hObject    handle to startStopCamera (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Start/Stop Camera
if strcmp(get(handles.startStopCamera,'String'),'Start Camera')
      % Camera is off. Change button string and start camera.
      set(handles.startStopCamera,'String','Stop Camera')
      set(handles.startStopCamera,'Backgroundcolor',[.8,0,0]);
      %start(handles.video)
      readCamera(hObject,eventdata,handles);
      frame_rate = test_frame_rate(handles.video);
      set(handles.frame_rate,'String',num2str(frame_rate));
      handles.frame_sep = 1/frame_rate;
      set(handles.startAcquisition,'Enable','on');
      set(handles.captureImage,'Enable','on');
      set(handles.video_length,'Enable','on');
      set(handles.filename,'Enable','on');
else
      % Camera is on. Stop camera and change button string.
      stoppreview(handles.video)
      set(handles.startStopCamera,'String','Start Camera')
      set(handles.startStopCamera,'Backgroundcolor',[0,.8,0]);
      stop(handles.video)
      set(handles.startAcquisition,'Enable','off');
      set(handles.captureImage,'Enable','off');
end
guidata(hObject,handles);


% --- Executes on button press in captureImage.
function captureImage_Callback(hObject, eventdata, handles)
% hObject    handle to captureImage (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% frame = getsnapshot(handles.video);
frame = get(get(handles.live_video,'children'),'cdata'); % The current displayed frame
save('testframe.mat', 'frame');
disp('Frame saved to file ''testframe.mat''');


% --- Executes on button press in startAcquisition.
function startAcquisition_Callback(hObject, eventdata, handles)
% hObject    handle to startAcquisition (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Start/Stop acquisition
global interupt_flag;
if strcmp(get(handles.startAcquisition,'String'),'Start Acquisition')
      % Camera is not acquiring. Change button string and start acquisition.
      set(handles.startAcquisition,'String','Stop Acquisition');
      set(handles.video_length,'Enable','off');
      set(handles.startAcquisition,'BackgroundColor',[.8,0,0]);
      tic
	  
      if(~exist(['Z:/SCN/Jared/May videos/',handles.filename_file,'.avi'],'file'))
          %vidFile = VideoWriter(['Z:/SCN/Jared/May videos/',handles.filename_file],'Uncompressed AVI');
          vidFile = VideoWriter(handles.filename_file,'Uncompressed AVI');
          vidFile.FrameRate = 1/handles.frame_sep;
          open(vidFile);
          frame_count = 0;
          handles.elapsed_time = toc;
          %while(handles.elapsed_time<handles.videoL || interupt_flag)
          while(1)
              if(handles.elapsed_time>(frame_count*handles.frame_sep))
                  frame_count = frame_count+1;
                  frame = getsnapshot(handles.video);
                  writeVideo(vidFile,frame);
              end
              handles.elapsed_time = toc;
              disp(toc)
              if(handles.elapsed_time>handles.videoL || interupt_flag)
                  close(vidFile)
                  set(handles.startAcquisition,'String','Start Acquisition');
                  set(handles.startAcquisition,'BackgroundColor',[0,.8,0]);
                  set(handles.video_length,'Enable','on');
                  set(handles.filename,'Enable','on');
                  handles.elapsed_time = 0;
                  interupt_flag = 0;
                  break;
              end
              %Why i need this pause I have no clue but it keeps the video
              %feed from freezing
              pause(.001);
          end
      else
          msgbox('This file already exists!!')
          set(handles.startAcquisition,'String','Start Acquisition');
          set(handles.startAcquisition,'BackgroundColor',[0,.8,0]);
          set(handles.video_length,'Enable','on');
      end

else
      handles.elapsed_time = inf;
      interupt_flag = 1;
      set(handles.startAcquisition,'String','Start Acquisition');
      set(handles.startAcquisition,'BackgroundColor',[0,.8,0]);
      set(handles.video_length,'Enable','on');
end
guidata(hObject,handles);


% --- Executes on slider movement.
function slider_exposure_Callback(hObject, eventdata, handles)
% hObject    handle to slider_exposure (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

handles.src.Exposure = get(hObject,'Value')*.5+.001;
guidata(hObject,handles);


% --- Executes during object creation, after setting all properties.
function slider_exposure_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider_exposure (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function threshold_Callback(hObject, eventdata, handles)
% hObject    handle to threshold (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
handles.threshold = get(hObject,'Value')*255;
guidata(hObject,handles);


% --- Executes during object creation, after setting all properties.
function threshold_CreateFcn(hObject, eventdata, handles)
% hObject    handle to threshold (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

function readCamera(hObject,eventdata,handles)
global counter;
if(~isempty(gco))
    
    axes(handles.live_video);
    vidRes = get(handles.video, 'VideoResolution');
    nBands = get(handles.video, 'NumberOfBands');
    hImage = image( zeros(vidRes(2), vidRes(1), nBands) );
    preview(handles.video, hImage);
    counter = counter + 1;
    %toc

    if(counter > 3)
        frame = getsnapshot(handles.video);
        segmentBodies(frame,handles);
        counter = 0;
    end

else 
    delete(imaqfind);
end

function segmentBodies(handles)
%{
frame = get(get(handles.live_video,'children'),'cdata');
% H = rgb2hsv(uint8(frame));
% mask = bwareaopen(H(:,:,1)<.05|H(:,:,1)>.9,400);
% 
% labeled = bwlabel(mask);
% 
% blobs = regionprops(mask,'MajorAxisLength','MinorAxisLength','Area');
% ind = [];
% for i = 1:length(blobs)
%     ratio = blobs(i).MajorAxisLength/blobs(i).MinorAxisLength;
%     area_ratio = blobs(i).MajorAxisLength*blobs(i).MinorAxisLength/blobs(i).Area;
%     if(ratio>2.7||ratio<2.2||area_ratio>1.4)
%         ind=[ind,i];
%         labeled(labeled==i)=0;
%     end
% end
imagesc(labeled>0);
set(gca,'xtick',[])
set(gca,'xticklabel',[])
set(gca,'ytick',[])
set(gca,'yticklabel',[])
%}
    %axes(handles.segmented_video);
    hold on;
    frame = get(get(handles.live_video,'children'),'cdata');
    imgb = frame(:,:,1)>handles.threshold;
    imgb = bwareaopen(imgb,500,4);
    %imgb = bwareaopen(imgb,2000,4);
    bounds = bwboundaries(imgb,8);
    colors = jet(length(bounds));
    %imshow(frame);
    imagesc(frame);
    set(gca,'xtick',[])
    set(gca,'xticklabel',[])
    set(gca,'ytick',[])
    set(gca,'yticklabel',[])
    for i = 1:length(bounds)
        temp = bounds{i};
        plot(temp(1:10:end,2),temp(1:10:end,1),'color',colors(i,:),'linewidth',2)
    end




function video_length_Callback(hObject, eventdata, handles)
% hObject    handle to video_length (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of video_length as text
%        str2double(get(hObject,'String')) returns contents of video_length as a double
handles.videoL = str2double(get(hObject,'String'));
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function video_length_CreateFcn(hObject, eventdata, handles)
% hObject    handle to video_length (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function [framerate] = test_frame_rate(vid)
%test frame rate
tic;
num_frames = 10;
for i  = 1:num_frames
    frame = getsnapshot(vid);
end
h = toc;
framerate = num_frames/h;


% --- Executes on button press in segment_bodies.
function segment_bodies_Callback(hObject, eventdata, handles)
% hObject    handle to segment_bodies (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%while(1)
    axes(handles.segmented_video);
    vidRes = get(handles.video, 'VideoResolution');
    nBands = get(handles.video, 'NumberOfBands');
    hImage = image( zeros(vidRes(2), vidRes(1), nBands) );
    %cla(handles.segmented_video);
    %preview(handles.video, hImage);
    segmentBodies(handles);
    pause(.001);
%end



function filename_Callback(hObject, eventdata, handles)
% hObject    handle to filename (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of filename as text
%        str2double(get(hObject,'String')) returns contents of filename as a double
handles.filename_file = get(hObject,'String');
if(strcmp(handles.filename_file(end-2:end),'avi'))
	handles.filename_file = handles.filename_file(1:end-4);
	set(hObject,'String',handles.filename_file);
end
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function filename_CreateFcn(hObject, eventdata, handles)
% hObject    handle to filename (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function frame_rate_Callback(hObject, eventdata, handles)
% hObject    handle to frame_rate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of frame_rate as text
%        str2double(get(hObject,'String')) returns contents of frame_rate as a double
max_framerate = test_frame_rate(handles.video)*.8;
user_framerate = str2double(get(hObject,'String'));
if(user_framerate < max_framerate)
    handles.frame_sep = 1/str2double(get(hObject,'String'));
else
    handles.frame_sep = 1/max_framerate;
    set(handles.frame_rate,'String',num2str(max_framerate));
end
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function frame_rate_CreateFcn(hObject, eventdata, handles)
% hObject    handle to frame_rate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
