info = dicominfo('QC20170824Z_H1H2_axial.dcm');
% info = setfield(info, 'PixelSpacing', '2.2090mm by 2.2090mm');
% info = setfield(info, 'SliceVector', 256);
% struct2File( info, 'file.txt', 'sort', false, 'delimiter','\t');

pixelLength = getfield(info, 'PixelSpacing', {1});
imageWidth = getfield(info, 'Width');
imageHeight = getfield(info, 'Height');
axialFrameRange = 130/pixelLength;
halfAxialRange= fix(axialFrameRange/2);
coronalFrameRange = 30/pixelLength;
halfCoronalRange = fix(coronalFrameRange/2);
sagittalFrameRange = 180/pixelLength;
halfSagittalRange = fix(sagittalFrameRange/2);
xValues = (1:imageWidth);
xValues = im2double(xValues);
xValues = xValues';
seriesRange = '';
threshold = 3000;
numberOfPoints = 3;
Terms = ["Central Transaxial: ", "Central Axial: ", "Peripheral Radial: ", "Peripheral Tangential: ", "Peripheral Axial: "];
result = struct;
Final_Results = zeros(1,5);

%Provide the tool with the three dicom files
f = fullfile({'QC20160907B_H1_axial.dcm';'QC20160907B_H1_coronal.dcm';'QC20160907B_H1_sagittal.dcm'});
for fileNumber = 1:size(f)
    %Instantiate two images, I2 and Itot.
    I2 = zeros(imageWidth, imageWidth, 1);
    Itot = zeros(imageWidth, imageWidth, 1);
    
    %Read file name and determine which 
    %image series it contains.
    fileName = f{fileNumber};
    if contains(fileName, 'axial')==1
        seriesRange = halfAxialRange;
        disp('......USING AXIAL.....')
    elseif contains(fileName, 'coronal')==1
        seriesRange = halfCoronalRange;
        disp('.....USING CORONAL.....')
    else
        seriesRange = halfSagittalRange;
        disp('.....USING SAGITTAL.....')
    end
    
    %read in the series of images
    I=dicomread(fileName);
    
    %Determine the frame within the image series that 
    %contains the highest pixel value in the centre spot
    maxValue = 0;
    maxFrame = getMaxFrame(I, fileName, maxValue);
    
    %Calculate upper and lower limits of 
    %frames to be included in the totalised image
    upperlimit = maxFrame + seriesRange;
    lowerlimit = maxFrame - seriesRange;
    
    %Create a totalised image from the image 
    %series based on these limits
    for i = 1:imageHeight
        for j = 1:imageWidth
            totalPixel = 0;
            for k =lowerlimit:upperlimit
                pixel = I(i, j, 1, k);
                totalPixel = totalPixel + pixel;
            end
            Itot(i, j, 1)= totalPixel;
            if totalPixel > threshold
                I2(i, j, 1)= totalPixel;
            end
        end
    end
   
    %Iterate over every point
    for b = 1:numberOfPoints
        %Present filtered image
        figure(1);
        imshow(I2, 'InitialMagnification', 'fit')
        
        %Size of the ROI is 50x50mm if sagittal, otherwise the
        %ROI is 75x75mm
        if contains(fileName, 'sagittal')==1
        roiLength = fix(50/pixelLength);        
        else
        roiLength = fix(75/pixelLength);        
        end
        
        %Create ROI and instructions.
        h = imrect(gca,[10 10 roiLength roiLength]);
        setResizable(h, false)
        dim = [0 0 0.1 0.1];
        str = {'Please click and drag the square over the point of interest and double-click.','Do this in the following order: Central Point, Peripheral Point 1, Peripheral Point 2.'};
        annotation('textbox', dim, 'String', str, 'FitBoxToText','on');

        
        %Save position of the top left vertex of the ROI after the user has
        %dragged and double-clicked
        position = wait(h);
        
        %Calculate the rows and columns needed to create the region of
        %interest. 
        c1 = position(1);
        r1 = position(2);
        r2 = r1+ position(4);
        c2 = c1+ position(3);
        
        %Declare this region of interest in a new image, with only
        %the specified spot present.
        roi_image = zeros(imageWidth, imageWidth, 1);
        roi_image(r1:r2,c1:c2,1) = I2(r1:r2,c1:c2,1);
        
        %Create a profile on the Y-axis
        roiColumn = sum(roi_image, 2);

        %Create a profile on the X-axis
        roiRow = sum(roi_image);
        
        %Calculate the Full Width at Half Maximum.
        widthC= findFWHM(roiColumn, pixelLength);
        widthR= findFWHM(roiRow, pixelLength);

        %Store FWHM in variable depending on the image series and the
        %point.
        if contains(fileName, 'axial')==1
            switch b
                case 1
                    disp('...AXIAL CENTRAL...')
                    Ax_Cx = widthR;
                    result.Ax_Cx = Ax_Cx;
                    Ax_Cy = widthC;
                    result.Ax_Cy = Ax_Cy;
                case 2
                    disp('...AXIAL P1...')                    
                    Ax_P1x = widthR;
                    result.Ax_P1x = Ax_P1x;
                    Ax_P1y = widthC;
                    result.Ax_P1y = Ax_P1y;
                case 3
                    disp('...AXIAL P2...')
                    Ax_P2x = widthR;
                    result.Ax_P2x = Ax_P2x;
                    Ax_P2y = widthC;
                    result.Ax_P2y = Ax_P2y;
            end
        elseif contains(fileName, 'coronal')==1
            switch b
                case 1
                    disp('...CORONAL CENTRAL...')
                    Cor_Cx = widthR;
                    result.Cor_Cx = Cor_Cx;
                    Cor_Cz = widthC;
                    result.Cor_Cz = Cor_Cz;
                case 2
                    disp('...CORONAL P1...')
                    Cor_P1x = widthR;
                    result.Cor_P1x = Cor_P1x;
                    Cor_P1z = widthC;
                    result.Cor_P1z = Cor_P1z;
                case 3
                    disp('...CORONAL P2...')
                    Cor_P2x = widthR;
                    result.Cor_P2x = Cor_P2x;
                    Cor_P2z = widthC;
                    result.Cor_P2z = Cor_P2z;
            end
        else
            switch b
                case 1
                    disp('...SAGITTAL CENTRAL...')
                    Sag_Cz = widthR;
                    result.Sag_Cz = Sag_Cz;
                    Sag_Cy = widthC;
                    result.Sag_Cy = Sag_Cy;
                case 2
                    disp('...SAGITTAL P1...')
                    Sag_P1z = widthR;
                    result.Sag_P1z = Sag_P1z;
                    Sag_P1y = widthC;
                    result.Sag_P1y = Sag_P1y;
                case 3
                    disp('...SAGITTAL P2...')
                    Sag_P2z = widthR;
                    result.Sag_P2z = Sag_P2z;
                    Sag_P2y = widthC;
                    result.Sag_P2y = Sag_P2y;
            end
        end
    end
