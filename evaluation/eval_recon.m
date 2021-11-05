function stats = eval_recon(subName, accRatio, compThreshold, histBins, maxRange)
%% EVAL_RECON - evaluate accuracy and completeness of a model
% acc is distance d (in m) such that [accRatio]% of the reconstruction is within d of the ground truth mesh
% comp is the percent of points on the GTM that are within [compThreshold] mm of the reconstruction

accPath = sprintf('submissions/%s/%s-acc.ply',subName,subName); % distances to GT
compPath = sprintf('submissions/%s/%s-comp.ply',subName,subName);  % distances from GT

stats.accRatio = accRatio; %0.9; 
stats.compThreshold = compThreshold; %0.1;
% histBins = 10;

%% read distances from CloudCompare pcls
compPcl = ply_read(compPath);
compDist = abs(compPcl.vertex.('scalar_C2M'));

accPcl = ply_read(accPath);
accDist = abs(accPcl.vertex.('scalar_C2C'));

%% compute stats

stats.acc = quantile(accDist,accRatio);
stats.comp = mean(compDist<compThreshold);
stats.histBins = linspace(maxRange/histBins/2, maxRange-maxRange/histBins/2, histBins);
stats.histBins = maxRange*logspace(-2,0,histBins);
histComp = hist(compDist,stats.histBins);
stats.histComp = histComp/sum(histComp);
histAcc = hist(accDist,stats.histBins);
stats.histAcc = histAcc/sum(histAcc);

%% plot
figure('Name',subName);
subplot(2,2,1); 
bar(stats.histBins,cumsum(stats.histComp));  title(sprintf('completeness: %.1f %%',stats.comp*100)); xlabel('m (GT to X)'); ylim([0 1]);
hold on; plot(compThreshold*[1 1],[0 1],'r-');
subplot(2,2,2); 
bar(stats.histBins,cumsum(stats.histAcc));  title(sprintf('accuracy: %.3f m',stats.acc)); xlabel('m (X to GT)'); ylim([0 1]);
 hold on; plot([0 maxRange],accRatio*[1 1],'r-'); 
subplot(2,2,3); imshow(imread(sprintf('submissions/%s/%s-comp.png',subName,subName)));
subplot(2,2,4); imshow(imread(sprintf('submissions/%s/%s-acc.png',subName,subName)));


print(sprintf('submissions/%s-recon.pdf',subName),'-dpdf','-bestfit');
