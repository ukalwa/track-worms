function prefix = segmentation
clear all
close all

% read video file
[filename,path] = uigetfile('*.mp4');
file = [path filename];
vid = VideoReader(file);
disp(file);
vidD = vid;

% Label worm number
worm_num = get_worm_num(file);
disp(worm_num);

% Create a output video file to overlay tracking points on the worm
writerObj = VideoWriter([file(1:end-4),'_worm',num2str(worm_num)],'MPEG-4');
writerObj.FrameRate = vidD.FrameRate;
open(writerObj);

steps = 13; % Number of tracking points
body = zeros(steps,2); % Skeleton of the worm
colors = jet(steps);
startingIndex = 1;
exceldata = []; % Excel sheet for recording x and y locations of skeleton
intensity_value = 30;
% minimum distance between points
% changed according to different worm sizes
dist_thresh = 10; 
%%
% Loop through all the frames in the video
for j = startingIndex:vid.NumberOfFrames
    img = read(vid,j);
    % convert to binary image
    img = img(:,:,1)>intensity_value;
    % remove blobs in the binary image less than 500 and greater than 10000
    % pixel areas (Only worms remain after this point)
    img=bwareaopen(img,500,4);
    max_img = ~bwareaopen(img,10000);
    img = img&max_img;
    
    % extract boundary of the worm
    border=bwperim(img);
    imgD = read(vidD,j);
    
    % Ask user to select an end point of a worm that is to be analysed
    if(j==startingIndex)
        imshow(imgD);
        [col,row] = ginput(1);
        col = round(col);
        row = round(row);
        body(1,1) = row;
        body(1,2) = col;  
    else
        label = bwlabel(img);
        label2 = label.*double(prev_img);
        values = unique(label2);
        values(values==0) = [];
        img = label==values(1);
        for i = 2:length(values)
            img = img|label==values(i);
        end
        skel = bwmorph(img,'thin','inf');
        endpoints = bwmorph(skel,'endpoints');
        [row,col] = find(endpoints);
        dist = zeros(length(row),1);
        for i = 1:length(row)
            dist(i) = sqrt((body(1,2)-col(i))^2+(body(1,1)-row(i))^2);
        end
        
        row(dist>dist_thresh) = [];
        col(dist>dist_thresh) = [];
        dist(dist>dist_thresh) = [];
        
        [~,n] = min(dist);
        col = col(n);
        row = row(n);
        if(~isempty(row))
            body(1,1) = row;
            body(1,2) = col;
        else
            [row,col] = find(skel);
            dist = (body(1,2)-col).^2+(body(1,1)-row).^2;
            [~,n] = min(dist);
            col = col(n);
            row = row(n);
            body(1,1) = row;
            body(1,2) = col;
            disp('Points are too close. Verification needed')
            disp(min(dist))
            disp(j);
        end
    end
    
    % Calculate the distance of the other end point
    D = bwdistgeodesic(img,round(body(1,2)),round(body(1,1)));
    D(D==inf) = NaN;
    
    % Find optimal point locations of skeleton along the body
    prevVal = 0;
    lastPointFound = 0;
    for i = 1:steps
        sep = max(D(:))/(steps);
        bin = D>((i-1)*sep)&D<(i*sep);
        if(j>startingIndex)
            R = round(body(i,1));
            C = round(body(i,2));
            subSample = D(R-3:R+3,C-3:C+3);
            subSample(isnan(subSample)) = 0;
            val = sum(subSample(:))/sum(sum(subSample>0));
            folds = ~img;
            [~,n] = bwlabel(folds);
            if(n>1)
                lower = val-sep/2;
                if(lower<0)
                    lower = 0;
                end
                bin = D>lower&D<(val+sep/2);
            end
            prevVal = val;
        end

        blob = regionprops(bin,uint8(bin),'WeightedCentroid');
        if(size(blob,1)>1)
            dist = zeros(size(blob,1),1);
            for z = 1:length(dist)
                dist(z) = sqrt( ...
                (body(i,1)-blob(z).WeightedCentroid(2))^2+...
                    (body(i,2)-blob(z).WeightedCentroid(1))^2);
            end
            [~,n] = min(dist);
            blob = blob(n);
             
        end
        
        if(~(size(blob,1)==0))
            if(j>startingIndex)
                body(i,1) = (blob(1).WeightedCentroid(2)+body(i,1))/2;
                body(i,2) = (blob(1).WeightedCentroid(1)+body(i,2))/2;
            else
                body(i,1) = blob(1).WeightedCentroid(2);
                body(i,2) = blob(1).WeightedCentroid(1);
            end
            lastPointFound = i;
        else
            disp(['Frame: ',num2str(j),' point: ',num2str(i)]);
        end
    end
    
    % Smooth the points by cubic interpolation
    temp = distributePoints(body(1:lastPointFound,:),steps,10);
    if(~isempty(temp))
        body = temp;
    end
    
    % Display the image along with tracking points information
    imgD(:,:,2) = imgD(:,:,2)+uint8(border)*255;
    clf('reset');
    imshow(imgD,'border','tight');
    hold on;
    pause(.001);
    for i = 1:length(body)
        plot(body(i,2),body(i,1),'ro','color',colors(i,:))
    end
    pause(.01);
    frame = getframe;
    
    % Write the frame to the output video
    writeVideo(writerObj,frame);
    % Write x and y locations of the skeleton to an array
    exceldata = [exceldata;[[{'Y'};'X'],transpose(num2cell(body))]];
    
    prev_img = ~isnan(D);
end

% Write the array to an excel sheet
xlswrite([file(1:end-4),'_worm',num2str(worm_num),'.xls'],exceldata);
close(writerObj);
close all
clear all
beep % alert the user after execution
end

function worm_num = get_worm_num(file)
	worm_num = 1;
	while 1 
	worm_file_name = [file(1:end-4),'_worm',num2str(worm_num),'.mp4'];
		if(exist(worm_file_name,'file') == 2)
			worm_num=worm_num+1;
		else
			break
		end
	end
end

