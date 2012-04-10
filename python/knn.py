"""
k nearest neighbour algorithm
"""

from numpy import array 

def knn_classify(target, record_set, labels, k):
    rows,columns = record_set.shape # get record_set's rows and columns
    distances = {}
    for i in xrange(rows):
        # calculate distance of target with every record
        # use Euclidian Distance
        sum = 0
        for j in xrange(columns):
            sum += pow(target[j]-record_set[i][j],2)
        score = pow(sum, 0.5)
        distances[i] = score
    # get the k few labels
    target_labels = {}
    count = 0
    if k>rows:
        k = rows
    for item in sorted(distances.iteritems(),          \
                        key=lambda(key,value):(value,key),  \
                        reverse=True):
        if count == k:
            break
        label = labels[item[0]]
        if target_labels.has_key(label):
            target_labels[label] += 1
        else:
            target_labels[label] = 0
        count += 1
    max_value = max(target_labels.values())
    return filter(lambda item: item[1] == max_value, target_labels.items())


def make_record_set():
    group = array([
        [1.0, 1.1],
        [1.0, 1.0],
        [0, 0],
        [0, 0.1]
    ])
    labels = ['A', 'A', 'B', 'B']
    return group, labels

group, labels = make_record_set()
target = [0,0]
print knn_classify(target, group, labels, 3)
