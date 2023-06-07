## This file is part of https://github.com/SensorsINI/dnd_hls. 
## This intellectual property is licensed under the terms of the project license available at the root of the project.

# this script trains an =MLPF with dataset test data

# run this script from the MLPTrainScripts folder
# python qtrain.py 0 4
# ```
#  * first parameter 0/1, 0 means quantized training, 1 means float training.
#  * second parameter, 4 means quantized bits for inputs and activations before the last layer. the last layer have 16 bits. Ignored for training floating point network

# see README.md for more information

from __future__ import print_function
from asyncio import current_task
from base64 import encode
from cmath import polar
import encodings
import time
from operator import mod

import numpy as np
# from numpy.core.numeric import load
# np.random.seed(1337)
import os

from tensorflow.keras import optimizers
from tqdm import tqdm


os.environ["CUDA_DEVICE_ORDER"] = "PCI_BUS_ID"
os.environ["CUDA_VISIBLE_DEVICES"] = ""

import tensorflow
from tensorflow import keras
from tensorflow.keras import callbacks, models
from tensorflow.keras.preprocessing import sequence
from tensorflow.keras.models import Model, Sequential, load_model
from tensorflow.keras.layers import Input, Dense,Embedding,Dropout
from tensorflow.keras.layers import LSTM
from tensorflow.keras.datasets import imdb
from tensorflow.keras.callbacks import Callback
from tensorflow.keras.optimizers import Adam, SGD
import matplotlib.pyplot as plt
from sklearn.metrics import confusion_matrix, f1_score, precision_score, recall_score,accuracy_score, confusion_matrix
import tensorflow as tf
from tensorflow.keras.utils import to_categorical

from sklearn.model_selection import train_test_split
from tensorflow.keras.callbacks import TensorBoard
from tensorflow.keras.callbacks import ModelCheckpoint

import matplotlib.pyplot as plt
import numpy as np
import os,sys,glob
import pandas as pd

# from sklearn.model_selection import train_test_split
# from custom_dataloader.dataloader import DataGenerator

from convertH5toPB import freeze_session # to save pb model

from qkeras import *
from qkeras.utils import model_save_quantized_weights, load_qmodel

import matplotlib
matplotlib.rcParams.update({'font.size': 14})
# Say, "the default sans-serif font is COMIC SANS"
matplotlib.rcParams['font.sans-serif'] = "Arial"
# Then, "ALWAYS use sans-serif fonts"
matplotlib.rcParams['font.family'] = "sans-serif"
matplotlib.rcParams['pdf.fonttype'] = 42
matplotlib.rcParams['ps.fonttype'] = 42

import scipy.io as sio
MODEL_DIR = 'models' # where models and plots are saved
DATASET_DIR='training_data'
# dataset location
# trainfilepath = '../2xTrainingDataDND21train'
# testfilepath = '../2xTrainingDataDND21test'
trainfilepath = os.path.join(DATASET_DIR,'particles_train')
testfilepath = os.path.join(DATASET_DIR,'particles_test')

# MLP params
# hidden = int(sys.argv[1])
# resize = int(sys.argv[2])
# epochs = int(sys.argv[3])
# csvfilepath = sys.argv[4]

hidden = 20
resize = 7 # size of input patches to MLP resize*resize
# tau = 100000 # 300ms if use exp decay for preprocessing
tau = 1000 #64#128


# training params
snr=1./100 # ratio of signal events to noise events in dataset. Set to 1 for original balanced DND21 paper; set to other values for e.g. high noise rate and low signal rate; see model.compile below
epochs = 5
learning_rate = 0.0005
batch_size = 1000 # training batch size
patchsize = 25 # size of actual recorded patches from jAER NoiseTesterFilter
csvinputlen = patchsize * patchsize
middle = int(csvinputlen / 2)

print(f'training MLP nodel with \n'
      f'{hidden} hidden units\n'
      f'{resize}x{resize} input patch\n'
      f'using batch size {batch_size}, learning rate {learning_rate}, {epochs} epochs, and class ratio SNR {snr:.3f}')

start_time=time.time()

# networkinputlen = resize * resize


global prefix

