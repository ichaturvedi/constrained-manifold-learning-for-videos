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
