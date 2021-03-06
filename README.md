Manifold learning for Smile Generation
===
This code implements the model discussed in the paper _Constrained Manifold Learning for Videos_. The model is able to generate a smile action video from a neutral face image. 

Requirements
---
This code is based on the Video Generation code found at:
https://github.com/dyelax/Adversarial_Video_Generation

Principal-path through the Manifold
---
We cluster the the sequence of images in all the videos using principal path manifold clustering. 
matlab -r TEST_kernel_smile
  - The centroids are in the folder 'output'

matlab -r clusterpts
  - This will sub-sample smile sequences and images closest to the centroids.

Preprocessing
---
The training data is in the form of a sequence of images in a single video. We first divide each image into patches before training.
python process_data.py --num_clips=10000 --train_dir=smile1 -o
  - The training data will be taken from ./smile1
  - "-o" is used to erase all previous clips
  - "--num_clips" is used to divide each image into patches of 32 x 32
  
![image](https://user-images.githubusercontent.com/29162185/80721007-0d454500-8b41-11ea-8dba-05c70fc474a4.png)

Training
---
Train the model:
python avg_runner.py –-test_dir=smiletest –O –-recursions=10 –-model_save_freq=1000 –-test_freq=1000

 - The training data will be taken from ./smiletest
 - "--recursions" is used to predict next 10 frames in the video
 - "--model_save_freq" will save the model after every 1000 epochs of training.
 - Trained models can be found in '../Save/Models'
 - The model for each centroid is used as starting point for next model training

Testing
---
python avg_runner.py –-test_dir=smiletest –O –T –-recursions=10 –l ../Save/Models/Default/model.ckpt-40000
 - The testing data will be taken from ./smiletest
 - "-l" indicates the path to trained model
 - Testing results found under ../Save/Images/Test

Test Sample for Video Generation
---
Smile Generation from neutral face ( the smile keeps getting bigger):
![image](https://user-images.githubusercontent.com/29162185/80721317-6a40fb00-8b41-11ea-8187-8a36370a64ca.png)

