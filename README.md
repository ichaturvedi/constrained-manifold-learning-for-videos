# CAMEL
Create sub-dataset for each centroid in shortest path

1.	Create video sequences and save in the folder ‘Drive’. Refer to ‘Drivetest’ for format.
2.	Cd rpks folder 
3.	Run TEST_kernel_smile.m
4.	The output centroids are in the folder ‘output’
5.	Cd ..
6.	Specify the centroids in clusterpts.m
7.	This will create a folder for each centroid : Drive1b, Drive2b, Drive3b etc

Train the GAN models
https://github.com/dyelax/Adversarial_Video_Generation
1.	Crop the dataset in folder ‘Drive1b’ into patches of size 32 x 32 :
python process_data.py –num_clips=10000 –train_dir=Drive1b -o
2.	Train the model for first centroid
python avg_runner.py –test_dir=drivetest –O –recursions=10 –model_save_freq=1000 –test_freq=1000
3.	Stop training after 10000 iterations. 
4.	Crop the dataset in folder ‘Drive2b’ into patches of size 32 x 32 :
 python process_data.py –num_clips=10000 –train_dir=Drive1b
5.	Train the model for second centroid and initialize using first model
python avg_runner.py –test_dir=drivetest –O –recursions=10 –model_save_freq=1000 –test_freq=1000 –l ../Save/Models/Default/model.ckpt-10000
6.	Repeat steps 4 and 5 for all centroids
7.	For testing only copy the scripts from folder ‘test’ :
python avg_runner.py –test_dir=drivetest –O –T –recursions=10 –l ../Save/Models/Default/model.ckpt-40000

# camel
Constrained Manifold Learning for Videos
===
This code implements the model discussed in Constrained Manifold Learning for Videos. The model is able to generate a smile action video from a neutral face image. It can also be used to generate the driving path of a car for the next few seconds. We can also use the model to predict the path for a car in the next few seconds on a road in autonomous driving.

Requirements
---
This code is based on the Video Generation code found at:
https://github.com/dyelax/Adversarial_Video_Generation

Preprocessing
---
The training data is in the form of triples : A (original image), B (styled background), C (segmentation mask)

sample_input.jpg

Training
---
Train the model:
python train.py --dataroot ./datasets/dataset_name --name model_instance_name --model sd --direction AtoB --dataset_mode triple
 - The training data will be taken from ./datasets/dataset_name/train
 - "--model sd" is used to set the training model as the one defined in sd_model.py
 - "--dataset_mode triple" is used to the dataloader as the one defined in triple_dataset.py
 - Training results found under ./checkpoint


Testing
---
python test.py --dataroot ./datasets/dataset_name --name model_instance_name --model sd --direction AtoB --num_test 300 --dataset_mode triple
 - The testing data will be taken from ./datasets/dataset_name/test
 - "--num_test" indicates the number of images to use from test set
 - Testing results found under ./results

Test Sample for Car Segmentation
---
Sample 1 For Input Car video :
carvideos/target1.gif

Generated Segmentation for Sample 1:
carvideos/generated1.gif

Sample 2 For Input Car video :
carvideos/target2.gif

Generated Segmentation for Sample 2:
carvideos/generated2.gif