end


%Calculate the reporting values
Cx_Avg = calculateCxAvg(Ax_Cx, Cor_Cx);
Cy_Avg = calculateCyAvg(Ax_Cy, Sag_Cy);
Final_Results(1, 1) = calculateCentralTransaxial(Cx_Avg, Cy_Avg);
Final_Results(1, 2) = calculateCzAvg(Sag_Cz, Cor_Cz);
Final_Results(1, 3) = calculatePxAvg(Ax_P1x, Cor_P1x, Ax_P2x, Cor_P2x);
Final_Results(1, 4) = calculatePyAvg(Ax_P1y, Sag_P1y, Ax_P2y, Sag_P2y);
Final_Results(1, 5) = calculatePzAvg(Sag_P1z, Cor_P1z, Sag_P2z, Cor_P2z);

%Print reporting values to text file.
y =vertcat(Terms, Final_Results);
fileID = fopen('QC_Results.txt', 'w');
fprintf(fileID, result);
fprintf(fileID, '%s %s\n', y);
fclose(fileID);

%Calculate the frame with the highest pixel count in the centre point

function maxFrame = getMaxFrame(Image, fileName, maxValue)
for i = 1:256
    %should be constants
    for j = 118:138
        %maxValue = 0;
        for k =1:256
            
            if contains(fileName, 'sagittal')==1
                pixelValue = Image(j, i, 1, k);
                if pixelValue > maxValue
                    maxValue = pixelValue;
                    maxFrame = k;
                end
                
            else
                pixelValue = Image(i, j, 1, k);
                if pixelValue > maxValue
                    maxValue = pixelValue;
                    maxFrame = k;
                end
            end
            
        end
    end
end
end

%Calculate the FWHM
function fwhm = findFWHM(data, pixelLength)
halfMax = (min(data) + max(data))/2;
index1 = find(data >= halfMax, 1, 'first');
index2 = find(data >= halfMax, 1, 'last');
fwhm = (index2 - index1 + 1)* pixelLength;
end

%Calculate the average central x-axis FWHM
function Cx_Avg = calculateCxAvg(Ax_Cx, Cor_Cx)
Cx_Avg = (Ax_Cx + Cor_Cx)/2;
end

%Calculate the average central y-axis FWHM
function Cy_Avg = calculateCyAvg(Ax_Cy, Sag_Cy)
Cy_Avg = (Ax_Cy + Sag_Cy)/2;
end

%Calculate the central transaxial FWHM
function Central_Transaxial = calculateCentralTransaxial(Cx_Avg, Cy_Avg)
Central_Transaxial = (Cx_Avg + Cy_Avg)/2;
end

%Calculate the average central z-axis FWHM
function Cz_Avg = calculateCzAvg(Sag_Cz, Cor_Cz)
Cz_Avg = (Sag_Cz + Cor_Cz)/2;
end

%Calculate the average peripheral x-axis FWHM
function Px_Avg = calculatePxAvg(Ax_P1x, Cor_P1x, Ax_P2x, Cor_P2x)
Px_Avg = (Ax_P1x + Cor_P1x + Ax_P2x + Cor_P2x)/4;
end

%Calculate the average peripheral y-axis FWHM
function Py_Avg = calculatePyAvg(Ax_P1y, Sag_P1y, Ax_P2y, Sag_P2y)
Py_Avg = (Ax_P1y + Sag_P1y + Ax_P2y + Sag_P2y)/4;
end

%Calculate the average peripheral z-axis FWHM
function Pz_Avg = calculatePzAvg(Sag_P1z, Cor_P1z, Sag_P2z, Cor_P2z)
Pz_Avg = (Sag_P1z + Cor_P1z + Sag_P2z + Cor_P2z)/4;
end
