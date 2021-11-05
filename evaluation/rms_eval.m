%% evaluate 3DRMS workshop challenge submissions

submissions = {'yt','jm','colmap'};  % each has separate folder
subnames = {'Taguchi','Moras','Colmap'};
accRatio = 0.9;
compThreshold = 0.05; % meters
maxRange = 0.3;
histBins = 20;
%%
stall = cell(length(submissions),1);

for i = 1:length(submissions)
  %%
  subName = submissions{i};
  fprintf('eval: %s ...',subName);
  sfn = sprintf('submissions/%s/%s-results.mat',subName,subName);
  if 0 %exist(sfn,'file')
    fprintf('loaded from %s\n',sfn);
    stats = load(sfn);
  else
    tic;
    stats = eval_recon(submissions{i}, accRatio, compThreshold, histBins, maxRange);
    save(sfn,'-struct','stats');
    toc;
  end
  disp(stats);
  stall{i} = stats;
end

%% summary
allAcc = zeros(length(submissions),histBins);
allComp = zeros(length(submissions),histBins);
for i = 1:length(submissions)
  allAcc(i,:) = cumsum(stall{i}.histAcc);
  legAcc{i} = sprintf('%s (%.3f m)', subnames{i}, stall{i}.acc);
  allComp(i,:) = cumsum(stall{i}.histComp);
  legComp{i} = sprintf('%s (%.1f%%)', subnames{i}, 100*stall{i}.comp);
end  
%% comp
figure('Name','Completeness');
plot(stats.histBins,allComp','LineWidth',2);  title(sprintf('completeness (at %.0fcm)',100*compThreshold)); xlabel('m (GT to X)'); ylim([0 1]);
hold on; plot(compThreshold*[1 1],[0 1],'r-'); legend(legComp,'Location','southeast');
print('recon-comp.pdf','-dpdf','-bestfit');
%% acc
figure('Name','Accuracy');
plot(stats.histBins,allAcc','LineWidth',2);  title(sprintf('accuracy (at %.0f%%)',100*accRatio)); xlabel('m (X to GT)');  ylim([0 1]);
hold on; plot([0 maxRange],accRatio*[1 1],'r-'); legend(legAcc,'Location','southeast'); 
print('recon-acc.pdf','-dpdf','-bestfit');


%% subMesh = pcread(subPath);
% if 0
%   %%
%   [subMesh.Faces, subMesh.Vertices, subMesh.Elements, subMesh.Name] = ply_read(subPath,'tri');
%   subMesh.Faces = subMesh.Faces';
%   subMesh.Vertices = subMesh.Vertices';  
%   save('yt.mat','-struct','subMesh');
% else
%   subMesh = load('yt.mat');
% end
% %% read GT with dist
% gtPath = 'wur10-25sem_test.ply';
% gtPoints = pcread(gtPath);
% 
% %figure; pcshow(subMesh); hold on; pcshow(gtPoints);
% 
% %%
% % ptsQuery = double( gtPoints.Location(1:100,:));
% % tic;
% % % [ distances, surface_points, faces2, vertices2, corresponding_vertices_ID, new_faces_ID ] = ...
% % [ distances, surface_points] = ...
% %     point2trimesh( 'Vertices',subMesh.Vertices, 'Faces', subMesh.Faces, 'QueryPoints',ptsQuery, 'MaxDistance', 0.1, ...
% %     'Algorithm','parallel');
% % toc;