def plot_confusion_matrix(cm, savename, title='Confusion Matrix'):

    plt.figure(figsize=(12, 8), dpi=100)
    np.set_printoptions(precision=2)

    classes = ['Not Fall', 'Fall']
    ind_array = np.arange(len(classes))
    x, y = np.meshgrid(ind_array, ind_array)
    for x_val, y_val in zip(x.flatten(), y.flatten()):
        c = cm[y_val][x_val]
        if c > 0.001:
            plt.text(x_val, y_val, "%0.2f" % (c,), color='red', fontsize=15, va='center', ha='center')
    
    plt.imshow(cm, interpolation='nearest', cmap=plt.cm.binary)
    plt.title(title)
    plt.colorbar()
    xlocations = np.array(range(len(classes)))
    plt.xticks(xlocations, classes, rotation=90)
    plt.yticks(xlocations, classes)
    plt.ylabel('Actual label')
    plt.xlabel('Predict label')
    
    # offset the tick
    tick_marks = np.array(range(len(classes))) + 0.5
    plt.gca().set_xticks(tick_marks, minor=True)
    plt.gca().set_yticks(tick_marks, minor=True)
    plt.gca().xaxis.set_ticks_position('none')
    plt.gca().yaxis.set_ticks_position('none')
    plt.grid(True, which='minor', linestyle='-')
    plt.gcf().subplots_adjust(bottom=0.15)
    
    # show confusion matrix
    plt.savefig(os.path.join(MODEL_DIR,savename), format='png')
    plt.show()

#LossHistory, keep loss and acc
class LossHistory(Callback):
    def on_train_begin(self, logs={}):
        self.losses = {'batch':[], 'epoch':[]}
        self.accuracy = {'batch':[], 'epoch':[]}
        self.val_loss = {'batch':[], 'epoch':[]}
        self.val_acc = {'batch':[], 'epoch':[]}
 
    def on_batch_end(self, batch, logs={}):
        self.losses['batch'].append(logs.get('loss'))
        self.accuracy['batch'].append(logs.get('accuracy'))
        self.val_loss['batch'].append(logs.get('val_loss'))
        self.val_acc['batch'].append(logs.get('val_accuracy'))
 
    def on_epoch_end(self, batch, logs={}):
        self.losses['epoch'].append(logs.get('loss'))
        self.accuracy['epoch'].append(logs.get('accuracy'))
        self.val_loss['epoch'].append(logs.get('val_loss'))
        self.val_acc['epoch'].append(logs.get('val_accuracy'))
 
    def loss_plot(self, prefix, loss_type, e0loss, e0acc, e0valloss, e0valacc):

        iters = range(len(self.losses[loss_type])+1)
        np.save(os.path.join(MODEL_DIR,prefix + 'loss.npy'), np.array([e0loss] + self.losses[loss_type]))
        np.save(os.path.join(MODEL_DIR,prefix + 'acc.npy'), np.array([e0acc] + self.accuracy[loss_type]))

        plt.figure()
        # acc
        plt.plot(iters, [e0acc] + self.accuracy[loss_type], 'r', label='train acc')
        # loss
        plt.plot(iters, [e0loss] + self.losses[loss_type], 'g', label='train loss')
        if loss_type == 'epoch':
            # val_acc
            plt.plot(iters, [e0valacc] + self.val_acc[loss_type], 'b', label='val acc')
            # val_loss
            plt.plot(iters, [e0valloss] + self.val_loss[loss_type], 'k', label='val loss')
        plt.grid(True)
        plt.xlabel(loss_type)
        plt.ylabel('acc-loss')
        plt.legend(loc="upper right")
        
        plt.savefig(os.path.join(MODEL_DIR,prefix+'training.pdf'))

import math

def lbppreprocessingresize(allfeatures, resize, targetEventTS, targetEventP): # auc 0.85/0.80
    # print(features.shape)
    # print(features)
    # print(allfeatures.shape, targetEventTS.shape, targetEventP.shape)
    absTS = allfeatures[:,:csvinputlen]
    polarity = allfeatures[:,csvinputlen:]
    
    features = absTS#.transpose()

    mid = math.floor(len(features) / 2)
    featuresNormed = np.array([(features[i,:] >= np.median(features[i,mid])) for i in range(len(features))])
    # print(featuresdiff)
    featuresNormed = featuresNormed.astype(np.int)

    
    # crop
    features = featuresNormed.reshape(featuresNormed.shape[0], patchsize, patchsize)
    margin = int((patchsize - resize) / 2)
    cropend = patchsize - margin
    features = features[:,margin:cropend, margin:cropend]
    features = features.reshape(features.shape[0],resize * resize)

    polarity = polarity.reshape(polarity.shape[0],patchsize, patchsize)
    margin = int((patchsize - resize) / 2)
    cropend = patchsize - margin
    channelP = polarity[:,margin:cropend, margin:cropend]
    channelP = channelP.reshape(channelP.shape[0], resize * resize)
    channelP[features==0] = 0 # set the polarity to be 0 if the event is too old, which means the ts features are 0
    channelP[:,int(resize*resize/2)] = targetEventP # ensure the center location has the classified event's polarity
    

    features2 = np.hstack((features,channelP))
    # print(features2.shape)
    return features2


