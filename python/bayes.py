"""
bayes algorithm
"""
from __future__ import division

def get_bayes_matrix(train_matrx, class_list):
    """
    get the bayes matrix
    """
    total_size = len(train_matrx)
    feature_size = len(train_matrx[0])

    class_set = set(class_list)
    class_p = {}
    feature_p = {}
    class_count = {}
    # calculate every class's probability
    for classname in class_set:
        class_p[classname] = class_list.count(classname)/total_size
        feature_p[classname] = [0.0]*feature_size
        class_count[classname] = 0
    # calculate every feature's probability in every class
    
    for i in xrange(total_size):
        classname = class_list[i]
        feature_list = map(lambda index:                       \
            feature_p[classname][index]+train_matrx[i][index], \
            xrange(feature_size))
        class_count[classname] += sum(feature_list)
        feature_p[classname] = feature_list
    for classname in class_set:
        feature_p[classname] = map(lambda index:               \
            feature_p[classname][index]/class_count[classname],
            xrange(feature_size))

    return feature_p, class_p
    """
    for i in xrange(total_size):
        classname = class_list[i]
        feature_p[classname] = map(lambda index:feature_p[classname][index]+train_matrx[i][index], \
                                    xrange(feature_size))
    for classname in feature_p.keys():
        feature_p[classname] = map(lambda index:feature_p[classname][index]/class_p[classname],               \
                                    xrange(feature_size))
        class_p[classname] = map(lambda key:class_p[key]/total_size,                                 \
                                    class_p.keys())
    return class_p, feature_p
    """

def create_recordset():
    """
    get features from post_list
    """
    post_list = [
        ['my', 'dog', 'has', 'flea',     \
         'problems', 'help', 'please'],
        ['maybe', 'not', 'take', 'him',  \
         'to', 'dog', 'park', 'stupid'],
        ['my', 'dalmation', 'is', 'so', 'cute', \
         'I', 'love', 'him'],
        ['stop', 'posting', 'stupid', 'worthless', \
         'garbage'],
        ['mr', 'licks', 'ate', 'my', 'steak', 'how', \
         'to', 'stop', 'him'],
        ['quit', 'buying', 'worthless', 'dog', 'food', \
         'stupid']]
    class_vectors = [0,1,0,1,0,1]
    return post_list, class_vectors

def create_word_list(recordset):
    """
    get the unique feature list
    """
    word_set = set([])
    for record in recordset:
        word_set = word_set | set(record)
    return list(word_set)

def create_vector_list(word_list, in_set):
    """
    build the vector on the feature_list
    """
    vector = [0]*len(word_list)
    for word in in_set:
        if word in word_list:
            vector[word_list.index(word)] = 1
        else:
            print "the word: %s is not in my list!" % word
    return vector


post_list, class_list = create_recordset()
word_list = create_word_list(post_list)

"""
train_matrix = []
for post in post_list:
    train_matrix.append(create_vector_list(word_list, post))

print "Training Num: %d" % len(train_matrix)
print "Features Num: %d" % len(train_matrix[0])

feature_p, class_p = get_bayes_matrix(train_matrix, class_list)
print "CLASS_P: ", class_p
print "FEATURE_P: ", feature_p
"""
