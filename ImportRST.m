%% Import data from text file.
% Script for importing data from .RST files, characterized by a structure
% like this: 
% 
% 
%! WinPLOTR profile fitting results:
% !   data file: E.chi
% !    wave (A):      1.40000     1.40000     0.50000
% !
% !   2theta(deg.) sig_2th        d(A)   Intensity     sig_int         FWHM    FWHM_sig         ETA     ETA_sig
% !------------------------------------------------------------------------------------------------------------------
%     1.067319    0.000436    75.15583    53068.27      177.34     0.408440    0.000925    0.000100    0.000000
%     1.185136    0.000127    67.68465    28587.36      102.87     0.121254    0.000338    0.000100    0.000000
%     .
%     .
%     .
% ... and so on
%  
% The objective is to create a comprehensive table of the low angle peaks of N samples
% measured in different conditions ('ND',"000","002","005","015","060","120")

clc
clear

%% Initialize variables.
 
delimiter = {' ','!'};
startRow = 7;

%% Format for each line of text:
%   column1: double (%f)
%	column2: double (%f)
%   column3: double (%f)
%	column4: double (%f)
%   column5: double (%f)
%	column6: double (%f)
%   column7: double (%f)
%	column8: double (%f)
%   column9: double (%f)
% For more information, see the TEXTSCAN documentation.
formatSpec = '%f%f%f%f%f%f%f%f%f%[^\n\r]';
ext='_PF.RST';
str=["000","002","005","015","060","120"];
STR=["CW_S","CW_TW","CW_P","CW_HPMC","SFW_S","SFW_TW","SFW_P","SFW_HPMC","FHPO_RSO_S","FHPO_RSO_TW","FHPO_RSO_P","FHPO_RSO_HPMC","FHPO_S","FHPO_TW","FHPO_P","FHPO_HPMC"];
T ={'Sample','Time','thetadeg','sig_2th','dA','Intensity','sig_int','FWHM','FWHM_sig','ETA','ETA_sig'};
for j=1:16
    % Stessa procedura per il campione non diluito
    root = strcat('.\E', num2str(j), '_', STR(j),'\LA 2 peaks\E', num2str(j),'_', STR(j),'_' );
    filename=strcat(root,'ND', ext);
    fileID = fopen(filename,'r');
    dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter, 'MultipleDelimsAsOne', true, 'TextType', 'string', 'HeaderLines' ,startRow-1, 'ReturnOnError', false, 'EndOfLine', '\r\n');
    dataArray(:,10)=[];
    fclose(fileID);
    TT={['E', num2str(j)],'ND'};
    for k=1:9
        TT (1,k+2)=dataArray(1,k);
    end
    T=[T;TT];
    %% 
    %% 
    %% 
    %% 
    clearvars fileID
    if j==2
        root = strcat('.\E', num2str(j), '_', STR(j), '\LA 2 peaks\E', num2str(j), '_', STR(j),'_' );
    else
        root = strcat('.\E', num2str(j), '_', STR(j), '\LA 2 peaks\E', num2str(j), '_', STR(j), '_avg_');
    end
    for i=1:6
        TT ={['E', num2str(j)],str(i)};
        if j==2
            filename=strcat(root,str(i),'_avg', ext);
        else
            filename=strcat(root,str(i), ext);
        end
        %% Open the text file.
        fileID = fopen(filename,'r');
        
        %% Read columns of data according to the format.
        % This call is based on the structure of the file used to generate this
        % code. If an error occurs for a different file, try regenerating the code
        % from the Import Tool.
        dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter, 'MultipleDelimsAsOne', true, 'TextType', 'string', 'HeaderLines' ,startRow-1, 'ReturnOnError', false, 'EndOfLine', '\r\n');
        fclose(fileID);
        for k=1:9
            TT (1,k+2)=dataArray(1,k);
        end
        T=[T;TT];
        
        %% Save as xcel
        %     filename=char(filename);
        %     fileout = strcat(filename(55:56),'.xlsx');
        %     sheetname=strtok(filename,'.');
        %     sheetname=sheetname(:,length(sheetname)-5:length(sheetname)-3);
        %     xlswrite(fileout,dataArray,sheetname)
    end
end

clearvars filename delimiter startRow formatSpec fileID dataArray ans;
A = cell2table(T(2:end,1:end),'VariableNames',T(1,1:end));
writetable(A,'LowAnglePeaks.xls')