def binpreprocessingresize(allfeatures, resize, targetEventTS, targetEventP):
    # print(features.shape)
    # print(features)
    # print(allfeatures.shape, targetEventTS.shape, targetEventP.shape)
    absTS = allfeatures[:,:csvinputlen]
    polarity = allfeatures[:,csvinputlen:]
    


    features = absTS#.transpose()
    featuresdiff = [features[i,:] - targetEventTS[i] for i in range(len(features))]
    # print(featuresdiff)



    
    featuresdiff = np.array(featuresdiff, dtype=int)
    featuresdiff = featuresdiff/1000
    featuresdiff = featuresdiff.astype(int)

    featuresNormed = np.abs(featuresdiff) < tau
    featuresNormed = featuresNormed.astype(int)

    # featuresNormed = (tau - np.abs(featuresdiff)) * 1.0 / tau
    # featuresNormed = np.clip(featuresNormed, 0, 1)
    # featuresNormed[featuresNormed > 0] = 1 # bin

    # crop
    features = featuresNormed.reshape(featuresNormed.shape[0], patchsize, patchsize)
    margin = int((patchsize - resize) / 2)
    cropend = patchsize - margin
    features = features[:,margin:cropend, margin:cropend]
    features = features.reshape(features.shape[0],resize * resize)

    polarity = polarity.reshape(polarity.shape[0],patchsize, patchsize)
    margin = int((patchsize - resize) / 2)
    cropend = patchsize - margin
    channelP = polarity[:,margin:cropend, margin:cropend]
    channelP = channelP.reshape(channelP.shape[0], resize * resize)
    channelP[features==0] = 0 # set the polarity to be 0 if the event is too old, which means the ts features are 0
    channelP[:,int(resize*resize/2)] = targetEventP # ensure the center location has the classified event's polarity
    

    features2 = np.hstack((features,channelP))
    # print(features2.shape)
    return features2


def preprocessingresize(allfeatures, resize, targetEventTS, targetEventP):
    # print(features.shape)
    # print(features)
    # print(allfeatures.shape, targetEventTS.shape, targetEventP.shape)
    absTS = allfeatures[:,:csvinputlen]
    polarity = allfeatures[:,csvinputlen:]
    
    features = absTS#.transpose()
    # print(features.shape, polarity.shape, targetEventTS.shape)
    # print(features[:10])
    # normalization
    # featuresdiff = pd.DataFrame(np.array(features)) - pd.DataFrame(np.array(targetEventTS)) 
    # print(featuresdiff.shape)
    featuresdiff = [features[i,:] - targetEventTS[i] for i in range(len(features))]
    # print(featuresdiff)

    
    featuresdiff = np.array(featuresdiff, dtype=np.int)
    featuresdiff = featuresdiff/1000
    featuresdiff = featuresdiff.astype(int)
    featuresNormed = (tau - np.abs(featuresdiff)) * 1.0 / tau
    
    
    featuresNormed = np.clip(featuresNormed, 0, 1)
    # print(np.unique(featuresNormed)[:10])
    # featuresNormed = np.exp(-np.abs(featuresdiff)/tau)
    
    # featuresNormed = featuresNormed.transpose()

    # crop
    features = featuresNormed.reshape(featuresNormed.shape[0], patchsize, patchsize)
    margin = int((patchsize - resize) / 2)
    cropend = patchsize - margin
    features = features[:,margin:cropend, margin:cropend]
    features = features.reshape(features.shape[0],resize * resize)

    polarity = polarity.reshape(polarity.shape[0],patchsize, patchsize)
    margin = int((patchsize - resize) / 2)
    cropend = patchsize - margin
    channelP = polarity[:,margin:cropend, margin:cropend]
    channelP = channelP.reshape(channelP.shape[0], resize * resize)
    channelP[features==0] = 0 # set the polarity to be 0 if the event is too old, which means the ts features are 0
    channelP[:,int(resize*resize/2)] = targetEventP # ensure the center location has the classified event's polarity
    

    features2 = np.hstack((features,channelP))
    # print(features2.shape)
    return features2

