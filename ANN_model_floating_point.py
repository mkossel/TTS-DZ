import keras
import time
import tensorflow as tf
from tensorflow.keras.layers import LeakyReLU, Dense, Dropout, BatchNormalization, LayerNormalization
from tensorflow.keras.utils import to_categorical
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
from sklearn.metrics import classification_report, confusion_matrix, ConfusionMatrixDisplay
from sklearn.utils import shuffle

# Ensure reproducible results across runs
np.random.seed(2)

# Download Iris dataset:
zip_file = tf.keras.utils.get_file('iris.csv','https://archive.ics.uci.edu/ml/machine-learning-databases/iris/iris.data')
data = pd.read_csv(zip_file,names=['Sepal length (cm)','Sepal width (cm)','Petal length (cm)','Petal width (cm)','Class'])
data = data.sample(frac=1, random_state=0).reset_index(drop=True) #reshuffling of rows and reset of row index

data_labels = np.array(data.pop('Class')) # extraction of the column labeled 'Class'
data_values = np.array(data) #conversion of DataFrame to into NumPy array

# TensorFlow requires lables in form of integers rather than text, so we create a mapping:
mapping = np.sort(np.unique(data_labels)) #find unique labels
data_y = np.searchsorted(mapping, data_labels) #replace labels by numbers


data_labels, data_values, data_y = shuffle(data_labels, data_values, data_y, random_state=2) #ensures reproducibilty of shuffling

# We assume the following hyperparameters:
# epochs = 300
# validation_split=0.2 in fit() functions that excludes the last 20% of examples before 
# shuffling (deterministic between calls) and uses them for reporting the validation accuracy
epochs = 400
v_s = 0.2

#%% Floating point values - ANN model 
ann_model = tf.keras.Sequential() #creates a feed-forward neural network
ann_model.add(tf.keras.layers.InputLayer(input_shape=[4])) #this defines the shape of the input data, i.e. petal/sepal width/length 
#ann_model.add(Dense(10, activation='relu')) #, use_bias=False, fully connected hidden layer of 10 neurons
ann_model.add(Dense(4, activation='relu')) #, use_bias=False, fully connected hidden layer of 5 neurons
ann_model.add(Dense(3, activation='relu')) #, use_bias=False, fully connected hidden layer of 3 neurons
ann_model.add(Dense(3, activation='softmax')) #output layer consisting of 3 neurons

# The standard way of training would be as follows:   
#ann_model.compile(optimizer='adam', loss='sparse_categorical_crossentropy', metrics=['accuracy'])
#ann_model.fit(data_values, data_y, validation_split=v_s, epochs=epochs, batch_size=10)
#
# However, the epochs are very short, so there would be way too much output.
# Below is a 'hack' that reports only each 20th epoch during the training:
    
time_start = time.time()
ann_model.compile(optimizer='adam', loss='sparse_categorical_crossentropy', metrics=['accuracy'])
history_ann = ann_model.fit(data_values, data_y, validation_split=v_s, epochs=epochs, batch_size=10, verbose=0)
print('Finished. Total time: {0:.1f} [s]'.format(time.time() - time_start))

# => output weights and biases (manually create the directory Weights_Biases if running for the first time)
ann_weights = ann_model.get_weights()
np.savetxt("Weights_Biases/ANN_weights_hiddenLayer.csv", ann_weights[0], delimiter=",")
np.savetxt("Weights_Biases/ANN_biases_hiddenLayer.csv", ann_weights[1], delimiter=",")
np.savetxt("Weights_Biases/ANN_weights_outputLayer.csv", ann_weights[2], delimiter=",")
np.savetxt("Weights_Biases/ANN_biases_outputLayer.csv", ann_weights[3], delimiter=",")
# weights_hiddenLayer = np.loadtxt("weights_hiddenLayer.csv", delimiter=",") #to reload the weights from the saved file

# summarize history for accuracy
plt.plot(history_ann.history['accuracy'])
plt.plot(history_ann.history['val_accuracy'])
plt.legend(['Training', 'Validation'],loc=4)
plt.xlabel("Epoch")
plt.ylabel("Accuracy [%]")
plt.ylim([0.0,1.0])
plt.xlim([0,400])
plt.grid()
plt.show()
# summarize history for loss
plt.plot(history_ann.history['loss'])
plt.plot(history_ann.history['val_loss'])
plt.legend(['Training', 'Validation'])
plt.xlabel("Epoch")
plt.ylabel("Loss")
plt.xlim([0,400])
plt.gca().set_ylim(bottom=0)
plt.grid()
plt.show()

data_predicted = np.argmax(ann_model.predict(data_values), axis=-1) #vector of predicted labels
ann_acc = np.sum((np.equal(data_predicted,data_y)*1))/data_y.shape[0] #convert boolean to integers, sum them up, divide by 150
print("Accuracy: ", ann_acc)

cm = confusion_matrix(data_y, data_predicted, labels=[0, 1, 2])
disp = ConfusionMatrixDisplay(confusion_matrix=cm, display_labels=[0, 1, 2])
disp.plot()
plt.show()


