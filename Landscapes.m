%% Landscapes 2.5

% Script file:      Landscapes.m
%                   Modificato per rappresentare i dati anche in funzione
%                   di zeta o phi invece che in funzione della temperatura

% Purpose:          carica, analizza e visualizza pattern integrati
%                   tramite fit2d ottenuti nel corso di esperimenti di
%                   diffrazione in funzione di una variabile, evidenziando
%                   quelli che corrispondono a valori significativi di tale
%                   variabile individuati ad es. tramite esperimenti di
%                   calorimetria

% Files requested:  per ogni immagine devono essere presenti nella cartella
%                   *   i file .chi generati da fit2d
%                   *   il file_OPE.txt che riporta su ogni riga i valori
%                       in temperatura (°C) di almeno due fra onset, peak e
%                       endset di tutti i picchi dell'esperimento in
%                       calorimetria. Se sono presenti solo due valori, si
%                       suppone che siano onset ed endset.
%                   *   Se i pattern presentano dei "buchi" dovuti
%                       all'esistenza della griglia su Pilatus, è bene che
%                       in tali buchi il valore dell'intensità sia
%                       esattamente zero (usare threshold mask), in modo da
%                       potere a seconda dei casi riconoscere la zona da
%                       interpolare o limitarsi a non rappresentare la
%                       parte non misurata.

% Data requested:   bisogna essere a conoscenza della lunghezza d'onda.
%                   E' possibile definire tutta una serie di parametri che
%                   permettono di variare l'aspetto dell'output.

% To-do list: da automatizzare
% 1)    se necessario, copiare nella cartella lo script inpaint_nans che
%       permette di interpolare le parti mancanti causa griglia pilatus
% 3)    Trovare il modo di scegliere da palette il colore dei DSC e delle
%       interpolazioni (riga 300)
% 4)    Normalizzare a d prescelta
% 5)    Riconoscere automaticamente se i punti per picco in OPE sono tre o
% due
% %**************************************************************************
%% Estendere la procedura a riga 972 agli altri percorsi termici quanto prima
%**************************************************************************

clc
close all
clear
%% Settaggio parametri
flagfigure=[1,1,1,1,1,1,1,1,1];     %Nell'ordine,
%flagfigure=[1,0,0,0,0,0,0,0,0];     %Nell'ordine,
%SAXS completo, SAXS c/f, SAXS f/c,
%WAXS completo, WAXS c/f, WAXS f/c,
%WAXS completo grigio, SAXS completo grigio e SAXS/WAXS contour
lambda=1.2;                         %Wavelenght
nameroot='Ramp_';        %Data collection name
titolofigura = 'Noccioli Organogel'; %Titolo per la barra della finestra
titolofigura1=strrep(titolofigura, '_', '\_'); %Titolo interno della figura
WAXDlim(1)=1.53;        %WAXD interplanar distances lower limit
WAXDlim(2)=10;        %WAXD interplanar distances upper limit
SAXDlim(1)=10;        %SAXD interplanar distances lower limit
SAXDlim(2)=70;        %SAXD interplanar distances upper limit
percorso=pwd;
label = 'Variable';        %Se si vuole rappresentare i grafici in
%funzione del tempo, mettere 'secondi', se si vuole
%rappresentarli in funzione dell'altra variabile,
%mettere 'Variable'.
% Variable='Phi';
% xlabelVariable='Phi(degrees)';
%Variable='Zeta';
%xlabelVariable='Zeta(mm)';
% Variable='Xposition';
% xlabelVariable='X position(mm)';
Variable='Temperature';
xlabelVariable='Temperature (°C)';
% Variable='Time';
% xlabelVariable='Time (min)';
TM='°C'; %Unità di misura delle temperature misurate
ViewColorFigures=[-45 46];
ViewGrayFigures=[90 60];
createcolorbar=false;    %Colorbar all'interno della figura; true o false
titoli = true;          %Titolo all'interno della figura; true o false


%NormalizationFactor=Intensity(1250,:); %Tipicamente, il valore massimo del
%picco più intenso o i valori di IOC2
NormalizationFactor=1; %Tipicamente, il valore massimo del picco più intenso o i valori di IOC2
ShiftTemporale=0;       %Corregge eventuali ritardi nella scrittura del
%file su phase (obsoleto)

%AUTOMATIZZARE LA SCELTA DELLO STEP

XtickStep=0;           %Ampiezza step per tick su asse tempo/temperatura
XlabelStep=0;          %Ampiezza step per label dei tick
Contour9LevelStep=0; %Step fra i livelli nel contour della bassa
%risoluzione (SAXS). Più è piccolo, più
%i livelli saranno fitti (e numerosi). Automatico=0
Contour10LevelStep=0; %Step fra i livelli nel contour dell'alta
%risoluzione (WAXS). Più è piccolo, più
%i livelli saranno fitti (e numerosi). Automatico=0
FormatoFileCriostato='%d %*c %d %*c %d %d %*c %d %*c %d  %*s %*s  %f %*s';
% FormatNumerazionePatternFiles='%05s'; %specifica il numero di cifre
FormatNumerazionePatternFiles='%02s'; %specifica il numero di cifre
%che compongono la parte numerale dei pattern files
FormatoNomeChiFiles1=nameroot;
FormatoNomeChiFiles2= '.chi';
Interpolate=false;
DSCmatch=true;
DSCpoints=3;    %Se il file .OPE contiene valori di temperatura per
%Onset Peak ed Endset mettere 3, se contiene valori
%di temperatura per Onset ed Endset mettere 2
DSCas2dPlots=true;%True: overimposes 2d plots on 3d in correspondence
%of onset peak and enset False: signals OPE changing mesh color
font_name='Lucida Console';
font_size=10;
switch Variable
    case 'Temperature'
        mappa='parula';
        colorbarlabel='T(°C)';
    otherwise
        mappa='pink';
        colorbarlabel=xlabelVariable;
end

closeimages=false;
% 'autumn' varies smoothly from red, through orange, to yellow.
% 'bone' is a grayscale colormap with a higher value for the blue component. This colormap is useful for adding an "electronic" look to grayscale images.
% 'colorcube' contains as many regularly spaced colors in RGB colorspace as possible, while attempting to provide more steps of gray, pure red, pure green, and pure blue.
% 'cool' consists of colors that are shades of cyan and magenta. It varies smoothly from cyan to magenta.
% 'copper' varies smoothly from black to bright copper.
% 'flag' consists of the colors red, white, blue, and black. This colormap completely changes color with each index increment.
% 'gray' returns a linear grayscale colormap.
% 'hot' varies smoothly from black through shades of red, orange, and yellow, to white.
% 'hsv' varies the hue component of the hue-saturation-value color model. The colors begin with red, pass through yellow, green, cyan, blue, magenta, and return to red. The colormap is particularly appropriate for displaying periodic functions. hsv(m) is the same as hsv2rgb([h ones(m,2)]) where h is the linear ramp, h = (0:m–1)'/m.
% 'jet' ranges from blue to red, and passes through the colors cyan, yellow, and orange. It is a variation of the hsv colormap. The jet colormap is associated with an astrophysical fluid jet simulation from the National Center for Supercomputer Applications. See the Examples section.
% 'lines' produces a colormap of colors specified by the axes ColorOrder property and a shade of gray.
% 'pink' contains pastel shades of pink. The pink colormap provides sepia tone colorization of grayscale photographs.
% 'prism' repeats the six colors red, orange, yellow, green, blue, and violet.
% 'spring' consists of colors that are shades of magenta and yellow.
% 'summer' consists of colors that are shades of green and yellow.
% 'white' is an all white monochrome colormap.
% 'winter' consists of colors that are shades of blue and green.
%% Creazione nomi dei file
estImmagini='.tif';
estPattern='.chi';
estFigure='png';
nomecryo=[nameroot 'cryo' '.txt'] ;
nomeOPE=[nameroot 'OPE' '.txt'] ;
nomeWS=[nameroot 'WS' '.mat'] ;
nomexcel=[nameroot 'cryo' '.xls'];
nomeDSC=[nameroot 'DSC.xls'];
nomeIntensity=[nameroot 'Intensity.xls'];
%% Creazione nomi delle figure

%% Importa tutti i dati sperimentali dal file DataExperiment.log
if exist('DataExperiment.log','file')
    DataExperiment=importdata('DataExperiment.log');
    x=strfind(DataExperiment, 'acquired:');
    DataExperiment=DataExperiment(~cellfun('isempty',x));
    DataExperiment=regexp(DataExperiment, ';', 'split');
    getTime = cell(length(DataExperiment),1);  % Pre-allocate
    getName = cell(length(DataExperiment),1);  % Pre-allocate
    getVariable = cell(length(DataExperiment),1);  % Pre-allocate
    h = waitbar(0,'Importing experimental data...');
    for ii=1:length(DataExperiment)
        waitbar(ii/length(DataExperiment))
        DataExperiment{ii}(1)=regexp(DataExperiment{ii}(1), 'Image acquired:', 'split');
        getTime{ii,1}=DataExperiment{ii,1}{1,1}{1,1};
        getName{ii,1}=DataExperiment{ii,1}{1,1}{1,2};
        switch Variable
            case 'Temperature'
                getVariable{ii,1}=DataExperiment{ii,1}{1,2};
            case 'Phi'
                getVariable{ii,1}=DataExperiment{ii,1}{1,12};
            case 'Zeta'
                getVariable{ii,1}=DataExperiment{ii,1}{1,6};
            case 'Xposition'
                getVariable{ii,1}=DataExperiment{ii,1}{1,4};
        end
    end
    delete(h)
    TF = strfind(getName{1,1}, nameroot);%Liberiamo il nome file dal path
    getName=cellfun(@(x) x(TF:end), getName, 'UniformOutput', false);
    [getName,idx]=unique(getName(:,1));  %eliminiamo duplicati
    getTime=getTime(idx,:);
    getVariable=getVariable(idx,:);
    switch Variable
        case 'Temperature'
            getVariable=cellfun(@(x) str2double(regexprep(x,' TEMPERATURE=','')), getVariable, 'UniformOutput', true);
            % Apply function to each cell in cell array: replace string
            % ' TEMPERATURE=' with '' using regular expression, overwrite
            % getVariable. Uniform output set to true means that for all
            % inputs, each output from function func is a cell array that
            % is always of the same type and size.
        case 'Phi'
            getVariable=cellfun(@(x) str2double(regexprep(x,'Phi=','')), getVariable, 'UniformOutput', true);
        case 'Zeta'
            getVariable=cellfun(@(x) str2double(regexprep(x,'KGONIOHEADZ=','')), getVariable, 'UniformOutput', true);
            % Ancora mai usato, potrebbe essere qualsiasi altro valore
            % desumibile da DataExperiment
        case 'Xposition'
            getVariable=cellfun(@(x) str2double(regexprep(x,'KGONIOHEADX=','')), getVariable, 'UniformOutput', true);
    end
    getTime=cellfun(@(x) 1440*datenum(x,'dd/mm/yyyy HH:MM:SS'), getTime, 'UniformOutput', true);
    ncurves=length(getVariable);