def preprocessing(features, targetEventTS):
    middle = int(patchsize * patchsize / 2)
    features = features.transpose()
    # normalization
    featuresdiff = features - targetEventTS
    featuresNormed = (tau - np.abs(featuresdiff)) * 1.0 / tau
    featuresNormed = np.clip(featuresNormed, 0, 1)
    # featuresNormed = np.exp(-np.abs(featuresdiff)/tau)

    featuresNormed = featuresNormed.transpose()
    return featuresNormed

train = {}
val = {}

import random as random
def getgeneratorbatches(files):
    # print('start generator')
    # while 1:
    if 1:
        # print('loop generator')
        sumtrainbatches = 0
        sumtestbatches = 0

        # random.shuffle(files)
        # print(files)
        for file_ in files:
            try:
                # print(file_)
                if 'concat' in file_:
                    encoding = "utf_8_sig"
                else:
                    encoding = "utf_8"
                df = pd.read_csv(file_,usecols=[0] + [i for i in range(3,5+csvinputlen*2)], header=0, )
                # df.fillna(0)
                
                zero = len(df[df.iloc[:,2] == 0])
                # random.shuffle(df.values)
                # print('read file', file_, zero, len(df)-zero)

                # if mode == 1: #Train
                # traindf = df.iloc[:int(len(df) * 1)]
                traindf = df
                # else:
                    # df = df.iloc[int(len(df) * 0.8):]
                # testbatches = int(np.ceil((len(df)-len(traindf))/batch_size))

                trainbatches = int(np.ceil(len(traindf)/batch_size))
                sumtrainbatches += trainbatches
                # sumtestbatches += testbatches

                
            except EOFError:
                print('error' + file_)
        # print(sumtrainbatches,sumtestbatches)
        return sumtrainbatches   

def mygenerator(files,mode,encodemethod):
    print('starting data generator')
    while 1:
        # print('loop generator')
        sumbatches = 0
        random.shuffle(files)
        # print(files)
        for file_ in files:
            try:
                # print(file_)
                if 'concat' in file_:
                    encoding = "utf_8_sig"
                else:
                    encoding = "utf_8"
                print(f'reading CSV file {file_}...')
                df = pd.read_csv(file_,usecols=[0] + [i for i in range(3,5+csvinputlen*2)], header=0, comment='#')
                df.fillna(0)
                # random.seed(1)
                # zero = len(df[df.iloc[:,2] == 0])
                random.shuffle(df.values)


                batches = int(np.ceil(len(df)/batch_size))
                sumbatches += batches
                for i in range(0, batches):
                    m_data = df[i*batch_size:min(len(df),i*batch_size+batch_size)].values
                    # print(m_data.shape,m_data[:10])
                    m_data = m_data.astype('float')
                    # print(m_data.shape)
                    if patchsize >= resize:
                        # sample = {'y': m_data[2], 'x': preprocessingresize(m_data[3:3+csvinputlen*2], resize, m_data[1], m_data[0])} # crop the TI patch according to the given size
                        y = m_data[:,2]
                        
                        # print(y.shape)
                        if encodemethod == 'bin':
                            x = binpreprocessingresize(m_data[:,3:3+csvinputlen*2], resize, m_data[:,1], m_data[:,0])
                        elif encodemethod == 'lbp':
                            x = lbppreprocessingresize(m_data[:,3:3+csvinputlen*2], resize, m_data[:,1], m_data[:,0])
                        
                        else:
                            x = preprocessingresize(m_data[:,3:3+csvinputlen*2], resize, m_data[:,1], m_data[:,0])

                        # print(y.shape,y[:10])
                        # print(x.shape,x[:10])
                    else:
                        # sample = {'y': m_data[:,4], 'x': preprocessing(m_data[:,5:5+csvinputlen*2], m_data[:,3])}
                        y = m_data[:,4]
                        x = preprocessing(m_data[:,5:5+csvinputlen*2], m_data[:,3])
                    # if self.transform:
                    #     sample = self.transform(m_data)
                    
                    # print(x[:10])
                    # print(y[:10])
                    # exit(0)
                    yield(x,y)
            except EOFError:
                print('error' + file_)
        # print(f'{sumbatches} batches done')


