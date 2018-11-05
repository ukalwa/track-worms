# Software to track nematodes *(H. Glycines)* and analyze behavior at different drug concentrations

This software is written for our [paper] in *Phytopathology*:
*"Movement and Motion of Soybean Cyst Nematode, Heterodera glycines,
Populations and Individuals in Response to Abamectin"*

## Requirments

### Environment Setup

- Download & Install [Matlab R2016a]
- Install Image Processing Toolbox
- Install supported video adaptors for imaging cameras (in our case Q-Imaging)

It was tested on Windows 10 and Mac OS X.

### Usage

- Clone this repo

  ```bash
  git clone https://github.com/ukalwa/track-worms.git
  cd track-worms
  ```

- Open Matlab and navigate to this cloned repo
- To use our video recording software, please run `Matlab/Video/Live_Segmentation.m`
- To segment and generate data of the worm from the video, please run `Matlab/Video/Segmentation/Live_Segmentation.m`
- To analyze the data, please run `Matlab/Analysis/calculate_parameters.m`

## License

This code is GNU GENERAL PUBLIC LICENSED.

## Contributing

If you have any suggestions or identified bugs please feel free to post
them!

  [Matlab]: https://www.mathworks.com/downloads/
  [meanthresh]: https://www.mathworks.com/matlabcentral/fileexchange/41787-meanthresh-local-image-thresholding?focused=3783566&tab=function
  [paper]: https://doi.org/10.1094/PHYTO-10-17-0339-R
