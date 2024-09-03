# -*- coding: utf-8 -*-
"""
Created on Sun Oct 17 12:05:25 2021

@author: Sandro Widmer
"""
import numpy as np
from fxpmath import Fxp
import matplotlib.pyplot as plt

''' Class '''
class ANNModel:
    def __init__(self, signal_bits=(10, 5), weight_bits=(10, 5), visualize=False, softmax_out=False, raw_out=False):
        self.signal_bits = signal_bits
        self.weight_bits = weight_bits
        self.layers = []
        self.built = False
        self.visualize = visualize
        self.softmax_out = softmax_out
        self.raw_out = raw_out
    
    def build(self):
        prev_units = 1
        for layer in self.layers:
            layer.addArguments(prev_units, self.signal_bits, self.weight_bits, self.visualize)
            prev_units = layer.getUnits()
        self.built = True


    def addLayer(self, layer):
        self.layers.append(layer)
        
    def __looping(self, data):
        y_pred = []
        if len(data.shape) == 1:
            data = data.reshape((1,data.shape[0]))
        
        for idx_data in range(data.shape[0]):
            X = data[idx_data,:]
            softmax = False
            raw = False
            for layer in self.layers:
                y = layer.call(X)
                X = y
                softmax = layer.softmax_out
                raw = layer.raw_out
            try:
                if softmax:
                    y_class = self.softmax(y)
                elif raw:
                    y_class = y
                else:
                    y_class = np.argmax(y)
            except ValueError:
                y_class = 3
            except IndexError:
                print("IndexError")
                y_class = 4
            y_pred.append(y_class)
        return np.array(y_pred)
    
    def predict(self, X_data):
        y_pred = self.__looping(X_data)
        return y_pred
    
    def calculate_Accuracy(y_pred, y):
        (y_pred == y)*1
       
    def getModel(self):
        if self.built:
            return self.layers
        else:
            return "Please build first"
        
    def softmax(self, vector):
         e = np.exp(vector)
         return e / np.sum(e)


''' Class '''
class ANNBasicCell(object):
    nr = 0
    
    def __init__(self, units, name):
        self.units = units
        self.signal_bits = (10, 5)
        self.weight_bits = (10, 5)
        self.weights = np.zeros((1,1))
        self.biases = np.zeros((1,1))
        self.prev_units = 1
        self.visualize = False
        self.softmax_out = False
        self.raw_out = False
        self.reLu_out = False
        ANNBasicCell.nr += 1
        self.name = name
    
    def addArguments(self, prev_units, signal_bits, weight_bits, visualize):
        self.prev_units = prev_units
        self.signal_bits = signal_bits
        self.weight_bits = weight_bits
        self.visualize = visualize
  
    def _initWeights(self):
        self.weights =  Fxp(np.random.normal(loc=0.0, scale=1.0, size=(self.prev_units, self.units)), 
                            signed=True, n_word=self.weight_bits[0], n_frac=self.weight_bits[1], rounding='around')
        self.biases = Fxp(np.random.normal(loc=0.0, scale=1.0, size=(self.units,)), 
                            signed=True, n_word=self.weight_bits[0], n_frac=self.weight_bits[1], rounding='around')

    def call(self, data):
        ...
    
    def __doTimestep(self, data):
        ...
    
    def getName(self):
        return self.name
     
    def setWeights(self, weights, biases):
        print("Weights set for", self.name)
        if weights.shape == (self.prev_units, self.units):
            self.weights = weights
        else:
            print('Attention random weights')
        if biases.shape == (self.units,):
            self.biases = biases
        else:
            print('Attention random biases')
            
    def getUnits(self):
        return self.units


''' Class '''
class ANNInput(ANNBasicCell):
    def __init__(self, units, name='IL'):
        super().__init__(units, name)
        
    def call(self, data):
        y = self.__doTimestep(data)
        return y
    
    def __doTimestep(self, data):
        signal = Fxp(data, signed=True, n_word=self.signal_bits[0], n_frac=self.signal_bits[1], rounding='around')
        return signal


''' Class '''
class ANNCell(ANNBasicCell):
    def __init__(self, units, name='ANNLayer'):
        super().__init__(units, name)
  
    def call(self, data):
        y = self.__doTimestep(data, self.weights, self.biases)
        return y
           
    def __doTimestep(self, signal, weights, biases):        
        output = Fxp(np.zeros(self.units), True, self.signal_bits[0] + self.weight_bits[0], self.signal_bits[1] + self.weight_bits[1], rounding='around')
        for idx in range(self.units):
            product = Fxp(weights[:,idx] * signal, True, self.signal_bits[0] + self.weight_bits[0], self.signal_bits[1] + self.weight_bits[1], rounding='around')
            bias = Fxp(biases[idx], True, self.signal_bits[0] + self.weight_bits[0], self.signal_bits[1] + self.weight_bits[1], rounding='around')
            sum_potential = Fxp(sum(product)+bias, True, self.signal_bits[0] + self.weight_bits[0], self.signal_bits[1] + self.weight_bits[1], rounding='around')
            out = output.get_val().tolist()
            out[idx] = sum_potential
            output = Fxp(out, True, self.signal_bits[0] + self.weight_bits[0], self.signal_bits[1] + self.weight_bits[1], rounding='around')
            
        if self.reLu_out:
            output = Fxp(np.where(output < 0.0, 0.0, output), True, self.signal_bits[0] + self.weight_bits[0], self.signal_bits[1] + self.weight_bits[1], rounding='around')
        
        rounding = Fxp(0, True, self.signal_bits[0] + self.weight_bits[0], self.signal_bits[1] + 1, rounding='trunc')
        output = Fxp(output + rounding.precision, signed=True, n_word=self.signal_bits[0], n_frac=self.signal_bits[1], rounding='trunc')
        return output

''' Functions for quantization '''
def quantize_weights(weights, bits):
    TEMPLATE = Fxp(None, True, bits[0], bits[1]) #FxP: This is the class used to create a fixed-point object. 
                                                 #None: The object is being created without an initial value.
                                                 #True: signed, False: unsigned.
                                                 #bit[0]: Total number of bits.
                                                 #bit[1]: Number of fractional bits.
    TEMPLATE.rounding = 'around' #Rounds to the nearest even number
    weights_q = Fxp(weights, signed=True, n_word=bits[0], n_frac=bits[1], rounding='around').like(TEMPLATE)
    #The .like() method modifies the newly created fixed-point object to have the same configuration as TEMPLATE.
    return weights_q