def splittraintest(csvdir, splitratio):
    
    allFiles = glob.glob(os.path.join(csvdir,'*TI25*.csv'))
    if len(allFiles) > 0:
        np_array_list = []
        for file_ in allFiles:
            print(file_)
            df = pd.read_csv(file_,usecols=[0] + [i for i in range(3,5+csvinputlen*2)], header=0) # might change if the collecting code change
            np_array_list.append(df.values)

        # read all csv files in a folder to one wpndas frame
        # comb_np_array = np.vstack(np_array_list)
        # np.random.shuffle(comb_np_array)
        # big_frame = pd.DataFrame(comb_np_array)
        # # big_frame = big_frame.fillna(0)
        # print(big_frame.head(), big_frame.size)

        # # split train and test set
        # leng = len(big_frame)
        # trainset = big_frame.iloc[:int(splitratio*leng)]
        # testset = big_frame.iloc[int(splitratio*leng):]
        # del big_frame 
        # del msk
        # trainlist = np_array_list[:int(splitratio*)]
        return pd.DataFrame(np.vstack(np_array_list[:int(splitratio*len(np_array_list))])), pd.DataFrame(np.vstack(np_array_list[int(splitratio*len(np_array_list)):]))


def qbuildDModel(resize, hidden):
    networkinputlen = resize * resize
    if resize > 0:
        inputs = Input(shape=[networkinputlen*2, ], name='input')
        x = Dense(hidden, input_shape=(networkinputlen*2, ), activation='relu', name='fc1')(inputs)
        x = Dense(hidden, activation='relu', name='fc2')(x)
        # x = Dropout(0.2)(x)
        x = Dense(1, activation='sigmoid', name='output')(x)
        model = Model(inputs, x)

        return model

def buildModel(resize, hidden):
    networkinputlen = resize * resize
    if resize > 0:
        inputs = Input(shape=[networkinputlen*2, ], name='input')
        x = Dense(hidden, input_shape=(networkinputlen*2, ), activation='relu', name='fc1')(inputs)
        
        # x = Dropout(0.2)(x)
        x = Dense(1, activation='sigmoid', name='output')(x)
        
        model = Model(inputs, x)

        return model


def qbuildModel(resize, hidden, bits):
    networkinputlen = resize * resize
    
    if resize > 0:
        inputs = Input(shape=[networkinputlen*2, ], name='input')
        x = QActivation("quantized_bits(" +str(bits)+ ")", name="qact0")(inputs)
        x = QDense(hidden, input_shape=(networkinputlen*2, ), kernel_quantizer=quantized_bits(bits),
           bias_quantizer=quantized_bits(bits),
           name="fc1")(x)  
        x = QActivation("quantized_relu(" +str(bits)+ ")", name="relu1")(x)
        x = QDense(1, kernel_quantizer=quantized_bits(bits),
           bias_quantizer=quantized_bits(bits),
           name="fc2")(x)
        x = QActivation("quantized_relu(" +str(16)+ ")", name="doutput")(x)
        x = QActivation("quantized_relu(bits=16, integer=0, use_sigmoid=1)",name='output')(x)
        model = Model(inputs, x)

        return model

# def qbuildModel(resize, hidden):
#     networkinputlen = resize * resize
#     if resize > 0:
#         inputs = Input(shape=[networkinputlen*2, ], name='input')
#         x = QActivation("quantized_bits(8)", name="qact0")(inputs)
#         x = QDense(hidden, input_shape=(networkinputlen*2, ), kernel_quantizer=quantized_bits(8),
#            bias_quantizer=quantized_bits(8),
#            name="fc1")(x)  
#         # x = QDense(hidden, input_shape=(networkinputlen*2, ), kernel_quantizer=quantized_bits(8),
#         #    bias_quantizer=quantized_bits(8),
#         #    name="fc1")(inputs)  
#         x = QActivation("quantized_relu(9)", name="relu1")(x)

#         # x = Dense(1, activation='sigmoid', name='output')(x)
#         x = QDense(1, kernel_quantizer=quantized_bits(8),
#            bias_quantizer=quantized_bits(8),
#            name="fc2")(x)
#         x = Activation("sigmoid", name="output")(x)
#         model = Model(inputs, x)

#         return model


def qbuildPerceptron(resize):
    networkinputlen = resize * resize
    if resize > 0:
        inputs = Input(shape=[networkinputlen*2, ], name='input')
        x = Dense(1, input_shape=(networkinputlen*2, ),  activation='sigmoid', name='output')(inputs)
        model = Model(inputs, x)

        return model



import sklearn
from sklearn.metrics import roc_auc_score
from sklearn.metrics import roc_curve
import matplotlib.pyplot as plt

