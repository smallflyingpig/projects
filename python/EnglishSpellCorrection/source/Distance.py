# ! /usr/bin/env/ python2
# -*- coding:utf-8 -*-

import  numpy as np
# for more information, please read paper: Error-tolerant Finite-state Recognition with
# Application to Morphological Analysis and Spelling Correction

g_edit_distance = np.zeros([0,0])
g_edit_distance_flag = np.zeros([0,0])

def EditDistance(reference, str):
    global g_edit_distance
    global g_edit_distance_flag

    dict_cost = {'deletion':1, 'insertion':1, 'replacement':1, 'transposition':1}
    len_str = len(str)
    len_refer = len(reference)

    recurrent_flag = False;
    distance = 0;
    look_up_shape = g_edit_distance_flag.shape;

    if len_str == 0:
        distance = dict_cost['insertion']*len_refer
    elif len_refer == 0:
        distance = dict_cost['deletion']*len_str
    elif len_refer<look_up_shape[0] and len_str<look_up_shape[1] and g_edit_distance_flag[len_refer][len_str]:
        distance = g_edit_distance[len_refer][len_str]
    else:
        recurrent_flag = True

    if recurrent_flag:
        idx_str = len_str-1
        idx_refer = len_refer-1
        if str[idx_str] == reference[idx_refer]:
            distance = EditDistance(reference[:len_refer-1], str[:len_str-1])
        elif len_str>=2 and len_refer>=2 and reference[-1] == str[-2] \
            and reference[-2] == str[-1]:#transposition
            distance_transposition = dict_cost['transposition'] + EditDistance(reference[:-2], str[:-2]);
            distance_deletion = dict_cost['deletion'] + EditDistance(reference, str[:-1])
            distance_insertion = dict_cost['insertion'] + EditDistance(reference[:-1], str)
            distance = min(distance_transposition, distance_deletion, distance_insertion);
        else:
            distance_replacement = dict_cost['replacement'] + EditDistance(reference[:-1], str[:-1])
            distance_deletion = dict_cost['deletion'] + EditDistance(reference, str[:-1])
            distance_insertion = dict_cost['insertion'] + EditDistance(reference[:-1], str)
            distance = min(distance_replacement, distance_deletion, distance_insertion)

        g_edit_distance_flag[len_refer][len_str] = 1;
        g_edit_distance[len_refer][len_str] = distance;
    #print 'edit distance:%d,(%s,%s)'%(distance, reference, str)

    return distance

def CutOffDistance(reference, str, t=2):
    global g_edit_distance
    global g_edit_distance_flag

    m = len(reference);
    n = len(str)

    g_edit_distance = np.zeros([m+1, n+1])
    g_edit_distance_flag = np.zeros([m+1, n+1])

    l = max(1, n-t)
    u = min(m, n+t)
    distance_list = [];
    for idx in range(l, u+1):
        distance_list.append(EditDistance(reference[:idx], str))

    #print distance_list
    distance = 0

    if len(distance_list)>0:
        distance = min(distance_list);

    return distance;
