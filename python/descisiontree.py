"""
decision-tree algorithm
"""

from math import log


def get_shannon_score(recordset):
    size = len(recordset)
    label_count = {}

    for record in recordset:
        label = record[-1]
        if not label_count.has_key(label):
            label_count[label] = 0
        label_count[label] += 1

    shannon_score = 0.0
    for label in label_count.keys():
        prob = float(label_count[label])/size
        shannon_score -= prob*log(prob, 2)
    return shannon_score

def split_recordset(recordset, column, value):
    size = len(recordset[0])
    target_recordset = []
    for record in recordset:
        if record[column] == value:
            new_arr = []
            new_arr.extend(record[0:column])
            new_arr.extend(record[column+1:])
            target_recordset.append(new_arr)
    return target_recordset

def get_best_feature(recordset):
    feature_nums = len(recordset[0])-1
    base_entropy = get_shannon_score(recordset)
    best_infogain = 0.0
    best_feature = -1

    for i in xrange(feature_nums):
        feature_value_list = [record[i] for record in recordset]
        unique_feature_value = set(feature_value_list)
        new_entropy = 0.0
        for value in unique_feature_value:
            subrecordset = split_recordset(recordset, i, value)
            prob = len(subrecordset)/float(len(recordset));
            new_entropy += prob*get_shannon_score(subrecordset)
        infogain = base_entropy-new_entropy
        if infogain>best_infogain:
            best_infogain = infogain
            best_feature = i
    return best_feature

"""
def marjority_cnt(class_list):
    class_count = {}
    for vote in class_list:
        if vote not in class_count.keys():
            class_count[vote] = 0
        class_count[vote] += 1
"""

def create_descision_tree(recordset, labels):
    class_list = [record[-1] for record in recordset]
    if class_list.count(class_list[0]) == len(class_list):
        # no other class exist
        return class_list[0]  
    if len(recordset[0]) == 1:
        return
    best_feature = get_best_feature(recordset)
    best_feature_label = labels[best_feature]
    tree = {best_feature_label:{}}
    del(labels[best_feature])
    feature_value_list = [record[best_feature] for record in recordset]
    unique_value_list = set(feature_value_list)
    for value in unique_value_list:
        sub_labels = labels[:]
        tree[best_feature_label][value] = create_descision_tree( \
            split_recordset(recordset,best_feature,value), sub_labels)
    return tree

def make_record_set():
    recordset = [
        [1,1,'yes'],
        [1,1,'yes'],
        [1,0,'no'],
        [0,1,'no'],
        [0,1,'no']]
    labels = ['no surfacing', 'flippers']
    return recordset, labels