def plot_roc_curve(y_true,y_score,prefix):
    fpr,tpr,threshold = roc_curve(y_true,y_score,pos_label=1)
    auc = roc_auc_score(y_true,y_score)
    plt.xlabel('FPR')
    plt.ylabel('TPR')
    plt.title('roc curve' + str(auc))
    plt.plot(fpr,tpr,color='b',linewidth=1)
    plt.plot([0,1],[0,1],'r--')
    plt.savefig(os.path.join(MODEL_DIR,prefix + '_roccurve.pdf'))
    plt.clf()

# https://stackoverflow.com/questions/35155655/loss-function-for-class-imbalanced-binary-classifier-in-tensor-flow
import keras.backend as K
def weighted_binary_crossentropy(pos_weight=1.):
    """ Weighted binary crossentropy between an output tensor and a target tensor.
    # Arguments
        pos_weight: A coefficient to use on the positive examples.
    # Returns
        A loss function supposed to be used in model.compile().
    """

    def _to_tensor(x, dtype):
        """Convert the input `x` to a tensor of type `dtype`.
        # Arguments
            x: An object to be converted (numpy array, list, tensors).
            dtype: The destination type.
        # Returns
            A tensor.
        """
        return tf.convert_to_tensor(x, dtype=dtype)

    def _calculate_weighted_binary_crossentropy(target, output, from_logits=False):
        """Calculate weighted binary crossentropy between an output tensor and a target tensor.
        # Arguments
            target: A tensor with the same shape as `output`.
            output: A tensor.
            from_logits: Whether `output` is expected to be a logits tensor.
                By default, we consider that `output`
                encodes a probability distribution.
        # Returns
            A tensor.
        """
        # Note: tf.nn.sigmoid_cross_entropy_with_logits
        # expects logits, Keras expects probabilities.
        if not from_logits:
            # transform back to logits
            _epsilon = _to_tensor(K.epsilon(), output.dtype.base_dtype)
            output = tf.clip_by_value(output, _epsilon, 1 - _epsilon)
            output = tf.math.log(output / (1 - output))
        target = tf.dtypes.cast(target, tf.float32)
        return tf.nn.weighted_cross_entropy_with_logits(labels=target, logits=output, pos_weight=pos_weight)

    def _weighted_binary_crossentropy(y_true, y_pred):
        return K.mean(_calculate_weighted_binary_crossentropy(y_true, y_pred), axis=-1)

    return _weighted_binary_crossentropy


