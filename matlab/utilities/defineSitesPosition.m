function defineSitesPosition()

%% DESCRIPTION
% La fonction defineSitesPosition vous permet de d�finir graphiquement
% l'ordre de visite des sites
%% WORKFLOW
% 
%
% # Lancez la fonction
% # Ajoutez la position des sites
% # Sauvegardez la trajectoire
%
% Etape 1 : *Lancez la fonction*
% 
%   defineSitesPosition
%
% Vous devriez avoir la photo suivante (Le chiffre 0 indique la position
% initiale du robot) :
%%
% 
% <<matlabDoc/defineSitesPosition_startScreen.jpg>>
% 
% Etape 2 : *Ajoutez la position des sites*
%
% Cliquez de nouveau avec le bouton droit de la souris pour d�finir la
% position du premier site � explorer :
%%
% 
% <<matlabDoc/defineSitesPosition_firstTargetScreen.jpg>>
% 
% Cliquez de nouveau sur le bouton droit de la souris pour d�finir les
% sites suivants :
%%
% 
% <<matlabDoc/defineSitesPosition_allTargetsScreen.jpg>>
% 
% Etape 3 : *Sauvegardez la trajectoire*
%
% Cliquez sur la croix dans le coin sup�rieur droit de la fen�tre pour
% fermer la fonction. Une boite de dialogue vous demande alors si vous
% voulez sauvegarder la nouvelle trajectoire.
%
% Si vous r�pondez par l'affirmative, la nouvelles trajectoire se
% subtituera � l'ancienne en �crasant le fichier Sites.M. La pr�c�dante
% version du fichier Sites.m est renomm� site.m_ _DATE_ .bak avec _DATE_ la
% date courrante avec le format yyyy *_* mm *_* dd *_* HH *H* MM *M* SS *.*
% FFF *s* (voir la documentation de la fonction *datenum* pour comprendre
% le format) :
%%
% 
% <<matlabDoc/defineSitesPosition_savedScreen.jpg>>
% 

%% LIMITATIONS
% 
% * Vous ne pouvez pas d�finir une position de site si celui ci se trouve
% sur la trajectoire existante
% * Vous ne pouvez pas d�finir une position de site si celui ci se trouve
% sur un num�ro (les num�ros vous indiquent l'ordre des sites)

simApp = SimDisplay.getInstance();
set(simApp.TrackView.Image,'ButtonDownFcn',{@f_setPosition,simApp});
set(simApp.Fig, 'CloseRequestFcn', @CloseRequestFcn);


% get the start position
loadRobotParameters;

line(startPos(1),startPos(2),'Color','b','LineStyle',':',...
    'LineWidth',2,'Parent',simApp.TrackView.Axes);  %#ok<NODEF>
text(startPos(1),startPos(2),num2str(0),'Color',[1 0 0],...
    'BackgroundColor',[.7 .9 .7],'FontWeight','bold',...
    'Parent',simApp.TrackView.Axes);
setappdata(simApp.Fig,'SitesPositions',startPos(:)');

end

function f_setPosition(~,~,simApp)
X = get(simApp.TrackView.Axes,'CurrentPoint');
X = round(X(1,1:2)) ;

SitesPositions = [getappdata(simApp.Fig,'SitesPositions');X];
setappdata(simApp.Fig,'SitesPositions',SitesPositions);
text(X(1),X(2),num2str(size(SitesPositions,1)-1),'Color',[1 0 0],...
    'BackgroundColor',[.7 .9 .7],'FontWeight','bold',...
    'Parent',simApp.TrackView.Axes);
hline = getappdata(simApp.Fig,'hLine');
if isempty(hline)
    hline = line(NaN,NaN,'Color','b','LineStyle','--',...
        'LineWidth',2,'Parent',simApp.TrackView.Axes);
end
set(hline,'XData',SitesPositions(:,1),'YData',SitesPositions(:,2));


end

function fMySave(filename,SitesPositions)
% fMySave Save target in M-file
%

% Get current date
[year,month,day,hour,minute,second] = datevec(now) ;

% Make a copy of the previous target definition file
oldfileName = sprintf('%s_%4d_%02d_%02d_%02dH%02dM%06.3fs.bak',...
    filename ,year,month,day,hour,minute,second );
movefile(filename,oldfileName,'f');

% Open new file for writing
fid = fopen(filename,'wt');
try %#ok<TRYNC>
    
    % Set file header (to write that file is autogenerated and print the
    % date)
    fprintf(fid,'%% File Autogenerate by function %s\n',mfilename);
    fprintf(fid,'%% Date %s\n',datestr(now,'dddd dd mmmm yyyy HH:MM:SS'));
    
    % Write vector SitesPositions with new values
    fprintf(fid,'SitesPositions = single([...\n');
    fprintf(fid,'\t%4.0f,%4.0f;...\n',SitesPositions');
    fprintf(fid,'\t]);');
end

% Close file
fclose(fid);

% Export SitesPositions vector in base workspace
assignin('base','SitesPositions',SitesPositions);

end

function CloseRequestFcn(hObject,~)
% CloseRequestFcn Callback when window is closed

% Get target position (to have the length of the vector = number of targets)
% Get ordered list of targets
SitesPositions=getappdata(hObject,'SitesPositions');
SitesPositions(1,:) = [] ;  

% Ask for confirmation before saving file
answer = questdlg('Do you want to save the order of targets', ...
    'Saving confirmation', 'Yes', 'No', 'Yes');

if strcmp(answer,'Yes')
    
    % Save new position file
    fMySave(which('Sites.m'),SitesPositions);
        
end
    
% Delete figure
delete(hObject)

end