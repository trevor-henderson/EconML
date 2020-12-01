# See _criterion.pyx for implementation details.

import numpy as np
cimport numpy as np

from ._tree cimport DTYPE_t          # Type of X
from ._tree cimport DOUBLE_t         # Type of y, sample_weight
from ._tree cimport SIZE_t           # Type for indices and counters
from ._tree cimport INT32_t          # Signed 32 bit integer
from ._tree cimport UINT32_t         # Unsigned 32 bit integer

cdef class Criterion:
    # The criterion computes the impurity of a node and the reduction of
    # impurity of a split on that node. It also computes the output statistics
    # such as the mean in regression and class probabilities in classification.

    # Internal structures
    cdef const DTYPE_t[::1, :] Data       # All other variables for computing the criterion
    cdef const DOUBLE_t[:, ::1] y        # Values of y
    cdef DOUBLE_t* sample_weight         # Sample weights
    
    cdef const DTYPE_t[::1, :] Data_val       # All other variables for computing the criterion
    cdef const DOUBLE_t[:, ::1] y_val        # Values of y
    cdef DOUBLE_t* sample_weight_val        # Sample weights

    cdef SIZE_t n_outputs                # Number of outputs
    cdef SIZE_t n_features               # Number of features
    
    cdef SIZE_t* samples                 # Sample indices in X, y
    cdef SIZE_t start                    # samples[start:pos] are the samples in the left node
    cdef SIZE_t pos                      # samples[pos:end] are the samples in the right node
    cdef SIZE_t end

    cdef SIZE_t* samples_val                 # Sample indices in X, y
    cdef SIZE_t start_val                    # samples[start:pos] are the samples in the left node
    cdef SIZE_t pos_val                      # samples[pos:end] are the samples in the right node
    cdef SIZE_t end_val

    cdef SIZE_t n_samples                # Number of samples
    cdef SIZE_t n_node_samples           # Number of samples in the node (end-start)
    cdef double weighted_n_samples       # Weighted number of samples (in total)
    cdef double weighted_n_node_samples  # Weighted number of samples in the node
    cdef double weighted_n_left          # Weighted number of samples in the left node
    cdef double weighted_n_right         # Weighted number of samples in the right node
    
    
    cdef SIZE_t n_samples_val                # Number of samples
    cdef SIZE_t n_node_samples_val           # Number of samples in the node (end-start)
    cdef double weighted_n_samples_val       # Weighted number of samples (in total)
    cdef double weighted_n_node_samples_val  # Weighted number of samples in the node
    cdef double weighted_n_left_val          # Weighted number of samples in the left node
    cdef double weighted_n_right_val         # Weighted number of samples in the right node
    
    
    
    cdef double* sum_total          # For classification criteria, the sum of the
                                    # weighted count of each label. For regression,
                                    # the sum of w*y. sum_total[k] is equal to
                                    # sum_{i=start}^{end-1} w[samples[i]]*y[samples[i], k],
                                    # where k is output index.
    cdef double* sum_left           # Same as above, but for the left side of the split
    cdef double* sum_right          # same as above, but for the right side of the split

    cdef double* sum_total_val      # For classification criteria, the sum of the
                                    # weighted count of each label. For regression,
                                    # the sum of w*y. sum_total[k] is equal to
                                    # sum_{i=start}^{end-1} w[samples[i]]*y[samples[i], k],
                                    # where k is output index.
    cdef double* sum_left_val       # Same as above, but for the left side of the split
    cdef double* sum_right_val      # same as above, but for the right side of the split

    # The criterion object is maintained such that left and right collected
    # statistics correspond to samples[start:pos] and samples[pos:end].

    # Methods
    cdef int init(self, const DTYPE_t[::1, :] Data, const DOUBLE_t[:, ::1] y, 
                  DOUBLE_t* sample_weight, double weighted_n_samples,
                  SIZE_t* samples,
                  const DTYPE_t[::1, :] Data_val, const DOUBLE_t[:, ::1] y_val, 
                  DOUBLE_t* sample_weight_val, double weighted_n_samples_val,
                  SIZE_t* samples_val) nogil except -1
    cdef int node_reset(self, SIZE_t start, SIZE_t end,
                        SIZE_t start_val, SIZE_t end_val) nogil except -1
    cdef int reset(self) nogil except -1
    cdef int reverse_reset(self) nogil except -1
    cdef int reverse_reset_train(self) nogil except -1
    cdef int reverse_reset_val(self) nogil except -1
    cdef int update(self, SIZE_t new_pos, SIZE_t new_pos_val) nogil except -1
    cdef double node_impurity(self) nogil
    cdef double node_impurity_val(self) nogil
    cdef void children_impurity(self, double* impurity_left,
                                double* impurity_right) nogil
    cdef void children_impurity_val(self, double* impurity_left,
                                    double* impurity_right) nogil
    cdef void node_value_val(self, double* dest) nogil
    cdef void node_jacobian_val(self, double* dest) nogil
    cdef void node_precond_val(self, double* dest) nogil
    cdef double impurity_improvement(self, double impurity) nogil
    cdef double proxy_impurity_improvement(self) nogil


cdef class RegressionCriterion(Criterion):
    """Abstract regression criterion."""

    cdef double sq_sum_total
    cdef double sq_sum_total_val