else
    %%Altrimenti, ricava i tempi dagli header dei file
    ncurves = size(dir([nameroot '*' estImmagini]),1);
    getTime=cell(ncurves,1);
    h = waitbar(0,'Extracting time variable from images headers...');
    nreject=0;
    elim=zeros(ncurves,1);
    elim1=zeros(ncurves,1);
    for i=1:ncurves
        s=[FormatoNomeChiFiles1 '' sprintf(FormatNumerazionePatternFiles,int2str(i)) estImmagini];
        if exist(s, 'file')
            [~,header]=imageread(s,'tif',[1475 1679]);
            getTime{i}=header(31:50);
        else
            % incrementa il contatore di "buchi" nella raccolta dati e
            % memorizza le posizioni nel vettore elim, in modo da poter cancellare le
            % righe corrispondenti nel vettore delle temperature
            nreject=nreject+1;
            elim(nreject)=i;
            getTime{i}=0;
        end
        waitbar(i/ncurves)
    end
    delete(h)
    %% Eliminazione delle righe corrispondenti a tif-file mancanti o difettosi
    if nreject ~=0
        elim1=elim;
        elim1(nreject+1:ncurves,:)=[];
        getTime(elim1,:)=[];
    end
    getTime=cellfun(@(x) 1440*datenum(x,'yyyy:mm:dd HH:MM:SS'), getTime, 'UniformOutput', true);
    % whole and fractional number of days from a fixed, preset date (January 0, 0000) in the proleptic ISO calendar.


    % else
    %     % Altrimenti, ricava i tempi dalle date di creazione dei file:
    %     % obsoleto, non dovrebbe essere mai raggiunto, lo tengo per pura
    %     % documentazione
    %     c = dir([nameroot '_*' estImmagini]);
    %     c=struct2cell(c);
    %     c(3:5,:)=[];
    %     c=sortrows(c');
    %     c = strrep(c, 'gen', 'jan');
    %     c = strrep(c, 'mag', 'may');
    %     c = strrep(c, 'giu', 'jun');
    %     c = strrep(c, 'lug', 'jul');
    %     c = strrep(c, 'ago', 'aug');
    %     c = strrep(c, 'set', 'sep');
    %     c = strrep(c, 'ott', 'oct');
    %     c = strrep(c, 'dic', 'dec');
    %     ncurves=size(c,1);
    %     if ncurves==0
    %         warning('OpenFile:notFoundInPath', 'No Pattern files found');
    %     end
    %     getTime=c(:,2);
    %     getName=c(:,1);
    %     FormatIn='dd-mmm-yyyy HH:MM:SS';
    %     getTime=cellfun(@(x) 1440*datenum(x,FormatIn), getTime, 'UniformOutput', true);
    %% ...e importa curva temperatura da file excel o dal log del criostato
    if exist(nomexcel,'file')
        % Esperimento con una misura di temperatura per pattern, registrate
        % su file excel
        %         getVariable=importdata(nomexcel);
        getVariable=xlsread(nomexcel,1);
        if isstruct(getVariable)
            getVariable=struct2cell(getVariable);
            getVariable=getVariable{2,1};
        end
    elseif exist(nomecryo, 'file')
        % Esperimento con misure prese al volo e registrazione indipendente
        % del criostato
        DataExperiment = importdata(nomecryo);
        DataExperiment=regexp(DataExperiment, ' ', 'split');
        getTimeCryo = cell(length(DataExperiment),1);  % Pre-allocate
        getTemperatureCryo = cell(length(DataExperiment),1);  % Pre-allocate
        ncryo=length(DataExperiment);
        for ii=1:length(DataExperiment)
            getTimeCryo{ii,1}=[DataExperiment{ii,1}{1,1} ' ' DataExperiment{ii,1}{1,2}];
            getTemperatureCryo{ii,1}=DataExperiment{ii,1}{1,3};
        end
        getTimeCryo=cellfun(@(x) datenum(x,'dd/mm/yyyy HH:MM:SS'), getTimeCryo, 'UniformOutput', true);
        getTemperatureCryo=cellfun(@(x) str2double(x), getTemperatureCryo, 'UniformOutput', true);
        getVariable=getTemperatureCryo;
        %getVariable=interp1(getTimeCryo,getTemperatureCryo,getTime,'linear','extrap');
        %trova le temperature corrispondenti ai tempi di misura dei pattern
        %interpolando i dati del criostato, ed estrapolandoli alle regioni
        %senza temperatura misurata.
    else
        if strcmp(label,'Variable')
            warning('OpenFile:notFoundInPath', 'No Temperature file found');
            return
        end
    end
end
%% Estrae i dati sulla Zeta dai metafiles
% xyz=zeros(1,3);
% XYZ=zeros(ncurves,3);
% ZetaPosition=zeros(ncurves,1);
% for k=1:(ncurves)
%     s = [FormatoNomeChiFiles1 '_' sprintf(FormatNumerazionePatternFiles,int2str(k)) '_metadata.txt'];
%     % se un file non esiste passa al successivo
%     if exist(s,'file')
%         fid=fopen(s);
%         % Skip the first 30 lines
%         for i=1:30
%             fgetl(fid);
%         end
%         mystring=fgetl(fid);
%         [str,remain]=strtok(strtok(mystring,')'),'(');
%         xyz=cell2mat(textscan(remain,'(%n;%n;%n'));
%         XYZ(k,:)=xyz;
%         if k>1
%             xyz=xyz-XYZ(k-1,:);
%             ZetaPosition(k)=ZetaPosition(k-1)+sqrt(sum(xyz.*xyz));
%         end
%         fclose(fid);
%     end
%     if strcmp(Variable,'Zeta')
%     getVariable=ZetaPosition;
%     end
% end
getTime=(getTime-getTime(1)); %espresso in minuti
if strcmp(label,'secondi')
    getVariable=getTime;
end
%% Determina la lunghezza dei chi-files
for k=1:(ncurves)
    s = [FormatoNomeChiFiles1 '' sprintf(FormatNumerazionePatternFiles,int2str(k)) FormatoNomeChiFiles2];
    % se un file non esiste passa al successivo
    if exist(s,'file')
        chifile = textread(s,'',-1,'headerlines', 4);
        numrows=size(chifile, 1);
        break
    end
    if k==ncurves
        warning('OpenFile:notFoundInPath', ['No ' FormatoNomeChiFiles1 ' files in directory'])
        return
    end
end
%% Importa dati di diffrazione dai chi-files
% e, se serve, decima le righe del log del criostato in base al principio
% di coincidenza con i tempi di misurazione dei pattern di diffrazione.
% Individua i minimi e massimi in temperatura e loro posizioni.
% Riconosce se si tratta di rampa di fusione, rampa di cristallizzazione,
% rampa di cristallizzazione/fusione o rampa di fusione/cristallizzazione
pst=zeros(ncurves,1);
Intensity=zeros(numrows(1), ncurves);
nreject=0;
elim=zeros(ncurves,1);
for k=1:(ncurves)
    s = [FormatoNomeChiFiles1 '' sprintf(FormatNumerazionePatternFiles,int2str(k)) FormatoNomeChiFiles2];
    % se un file non esiste passa al successivo
    if exist(s,'file')
        [DueTheta(:,1),Intensity(:,k-nreject)] = textread(s,'',-1,'headerlines', 4);
        %mette la colonna dei 2theta in DueTheta e la colonna delle intensità
        %nella k-esima colonna di Intensity
    else
        % incrementa il contatore di "buchi" nella raccolta dati e
        % memorizza le posizioni nel vettore elim, in modo da poter cancellare le
        % righe corrispondenti nel vettore delle temperature
        nreject=nreject+1;
        elim(nreject)=k;
    end
end

%% Eliminazione delle righe corrispondenti a chi-file mancanti
if nreject ~=0
    elim(nreject+1:ncurves,:)=[];%conserva solo i valori non zero di elim
    elim1(nreject+1:ncurves,:)=[];%conserva solo i valori non zero di elim
    if elim~=elim1
        for i=1:max(size(elim1))
            for k=1:max (size( elim))
                if elim(k)==elim1(i)
                    elim(k)=[];
                end
            end
        end
        getTime(elim,:)=[];
        getVariable(elim,:)=[];
    end
    Intensity(:,ncurves-nreject+1:ncurves)=[];
end
%% Normalizzazione delle intensità
[rows,col]=size(Intensity);
if size(NormalizationFactor)==[1,1]
    A=repmat(NormalizationFactor,rows,col);
    %Replicate and tile array
else
    A=repmat(NormalizationFactor,rows,1);
    %Replicate and tile array
end
Intensity=Intensity./A;
%% Individuazione minimi e massimi della curva della variabile
minVar=10000;
maxVar=-10000;
posminVar=zeros(1,2);
posmaxVar=zeros(1,2);
delta=mean(abs(diff(getVariable)));
for k=1:(ncurves-nreject)
    if getVariable(k)<minVar-delta/2
        minVar=getVariable(k);
        posminVar(1)=k;
    end
    if getVariable(k)<minVar+delta/2
        minVar=getVariable(k);
        posminVar(2)=k;
    end
    if getVariable(k)>maxVar+delta/2
        maxVar=getVariable(k);
        posmaxVar(1)=k;
    end
    if getVariable(k)>maxVar-delta/2
        maxVar=getVariable(k);
        posmaxVar(2)=k;
    end
end
%% Individuazione tipo di percorso della variabile
if posminVar(2)>posmaxVar(2)
    if posmaxVar(1)>1 && posminVar(2)==ncurves-nreject
        order=1;
        switch Variable
            case 'Temperature'
                orderstring=', Melting and Crystallization';
                orderstring1=', Melting';
                orderstring2=', Crystallization';
                nomefigWAXD1='WAXDmelt';
                nomefigWAXD2='WAXDcryst';
                nomefigSAXD1='SAXDmelt';
                nomefigSAXD2='SAXDcryst';
            otherwise
                nomefigWAXD1='WAXDincr';
                nomefigWAXD2='WAXDdecr';
                nomefigSAXD1='SAXDincr';
                nomefigSAXD2='SAXDdecr';
                switch Variable
                    case 'Zeta'
                        orderstring=', Increasing and Decreasing sample height (Zeta)';
                    case 'Xposition'
                        orderstring=', Increasing and Decreasing sample X position (Xpos)';
                    case 'Phi'
                        orderstring=', Counterclockwise and Clockwise Phi rotation';
                end
        end
    elseif posmaxVar(1)==1 && posminVar(2)==ncurves-nreject
        order=2;
        switch Variable
            case 'Temperature'
                orderstring=', Crystallization';
                nomefigWAXD2='WAXDcryst';
                nomefigSAXD2='SAXDcryst';
            otherwise
                nomefigWAXD2='WAXDdecr';
                nomefigSAXD2='SAXDdecr';
                switch Variable
                    case 'Zeta'
                        orderstring=', Decreasing sample height (Zeta)';
                    case 'Xposition'
                        orderstring=', Decreasing sample X position (Xpos)';
                    case 'Phi'
                        orderstring=', Counterclockwise Phi rotation';
                end
        end
    elseif posmaxVar(1)==1 && posminVar(2)<ncurves-nreject
        order=3;
        switch Variable
            case 'Temperature'
                orderstring=', Crystallization and Melting';
                orderstring1=', Crystallization';
                orderstring2=', Melting';
                nomefigWAXD2='WAXDmelt';
                nomefigWAXD1='WAXDcryst';
                nomefigSAXD2='SAXDmelt';
                nomefigSAXD1='SAXDcryst';
            otherwise
                nomefigWAXD2='WAXDincr';
                nomefigWAXD1='WAXDdecr';
                nomefigSAXD2='SAXDincr';
                nomefigSAXD1='SAXDdecr';
                switch Variable
                    case 'Zeta'
                        orderstring=', Decreasing and Increasing sample height (Zeta)';
                    case 'Xposition'
                        orderstring=', Decreasing and Increasing sample X position (Xpos)';
                    case 'Phi'
                        orderstring=', Clockwise and Counterclockwise Phi rotation';
                end

        end
    end
elseif posminVar(2)<posmaxVar(2)
    if posminVar(1)==1 && posmaxVar(2)< ncurves-nreject
        order=4;
        switch Variable
            case 'Temperature'
                orderstring=', Melting and Crystallization';
                orderstring1=', Melting';
                orderstring2=', Crystallization';
                nomefigWAXD1='WAXDmelt';
                nomefigWAXD2='WAXDcryst';
                nomefigSAXD1='SAXDmelt';
                nomefigSAXD2='SAXDcryst';
            otherwise
                nomefigWAXD1='WAXDincr';
                nomefigWAXD2='WAXDdecr';
                nomefigSAXD1='SAXDincr';
                nomefigSAXD2='SAXDdecr';
                switch Variable
                    case 'Zeta'
                        orderstring=', Increasing and Decreasing sample height (Zeta)';
                    case 'Xposition'
                        orderstring=', Increasing and Decreasing sample X position (Xpos)';
                    case 'Phi'
                        orderstring=', Counterclockwise and Clockwise Phi rotation';
                end
        end
    elseif posminVar(1)==1 && posmaxVar(2)==ncurves-nreject
        order=5;
        switch Variable
            case 'Temperature'
                orderstring=', Melting';
                nomefigWAXD1='WAXDmelt';
                nomefigSAXD1='SAXDmelt';
            otherwise
                nomefigWAXD1='WAXDincr';
                nomefigSAXD1='SAXDincr';
                switch Variable
                    case 'Zeta'
                        orderstring=', Increasing sample height (Zeta)';
                    case 'Xposition'
                        orderstring=', Increasing sample X position (Xpos)';
                    case 'Phi'
                        orderstring=', Counterclockwise Phi rotation';
                    case 'Time'
                        orderstring=', increasing time';
                end
        end
    elseif posminVar(1)>1 && posmaxVar(2)==ncurves-nreject
        order=6;
        switch Variable
            case 'Temperature'
                orderstring=', Crystallization and Melting';
                orderstring1=', Crystallization';
                orderstring2=', Melting';
                nomefigWAXD2='WAXDmelt';
                nomefigWAXD1='WAXDcryst';
                nomefigSAXD2='SAXDmelt';
                nomefigSAXD1='SAXDcryst';
            otherwise
                nomefigWAXD2='WAXDincr';
                nomefigWAXD1='WAXDdecr';
                nomefigSAXD2='SAXDincr';
                nomefigSAXD1='SAXDdecr';
                switch Variable
                    case 'Zeta'
                        orderstring=', Decreasing and Increasing sample height (Zeta)';
                    case 'Xposition'
                        orderstring=', Decreasing and Increasing sample X position (Xpos)';
                    case 'Phi'
                        orderstring=', Clockwise and Counterclockwise Phi rotation';
                end
        end
    end
elseif posminVar(1)==posmaxVar(1) && posminVar(2)==posmaxVar(2)
    order=7;
    orderstring=', Constant Temperature';
end

%% Individuazione eventuali plateau della curva della variabile

minVar=10000;
maxVar=-10000;
posminVar=zeros(1,2);
posmaxVar=zeros(1,2);
plateauStart=zeros(1,2);
plateauEnd=zeros(1,2);
delta=mean(abs(diff(getVariable)));
pflag=0;
for k=1:(ncurves-nreject)
    if getVariable(k)<minVar-delta/2
        minVar=getVariable(k);
        posminVar(1)=k;
    end
    if getVariable(k)<minVar+delta/2
        minVar=getVariable(k);
        posminVar(2)=k;
    end
    if getVariable(k)>maxVar+delta/2
        maxVar=getVariable(k);
        posmaxVar(1)=k;
    end
    if getVariable(k)>maxVar-delta/2
        maxVar=getVariable(k);
        posmaxVar(2)=k;
    end
    switch order
        case {1,4,5}
            if posmaxVar==posminVar
                plateauStart=posminVar;
            end
            if posminVar(2)<posmaxVar(2)
                if pflag==0
                    plateauEnd(1,1)=posminVar(2);
                    pflag=1;
                elseif pflag==1
                    plateauEnd(1,2)=posminVar(2);
                end
            end
        case {3,6}
            if posmaxVar==posminVar
                plateauStart=posmaxVar;
            end
            if posmaxVar(2)>posminVar(2)
                if pflag==0
                    plateauEnd(1,1)=posmaxVar(2);
                    pflag=1;
                elseif pflag==1
                    plateauEnd(1,2)=posmaxVar(2);
                end
            end
        case 2
            if posmaxVar==posminVar
                plateauStart=posmaxVar;
            end
            if posmaxVar(2)<posminVar(1)
                %if pflag==0
                plateauEnd(1,1)=posminVar(1);
                %   pflag=1;
                %elseif pflag==1
                plateauEnd(1,2)=posminVar(2);
                %end
            end

    end
end
%% Impone andamento monotono in temperatura ai tratti a temperatura costante interni alla rampa.
%linspace: returns the value of the 1-D function Y at the points of column
%vector xi using linear interpolation. The vector x specifies the
%coordinates of the underlying interval. The length of output yi is equal
%to the length of xi.
switch order
    case {1,4,5}
        a=min(getVariable(posmaxVar(1):posmaxVar(2)));
        b=max(getVariable(posmaxVar(1):posmaxVar(2)));
        c=(1+posmaxVar(2)-posmaxVar(1));
        getVariable(posmaxVar(1):posmaxVar(2))=linspace(a,b,c);
    case {2,3,6}
        a=max(getVariable(posminVar(1):posminVar(2)));
        b=min(getVariable(posminVar(1):posminVar(2)));
        c=(1+posminVar(2)-posminVar(1));
        getVariable(posminVar(1):posminVar(2))=linspace(a,b,c);
end

%% Impone andamento monotono in temperatura ai tratti a temperatura costante esterni alla rampa.
if ~( isequal(plateauStart(1,1),plateauStart(1,2)) && isequal(plateauEnd(1,2),plateauEnd(1,1)));
    a=max(getVariable(plateauStart(1):plateauStart(2)));
    b=min(getVariable(plateauStart(1):plateauStart(2)));
    c=(1+plateauStart(2)-plateauStart(1));
    getVariable(plateauStart(1):plateauStart(2))=linspace(a,b,c);
    a=min(getVariable(plateauEnd(1):plateauEnd(2)));
    b=max(getVariable(plateauEnd(1):plateauEnd(2)));
    c=(1+plateauEnd(2)-plateauEnd(1));
    getVariable(plateauEnd(1):plateauEnd(2))=linspace(a,b,c);
end
%% Crea il vettore d e la matrice delle temperature VariableMatrix
if exist(nomeOPE,'file')
    TempOPE = textread(nomeOPE,'',-1);
end
if strcmp(Variable,'Temperature')
    if strcmp(TM, 'Kelvin')
        getVariable=getVariable-273;
    end
end
si= size(DueTheta);
d=zeros(si(1),1);
VariableMatrix=zeros(si(1),ncurves-nreject);
for i=1 : si(1)
    d(i,1)=lambda/(2*sin((DueTheta(i,1)/360)*pi));
end
for i=1:si(1)
    VariableMatrix(i,1:ncurves-nreject)=getVariable(1:ncurves-nreject);
end
%% Importa dati DSC, scrive la matrice dei pattern significativi, cambia il colore del pattern preso in corrispondenza dell'onset, del picco e dell'endset del DSC
if DSCmatch
    if exist(nomeOPE,'file')
        si=size(TempOPE);
        q=0;
        flag=0;
        OPE=zeros(si(1), si(2));
        %il file OPE contiene una riga per ciascun picco del DSC,
        %e per ciascuna riga riporta almeno due fra le temperature di Onset Peak
        %ed Endset in °C.
        %Che il picco si trovi nella parte decrescente o crescente della rampa
        %si desume dal fatto che la sequenza OPE sia decrescente o crescente.
        %Mettiamo nella matrice OPE i numeri ordinali delle curve corrispondenti.
        for j=1:si(1)%indice di riga
            for k=1:si(2)%indice di colonna
                for i= 1:ncurves-nreject-1
                    %Caso curva crescente
                    if getVariable(i,1)<=TempOPE(j,k) && TempOPE(j,k)<= getVariable(i+1,1)&& TempOPE(j,1)<TempOPE(j,2)
                        q=q+1;
                        OPE(j,q)=i;
                        %TemperatureMatrix(:,i)=TemperatureMatrix(:,ncurves-nreject);
                        if ~DSCas2dPlots                             
                            VariableMatrix(:,i)=VariableMatrix(:,1);
                        end
                        if (q==si(2))
                            q=0;
                        end
                        %Cambia il colore del pattern preso in corrispondenza
                        %dell'onset, del picco e dell'endset del DSC
                        break
                        %Caso curva decrescente
                    elseif getVariable(i,1)>=TempOPE(j,k) && TempOPE(j,k) >=getVariable(i+1,1)&& TempOPE(j,1)>=TempOPE(j,2)
                        q=q+1;
                        OPE(j,q)=i
                        %TemperatureMatrix(:,i)=TemperatureMatrix(:,ncurves-nreject);
                        if ~DSCas2dPlots
                            VariableMatrix(:,i)=VariableMatrix(:,1);
                        end
                        %TemperatureMatrix(:,i)=TemperatureMatrix(:,ncurves-nreject);
                        if (q==si(2))
                            q=0;
                        end
                        break
                    end
                end
            end
        end
        i=size(OPE,1)* size(OPE,2);
        j=size(DueTheta,1);
        TimeOPE=zeros(1,i);
        DSCcurves=zeros(j,i);
        DSCcurves(:,1)=DueTheta(:,1);
        DSCcurves(:,2)=d(:,1);
        OPE=OPE';
        a=find(OPE==0);
        mystring=mat2str(a);
        if size(a,1)>1
            mystring=['OPE elements ' mystring ' are out of temperature range. No DSC match will be shown.'];
        elseif size(a)==1
            mystring=['OPE element ' mystring ' is out of temperature range. No DSC match will be shown.'];
        end
        if any(a)
            warning('MATLAB:IndexNotPositive', mystring)
            DSCmatch = false;
        end
        if DSCmatch
            for j=1: i
                TimeOPE(j)=getTime(OPE(j),1);
                DSCcurves(:,j+2)=Intensity(:,OPE(j));
            end
        end
    else
        warning('OpenFile:notFoundInPath', ['No ' nomeOPE ' file in directory'])
    end
end
%% Output cartella Indexing e file xls delle I e dei pattern significativi
%Usciamo con due file xls, uno col matricione delle intesità e
%l'altro con prime due colonne le 2Theta e le d e le altre colonne con i
%pattern misurati in corrispondenza delle temperature di onset peak ed
%endset del dsc. Crea la struttura di directory per poter lavorare con
%winplotr e mette in ciascuna sottodirectory il file .dat correttamente
%nominato.
if DSCmatch
    if exist(nomeOPE,'file')
        if DSCpoints==3
            mystring='DueTheta d Aonset Apeak Aoffset Bonset Bpeak Boffset Conset Cpeak Coffset Donset Dpeak Doffset Eonset Epeak Eoffset Fonset Fpeak Foffset';
            Intestazione=textscan(mystring, '%s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s', 1);
            Intestazione(i+3:20)=[];
        else
            mystring='DueTheta d Aonset Aoffset Bonset Boffset Conset Coffset Donset Doffset Eonset Eoffset Fonset Foffset';
            Intestazione=textscan(mystring, '%s %s %s %s %s %s %s %s %s %s %s %s %s %s', 1);
            Intestazione(i+3:14)=[];
        end
        Int=cell(1,i+2);
        for j=1 : i+2
            Int(j)=Intestazione{1,j};
        end
        button='';
        button1='';
        h = waitbar(0,'Exporting significative patterns...',...
            'visible','off');
        if isempty(button1)
            if exist (nomeDSC,'file')
                button1 = questdlg(['File ',nomeDSC,' containing significative patterns for indexing already exist. Overwrite?'],'Warning','Yes');
                if strcmp(button1, 'Yes')
                    delete(nomeDSC)
                    fileDSCstring=nomeDSC;
                elseif strcmp(button1, 'No')
                    mystring=[nameroot '_DSC' ];
                    string=[mystring, '*'];
                    files=dir(string);
                    mm=zeros(size(files,1),1);
                    for k=1 : size(files,1)
                        n=files(k,1).name;
                        m=regexp(n,'\d','match');
                        mm(k)=str2double(m(1,1));
                    end
                    fileDSCstring=[mystring, '_', int2str(max(mm)+1) '.xls'];
                elseif strcmp(button1, 'Cancel')
                    quit
                end
            else
                fileDSCstring=nomeDSC;
            end
        end
        for j=1 : i
            A=cat(2,DSCcurves(:,1),DSCcurves(:,j+2));
            string=Intestazione{1,j+2}{1,1};
            pathstring=['./Indexing/' string];
            filestring=[string, '.dat'];
            if exist(pathstring, 'dir')==false
                mkdir(pathstring)
                cd(pathstring)
            else
                cd(pathstring)
                if exist (filestring,'file')
                    if isempty(button)
                        button = questdlg('Files .dat corresponding to significative patterns already exist. Overwrite?','Warning','Yes');
                    end
                    set(h,'visible','on')
                    if strcmp(button,'No')
                        files=dir('*.dat');
                        n=files(size(files,1)).name;
                        m=regexp(n,'_(\d*).dat','tokens');
                        mm=str2double(m{1,1});
                        filestring=[string, '_', int2str(max(mm)+1) '.dat'];
                    elseif strcmp(button, 'Cancel')
                        quit
                    end
                end
                waitbar(j/i)
            end
            save(filestring,'A','-ascii');
            A=num2cell(A);
            B=Int;
            B(2:j+1)=[];
            B(3:i+2-j)=[];
            A=vertcat(B,A);
            if strcmp(button1, 'Yes')|| exist (nomeDSC,'file')==false
                xlswrite([percorso, '\',fileDSCstring], A,string, 'A1');
            end
            cd (percorso)
            xlswrite([percorso, '/',nomeDSC], A,string, 'A1');
        end
        delete(h)
        OPE=OPE';
        DSCcell=num2cell(DSCcurves);
        DSCcell=vertcat(Int,DSCcell);
        xlswrite([percorso,'/',nomeDSC], DSCcell,'Significative patterns', 'A1');
    end
    xlswrite(nomeIntensity, Intensity);
end
h = waitbar(0,'Finding zero intensity regions...');
%% Interpolazione del'intensità alle regioni non misurate, segnalando tramite colore
for i=1 : numrows(1)
    if Intensity(i,:)==zeros(1,ncurves-nreject)
        Intensity(i,:)=NaN;
    end
    waitbar(i/numrows(1))
end
delete(h)
if Interpolate==true
    k=isnan(Intensity(:,1));
    % list the nodes which are known, and which will
    % be interpolated
    nan_list=find(k);
    VariableMatrix(nan_list,:)=0;
    Intensity=inpaint_nans(Intensity,2);
    %Ricordarsi di citare: D'Errico, John (2004).
    %Interpolate NaN elements in a 2-d array using non-NaN elements
    %http://www.mathworks.com/matlabcentral/fileexchange/4551-inpaintnans,
    %MATLAB Central File Exchange. Retrieved Oct 4, 2012.
end
%% Crea le sottomatrici contenenti i dati di intensità diffratta relativi a bassa e alta risoluzione
dmin=d(numrows(1));
h = waitbar(0,'Creating high resolution intensity matrices...');
for i=2:numrows(1)
    if d(i)<WAXDlim(2)
        j=i-1;
        IntensityWAXD=Intensity(j:numrows(1),:);
        ColoriWAXD=VariableMatrix(j:numrows(1),:);
        dWAXD=d(j:numrows(1));
        break
    end
    waitbar(i/numrows(1))
end
delete(h)
h = waitbar(0,'Creating low resolution intensity matrices...');
for i=2:j
    if SAXDlim(2)>d(i) && d(i)>SAXDlim(1)
        dSAXD=d(i-1:j);
        IntensitySAXD=Intensity(i-1:j,:);
        ColoriSAXD=VariableMatrix(i-1:j,:);
        break
    end
    waitbar(i/numrows(1))
end
delete(h)
h = waitbar(0,'Creating Variable/Color matrices...');
for i=j:numrows(1)
    if d(i)<WAXDlim(1)
        IntensityWAXD=Intensity(j:i,:);
        ColoriWAXD=VariableMatrix(j:i,:);
        dWAXD=d(j:i);
        break
    end
    waitbar(i/numrows(1))
end
delete(h)
if flagfigure(4) || flagfigure(5) || flagfigure(6) || flagfigure(7)
    ZmaxWAXD=max(max(IntensityWAXD));
    ZminWAXD=min(min(IntensityWAXD));
    if Contour9LevelStep==0
        Contour9LevelStep=(ZmaxWAXD-ZminWAXD)/100;
    end
end
if flagfigure(1) || flagfigure(2) || flagfigure(3) || flagfigure(7)
    ZmaxSAXD=max(max(IntensitySAXD));
    ZminSAXD=min(min(IntensitySAXD));
    if Contour10LevelStep==0
        Contour10LevelStep=(ZmaxSAXD-ZminSAXD)/100;
    end
end
switch order
    case 2  %', Crystallization'

        IntensitySAXDCristallizzazione=IntensitySAXD(:,1:ncurves-nreject);
        ColoriSAXDCristallizzazione=ColoriSAXD(:,1:ncurves-nreject);
        TempiCristallizzazione=getTime(1:ncurves-nreject,1);
        TcMin=getTime(1,1);
        TMax=getTime(ncurves-nreject,1);
        ZmaxcSAXD=max(max(IntensitySAXDCristallizzazione));
        ZmincSAXD=min(min(IntensitySAXDCristallizzazione));

        IntensityWAXDCristallizzazione=IntensityWAXD(:,1:ncurves-nreject);
        ColoriWAXDCristallizzazione=ColoriWAXD(:,1:ncurves-nreject);
        ZmaxcWAXD=max(max(IntensityWAXDCristallizzazione));
        ZmincWAXD=min(min(IntensityWAXDCristallizzazione));

    case 5  %', Melting'
        TempiFusione=getTime(1:ncurves-nreject,1);
        TfMax=getTime(ncurves-nreject,1);

        if flagfigure(1) || flagfigure(2) || flagfigure(3) || flagfigure(7)

            IntensitySAXDFusione=IntensitySAXD(:,1:ncurves-nreject);
            ColoriSAXDFusione=ColoriSAXD(:,1:ncurves-nreject);
            ZmaxfSAXD=max(max(IntensitySAXDFusione));
            ZminfSAXD=min(min(IntensitySAXDFusione));
        end
        if flagfigure(4) || flagfigure(5) || flagfigure(6) || flagfigure(8)
            IntensityWAXDFusione=IntensityWAXD(:,1:ncurves-nreject);
            ColoriWAXDFusione=ColoriWAXD(:,1:ncurves-nreject);
            ZmaxfWAXD=max(max(IntensityWAXDFusione));
            ZminfWAXD=min(min(IntensityWAXDFusione));
        end
    case {1,4}  %', Melting and Crystallization'

        IntensitySAXDFusione=IntensitySAXD(:,1:posmaxVar(2));
        ColoriSAXDFusione=ColoriSAXD(:,1:posmaxVar(2));
        TempiFusione=getTime(1:posmaxVar(2),1);
        TfMax=getTime(posmaxVar(2),1);
        ZmaxfSAXD=max(max(IntensitySAXDFusione));
        ZminfSAXD=min(min(IntensitySAXDFusione));

        IntensityWAXDFusione=IntensityWAXD(:,1:posmaxVar(2));
        ColoriWAXDFusione=ColoriWAXD(:,1:posmaxVar(2));
        ZmaxfWAXD=max(max(IntensityWAXDFusione));
        ZminfWAXD=min(min(IntensityWAXDFusione));

        IntensitySAXDCristallizzazione=IntensitySAXD(:,posmaxVar(2):ncurves-nreject);
        ColoriSAXDCristallizzazione=ColoriSAXD(:,posmaxVar(2):ncurves-nreject);
        TempiCristallizzazione=getTime(posmaxVar(2):ncurves-nreject,1);
        TcMin=getTime(posmaxVar(2),1);
        TMax=getTime(ncurves-nreject,1);
        ZmaxcSAXD=max(max(IntensitySAXDCristallizzazione));
        ZmincSAXD=min(min(IntensitySAXDCristallizzazione));

        IntensityWAXDCristallizzazione=IntensityWAXD(:,posmaxVar(2):ncurves-nreject);
        ColoriWAXDCristallizzazione=ColoriWAXD(:,posmaxVar(2):ncurves-nreject);
        ZmaxcWAXD=max(max(IntensityWAXDCristallizzazione));
        ZmincWAXD=min(min(IntensityWAXDCristallizzazione));

    case {3,6}  %', Crystallization and Melting'

        IntensitySAXDCristallizzazione=IntensitySAXD(:,1:posminVar(2));
        ColoriSAXDCristallizzazione=ColoriSAXD(:,1:posminVar(2));
        TempiCristallizzazione=getTime(1:posminVar(2),1);
        TcMax=getTime(posminVar(2),1);
        ZmaxcSAXD=max(max(IntensitySAXDCristallizzazione));
        ZmincSAXD=min(min(IntensitySAXDCristallizzazione));

        IntensityWAXDCristallizzazione=IntensityWAXD(:,1:posminVar(2));
        ColoriWAXDCristallizzazione=ColoriWAXD(:,1:posminVar(2));
        ZmaxcWAXD=max(max(IntensityWAXDCristallizzazione));
        ZmincWAXD=min(min(IntensityWAXDCristallizzazione));

        IntensitySAXDFusione=IntensitySAXD(:,posminVar(2):ncurves-nreject);
        ColoriSAXDFusione=ColoriSAXD(:,posminVar(2):ncurves-nreject);
        TempiFusione=getTime(posminVar(2):ncurves-nreject,1);
        TfMin=getTime(posminVar(2),1);
        TMax=getTime(ncurves-nreject,1);
        ZmaxfSAXD=max(max(IntensitySAXDFusione));
        ZminfSAXD=min(min(IntensitySAXDFusione));

        IntensityWAXDFusione=IntensityWAXD(:,posminVar(2):ncurves-nreject);
        ColoriWAXDFusione=ColoriWAXD(:,posminVar(2):ncurves-nreject);
        ZmaxfWAXD=max(max(IntensityWAXDFusione));
        ZminfWAXD=min(min(IntensityWAXDFusione));

end
%% Crea ticks e label per l'asse X (Tempo/Temperatura/Phi/Zeta ecc)
if XtickStep==0
    XtickStep=(ceil(max(getVariable))-floor(min(getVariable)))/5;
    XlabelStep=XtickStep;
end
%flagfigure=[0,0,0,1,0,0,0,0,1];     %Nell'ordine,
%SAXS completo, SAXS c/f, SAXS f/c,
%WAXS completo, WAXS c/f, WAXS f/c,
%WAXS completo grigio, SAXS completo grigio e SAXS/WAXS contour

switch order
    case 2 %', Crystallization'
        flagfigure(1)=0;
        flagfigure(3)=0;
        flagfigure(4)=0;
        flagfigure(6)=0;
        if strcmp(label,'Variable')
            a=fix(getVariable(posmaxVar(2),1)/XtickStep)*XtickStep;
            b=fix(getVariable(posminVar(1),1)/XtickStep)*XtickStep;
            xi=(a:-XtickStep:b);
            yi=interp1(getVariable(posmaxVar(2):posminVar(1),1),getTime(posmaxVar(2):posminVar(1),1),xi,'linear','extrap');
            nstepy(1)=round(getTime(posmaxVar(2)))/mean(diff(yi));%numero di step nella regione iniziale a valore costante della variabile
            nstepy(2)=round(getTime((1+posminVar(2)-posminVar(1))))/mean(diff(yi));%numero di step nella regione finale a valore costante della variabile
            yp1=(getTime(1):yi(1)/nstepy(1):yi(1));
            yp2=(yi(end):(getTime(end)-yi(end))/nstepy(2):getTime(end));
            if any(yp1)
                yp1(end)=[];
            end
            xp1=mean(getVariable(posmaxVar(1):posmaxVar(2)))*ones(size(yp1));
            if any(yp2)
                yp2(1)=[];
            end
            xp2=mean(getVariable(posminVar(1):posminVar(2)))*ones(size(yp2));
            xii=[];
            yii=[];
        end
    case 5  %', Melting'
        flagfigure(1)=0;
        flagfigure(2)=0;
        flagfigure(4)=0;
        flagfigure(5)=0;
        i=strcmp(label,'Variable') ;
        if i==true
            a=fix(getVariable(1,1)/XtickStep)*XtickStep;
            b=fix(getVariable(ncurves-nreject,1)/XtickStep)*XtickStep;
            xi=(a:XtickStep:b);
            yi=interp1(getVariable(posminVar(2):posmaxVar(1),1),getTime(posminVar(2):posmaxVar(1),1),xi,'linear','extrap');
            nstepy(1)=round(getTime(posminVar(1)))/mean(diff(yi));%numero di step nella regione iniziale a valore costante della variabile
            nstepy(2)=round(getTime((1+posmaxVar(1)-posminVar(1))))/mean(diff(yi));%numero di step nella regione finale a valore costante della variabile
            yp1=(getTime(1):yi(1)/nstepy(1):yi(1));%
            yp2=(yi(end):(getTime(end)-yi(end))/nstepy(2):getTime(end));
            if any(yp1)
                yp1(end)=[];
            end
            xp1=mean(getVariable(posmaxVar(1):posmaxVar(2)))*ones(size(yp1));
            if any(yp2)
                yp2(1)=[];
            end
            xp2=mean(getVariable(posminVar(1):posminVar(2)))*ones(size(yp2));
            xii=[];
            yii=[];
        end
    case {1,4}  %', Melting and Crystallization'
        if strcmp(label,'Variable')
            a=(fix(getVariable(1,1)/XtickStep))*XtickStep;
            b=fix(posmaxVar(1));
            c=fix(getVariable(b,1)/XtickStep)*XtickStep;
            d=fix(1+(getVariable(ncurves-nreject,1))/XtickStep)*XtickStep;
            xi=(a:XtickStep:c);
            yi=interp1(getVariable(1:b,1),getTime(1:b,1),xi,'linear', 'extrap');
            %Interpolazione dei valori della temperatura in
            %corrispondenza dei valori del tempo nel range compreso
            %fra primo valore di temperatura e massimo valore di
            %temperatura
            xii=(c:-XtickStep:d);
            yii=interp1(getVariable(b:ncurves-nreject,1),getTime(b:ncurves-nreject,1),xii,'linear', 'extrap');
            %Interpolazione dei valori della temperatura in
            %corrispondenza dei valori del tempo nel range compreso
            %fra massimo valore di temperatura e ultimo valore di
            %temperatura
            if yi(size(xi))>yii(1)
                y=(yi(size(xi,1))+yii(1))/2;
                yi(size(xi))=a;
                yii(1)=a;
            end
        end
    case {3,6} %', Crystallization and Melting'
        if strcmp(label,'Variable')
            %a=fix((getVariable(1,1)*2)/XtickStep)*2*XtickStep;
            %Temperatura iniziale arrotondata
            a=(fix(getVariable(1,1)/XtickStep))*XtickStep;
            b=fix(posminVar(2));
            c=fix(getVariable(b,1)/XtickStep)*XtickStep;
            d=fix(getVariable(ncurves-nreject,1)/XtickStep)*XtickStep;
            xi=(a:-XtickStep:c);
            yi=interp1(getVariable(1:b,1),getTime(1:b,1),xi,'linear', 'extrap');
            %Interpolazione dei valori della temperatura in
            %corrispondenza dei valori del tempo nel range compreso
            %fra primo valore di temperatura e minimo valore di
            %temperatura
            xii=(c:XtickStep:d);
            yii=interp1(getVariable(b:ncurves-nreject,1),getTime(b:ncurves-nreject,1),xii,'linear', 'extrap');
            %Interpolazione dei valori della temperatura in
            %corrispondenza dei valori del tempo nel range compreso
            %fra minimo valore di temperatura e ultimo valore di
            %temperatura
        end
    otherwise
        warning('OpenFile:notFoundInPath', ['Could not find trend of ' Variable ' in time. Check DataExperiment.log']);
        return
end
%% Figura 1: SAXD completo
if flagfigure(1)==1
    scrsz = get(0,'ScreenSize');
    %  scrsz=[left, bottom, width, height]
    figure1 = figure(...
        'Position',[1,scrsz(4)/25, scrsz(3)*2/3, scrsz(4)/2],...
        'Name',['SAXD Pattern of ',titolofigura, orderstring],...
        'PaperPosition',[0.6345 6.345 20.3 15.23],...
        'PaperSize',[20.98 29.68],...
        'PaperType','A4');
    colormap(mappa);
    %Create axes
    axes1 = axes(...
        'YMinorGrid','on',...
        'Parent',figure1);
    axis(axes1,[getTime(1,1) getTime(ncurves-nreject,1)+1 SAXDlim(1) SAXDlim(2) ZminSAXD ZmaxSAXD]);
    camproj(axes1,'orthographic')
    if strcmp(label,'Variable')
        Xtick=[yi,yii];
        Xticklabeldouble=[xi,xii];
        n=XlabelStep/XtickStep;
        m=size(Xticklabeldouble);
        Xticklabel=cell(m);
        for i=1: m(2)
            Xticklabel(i)=cellstr(num2str(Xticklabeldouble(i)));
        end
        for i=1:n: m(2)+1
            for j=1:n-1
                if i+j>m(2)
                    break
                else
                    Xticklabel{i+j}='';
                end
            end
        end
        set(axes1,'XTick',Xtick);
        set(axes1,'XTickLabel',Xticklabel,'FontName',font_name);
        set(axes1,'XMinorTick','on');
        xlabel(axes1,xlabelVariable,'FontWeight','bold','FontName',font_name, 'FontSize', font_size);
    else
        xlabel(axes1,'Time (min)','FontWeight','bold','FontName',font_name, 'FontSize', font_size);
    end
    if titoli
        title(axes1,[ 'SAXD Pattern of ',titolofigura1,orderstring],'FontWeight','bold','FontName',font_name, 'FontSize', 8);
    end
    if strcmp(label,'Variable')
        xlabel(axes1,xlabelVariable,'FontWeight','bold','FontName',font_name, 'FontSize', font_size);
    else
        xlabel(axes1,'Time (min)','FontWeight','bold','FontName',font_name, 'FontSize', font_size);
    end
    ylabel(axes1,'Interplanar Distances(Å)','FontWeight','bold','FontName',font_name, 'FontSize', font_size);
    zlabel(axes1,'Intensity (counts)','FontWeight','bold','FontName',font_name, 'FontSize', font_size);
    view(axes1,ViewColorFigures);
    grid(axes1,'on');
    hold(axes1,'all');
    % Create mesh
    mesh1 = mesh(...
        getTime(:,1),dSAXD,IntensitySAXD,ColoriSAXD,...
        'Parent',axes1,...
        'Facecolor','interp',...
        'Facelighting','none',...
        'BackFaceLighting',' unlit',...
        'Edgecolor','interp',...
        'EdgeLighting','flat');
    if DSCas2dPlots
        hold on
        X=reshape(OPE,1,[]);
        for i=1:size(X,2)
            plot3(getTime(X(i),1)*ones(size(dSAXD)), dSAXD, IntensitySAXD(:,X(i)), 'r', 'LineWidth', 3);
        end
    end
    if createcolorbar
        % Create colorbar
        colorbar1 = colorbar('peer',...
            axes1,[0.9411 0.3916 0.01529 0.5227],...
            'Box','on',...
            'Location','manual');
        % Create textbox
        annotation1 = annotation(...
            figure1,'textbox',...
            'Position',[0.9125 0.904 0.07917 0.0746],...
            'LineStyle','none',...
            'String',{colorbarlabel},...
            'FontWeight','bold',...
            'FontName',font_name, 'FontSize', font_size,...
            'FitHeightToText','on');
    end
    % Create light
    light11 = light('Parent',axes1, 'position', [1 0 0],'style', 'infinite','visible', 'on');
    light12 = light('Parent',axes1, 'position', [0 1 0],'style', 'infinite','visible', 'on');
    light13 = light('Parent',axes1, 'position', [0 0 1],'style', 'infinite','visible', 'on');
    %     saveas(figure1,[percorso,'\', 'SAXD.fig'],'fig')
    %     saveas(figure1,[percorso,'\', 'SAXD.',estFigure],estFigure)
    switch Variable
        case 'Temperature'
            saveas(figure1,[percorso,'\', 'SAXD_Temperature.fig'],'fig')
            saveas(figure1,[percorso,'\', 'SAXD_Temperature.',estFigure],estFigure)
        otherwise
            saveas(figure1,[percorso,'\', 'SAXD_',Variable, '.fig'],'fig')
            saveas(figure1,[percorso,'\', 'SAXD_',Variable, '.', estFigure],estFigure)
    end
    if closeimages
        close(gcf)
    end
end
%% Figura 2: SAXD cristallizzazione
if flagfigure(2)==1
    scrsz = get(0,'ScreenSize');
    %  scrsz=[left, bottom, width, height]
    figure2 = figure(...
        'Position',[1,scrsz(4)/25, scrsz(3)*2/3, scrsz(4)/2],...
        'Name',['SAXD Pattern of ',titolofigura, orderstring1],...
        'PaperPosition',[0.6345 6.345 20.3 15.23],...
        'PaperSize',[20.98 29.68],...
        'PaperType','A4');
    colormap(mappa);
    switch order
        case 2  %', Crystallization'
            Xmin=1;
            Xmax=TMax;
            if strcmp(label,'Variable')
                Xtick=[yp1 yi yp2];
                Xticklabeldouble=[xp1 xi xp2];
                n=XlabelStep/XtickStep;
                m=size(Xticklabeldouble);
                Xticklabel=cell(m);
                for i=1: m(2)
                    Xticklabel(i)=cellstr(num2str(Xticklabeldouble(i)));
                end
                for i=1:n: m(2)+1
                    for j=1:n-1
                        if i+j>m(2)
                            break
                        else
                            Xticklabel{i+j}='';
                        end
                    end
                end
            end
        case {3,6}  %', Crystallization and Melting'
            Xmin=0;
            Xmax=TcMax;
            if strcmp(label,'Variable')
                Xtick=yi;
                Xticklabeldouble=xi;
                n=XlabelStep/XtickStep;
                m=size(Xticklabeldouble);
                Xticklabel=cell(m);
                for i=1: m(2)
                    Xticklabel(i)=cellstr(num2str(Xticklabeldouble(i)));
                end
                for i=1:n: m(2)+1
                    for j=1:n-1
                        if i+j>m(2)
                            break
                        else
                            Xticklabel{i+j}='';
                        end
                    end
                end
            end
        case {1,4}  %', Melting and Crystallization'
            Xmin=TcMin;
            Xmax=TMax;
            if strcmp(label,'Variable')
                Xtick=yii;
                Xticklabeldouble=xii;
                n=XlabelStep/XtickStep;
                m=size(Xticklabeldouble);
                Xticklabel=cell(m);
                for i=1: m(2)
                    Xticklabel(i)=cellstr(num2str(Xticklabeldouble(i)));
                end
                for i=1:n: m(2)+1
                    for j=1:n-1
                        if i+j>m(2)
                            break
                        else
                            Xticklabel{i+j}='';
                        end
                    end
                end
            end
    end
    % Create axes
    axes2 = axes(...
        'YMinorGrid','on',...
        'Parent',figure2);
    axis(axes2,[Xmin Xmax SAXDlim(1) SAXDlim(2) ZmincSAXD ZmaxcSAXD]);
    camproj(axes2,'orthographic')
    if titoli
        title(axes2,['SAXD pattern of ',titolofigura1, orderstring1],'FontWeight','bold','FontName',font_name, 'FontSize', font_size);
    end
    if strcmp(label,'Variable')
        set(axes2,'XTick',Xtick);
        set(axes2,'XTickLabel',Xticklabel,'FontName',font_name, 'FontSize', font_size);
        set(axes2,'XMinorTick','on');
        xlabel(axes2,xlabelVariable,'FontWeight','bold','FontName',font_name, 'FontSize', font_size);
    else
        xlabel(axes2,'Time (min)','FontWeight','bold','FontName',font_name, 'FontSize', font_size);
    end
    ylabel(axes2,'Interplanar Distances(Å)','FontWeight','bold','FontName',font_name, 'FontSize', font_size);
    zlabel(axes2,'Intensity (counts)','FontWeight','bold','FontName',font_name, 'FontSize', font_size);
    view(axes2,ViewColorFigures);
    grid(axes2,'on');
    hold(axes2,'all');
    % Create mesh
    mesh2 = mesh(...
        TempiCristallizzazione,dSAXD,IntensitySAXDCristallizzazione,ColoriSAXDCristallizzazione,...
        'Parent',axes2,...
        'Facecolor','interp',...
        'Facelighting','none',...
        'BackFaceLighting',' unlit',...
        'Edgecolor','interp',...
        'EdgeLighting','flat');
    if DSCas2dPlots
        hold on
        X=reshape(OPE,1,[]);
        for i=1:size(X,2)
            if (min(TempiCristallizzazione)<=X(i)) && (X(i)<=max(TempiCristallizzazione))
                plot3(getTime(X(i),1)*ones(size(dSAXD)), dSAXD, IntensitySAXD(:,X(i)), 'r', 'LineWidth', 3);
            end
        end
    end

    if createcolorbar
        % Create colorbar
        colorbar2 = colorbar;
        % Create textbox
        annotation2 = annotation(...
            figure2,'textbox',...
            'Position',[0.9125 0.904 0.07917 0.0746],...
            'LineStyle','none',...
            'String',{colorbarlabel},...
            'FontWeight','bold',...
            'FontName',font_name, 'FontSize', font_size,...
            'FitHeightToText','on');
    end
    % Create light
    light21 = light('Parent',axes2, 'position', [1 0 0],'style', 'infinite','visible', 'on');
    light22 = light('Parent',axes2, 'position', [0 1 0],'style', 'infinite','visible', 'on');
    light23 = light('Parent',axes2, 'position', [0 0 1],'style', 'infinite','visible', 'on');
    switch Variable
        case 'Temperature'
            saveas(figure2,[percorso,'\', 'SAXD_cryst.fig'],'fig')
            saveas(figure2,[percorso,'\', 'SAXD_cryst.',estFigure],estFigure)
        otherwise
            saveas(figure2,[percorso,'\', 'SAXDdecr.fig'],'fig')
            saveas(figure2,[percorso,'\', 'SAXDdecr.',estFigure],estFigure)
    end
    if closeimages
        close(gcf)
    end
end
%% Figura 3: SAXD fusione
if flagfigure(3)==1
    scrsz = get(0,'ScreenSize');
    %  scrsz=[left, bottom, width, height]
    figure3 = figure(...
        'Position',[1,scrsz(4)/25, scrsz(3)*2/3, scrsz(4)/2],...
        'Name',['SAXD Pattern of ',titolofigura, orderstring2],...
        'PaperPosition',[0.6345 6.345 20.3 15.23],...
        'PaperSize',[20.98 29.68],...
        'PaperType','A4');
    colormap(mappa);
    switch order
        case {1,4}  %', Melting and Crystallization';
            Xmin=0;
            Xmax=TfMax;
            if strcmp(label,'Variable')
                Xtick=yi;
                Xticklabeldouble=xi;
                n=XlabelStep/XtickStep;
                m=size(Xticklabeldouble);
                Xticklabel=cell(m);
                for i=1: m(2)
                    Xticklabel(i)=cellstr(num2str(Xticklabeldouble(i)));
                end
                for i=1:n: m(2)+1
                    for j=1:n-1
                        if i+j>m(2)
                            break
                        else
                            Xticklabel{i+j}='';
                        end
                    end
                end
            end
        case {3,6}  %', Crystallization and Melting'
            Xmin=TfMin;
            Xmax=TMax;
            if strcmp(label,'Variable')
                Xtick=yii;
                Xticklabeldouble=xii;
                n=XlabelStep/XtickStep;
                m=size(Xticklabeldouble);
                Xticklabel=cell(m);
                for i=1: m(2)
                    Xticklabel(i)=cellstr(num2str(Xticklabeldouble(i)));
                end
                for i=1:n: m(2)+1
                    for j=1:n-1
                        if i+j>m(2)
                            break
                        else
                            Xticklabel{i+j}='';
                        end
                    end
                end
            end
        case 5  %', Melting'
            Xmin=0;
            Xmax=TfMax;
            if strcmp(label,'Variable')
                Xtick=yi;
                Xticklabeldouble=xi;
                n=XlabelStep/XtickStep;
                m=size(Xticklabeldouble);
                Xticklabel=cell(m);
                for i=1: m(2)
                    Xticklabel(i)=cellstr(num2str(Xticklabeldouble(i)));
                end
                for i=1:n: m(2)+1
                    for j=1:n-1
                        if i+j>m(2)
                            break
                        else
                            Xticklabel{i+j}='';
                        end
                    end
                end
            end
    end
    % Create axes
    axes3 = axes(...
        'YMinorGrid','on',...
        'Parent',figure3);
    axis(axes3,[Xmin Xmax SAXDlim(1) SAXDlim(2) ZminfSAXD ZmaxfSAXD]);
    camproj(axes3,'orthographic')
    if titoli
        title(axes3,['SAXD pattern of ',titolofigura1, orderstring],'FontWeight','bold','FontName',font_name, 'FontSize', font_size);
    end
    if strcmp(label,'Variable')
        set(axes3,'XTick',Xtick);
        set(axes3,'XTickLabel',Xticklabel,'FontName',font_name, 'FontSize', font_size);
        set(axes3,'XMinorTick','on');
        xlabel(axes3,xlabelVariable,'FontWeight','bold','FontName',font_name, 'FontSize', font_size);
    else
        xlabel(axes3,'Time (min)','FontWeight','bold','FontName',font_name, 'FontSize', font_size);
    end
    ylabel(axes3,'Interplanar Distances(Å)','FontWeight','bold','FontName',font_name, 'FontSize', font_size);
    zlabel(axes3,'Intensity (counts)','FontWeight','bold','FontName',font_name, 'FontSize', font_size);
    view(axes3,ViewColorFigures);
    grid(axes3,'on');
    hold(axes3,'all');
    % Create mesh
    mesh3 = mesh(...
        TempiFusione,dSAXD,IntensitySAXDFusione,ColoriSAXDFusione,...
        'Parent',axes3,...
        'Facecolor','interp',...
        'Facelighting','none',...
        'BackFaceLighting',' unlit',...
        'Edgecolor','interp',...
        'EdgeLighting','flat');
    if DSCas2dPlots
        hold on
        X=reshape(OPE,1,[]);
        for i=1:size(X,2)
            if (min(TempiFusione)<=X(i)) && (X(i)<=max(TempiFusione))
                plot3(getTime(X(i),1)*ones(size(dSAXD)), dSAXD, IntensitySAXD(:,X(i)), 'r', 'LineWidth', 3);
            end
        end
    end

    if createcolorbar
        % Create colorbar
        colorbar3 = colorbar;
        % Create textbox
        annotation3 = annotation(...
            figure3,'textbox',...
            'Position',[0.9125 0.904 0.07917 0.0746],...
            'LineStyle','none',...
            'FontWeight','bold',...
            'FontName',font_name, 'FontSize', font_size,...
            'String',{colorbarlabel},...
            'FitHeightToText','on');
    end
    % Create light
    light31 = light('Parent',axes3, 'position', [1 0 0],'style', 'infinite','visible', 'on');
    light32 = light('Parent',axes3, 'position', [0 1 0],'style', 'infinite','visible', 'on');
    light33 = light('Parent',axes3, 'position', [0 0 1],'style', 'infinite','visible', 'on');
    %     saveas(figure3,[percorso,'\', 'SAXDincr.fig'],'fig')
    %     saveas(figure3,[percorso,'\', 'SAXDincr.',estFigure],estFigure)
    switch Variable
        case 'Temperature'
            saveas(figure3,[percorso,'\', 'SAXD_melt.fig'],'fig')
            saveas(figure3,[percorso,'\', 'SAXD_melt.',estFigure],estFigure)
        otherwise
            saveas(figure3,[percorso,'\', 'SAXDincr.fig'],'fig')
            saveas(figure3,[percorso,'\', 'SAXDincr.',estFigure],estFigure)
    end
    if closeimages
        close(gcf)
    end
end
%% Figura 4: WAXD completo
if flagfigure(4)==1
    scrsz = get(0,'ScreenSize');
    %  scrsz=[left, bottom, width, height]
    figure4 = figure(...
        'Position',[1,scrsz(4)/25, scrsz(3)*2/3, scrsz(4)/2],...
        'Name',['WAXD Pattern of ',titolofigura, orderstring],...
        'PaperPosition',[0.6345 6.345 20.3 15.23],...
        'PaperSize',[20.98 29.68],...
        'PaperType','A4');
    colormap(mappa);
    axes4 = axes(...
        'YMinorGrid','on',...
        'Parent',figure4);
    axis(axes4,[getTime(1,1) getTime(ncurves-nreject,1)+1 WAXDlim(1) WAXDlim(2) ZminWAXD ZmaxWAXD]);
    camproj(axes4,'orthographic')
    if strcmp(label,'Variable')
        Xtick=[yi,yii];
        Xticklabeldouble=[xi,xii];
        n=XlabelStep/XtickStep;
        m=size(Xticklabeldouble);
        Xticklabel=cell(m);
        for i=1: m(2)
            Xticklabel(i)=cellstr(num2str(Xticklabeldouble(i)));
        end
        for i=1:n: m(2)+1
            for j=1:n-1
                if i+j>m(2)
                    break
                else
                    Xticklabel{i+j}='';
                end
            end
        end
        set(axes4,'XTick',Xtick);
        set(axes4,'XTickLabel',Xticklabel,'FontName',font_name, 'FontSize', font_size);
        set(axes4,'XMinorTick','on');
    end
    if titoli
        title(axes4,[ 'WAXD Pattern of ',titolofigura1,orderstring],'FontWeight','bold','FontName',font_name, 'FontSize', font_size);
    end
    if strcmp(label,'Variable')
        xlabel(axes4,xlabelVariable,'FontWeight','bold','FontName',font_name, 'FontSize', font_size);
    else
        xlabel(axes4,'Time (min)','FontWeight','bold','FontName',font_name, 'FontSize', font_size);
    end
    ylabel(axes4,'Interplanar Distances(Å)','FontWeight','bold','FontName',font_name, 'FontSize', font_size);
    zlabel(axes4,'Intensity (counts)','FontWeight','bold','FontName',font_name, 'FontSize', font_size);

    view(axes4,ViewColorFigures);
    grid(axes4,'on');
    hold(axes4,'on');
    %Create mesh
    mesh4 = mesh(...
        getTime(:,1),dWAXD,IntensityWAXD,ColoriWAXD,...
        'Parent',axes4,...
        'Facecolor','interp',...
        'Facelighting','none',...
        'BackFaceLighting',' unlit',...
        'Edgecolor','interp',...
        'EdgeLighting','flat');
    if DSCas2dPlots
        hold on
        X=reshape(OPE,1,[]);
        for i=1:size(X,2)
                plot3(getTime(X(i),1)*ones(size(dWAXD)), dWAXD, IntensityWAXD(:,X(i)), 'r', 'LineWidth', 3);
        end
    end
    if createcolorbar
        % Create colorbar
        colorbar4 = colorbar;
        % Create textbox
        annotation4 = annotation(...
            figure4,'textbox',...
            'Position',[0.9125 0.904 0.07917 0.0746],...
            'LineStyle','none',...
            'FontWeight','bold',...
            'FontName',font_name, 'FontSize', font_size,...
            'String',{colorbarlabel},...
            'FitHeightToText','on');
    end
    % Create light
    light41 = light('Parent',axes4, 'position', [-1 0 0],'style', 'infinite','visible', 'on');
    light42 = light('Parent',axes4, 'position', [0 -1 0],'style', 'infinite','visible', 'on');
    light43 = light('Parent',axes4, 'position', [0 0 -1],'style', 'infinite','visible', 'on');
    %     saveas(figure4,[percorso,'\', 'WAXD.fig'],'fig')
    %     saveas(figure4,[percorso,'\', 'WAXD.',estFigure],estFigure)
    switch Variable
        case 'Temperature'
            saveas(figure4,[percorso,'\', 'WAXD_Temperature.fig'],'fig')
            saveas(figure4,[percorso,'\', 'WAXD_Temperature.',estFigure],estFigure)
        otherwise
            saveas(figure4,[percorso,'\', 'WAXD_',Variable, '.fig'],'fig')
            saveas(figure4,[percorso,'\', 'WAXD_',Variable, '.', estFigure],estFigure)
    end
    if closeimages
        close(gcf)
    end
end
%% Figura 5: WAXD cristallizzazione
if flagfigure(5)==1
    scrsz = get(0,'ScreenSize');
    %  scrsz=[left, bottom, width, height]
    figure5 = figure(...
        'Position',[1,scrsz(4)/25, scrsz(3)*2/3, scrsz(4)/2],...
        'Name',['WAXD Pattern of ',titolofigura, orderstring1],...
        'PaperPosition',[0.6345 6.345 20.3 15.23],...
        'PaperSize',[20.98 29.68],...
        'PaperType','A4');
    colormap(mappa);
    switch order
        case 2  %', Crystallization'
            Xmin=1;
            Xmax=TMax;
            if strcmp(label,'Variable')
                Xtick=[yp1 yi yp2];
                Xticklabeldouble=[xp1 xi xp2];
                n=XlabelStep/XtickStep;
                m=size(Xticklabeldouble);
                Xticklabel=cell(m);
                for i=1: m(2)
                    Xticklabel(i)=cellstr(num2str(Xticklabeldouble(i)));
                end
                for i=1:n: m(2)+1
                    for j=1:n-1
                        if i+j>m(2)
                            break
                        else
                            Xticklabel{i+j}='';
                        end
                    end
                end
            end
        case {3,6}  %', Crystallization and Melting'
            Xmin=0;
            Xmax=TcMax;
            if strcmp(label,'Variable')
                Xtick=yi;
                Xticklabeldouble=xi;
                n=XlabelStep/XtickStep;
                m=size(Xticklabeldouble);
                Xticklabel=cell(m);
                for i=1: m(2)
                    Xticklabel(i)=cellstr(num2str(Xticklabeldouble(i)));
                end
                for i=1:n: m(2)+1
                    for j=1:n-1
                        if i+j>m(2)
                            break
                        else
                            Xticklabel{i+j}='';
                        end
                    end
                end
            end
        case {1,4}  %', Melting and Crystallization'
            Xmin=TcMin;
            Xmax=TMax;
            if strcmp(label,'Variable')
                Xtick=yii;
                Xticklabeldouble=xii;
                n=XlabelStep/XtickStep;
                m=size(Xticklabeldouble);
                Xticklabel=cell(m);
                for i=1: m(2)
                    Xticklabel(i)=cellstr(num2str(Xticklabeldouble(i)));
                end
                for i=1:n: m(2)+1
                    for j=1:n-1
                        if i+j>m(2)
                            break
                        else
                            Xticklabel{i+j}='';
                        end
                    end
                end
            end
    end
    % Create axes
    axes5 = axes(...
        'YMinorGrid','on',...
        'Parent',figure5);
    axis(axes5,[Xmin Xmax WAXDlim(1) WAXDlim(2) ZmincWAXD ZmaxcWAXD]);
    camproj(axes5,'orthographic')
    if titoli
        title(axes5,['WAXD pattern of ',titolofigura1, orderstring1],'FontWeight','bold','FontName',font_name, 'FontSize', font_size);
    end
    if strcmp(label,'Variable')
        set(axes5,'XTick',Xtick);
        set(axes5,'XTickLabel',Xticklabel,'FontName',font_name, 'FontSize', font_size);
        set(axes5,'XMinorTick','on');
        xlabel(axes5,xlabelVariable,'FontWeight','bold','FontName',font_name, 'FontSize', font_size);
    else
        xlabel(axes5,'Time (min)','FontWeight','bold','FontName',font_name, 'FontSize', font_size);
    end
    ylabel(axes5,'Interplanar Distances(Å)','FontWeight','bold','FontName',font_name, 'FontSize', font_size);
    zlabel(axes5,'Intensity (counts)','FontWeight','bold','FontName',font_name, 'FontSize', font_size);
    view(axes5,ViewColorFigures);
    grid(axes5,'on');
    hold(axes5,'all');
    % Create mesh
    mesh5 = mesh(...
        TempiCristallizzazione,dWAXD,IntensityWAXDCristallizzazione,ColoriWAXDCristallizzazione,...
        'Parent',axes5,...
        'Facecolor','interp',...
        'Facelighting','none',...
        'BackFaceLighting',' unlit',...
        'Edgecolor','interp',...
        'EdgeLighting','flat');
    hold on
    X=reshape(OPE,1,[]);
    for i=1:size(X,2)
        if (min(TempiCristallizzazione)<=X(i)) && (X(i)<=max(TempiCristallizzazione))
            plot3(getTime(X(i),1)*ones(size(dWAXD)), dWAXD, IntensityWAXD(:,X(i)), 'r', 'LineWidth', 3);
        end
    end

    if createcolorbar
        % Create colorbar
        colorbar5 = colorbar;
        % Create textbox
        annotation5 = annotation(...
            figure5,'textbox',...
            'Position',[0.9125 0.904 0.07917 0.0746],...
            'LineStyle','none',...
            'FontWeight','bold',...
            'FontName',font_name, 'FontSize', font_size,...
            'String',{colorbarlabel},...
            'FitHeightToText','on');
    end
    % Create light
    light51 = light('Parent',axes5, 'position', [-1 0 0],'style', 'infinite','visible', 'on');
    light52 = light('Parent',axes5, 'position', [0 -1 0],'style', 'infinite','visible', 'on');
    light53 = light('Parent',axes5, 'position', [0 0 -1],'style', 'infinite','visible', 'on');
    % light54 = light('Parent',axes5, 'position', [1 0 0],'style','infinite','visible', 'on');
    % light55 = light('Parent',axes5, 'position', [0 1 0],'style', 'infinite','visible', 'on');
    % light56 = light('Parent',axes5, 'position', [0 0 1],'style', 'infinite','visible', 'on');
    %     saveas(figure5,[percorso,'\', 'WAXDdecr.fig'],'fig')
    %     saveas(figure5,[percorso,'\', 'WAXDdecr.',estFigure],estFigure)
    switch Variable
        case 'Temperature'
            saveas(figure5,[percorso,'\', 'WAXD_cryst.fig'],'fig')
            saveas(figure5,[percorso,'\', 'WAXD_cryst.',estFigure],estFigure)
        otherwise
            saveas(figure5,[percorso,'\', 'WAXDdecr.fig'],'fig')
            saveas(figure5,[percorso,'\', 'WAXDdecr.',estFigure],estFigure)
    end
    if closeimages
        close(gcf)
    end
end
%% Figura 6: WAXD fusione
if flagfigure(6)==1
    scrsz = get(0,'ScreenSize');
    %  scrsz=[left, bottom, width, height]
    figure6 = figure(...
        'Position',[1,scrsz(4)/25, scrsz(3)*2/3, scrsz(4)/2],...
        'Name',['WAXD Pattern of ',titolofigura, orderstring2],...
        'PaperPosition',[0.6345 6.345 20.3 15.23],...
        'PaperSize',[20.98 29.68],...
        'PaperType','A4');
    colormap(mappa);
    switch order
        case {1,4}  %', Melting and Crystallization';
            Xmin=0;
            Xmax=TfMax;
            if strcmp(label,'Variable')
                Xtick=yi;
                Xticklabeldouble=xi;
                n=XlabelStep/XtickStep;
                m=size(Xticklabeldouble);
                Xticklabel=cell(m);
                for i=1: m(2)
                    Xticklabel(i)=cellstr(num2str(Xticklabeldouble(i)));
                end
                for i=1:n: m(2)+1
                    for j=1:n-1
                        if i+j>m(2)
                            break
                        else
                            Xticklabel{i+j}='';
                        end
                    end
                end
            end
        case {3,6}  %', Crystallization and Melting'
            Xmin=TfMin;
            Xmax=TMax;
            if strcmp(label,'Variable')
                Xtick=yii;
                Xticklabeldouble=xii;
                n=XlabelStep/XtickStep;
                m=size(Xticklabeldouble);
                Xticklabel=cell(m);
                for i=1: m(2)
                    Xticklabel(i)=cellstr(num2str(Xticklabeldouble(i)));
                end
                for i=1:n: m(2)+1
                    for j=1:n-1
                        if i+j>m(2)
                            break
                        else
                            Xticklabel{i+j}='';
                        end
                    end
                end
            end
        case 5 %', Melting'
            Xmin=0;
            Xmax=TfMax;
            if strcmp(label,'Variable')
                Xtick=yi;
                Xticklabeldouble=xi;
                n=XlabelStep/XtickStep;
                m=size(Xticklabeldouble);
                Xticklabel=cell(m);
                for i=1: m(2)
                    Xticklabel(i)=cellstr(num2str(Xticklabeldouble(i)));
                end
                for i=1:n: m(2)+1
                    for j=1:n-1
                        if i+j>m(2)
                            break
                        else
                            Xticklabel{i+j}='';
                        end
                    end
                end
            end
    end
    % Create axes
    axes6 = axes(...
        'YMinorGrid','on',...
        'Parent',figure6);
    axis(axes6,[Xmin Xmax WAXDlim(1) WAXDlim(2) ZminfWAXD ZmaxfWAXD]);
    camproj(axes6,'orthographic')
    if titoli
        title(axes6,['WAXD pattern of ',titolofigura1, orderstring2],'FontWeight','bold','FontName',font_name, 'FontSize', font_size);
    end
    if strcmp(label,'Variable')
        set(axes6,'XTick',Xtick);
        set(axes6,'XTickLabel',Xticklabel,'FontName',font_name, 'FontSize', font_size);
        set(axes6,'XMinorTick','on');
        xlabel(axes6,xlabelVariable,'FontWeight','bold','FontName',font_name, 'FontSize', font_size);
    else
        xlabel(axes6,'Time (min)','FontWeight','bold','FontName',font_name, 'FontSize', font_size);
    end
    ylabel(axes6,'Interplanar Distances(Å)','FontWeight','bold','FontName',font_name, 'FontSize', font_size);
    zlabel(axes6,'Intensity (counts)','FontWeight','bold','FontName',font_name, 'FontSize', font_size);
    view(axes6,ViewColorFigures);
    grid(axes6,'on');
    hold(axes6,'all');
    % Create mesh
    mesh6 = mesh(...
        TempiFusione,dWAXD,IntensityWAXDFusione,ColoriWAXDFusione,...
        'Parent',axes6,...
        'Facecolor','interp',...
        'Facelighting','none',...
        'BackFaceLighting',' unlit',...
        'Edgecolor','interp',...
        'EdgeLighting','flat');
        hold on
    X=reshape(OPE,1,[]);
    for i=1:size(X,2)
        if (min(TempiFusione)<=X(i)) && (X(i)<=max(TempiFusione))
            plot3(getTime(X(i),1)*ones(size(dWAXD)), dWAXD, IntensityWAXD(:,X(i)), 'r', 'LineWidth', 3);
        end
    end
    if createcolorbar
        % Create colorbar
        colorbar6 = colorbar;
        % Create textbox
        annotation6 = annotation(...
            figure6,'textbox',...
            'Position',[0.9125 0.904 0.07917 0.0746],...
            'LineStyle','none',...
            'FontWeight','bold',...
            'FontName',font_name, 'FontSize', font_size,...
            'String',{colorbarlabel},...
            'FitHeightToText','on');
    end
    % Create light
    light61 = light('Parent',axes6, 'position', [-1 0 0],'style', 'infinite','visible', 'on');
    light62 = light('Parent',axes6, 'position', [0 -1 0],'style', 'infinite','visible', 'on');
    light63 = light('Parent',axes6, 'position', [0 0 -1],'style', 'infinite','visible', 'on');
    %     saveas(figure6,[percorso,'\', 'WAXDincr.fig'],'fig')
    %     saveas(figure6,[percorso,'\', 'WAXDincr.',estFigure],estFigure)
    switch Variable
        case 'Temperature'
            saveas(figure6,[percorso,'\', 'WAXD_melt.fig'],'fig')
            saveas(figure6,[percorso,'\', 'WAXD_melt.',estFigure],estFigure)
        otherwise
            saveas(figure6,[percorso,'\', 'WAXDincr.fig'],'fig')
            saveas(figure6,[percorso,'\', 'WAXDincr.',estFigure],estFigure)
    end
    if closeimages
        close(gcf)
    end
end
%% Figura 7: SAXD cristallizazione e fusione, in grigio
if flagfigure(7)==1
    if getTime(ncurves-nreject,1)>0
        scrsz = get(0,'ScreenSize');
        %  scrsz=[left, bottom, width, height]
        figure7 = figure(...
            'Position',[1,scrsz(4)/25, scrsz(3)*2/3, scrsz(4)/2],...
            'Name',['SAXD Pattern of ',titolofigura, orderstring],...
            'PaperPosition',[0.6345 6.345 20.3 15.23],...
            'PaperSize',[20.98 29.68],...
            'PaperType','A4');
        colormap(gray);
        %Create axes
        axes7 = axes(...
            'YMinorGrid','on',...
            'Parent',figure7);
        axis(axes7,[getTime(1,1) getTime(ncurves-nreject,1)+1 SAXDlim(1) SAXDlim(2) ZminSAXD ZmaxSAXD]);
        camproj(axes7,'orthographic')
        if strcmp(label,'Variable')
            Xtick=[yi,yii];
            Xticklabeldouble=[xi,xii];
            n=XlabelStep/XtickStep;
            m=size(Xticklabeldouble);
            Xticklabel=cell(m);
            for i=1: m(2)
                Xticklabel(i)=cellstr(num2str(Xticklabeldouble(i)));
            end
            for i=1:n: m(2)+1
                for j=1:n-1
                    if i+j>m(2)
                        break
                    else
                        Xticklabel{i+j}='';
                    end
                end
            end
            set(axes7,'XTick',Xtick);
            set(axes7,'XTickLabel',Xticklabel,'FontName',font_name, 'FontSize', font_size);
            set(axes7,'XMinorTick','on');
        end
        if titoli
            title(axes7,[ 'SAXD Pattern of ',titolofigura1,orderstring],'FontWeight','bold','FontName',font_name, 'FontSize', font_size);
        end
        if strcmp(label,'Variable')
            xlabel(axes7,xlabelVariable,'FontWeight','bold','FontName',font_name, 'FontSize', font_size);
        else
            xlabel(axes7,'Time (min)','FontWeight','bold','FontName',font_name, 'FontSize', font_size);
        end
        ylabel(axes7,'Interplanar Distances(Å)','FontWeight','bold','FontName',font_name, 'FontSize', font_size);
        zlabel(axes7,'Intensity (counts)','FontWeight','bold','FontName',font_name, 'FontSize', font_size);
        view(axes7,ViewGrayFigures);
        grid(axes7,'on');
        hold(axes7,'all');
        % Create mesh
        mesh7 = mesh(...
            getTime(:,1),dSAXD,IntensitySAXD,ColoriSAXD,...,...
            'Parent',axes7,...
            'EdgeLighting','gouraud',...
            'FaceLighting','gouraud',...
            'BackFaceLighting','unlit',...
            'LineStyle','-',...
            'FaceColor','Flat',...
            'EdgeColor','Interp');
        if DSCas2dPlots
            hold on
            X=reshape(OPE,1,[]);
            for i=1:size(X,2)
                plot3(getTime(X(i),1)*ones(size(dSAXD)), dSAXD, IntensitySAXD(:,X(i)), 'r', 'LineWidth', 3);
            end
        end
        % Create light
        light71 = light('Parent',axes7, 'position', [-1 0 0],'style', 'infinite','visible', 'on');
        light72 = light('Parent',axes7, 'position', [0 -1 0],'style', 'infinite','visible', 'on');
        light73 = light('Parent',axes7, 'position', [0 0 -1],'style', 'infinite','visible', 'on');
        light74 = light('Parent',axes7, 'position', [1 0 0],'style','infinite','visible', 'on');
        light75 = light('Parent',axes7, 'position', [0 1 0],'style', 'infinite','visible', 'on');
        light76 = light('Parent',axes7, 'position', [0 0 1],'style', 'infinite','visible', 'on');
        saveas(figure7,[percorso,'\', 'SAXDgray.fig'],'fig')
        saveas(figure7,[percorso,'\', 'SAXDgray.',estFigure],estFigure)
        if closeimages
            close(gcf)
        end
    end
end
%% Figura 8: WAXD cristallizazione e fusione, in grigio
if flagfigure(8)==1
    scrsz = get(0,'ScreenSize');
    %  scrsz=[left, bottom, width, height]
    figure8 = figure(...
        'Position',[1,scrsz(4)/25, scrsz(3)*2/3, scrsz(4)/2],...
        'Name',['WAXD Pattern of ',titolofigura, orderstring],...
        'PaperPosition',[0.6345 6.345 20.3 15.23],...
        'PaperSize',[20.98 29.68],...
        'PaperType','A4');
    colormap(gray);
    axes8 = axes(...
        'YMinorGrid','on',...
        'Parent',figure8);
    axis(axes8,[getTime(1,1) getTime(ncurves-nreject,1)+1 WAXDlim(1) WAXDlim(2) ZminWAXD ZmaxWAXD]);
    camproj(axes8,'orthographic')
    if strcmp(label,'Variable')
        Xtick=[yi,yii];
        Xticklabeldouble=[xi,xii];
        n=XlabelStep/XtickStep;
        m=size(Xticklabeldouble);
        Xticklabel=cell(m);
        for i=1: m(2)
            Xticklabel(i)=cellstr(num2str(Xticklabeldouble(i)));
        end
        for i=1:n: m(2)+1
            for j=1:n-1
                if i+j>m(2)
                    break
                else
                    Xticklabel{i+j}='';
                end
            end
        end
        set(axes8,'XTick',Xtick);
        set(axes8,'XTickLabel',Xticklabel,'FontName',font_name, 'FontSize', font_size);
        set(axes8,'XMinorTick','on');
    end
    if titoli
        title(axes8,[ 'WAXD Pattern of ',titolofigura1,orderstring],'FontWeight','bold','FontName',font_name, 'FontSize', font_size);
    end
    if strcmp(label,'Variable')
        xlabel(axes8,xlabelVariable,'FontWeight','bold','FontName',font_name, 'FontSize', font_size);
    else
        xlabel(axes8,'Time (min)','FontWeight','bold','FontName',font_name, 'FontSize', font_size);
    end
    ylabel(axes8,'Interplanar Distances(Å)','FontWeight','bold','FontName',font_name, 'FontSize', font_size);
    zlabel(axes8,'Intensity (counts)','FontWeight','bold','FontName',font_name, 'FontSize', font_size);
    view(axes8,ViewGrayFigures);
    grid(axes8,'on');
    hold(axes8,'on');
    mesh8 = mesh(...
        getTime(:,1),dWAXD,IntensityWAXD,ColoriWAXD,...
        'Parent',axes8,...
        'EdgeLighting','gouraud',...
        'FaceLighting','gouraud',...
        'BackFaceLighting','unlit',...
        'LineStyle','-',...
        'FaceColor','Flat',...
        'EdgeColor','Interp');
    if DSCas2dPlots
        hold on
        X=reshape(OPE,1,[]);
        for i=1:size(X,2)
            plot3(getTime(X(i),1)*ones(size(dWAXD)), dWAXD, IntensityWAXD(:,X(i)), 'r', 'LineWidth', 3);
        end
    end

    saveas(figure8,[percorso,'\', 'WAXDgray.fig'],'fig')
    saveas(figure8,[percorso,'\', 'WAXDgray.', estFigure],estFigure)
    if closeimages
        close(gcf)
    end
end
%% Figura 9: Contour plot
if flagfigure(9)==1
    scrsz = get(0,'ScreenSize');
    %  scrsz=[left, bottom, width, height]
    figure9 = figure(...
        'Position',[1,scrsz(4)/25, scrsz(3)*2/3, scrsz(4)/2],...
        'FileName',[percorso,'\', 'Contour.fig'],...
        'Name',['SAXD and WAXD Pattern Contour of ',nameroot, orderstring],...
        'PaperPosition',[0.6345 6.345 20.3 15.23],...
        'PaperSize',[20.98 29.68],...
        'PaperType','A4');
    colormap(mappa);
    % Create SAXS axes
    if ~eq(SAXDlim(1), SAXDlim(2));
        if ~eq(WAXDlim(1), WAXDlim(2));
            axes9 = axes(...
                'Layer','top',...
                'Position',[0.1 0.57 0.8 0.35],...
                'XTickmode','manual',...
                'XTick',[],...
                'Parent',figure9);
        else
            axes9 = axes(...
                'Layer','top',...
                'Position',[0.1 0.57 0.8 0.6],...
                'XTickmode','manual',...
                'XTick',[],...
                'Parent',figure9);
        end
        axis(axes9,[getTime(1,1) getTime(ncurves-nreject,1) SAXDlim(1) SAXDlim(2)]);
        if titoli
            title(axes9,['SAXD and WAXD Pattern Contour of ' , titolofigura1],'FontWeight','bold','FontName',font_name, 'FontSize', font_size);
        end
        ylabel(axes9,'Interplanar Distance (Å)');
        hold(axes9,'all');
        % Create contour
        contour9 = contour(getTime(:,1),...
            dSAXD,IntensitySAXD,...
            'Parent',axes9,...
            'LevelStep',Contour9LevelStep);
    end
    if ~eq(WAXDlim(1), WAXDlim(2));
        if ~eq(SAXDlim(1), SAXDlim(2));

            % Create axes
            axes10 = axes('Position',[0.1 0.3 0.8 0.25],...
                'Parent',figure9);
        else
            % Create axes
            axes10 = axes('Position',[0.1 0.3 0.8 0.6],...
                'Parent',figure9);

        end
        % 'XTickmode','manual',...
        % 'XTick',[],...
        axis(axes10,[getTime(1,1) getTime(ncurves-nreject,1) WAXDlim(1) WAXDlim(2)]);
        hold(axes10,'all');
        % Create contour
        contour10 = contour(getTime(:,1),...
            dWAXD,IntensityWAXD,...
            'Parent',axes10,...
            'LevelStep',Contour10LevelStep);
    end
    % Create axes
    axes11 = axes(...
        'Position',[0.1 0.08 0.8 0.18],...
        'XGrid','on',...
        'YGrid','on',...
        'YMinorGrid','on',...
        'Parent',figure9);
    axis(axes11,[getTime(1,1) getTime(ncurves-nreject,1) min(getVariable) max(getVariable)]);
    xlabel(axes11,'Time (min)');
    ylabel(axes11,xlabelVariable);
    hold(axes11,'all');
    % Create plot
    plot1 = plot(...
        getTime(:,1),getVariable(:,1),...
        'Parent',axes11,...
        'DisplayName','Variable',...
        'XDataSource','getTime',...
        'YDataSource','getVariable');
    % Create annotations: DSC references
    if DSCmatch
        if exist(nomeOPE,'file')
            k=size(TimeOPE);
            for i=1 : k(2)
                annotation1 = annotation(figure9,...
                    'line',...
                    [0.1+(0.8/getTime(ncurves-nreject,1))*TimeOPE(i) 0.1+(0.8/getTime(ncurves-nreject,1))*TimeOPE(i)],[0.08  0.92],...
                    'LineStyle',':',...
                    'LineWidth',2,...
                    'Color',[1 0 0]);
            end
            % Create textbox
            if DSCpoints==3
                mystring='----    Onset Peak Endset of DSC';
            else
                mystring='----    Onset - Endset of DSC';
            end
            annotation13 = annotation(...
                figure9,'textbox',...
                'Position',[0.65 -.015 0.3018 0.07143],...
                'LineStyle','none',...
                'Color',[1 0 0],...
                'FitHeightToText','off',...
                'FontSize',8,...
                'String',{mystring});
        end
    end
    switch Variable
        case 'Temperature'
            savefig(gcf,'Contour_Temperature.fig','compact')
            saveas(figure9,[percorso,'\', 'Contour_Temperature.',estFigure],estFigure)
        otherwise
            savefig(gcf,['Contour_' Variable '.fig'],'compact')
            saveas(figure9,[percorso '\' 'Contour_' Variable, '.', estFigure],estFigure)
    end
    if closeimages
        close(gcf)
    end
end
%% Save workspace data

save([percorso,'\',nomeWS]);
