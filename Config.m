%% Settaggio parametri
config.flagfigure = [1,1,1,1,1,1,1,1,1];
config.lambda = 1.2;
config.Variable = 'Temperature';
config.DSCpoints = 3;
config.mappa = 'jet';
config.colorbarlabel = 'T(°C)';
config.flagfigure=[1,1,1,1,1,1,1,1,1];     %Nell'ordine,
%flagfigure=[1,0,0,0,0,0,0,0,0];     %Nell'ordine,
%SAXS completo, SAXS c/f, SAXS f/c,
%WAXS completo, WAXS c/f, WAXS f/c,
%WAXS completo grigio, SAXS completo grigio e SAXS/WAXS contour
config.lambda=1.2;                         %Wavelenght
config.path='Z:\Il mio Drive\Analisi UD\Noccioli\RampeMesh\1\Winplotr\Rampa cristallizzazione-fusione\';
config.nameroot = [config.path 'Ramp_'];
config.titolofigura = 'Organogel'; %Titolo per la barra della finestra
config.titolofigura1=strrep(config.titolofigura, '_', '\_'); %Titolo interno della figura
config.WAXDlim(1)=1.53;        %WAXD interplanar distances lower limit
config.WAXDlim(2)=10;        %WAXD interplanar distances upper limit
config.SAXDlim(1)=10;        %SAXD interplanar distances lower limit
config.SAXDlim(2)=70;        %SAXD interplanar distances upper limit
config.label = 'Variable';        %Se si vuole rappresentare i grafici in
%funzione del tempo, mettere 'secondi', se si vuole
%rappresentarli in funzione dell'altra variabile,
%mettere 'Variable'.
% Variable='Phi';
% xlabelVariable='Phi(degrees)';
%Variable='Zeta';
%xlabelVariable='Zeta(mm)';
% Variable='Xposition';
% xlabelVariable='X position(mm)';
config.Variable='Temperature';
config.xlabelVariable='Temperature (°C)';
% Variable='Time';
% xlabelVariable='Time (min)';
config.TM='°C'; %Unità di misura delle temperature misurate
config.ViewColorFigures=[-45 46];
config.ViewGrayFigures=[90 60];
config.createcolorbar=false;    %Colorbar all'interno della figura; true o false
config.titoli = true;          %Titolo all'interno della figura; true o false


%NormalizationFactor=Intensity(1250,:); %Tipicamente, il valore massimo del
%picco più intenso o i valori di IOC2
config.NormalizationFactor=1; %Tipicamente, il valore massimo del picco più intenso o i valori di IOC2
config.ShiftTemporale=0;       %Corregge eventuali ritardi nella scrittura del
%file su phase (obsoleto)

%AUTOMATIZZARE LA SCELTA DELLO STEP

config.XtickStep=0;         %Ampiezza step per tick su asse tempo/temperatura
config.XlabelStep=0;        %Ampiezza step per label dei tick
config.Contour9LevelStep=0; %Step fra i livelli nel contour della bassa
                            %risoluzione (SAXS). Più è piccolo, più
                            %i livelli saranno fitti (e numerosi). 
                            % Automatico=0
config.Contour10LevelStep=0;%Step fra i livelli nel contour dell'alta
                            %risoluzione (WAXS). Più è piccolo, più
                            %i livelli saranno fitti (e numerosi). 
                            % Automatico=0
config.FormatoFileCriostato='%d %*c %d %*c %d %d %*c %d %*c %d  %*s %*s  %f %*s';
% FormatNumerazionePatternFiles='%05s'; %specifica il numero di cifre
config.FormatNumerazionePatternFiles='%02s'; %specifica il numero di cifre
%che compongono la parte numerale dei pattern files
config.FormatoNomeChiFiles1=config.nameroot;
config.FormatoNomeChiFiles2= '.chi';
config.Interpolate=false;
config.DSCmatch=true;
config.DSCpoints=3;    %Se il file .OPE contiene valori di temperatura per
%Onset Peak ed Endset mettere 3, se contiene valori
%di temperatura per Onset ed Endset mettere 2
config.DSCas2dPlots=true;%True: overimposes 2d plots on 3d in correspondence
%of onset peak and enset False: signals OPE changing mesh color
config.font_name='Lucida Console';
config.font_size=10;
switch config.Variable
    case 'Temperature'
        config.mappa='parula';
        config.colorbarlabel='T(°C)';
    otherwise
        config.mappa='pink';
        config.colorbarlabel=xlabelVariable;
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
config.estImmagini='.tif';
config.estPattern='.chi';
config.estFigure='png';
config.nomecryo=[config.nameroot 'cryo' '.txt'] ;
config.nomeOPE=[config.nameroot 'OPE' '.txt'] ;
config.nomeWS=[config.nameroot 'WS' '.mat'] ;
config.nomexcel=[config.nameroot 'cryo' '.xls'];
config.nomeDSC=[config.nameroot 'DSC.xls'];
config.nomeIntensity=[config.nameroot 'Intensity.xls'];