##---- bunch of utils

## --- converting Spark.ml.Vector into array
## as NNClassifier only supports Array type for now
## reference : https://danvatterott.com/blog/2018/07/08/aggregating-sparse-and-dense-vectors-in-pyspark/
from pyspark.sql import functions as F
from pyspark.sql import types as T
import numpy as np

def dense_to_array(v):
#   return np.array(v.toArray())
    new_array = list([float(x) for x in v])
    return new_array


dense_to_array_udf = F.udf(dense_to_array, T.ArrayType(T.FloatType()))

def sparse_to_array(v):
  v = DenseVector(v)
  new_array = list([float(x) for x in v])
  return new_array

sparse_to_array_udf = F.udf(sparse_to_array, T.ArrayType(T.FloatType()))
## --- end converting Spark.ml.Vector into array


## -- setup tensorboard logs dir
def setup_tensorboard_dir(app_name):
    pass
# end: def setup_tensorboard_dir(app_name):
