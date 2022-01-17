# 3D Reconstruction meets Semantics 

Part of the ICCV 2017 workshop [3D Reconstruction meets Semantics](http://trimbot2020.webhosting.rug.nl/events/3drms/) was a challenge on combining 3D and semantic information in complex scenes. 
To this end, a challenging outdoor dataset, captured by a robot driving through a semantically-rich garden that contains fine geometric details, is released. 
A multi-camera rig is mounted on top of the robot, enabling the use of both stereo and motion stereo information. 
Precise ground truth for the 3D structure of the garden has been obtained with a laser scanner and accurate pose estimates for the robot are available as well. 
Ground truth semantic labels and ground truth depth from a laser scan will be used for benchmarking the quality of the 3D reconstructions.

## Reconstruction Challenge
Given a set of images and their known camera poses, the goal of the challenge is to create a semantically annotated 3D model of the scene. 
To this end, it will be necessary to compute depth maps for the images and then fuse them together (potentially while incorporating information from the semantics) into a single 3D model.

We provide the following data for the challenge:
* A set of training sequences consisting of
  * calibrated images with their camera poses,
  * ground truth semantic annotations for a subset of these images,
  * a semantically annotated 3D point cloud depicting the area of the training sequence.
* A testing sequence consisting of calibrated images with their camera poses.

Please notice that only a subset of all cameras (cameras 0 and 2) provide colour images while the other cameras capture the scene only in greyscale. 
Labels are only provided for the colour cameras, while the greyscale cameras are intended to be used for obtained better depth maps (cameras 0 and 1 and cameras 2 and 3 form a stereo pair).

## Data

Challenge dataset archives are hosted are hosted [here](https://homepages.inf.ed.ac.uk/rbf/TrimBot2020git/public/).
Please use [`download.sh`](https://github.com/TrimBot2020/3DRMS_Challenge2017/blob/master/download.sh) script to retrieve training and test data (or see the script for manual download steps).

* File [`labels.yaml`](https://github.com/TrimBot2020/3DRMS_Challenge2017/blob/master/calibration/labels.yaml) - semantic label definition list
* File [`colors.yaml`](https://github.com/TrimBot2020/3DRMS_Challenge2017/blob/master/calibration/colors.yaml) - label color definition (for display)
* File [`calibration/camchain-DDDD.yaml`](https://github.com/TrimBot2020/3DRMS_Challenge2017/blob/master/calibration/camchain-2017-05-16-09-53-50.yaml) - camera rig calibration


### Training

| Sequence | cameras | range | frames | annotated frames |
| -------- | ------- | ----- | ------ | ---------   |
| train_around_hedge  | cam_0, cam_1*, cam_2, cam_3*   | 100:10:260 | 68  | 34 |
| train_boxwood_row  | cam_0, cam_1*, cam_2, cam_3*   | 90:10:650 | 228  | 114 |
| train_boxwood_slope  | cam_0, cam_1*, cam_2, cam_3*   | 120:10:340 | 92 | 46 |
| train_around_garden_roses  | cam_0, cam_1*, cam_2, cam_3*   | 590:10:690 | 44 | 22 | 

* File `model_SSSS.ply` - point cloud with semantic labels (field `scalar_s` or color) for sequence `SSS`
  * Subfolders `uvc_camera_cam_X`
    * Files `uvc_camera_cam_X_fXXXXX_gtr.png` - GT annotation with label set IDs (indexed bitmap)
    * Files `uvc_camera_cam_X_fXXXXX_undist.png` - undistorted color image (RGB)
    * Files `uvc_camera_cam_X_fXXXXX_over.png` - overlay of annotation over greyscale image (for display)
    * Files `uvc_camera_cam_X_fXXXXX_cam.txt` - camera parameters (f,c,q,t)

* *For `cam_1` and `cam_3` there is no annotation provided, ie. _gtr and _over are missing, and _undist is greyscale only

#### Camera parameters
The pose format is `fx fy cx cy qw qx qy qz tx ty tz`, where `f` is focal length in pixels `c` centre point in pixels, `q` is the quaternion denoting the camera orientation and `t` is the camera translation. 
The transformation from world to camera coordinates is given as `[R(q)|t]`, where `R(q)` is the rotation matrix corresponding to quaternion `q`.

### Testing

| Sequence | cameras | range | frames |
| -------- | ------- | ------ | ------- | 
| test_around_garden  | cam_0, cam_1, cam_2, cam_3   | 140:10:580, 700:10:1480 | 257 | 

  * Subfolders `uvc_camera_cam_X`
    * Files `uvc_camera_cam_X_fXXXXX_undist.png` - undistorted color image (RGB)
    * Files `uvc_camera_cam_X_fXXXXX_cam.txt` - camera parameters (f,c,q,t)

## Evaluation

We evaluate the following measures:
* Reconstruction accuracy in % for a set of distance thresholds (similar to [1,2])
* Reconstruction completeness in % for a set of distance thresholds (similar to [1,2])
* Semantic quality in % of the triangles that are correctly labeled.

We use distance thresholds from 1 to 30 cm. 

The evaluation code and GT can be found [here](evaluation).
The methodology and performance is given in a [report](https://github.com/TrimBot2020/3DRMS_Challenge2017/blob/master/evaluation/report/rms_challenge.pdf).

#### References

* [1] Seitz et al., A Comparison and Evaluation of Multi-View Stereo Reconstruction Algorithms, CVPR 2006
* [2] Schöps et al., A Multi-View Stereo Benchmark with High-Resolution Images and Multi-Camera Videos, CVPR 2017

## Submission

In order to submit to the challenge, please create a semantically annotated 3D triangle mesh from the test sequence. 
* The mesh should be stored in the [PLY text format](http://paulbourke.net/dataformats/ply/). 
* The file should store for each triangle a color corresponding to the triangle’s semantic class (see the [`calibrations/colors.yaml`](https://github.com/TrimBot2020/3DRMS_Challenge2017/blob/master/calibration/colors.yaml) file for the mapping between semantic classes and colors). 
  * Semantic labels 'Unknown' and 'Background' are only for 2D images, and should not be present in the submitted 3D mesh, ie. only values 1-8 are valid.

Once you have created the mesh, please submit it using [this link](https://www.dropbox.com/request/23XzljBTn93zYl3ETjXn). 
In addition, please send an email to `torsten.sattler@cvut.cz` that includes the filename of the file you submitted as well as contact information.

## Questions

For questions, please contact `torsten.sattler@cvut.cz`.

## Credits

Dataset composed by T.Sattler and R.Tylecek.

Data recorded and processed by D.Honegger and M.Blaich.

### Annotators:
* Christos Maniatis
* Alex Chan
* Nanbo Li
* Stefanie Speichert
* Xinda Xu
* Omar Abarca Arriaga

Please report any errors via [issue tracker](https://github.com/TrimBot2020/3DRMS_Challenge2017/issues/new) or via email to torsten.sattler@cvut.cz.

### Acknowledgements

Production of this dataset was supported by EU project TrimBot2020.

Please cite the following [report](https://github.com/TrimBot2020/3DRMS_Challenge2017/blob/master/evaluation/report/rms_challenge.pdf) when using the dataset: 


    @techreport{sattler2017rms,
      author={Torsten Sattler and Thomas Brox and Marc Pollefeys and Robert B. Fisher and Radim Tylecek},
      title={3D Reconstruction meets Semantics – Reconstruction Challenge},
      institution={ICCV Workshops}, 
      month={October},
      year={2017},
      URL={http://trimbot2020.webhosting.rug.nl/events/3drms/challenge/}
    }
