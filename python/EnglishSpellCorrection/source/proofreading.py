# ! /usr/bin/env/ python2
# -*- coding:utf-8 -*-

from SearchTree import SearchTree
from Data import ReadData
import numpy as np
import random
import copy
import string
import re
import sys

_WORD_SPLIT = re.compile(b"([.,!?\"':;)(])")

DATA_PATH = './'
VOCABULARY_FILENAME = 'vocab10000.to'
TEST_DOC_NAME = 'en.txt'


def test_console_input():
    search_tree = SearchTree()
    vocabulary = ReadData(DATA_PATH, VOCABULARY_FILENAME)
    print('vocabulary size: %d'% len(vocabulary))

    search_tree.construct(vocabulary);
    while True:
        input_word = raw_input("input (input 'q' to quit):")
        if input_word == 'q':
            break

        word_list = input_word.split(' ')
        for word in word_list:
            word = word.lower()
            print(word)
            candidate = search_tree.Candidate(word)
            print(candidate)

def top_n_is_true(label, predict_list, top=1):

    rtn_value = [0] * top

    if top > len(predict_list):
        top = len(predict_list)

    idx = 0
    for idx in range(0, top):
        if predict_list[idx] == label:
            rtn_value[idx] = 1
            break

    rtn_value[idx+1:] = [1]*(len(rtn_value)-idx-1)

    return rtn_value

def rand_misspell_deletion(str):
    print('deletion')
    str_temp = copy.deepcopy(str)
    str_len = len(str)

    delete_pos = random.randint(0, str_len-1)

    str_temp = str_temp[:delete_pos]+str_temp[delete_pos+1:]

    return str_temp

def rand_misspell_insertion(str):
    print('insertion')
    str_temp = copy.deepcopy(str)
    str_len = len(str)

    insert_pos = random.randint(0, str_len)

    char_insert = random.choice(string.letters).lower();

    if insert_pos == str_len:
        str_temp = str_temp + char_insert
    elif insert_pos == 0:
        str_temp = char_insert + str_temp
    else:
        str_temp = str_temp[:insert_pos] + char_insert + str_temp[insert_pos:]

    return str_temp

def rand_misspell_replacement(str):
    print('replacement')
    str_temp = copy.deepcopy(str)
    str_len = len(str)

    replace_pos = random.randint(0, str_len-1)

    char_replace = random.choice(string.letters).lower();

    str_temp = str_temp[:replace_pos] + char_replace + str_temp[replace_pos+1:]

    return str_temp

def rand_misspell_transposition(str):
    print('transposition')
    str_temp = copy.deepcopy(str)
    str_len = len(str)

    if str_len < 2:
        return str_temp

    trans_pos = random.randint(0, str_len-2)

    str_temp = str_temp[:trans_pos] + str_temp[trans_pos+1]+str_temp[trans_pos] + str_temp[trans_pos+2:]

    return str_temp

def rand_misspell(str):
    misspell_type_list = ['deletion', 'insertion', 'replacement', 'transposition']
    misspell_func_dict = {'deletion' : rand_misspell_deletion, 'insertion': rand_misspell_insertion, \
                          'replacement': rand_misspell_replacement, 'transposition': rand_misspell_transposition}
    misspell_type = misspell_type_list[random.randint(0, len(misspell_type_list)-1)]

    str_misspell_func = misspell_func_dict.get(misspell_type, lambda str: str)

    str_misspell = str_misspell_func(str)

    print('%s -> %s'%(str, str_misspell))

    return str_misspell, misspell_type

