%% evaluate semantics

addpath('render','toolbox');

subName = 'jm';

modelPath = sprintf('submissions/%s/%s-mesh.ply',subName,subName); % distances to GT

dataPath = '../testing/test_around_garden';
gtPath = 'gt/mesh-crop.ply';
evalFrames = 140:10:1480;
evalCams = [0 2];

%% read label def
def = read_labels('../calibration');
labelCount = length(def.labelNames);

if 1
  %% read models
  model = read_model(modelPath);
  figure(101); clf; trimesh(model.tri,model.vtx(:,1),model.vtx(:,2),model.vtx(:,3)); axis equal; title('submitted');
end
gtmodel = read_model(gtPath);
figure(102); clf; trimesh(gtmodel.tri,gtmodel.vtx(:,1),gtmodel.vtx(:,2),gtmodel.vtx(:,3)); axis equal; title('gt');

%% project to images
stats.conf = zeros(labelCount-1,labelCount-1,length(evalCams));
stats.acc = zeros(length(evalCams),length(evalFrames));
for c = 1:length(evalCams)
  %% select camera
  idCam = evalCams(c);
  acc = zeros(length(evalFrames),1);
  conf = zeros(labelCount-1,labelCount-1,length(evalFrames));
  vid = VideoWriter(sprintf('submissions/%s-sem-vid-cam%d.avi',subName,idCam));
  vid.FrameRate = 3;
  vid.Quality = 100;
  open(vid);
  for i = 1:length(evalFrames)
    %% select frame
    idFrame = evalFrames(i);
    basePath = sprintf('%s/uvc_camera_cam_%d/uvc_camera_cam_%d_f%05d',dataPath,idCam,idCam,idFrame);
    txtPath = [basePath '_cam.txt'];
    clsPath = sprintf('submissions/%s/uvc_camera_cam_%d/uvc_camera_cam_%d_f%05d_undist.png',subName,idCam,idCam,idFrame);
    if exist(txtPath,'file')
      %% read from colmap txt
      txtCam = load(txtPath);
      cam.f = txtCam(1:2); % fx fy
      cam.c = txtCam(3:4); % cx cy
      cam.q = txtCam(5:8); % qw qx qy qz
      cam.t = txtCam(9:11); % tx ty tz
      cam.resolution = [752, 480];
      
      cam.R = quat2rotm(cam.q);
      cam.K = eye(3);
      cam.K(1,1) = cam.f(1);
      cam.K(2,2) = cam.f(2);
      cam.K(1,3) = cam.c(1);
      cam.K(2,3) = cam.c(2);
      fprintf('Cam pose loaded from %s\n',txtPath);
      
      %% mesh projection
      camParsMesh{1} = struct('TcV', cam.t, ...
        'RcM', cam.R, ...
        'fcV', [cam.K(1,1); cam.K(2,2)], ...
        'ccV', [cam.K(1,3); cam.K(2,3)], ...
        'imSizeV', [cam.resolution(2); cam.resolution(1)]);
      projZrange = [1e-3; 2000];
      %% gt depths
      [projDmap, cx] = RenderDepthMesh(gtmodel.tri, gtmodel.ptXh(:,1:3), camParsMesh{1}, ...
        [cam.resolution(2); cam.resolution(1)], projZrange, 1, 0);

      if exist(clsPath,'file')
        %% load anot from file
        imgAnot = imread(clsPath);
      else
        projColor = RenderColorMesh(model.tri, model.ptXh(:,1:3), single(model.vtxColor)/255, ...
          camParsMesh{1}, [cam.resolution(2); cam.resolution(1)], projZrange, 1);
        %% tranform color to labels
        projColor = uint8(projColor);
        imgAnot = uint8(rgbmapind(projColor,uint8(def.labelColors*255))) - 1;
      end

      imgAnot(imgAnot(:)==0) = 9;
    else
      stats.acc(c,i) = nan;
      continue;
    end
    %% load gt anot
    gtAnot = imread([basePath '_gtr.png']);
    gtAnot(gtAnot(:)>10) = 9;
    gtAnotTest = gtAnot;
    
    gtValid = (projDmap<1);
    gtValid = imdilate(gtValid,strel('diamond',3));
    gtValid(gtAnot(:)==0) = 0;
    gtAnotTest(gtValid==0) = 0;
    gtDiff = double(gtAnotTest~=imgAnot);
    gtDiff(gtAnotTest==0) = -1;
    
    %% stats
    stats.acc(c,i) = sum(gtDiff(:)==0) / sum(gtDiff(:)>=0);
    conf(:,:,i) = confMatrix(gtAnotTest(gtValid(:)),imgAnot(gtValid(:)),labelCount-1);
    %figure(103);
    %confMatrixShow(conf(:,:,i), def.labelNames(2:end), {'FontSize',12}, 2, 1 ); colormap hot; ylabel('GT');
    
    % plot
    figure(1);
    subplot(2,2,1); imshow(imgAnot,def.labelColors); axis image; title(sprintf('cam %d frame %d: submitted labels',idCam,idFrame));
    subplot(2,2,2); imagesc(projDmap); axis image; title('gt depths');
    subplot(2,2,3); imshow(gtAnotTest,def.labelColors); axis image; title('gt labels (masked)');
    subplot(2,2,4); imshow(gtDiff+2,[0 0 0; 0.5 0.5 0.5; 1 0 0]); axis image; title(sprintf('error mask (accuracy = %.03f)',stats.acc(c,i))); colormap jet;
    drawnow;
    writeVideo(vid,getframe(gcf));
    
    
  end
  close(vid);
  %% camera totals
  camconf = sum(conf,3);
  stats.conf(:,:,c) = sum(camconf,3);
  stats.cacc(c) = sum(diag(camconf))/sum(camconf(:));
end
%% overall totals
stats.tconf = sum(stats.conf,3);
stats.tacc = sum(diag(stats.tconf))/sum(stats.tconf(:));
disp(stats.tacc);
save(sprintf('submissions/%s/stats.mat',subName),'-struct','stats');
%
figure(105);
plot(stats.acc','*'); ylabel 'accuracy'; grid on;
title(sprintf('%s: total pixelwise accuracy = %.3f',subName,stats.tacc));
print(sprintf('submissions/%s-acc.pdf',subName),'-dpdf','-bestfit');
%
figure(106);
confMatrixShow(stats.tconf, def.labelNames(2:end), {'FontSize',12}, 2, 1 );
colormap hot; ylabel('GT');
title(sprintf('%s: total pixelwise accuracy = %.3f',subName,stats.tacc));
print(sprintf('submissions/%s-confmat.pdf',subName),'-dpdf','-bestfit');