# trainbatches = 2705#3842
# testbatches = 784#2078#938
def trainFunction(trainfiles, testfiles, trainbatches, testbatches,resize, hidden, epochs, repeat, mtype, Train,bits):
    # global csvdir
    encodemethod='bin'
    prefix = ''
    if mtype == 'double': # two hidden layer floating-point MLP
        model = qbuildDModel(resize,hidden)
        middlefix = 'DH'
    elif mtype == 'qsingle': # quanitized MLP with one hidden layer
        model = qbuildModel(resize,hidden,bits)
        middlefix = 'qH'
        prefix = '16bit-qsigmoidput' + encodemethod + str(tau)+'tau'+str(bits)+'bitaw' + str(repeat) + 'MSEO1' + middlefix + str(hidden) + '_linear_' + str(resize)
    elif mtype == 'single': # floating MLP with one hidden layer
        model = buildModel(resize,hidden)
        middlefix = 'fH'
        prefix = 'float' + encodemethod + str(tau)+'tau'+str(bits)+'bitaw' + str(repeat) + 'MSEO1' + middlefix + str(hidden) + '_linear_' + str(resize)
    elif mtype == 'perceptron': # single layer pereception (no hidden layer)
        model = qbuildPerceptron(resize)
        middlefix = 'H'

    from pathlib import Path
    Path(MODEL_DIR).mkdir(exist_ok=True)

    if Train:
        traingenerator = mygenerator(trainfiles,1,encodemethod)
        # testx,testy = getxandy(testfiles[0])
        testgenerator = mygenerator(testfiles,0,encodemethod)
        
        print('qbuild model...', prefix + '.h5')
        optimizer = Adam(learning_rate=learning_rate)
        # model.compile(optimizer, loss='mean_squared_error', metrics=['accuracy']) # original loss used in DND21 paper with balanced signal and noise event counts
        # https://stackoverflow.com/questions/35155655/loss-function-for-class-imbalanced-binary-classifier-in-tensor-flow
        pos = snr # count of positive class
        neg = 1-snr # count of negative class
        total = pos + neg
        weight_for_0 = (1 / neg) * (total) / 2.0
        weight_for_1 = (1 / pos) * (total) / 2.0

        class_weight = {0: weight_for_0, 1: weight_for_1}
        model.compile(
            optimizer=tf.keras.optimizers.Adam(learning_rate=learning_rate),
            loss=weighted_binary_crossentropy(weight_for_1),
            metrics=tf.keras.metrics.Precision(name='precision')
        )
        model.summary()


        # n_batches = testgenerator.samples//batch_size
        e0loss, e0acc = 0.25,0.49#model.evaluate_generator(traingenerator,steps=trainbatches,verbose=1) 
        e0valloss, e0valacc = 0.26,0.29#model.evaluate_generator(testgenerator, steps=testbatches, verbose=1) 
        print('No.%d newly-initialized net %s loss: %.2f, acc: %.2f'%(repeat,prefix,e0valloss,e0valacc))

        # model = qbuildModel(resize,hidden)

        history = LossHistory()

        filepath=os.path.join(MODEL_DIR,prefix + "-{epoch:02d}-{val_accuracy:.3f}.h5")
        checkpoint = ModelCheckpoint(filepath,monitor='val_accuracy',mode='max' ,save_best_only='True', save_weights_only='True', save_freq='epoch')
        print(f'checkpoint={checkpoint}')

        # checkpoint = ModelCheckpoint(filepath='mlpmodels',monitor='loss',mode='auto' ,save_best_only='True')
        

       
        model.fit_generator(generator=traingenerator,
        steps_per_epoch=trainbatches,
        epochs=epochs, 
        validation_data=testgenerator, 
        validation_steps=testbatches,
        callbacks=[history,checkpoint], 
        # callbacks=[history], 
        verbose=1, workers=1, use_multiprocessing=False)

        all_weights = []
        history.loss_plot(prefix,'epoch', e0loss, e0acc, e0valloss, e0valacc)


        model_file_name = os.path.join(MODEL_DIR,prefix + 'model.h5')
        model.save(model_file_name)
        quantized_weights_filename=os.path.join(MODEL_DIR, prefix+'weights.h5')
        model_save_quantized_weights(model, quantized_weights_filename)

        for layer in model.layers:
            for w, weights in enumerate(layer.get_weights()):
                print(layer.name, w)
                all_weights.append(weights.flatten())

        all_weights = np.concatenate(all_weights).astype(np.float32)
        print(all_weights.size)


        for layer in model.layers:
          for w, weight in enumerate(layer.get_weights()):
            print(layer.name, w, weight.shape)

        print_qstats(model)
        print(f'saved model as {model_file_name}')

        try:
            freeze_session(model_file_name)
        except Exception as e:
            print(f'could not convert h5 model to pb model; got: {e}')
    else:
        # model = load_model( prefix + '.h5')
        # model.summary()
        # model = qbuildModel(resize,hidden)
        # model = load_model( prefix + '.h5')
        # model.summary()
        # model.compile(optimizer, loss)
        # model.compile(optimizer, loss='mean_squared_error', metrics=['accuracy'])

        testgenerator = mygenerator(testfiles,0)
        # model = load_model( prefix + '.h5')
        # model.summary()
        # model = qbuildModel(resize,hidden)
        # model = load_model( prefix + '.h5')
        # model = load_model('0308pm16bitsqsigmoidput' + encodemethod + 'tau'+str(tau)+'quantize8awq2x8bitawawI7qH20-01-0.952.h5')
        
        model.compile(optimizer='adam', loss='mean_squared_error', metrics=['accuracy'])
        # model.load_weights(prefix + 'wk.h5')
        # weightpath = '0308pm16bitsqsigmoidput' + encodemethod + 'tau'+str(tau)+'quantize8awq2x8bitawawI7qH20-02-0.817.h5'
        # weightpath = '0308pm16bitsqsigmoidput' + encodemethod + 'tau'+str(tau)+'quantize8awq2x8bitawawI7qH20-01-0.962.h5'
        # weightpath = '0308pm16bitsqsigmoidput' + encodemethod + 'tau'+str(tau)+'quantize8awq2x8bitaw0MSEO1qH20_linear_7wk.h5'
        weightpath = prefix + 'wk.h5'
        model.load_weights(weightpath)
        # model.summary()


    # return

    # n_batches = len(testgenerator)
    if True:
        # loss, acc = model.evaluate_generator(testgenerator,steps=testbatches, verbose=1) 
        # print('No.%d trained net %s loss: %.2f, acc: %.2f'%(repeat,prefix,loss,acc))
        # y_true = np.concatenate([testgenerator[i][1] for i in range(testbatches)])
        # initpredictions = model.predict_generator(testgenerator, steps=testbatches, verbose=1) 
        y_true = np.array([])
        initpredictions = np.array([])

        icount = 0
        for i,(batchx,batchy) in tqdm(enumerate(testgenerator)):
            
            if icount == testbatches:
                print('predict all batch', i)
                break
            icount +=1
            # print('predict batch', i)
            y_true = np.concatenate([y_true,batchy])
            # print(y_true.shape)
            # print(batchx.shape,batchy.shape,model.predict(batchx,verbose=0).shape)
            # return
            initpredictions = np.concatenate([initpredictions, np.squeeze(model.predict(batchx,verbose=0))])
            # print(initpredictions.shape)
        
        rocauc = roc_auc_score(y_true,initpredictions)
        print(prefix,'auc',rocauc)
        if Train:
            weightpath = prefix
            
        plot_roc_curve(y_true,initpredictions,weightpath.replace('.h5',str(rocauc)))
        # del model
        # return
        y_pred = (initpredictions > 0.5).astype(int)
        y_true = np.reshape(y_true, [-1])
        y_pred = np.reshape(y_pred, [-1])
        print(y_true.shape, y_pred.shape)

        finderrorloc = y_true == y_pred
        indices = np.where(finderrorloc == False)

        accuracy = accuracy_score(y_true, y_pred)
        precision = precision_score(y_true, y_pred)
        TPR = recall_score(y_true, y_pred, average='binary')
        f1score = f1_score(y_true, y_pred, average='binary')

        tn, fp, fn, tp = confusion_matrix(y_true, y_pred).ravel()
        specificity = tn * 1.0 / (tn + fp) # TNR
        FPR = fp * 1.0 / (tn + fp) 

        print( prefix + '.h5')
        print('testacc:',accuracy)
        print('precision:',precision)
        print('FPR:',FPR)
        print('TPR:',TPR)
        print('f1score:',f1score)
        cm= confusion_matrix(y_true, y_pred)

        print('confusion matrix')
        print(cm)

        cm_normalized = cm.astype('float') / cm.sum(axis=1)[:, np.newaxis]
        print('normalized confusion matrix')
        print(cm_normalized)

        # plot output distribution
        # initpredictions = np.array(initpredictions)
        # initpredictions = initpredictions.reshape((initpredictions.shape[0] * initpredictions.shape[1]))
        
        plt.clf()
        if Train:
            histlabel = 'network output'
        else:
            histlabel = 'newly-initialized network output'
        plt.hist(initpredictions, bins=20, label=histlabel)
        plt.xlim(0,1)
        plt.legend()
        plt.savefig(os.path.join(MODEL_DIR,prefix + '_outputhist.pdf'))