def test_vocabulary(test_size = 1000):
    f_log = open('test_doc.log','wb')

    print('test vocabulary...')
    vocabulary = ReadData(DATA_PATH, VOCABULARY_FILENAME)
    print('vocabulary size: %d'% len(vocabulary))

    save_out = sys.stdout;

    sys.stdout = f_log

    if test_size>vocabulary:
        test_size = vocabulary

    search_tree = SearchTree()
    search_tree.construct(vocabulary)

    top_true_num = [0, 0, 0]
    top_true_num_delete = [0,0,0]
    test_size_delete = 0;
    top_true_num_insert = [0,0,0]
    test_size_insert = 0
    top_true_num_replace = [0,0,0]
    test_size_replace = 0
    top_true_num_trans = [0,0,0]
    test_size_trans = 0

    for idx in range(0, test_size):
        word = random.choice(vocabulary)
        word_mis, misspell_type = rand_misspell(word)
        predict_pair_list = search_tree.Candidate(word_mis) #[str, edit_dis]
        predict_list = [x[0] for x in predict_pair_list]
        match = top_n_is_true(word, predict_list, 3)
        top_true_num = [a+b for (a, b) in zip(top_true_num, match)]
        if misspell_type == 'deletion':
            test_size_delete  = test_size_delete+1
            top_true_num_delete = [a+b for (a, b) in zip(top_true_num_delete, match)]
        elif misspell_type == 'insertion':
            test_size_insert = test_size_insert + 1
            top_true_num_insert = [a+b for (a, b) in zip(top_true_num_insert, match)]
        elif misspell_type == 'replacement':
            test_size_replace = test_size_replace + 1
            top_true_num_replace = [a+b for (a, b) in zip(top_true_num_replace, match)]
        elif misspell_type == 'transposition':
            test_size_trans = test_size_trans + 1
            top_true_num_trans = [a+b for (a, b) in zip(top_true_num_trans, match)]
        else:
            print('pass')
            pass
        print('word: %s ->%s'% (word, word_mis))
        print predict_list
        print match

    accu = [float(x)/test_size for x in top_true_num]
    accu_delete = [float(x)/test_size_delete for x in top_true_num_delete]
    accu_insert = [float(x)/test_size_insert for x in top_true_num_insert]
    accu_replace = [float(x)/test_size_replace for x in top_true_num_replace]
    accu_trans = [float(x)/test_size_trans for x in top_true_num_trans]

    #print('accu:%f \t delete:%f \t insert:%f \t replace:%f \t trans:%f'%(accu, accu_delete, accu_insert, \
    #                                                                     accu_replace, accu_trans))

    print accu
    print accu_delete
    print accu_insert
    print accu_replace
    print accu_trans
    sys.stdout = save_out

    print('test vocabulary end')

def test_doc(filename, max_word = 10000):

    f_log = open('test_doc.log','wb')

    print('test doc:%s start'%filename)
    vocabulary = ReadData(DATA_PATH, VOCABULARY_FILENAME)
    print('vocabulary size: %d'% len(vocabulary))

    save_out = sys.stdout;

    sys.stdout = f_log

    with open(filename, 'rb') as doc:
        data = doc.read()

    words = []
    for space_separated_fragment in data.strip().split():
        words.extend(_WORD_SPLIT.split(space_separated_fragment))
    search_tree = SearchTree()
    search_tree.construct(vocabulary)

    test_size = 0;
    top_true_num = [0, 0, 0]
    top_true_num_delete = [0,0,0]
    test_size_delete = 0;
    top_true_num_insert = [0,0,0]
    test_size_insert = 0
    top_true_num_replace = [0,0,0]
    test_size_replace = 0
    top_true_num_trans = [0,0,0]
    test_size_trans = 0

    for word in words:
        if not word.isalpha():
            continue
        if test_size>=max_word:
            break

        test_size = test_size + 1
        word_mis, misspell_type = rand_misspell(word)
        predict_pair_list = search_tree.Candidate(word_mis) #[str, edit_dis]
        predict_list = [x[0] for x in predict_pair_list]
        match = top_n_is_true(word, predict_list, 3)
        top_true_num = [a+b for (a, b) in zip(top_true_num, match)]
        if misspell_type == 'deletion':
            test_size_delete  = test_size_delete + 1
            top_true_num_delete = [a+b for (a, b) in zip(top_true_num_delete, match)]
        elif misspell_type == 'insertion':
            test_size_insert = test_size_insert + 1
            top_true_num_insert = [a+b for (a, b) in zip(top_true_num_insert, match)]
        elif misspell_type == 'replacement':
            test_size_replace = test_size_replace + 1
            top_true_num_replace = [a+b for (a, b) in zip(top_true_num_replace, match)]
        elif misspell_type == 'transposition':
            test_size_trans = test_size_trans + 1
            top_true_num_trans = [a+b for (a, b) in zip(top_true_num_trans, match)]
        else:
            print('pass')
            pass
        print('word: %s ->%s'% (word, word_mis))
        print predict_list
        print match

    accu = [float(x)/test_size for x in top_true_num]
    accu_delete = [float(x)/test_size_delete for x in top_true_num_delete]
    accu_insert = [float(x)/test_size_insert for x in top_true_num_insert]
    accu_replace = [float(x)/test_size_replace for x in top_true_num_replace]
    accu_trans = [float(x)/test_size_trans for x in top_true_num_trans]

    #print('accu:%f \t delete:%f \t insert:%f \t replace:%f \t trans:%f'%(accu, accu_delete, accu_insert, \
    #                                                                     accu_replace, accu_trans))

    print accu
    print accu_delete
    print accu_insert
    print accu_replace
    print accu_trans
    sys.stdout = save_out
    print('test doc end')


if __name__ == '__main__':

    test_console_input()
    #test_vocabulary(1000)
    #test_doc(DATA_PATH+TEST_DOC_NAME)







