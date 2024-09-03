import pandas as pd
import numpy as np
import matplotlib
from matplotlib import cm
import matplotlib.pyplot as plt
import seaborn as sns
from fxpmath import Fxp
import tensorflow as tf
from tensorflow.keras.layers import LeakyReLU, Dense, Dropout
from sklearn.metrics import classification_report, confusion_matrix, ConfusionMatrixDisplay

from ANNModel import ANNModel, ANNCell, ANNInput, quantize_weights

#%% Load the iris data and load the weights from the ANN file

matplotlib.rc_file_defaults()
# Download Iris dataset:
zip_file = tf.keras.utils.get_file('iris.csv','https://archive.ics.uci.edu/ml/machine-learning-databases/iris/iris.data')
data = pd.read_csv(zip_file,names=['Sepal length (cm)','Sepal width (cm)','Petal length (cm)','Petal width (cm)','Class'])
data = data.sample(frac=1, random_state=0).reset_index(drop=True)

data_labels = np.array(data.pop('Class'))
data_values = np.array(data)

# TensorFlow requires lables in form of integers rather than text, so we create a mapping:
mapping = np.sort(np.unique(data_labels)) #find unique labels
data_y = np.searchsorted(mapping, data_labels)

#use old weights for the model
weights_HL = np.loadtxt('Weights_Biases/ANN_weights_hiddenLayer.csv', delimiter=',')

weights_OL = np.loadtxt('Weights_Biases/ANN_weights_outputLayer.csv', delimiter=',')

biases_HL = np.loadtxt('Weights_Biases/ANN_biases_hiddenLayer.csv', delimiter=',')

biases_OL = np.loadtxt('Weights_Biases/ANN_biases_outputLayer.csv', delimiter=',')


data_resBits = [(3,1), (4,1), (5,1), (6,2), (7,2), (8,3), (9,3), (10,4), (11,4), (12,5), 
                (13,5), (15,6), (16,6), (20,7), (28,13), (32,16)]
weights_resBits = [(3,1), (4,2), (5,3), (6,4), (7,5), (8,6), (9,7), (10,8), (11,9), (12,10), 
                   (13,11), (15,13), (16,14), (20,18), (28,26), (32,30)]

accuracy = np.zeros((len(data_resBits),len(weights_resBits)))

#%% precision table !! Attention this code part runs longer than an hour !!

idx_d = 0
len_loop = len(data_resBits)*len(weights_resBits)
idx_l = 1
print("Start precision development loop (length ", len_loop, ")")
for d_bits in data_resBits:
    idx_w = 0
    for w_bits in weights_resBits:
        weights_HL_q = quantize_weights(weights_HL, w_bits)
        weights_OL_q = quantize_weights(weights_OL, w_bits)
        biases_HL_q = quantize_weights(biases_HL, w_bits)
        biases_OL_q = quantize_weights(biases_OL, w_bits)
        
        model = ANNModel(signal_bits=d_bits, weight_bits=w_bits)
        model.addLayer(ANNInput(units=4))
        model.addLayer(ANNCell(units=10, name='HL'))
        model.addLayer(ANNCell(units=3, name='OL'))
        model.build()


        layer_list = model.getModel()
        for layer in layer_list:
            if layer.getName() == 'IL':
                layer.raw_out = False
            elif layer.getName() == 'HL':
                layer.setWeights(weights_HL_q, biases_HL_q)
                layer.raw_out = True
                layer.reLu_out = True
            elif layer.getName() == 'OL':
                layer.setWeights(weights_OL_q, biases_OL_q)
                layer.softmax_out = False
                layer.raw_out = False
        
        input_data = data_values[:,:]
        y_pred = model.predict(input_data)
        train_acc = np.sum((np.equal(y_pred,data_y)*1))/y_pred.shape[0]
        
        accuracy[idx_d, idx_w] = train_acc
        
        print("Standing: ", idx_l, "/", len_loop)
        idx_l += 1
        idx_w += 1
    idx_d += 1

np.savetxt('ANN_resolutionTable.csv', accuracy, delimiter=',')

#%% resolution of quantization
matplotlib.rc_file_defaults()
accuracy = np.loadtxt('ANN_resolutionTable.csv', delimiter=',')

fig = plt.figure()
fig.set_size_inches(20, 11.25)
ax = fig.add_subplot(111, projection='3d')

xx, yy = np.meshgrid([x[0] for x in data_resBits], [x[0] for x in weights_resBits])
Z = np.transpose(accuracy)
ax.plot_surface(xx, yy, Z, cmap=cm.coolwarm)

ax.set_xlabel('communication signal bit resolution')
ax.set_ylabel('weight bit resolution')
ax.set_zlabel('accuracy')
plt.gca().invert_yaxis()
plt.show()

#%%
sns.set_theme()
df3 = pd.DataFrame(accuracy, columns=weights_resBits, index=data_resBits)

fig = plt.figure()
fig.set_size_inches(20, 11.25)

ax = sns.heatmap(df3, annot=True, vmin=0.3, vmax=1, linewidths=.5)
ax.invert_yaxis()
ax.set_xlabel('weight bit resolution')
ax.set_ylabel('communication signal bit resolution')

plt.show()