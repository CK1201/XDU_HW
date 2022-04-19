# DnCNN-TensorFlow
Simple implementation of the paper (DnCNN)'Beyond a Gaussian Denoiser: Residual Learning of Deep CNN for Image Denoising'
## Introduction
This code just simplely implement the paper [Beyond a Gaussian Denoiser: Residual Learning of Deep CNN for Image Denoising](http://cn.arxiv.org/pdf/1608.03981), but there are some details of the code are different from the paper.
![](https://github.com/MingtaoGuo/DnCNN-TensorFlow/blob/master/IMAGES/method.jpg)
## DataSets
The datasets include 400 gray images, but i have croped them into 40x40 patches. the croped datasets can be downloaded from my [BaiduYun](https://pan.baidu.com/s/1Uiq29K2WLvOyeGlnRu8j_A) 

Examples of TrainingSet

|||||||||
|-|-|-|-|-|-|-|-|
|![](https://github.com/MingtaoGuo/DnCNN-TensorFlow/blob/master/TrainingSet/1_17.jpg)|![](https://github.com/MingtaoGuo/DnCNN-TensorFlow/blob/master/TrainingSet/1_18.jpg)|![](https://github.com/MingtaoGuo/DnCNN-TensorFlow/blob/master/TrainingSet/1_19.jpg)|![](https://github.com/MingtaoGuo/DnCNN-TensorFlow/blob/master/TrainingSet/1_20.jpg)|![](https://github.com/MingtaoGuo/DnCNN-TensorFlow/blob/master/TrainingSet/1_25.jpg)|![](https://github.com/MingtaoGuo/DnCNN-TensorFlow/blob/master/TrainingSet/1_26.jpg)|![](https://github.com/MingtaoGuo/DnCNN-TensorFlow/blob/master/TrainingSet/1_27.jpg)|![](https://github.com/MingtaoGuo/DnCNN-TensorFlow/blob/master/TrainingSet/1_28.jpg)|
## Python packages
====================
1. python3.5
2. tensorflow1.4.0
3. pillow
4. numpy
5. scipy

====================
## Results of the code
Trained about 1 epoch

|Raw|Noised|Denoised|
|-|-|-|
|![](https://github.com/MingtaoGuo/DnCNN-TensorFlow/blob/master/TestingSet/01.png)|![](https://github.com/MingtaoGuo/DnCNN-TensorFlow/blob/master/IMAGES/noised1.jpg)|![](https://github.com/MingtaoGuo/DnCNN-TensorFlow/blob/master/IMAGES/denoised1.jpg)|
|![](https://github.com/MingtaoGuo/DnCNN-TensorFlow/blob/master/TestingSet/02.png)|![](https://github.com/MingtaoGuo/DnCNN-TensorFlow/blob/master/IMAGES/noised2.jpg)|![](https://github.com/MingtaoGuo/DnCNN-TensorFlow/blob/master/IMAGES/denoised2.jpg)|
|![](https://github.com/MingtaoGuo/DnCNN-TensorFlow/blob/master/TestingSet/03.png)|![](https://github.com/MingtaoGuo/DnCNN-TensorFlow/blob/master/IMAGES/noised3.jpg)|![](https://github.com/MingtaoGuo/DnCNN-TensorFlow/blob/master/IMAGES/denoised3.jpg)|
|![](https://github.com/MingtaoGuo/DnCNN-TensorFlow/blob/master/TestingSet/04.png)|![](https://github.com/MingtaoGuo/DnCNN-TensorFlow/blob/master/IMAGES/noised4.jpg)|![](https://github.com/MingtaoGuo/DnCNN-TensorFlow/blob/master/IMAGES/denoised4.jpg)|
|![](https://github.com/MingtaoGuo/DnCNN-TensorFlow/blob/master/TestingSet/05.png)|![](https://github.com/MingtaoGuo/DnCNN-TensorFlow/blob/master/IMAGES/noised5.jpg)|![](https://github.com/MingtaoGuo/DnCNN-TensorFlow/blob/master/IMAGES/denoised5.jpg)|
|![](https://github.com/MingtaoGuo/DnCNN-TensorFlow/blob/master/TestingSet/06.png)|![](https://github.com/MingtaoGuo/DnCNN-TensorFlow/blob/master/IMAGES/noised6.jpg)|![](https://github.com/MingtaoGuo/DnCNN-TensorFlow/blob/master/IMAGES/denoised6.jpg)|
|![](https://github.com/MingtaoGuo/DnCNN-TensorFlow/blob/master/TestingSet/07.png)|![](https://github.com/MingtaoGuo/DnCNN-TensorFlow/blob/master/IMAGES/noised7.jpg)|![](https://github.com/MingtaoGuo/DnCNN-TensorFlow/blob/master/IMAGES/denoised7.jpg)|
