from ops import *
from config import *
import numpy as np

class net:
    def __init__(self, name):
        self.name = name

    def __call__(self, inputs, train_phase):
        with tf.variable_scope(self.name):
            inputs = tf.nn.relu(conv("conv0", inputs, 64, 3, 1))
            for d in np.arange(1, DEPTH - 1):
                inputs = tf.nn.relu(batchnorm(conv("conv_" + str(d + 1), inputs, 64, 3, 1), train_phase, "bn" + str(d)))
            inputs = conv("conv" + str(DEPTH - 1), inputs, IMG_C, 3, 1)
            return inputs