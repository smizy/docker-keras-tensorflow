# docker-keras-tensorflow
[![](https://images.microbadger.com/badges/image/smizy/keras-tensorflow.svg)](https://microbadger.com/images/smizy/keras-tensorflow "Get your own image badge on microbadger.com") 
[![](https://images.microbadger.com/badges/version/smizy/keras-tensorflow.svg)](https://microbadger.com/images/smizy/keras-tensorflow "Get your own version badge on microbadger.com")
[![CircleCI](https://circleci.com/gh/smizy/docker-keras-tensorflow.svg?style=svg&circle-token=37eedbebf402eb63dcccbf25e7d6e875f87fbb53)](https://circleci.com/gh/smizy/docker-keras-tensorflow)

Python3 Tensorflow backended Keras with Jupyter docker image based on alpine 

* numpy, scipy, pandas, scikit-learn, seaborn, tensorflow, keras installed via pip. See ` pip list --format=columns` for detail.
* CPU only

## Usage
```
docker run -it --rm -v $(pwd):/data -w /data -p 8888:8888 smizy/keras-tensorflow:1.2.1-cpu-alpine
```