# main part of script
if len(sys.argv)<3:
    print(f'need at least 3 arguments, e.g. "python qtrain.py 0 4" to train quantized net with 4-bit weights and states. See ReadMe.md')
    quit(1)

trainfiles = glob.glob(os.path.join(trainfilepath,'*.csv*')) # trailing wildcard to read compressed csv files, e.g. xxx.csv.xz or xxx.csv
testfiles = glob.glob(os.path.join(testfilepath,'*.csv*'))
if len(trainfiles)==0 or len(testfiles)==0:
    print(f'there are no files in {trainfilepath} or in {testfilepath}; check trainfilepath and testfilepath variables and working folder')
    quit(1)
else:
    print(f'** found {len(trainfiles)} training CSV files and {len(testfiles)} testing CSV files')
trainbatches = 3000#getgeneratorbatches(trainfiles)
testbatches = 699#getgeneratorbatches(testfiles)
print(f'trainbatches={trainbatches}, testbatches={testbatches}')
trainflag=True

bits = int(sys.argv[2]) # quantization bits for training quantized net, ignored for floating point training

if int(sys.argv[1])>0: # train float model
    print('training floating point model')
    trainFunction(trainfiles,testfiles, trainbatches,testbatches, resize, hidden, epochs, 0, 'single', trainflag, bits)
else: # train quantized model
    print(f'training quantized model with {bits} bits for weights and activations (except last layer)')
    trainFunction(trainfiles,testfiles, trainbatches, testbatches, resize, hidden, epochs, 0, 'qsingle', trainflag, bits)

end_time=time.time()
print(f'total elapsed time {end_time-start_time:.1f} seconds')