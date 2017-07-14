# ! /usr/bin/env/ python2
# -*- coding:utf-8 -*-

LOG_PATH = './'
LOG_FILENAME = 'test_doc.log' #'top3_t2_basic_1.log'
def StatisticLog():
    data = open(LOG_PATH+LOG_FILENAME, 'rb')

    #data.readline()
    #data.readline()

    misspell_type_list = ['deletion', 'insertion', 'replacement', 'transposition']

    line = ''
    word_correct_len_add = [[0,0,0], [0,0,0], [0,0,0], [0,0,0]]
    word_correct_len_size = [[0,0,0], [0,0,0], [0,0,0], [0,0,0]]

    word_error_len_add = [[0,0,0], [0,0,0], [0,0,0], [0,0,0]]
    word_error_len_size = [[0,0,0], [0,0,0], [0,0,0], [0,0,0]]

    while True:
        misspell_type = data.readline().replace('\n', '');
        if misspell_type not in misspell_type_list:
            line = misspell_type
            break;
        misspell_type_idx = misspell_type_list.index(misspell_type)

        line = data.readline()
        words = line.split(' ')

        label = ''
        if len(words)<3:
            print('error occur')
            break
        else:
            label = words[0]

        label_len = len(label)

        data.readline()
        data.readline()
        match = eval(data.readline())

        for idx in range(0, 3):
            if match[idx]:
                word_correct_len_add[misspell_type_idx][idx] += label_len
                word_correct_len_size[misspell_type_idx][idx] += 1
            else:
                word_error_len_add[misspell_type_idx][idx] += label_len
                word_error_len_size[misspell_type_idx][idx] += 1

    top_correct_len_add = [0,0,0]
    top_correct_len_size = [0,0,0]
    top_error_len_add = [0,0,0]
    top_error_len_size = [0,0,0]

    for idx in range(0,4):
        top_correct_len_add[0] += word_correct_len_add[idx][0]
        top_correct_len_add[1] += word_correct_len_add[idx][1]
        top_correct_len_add[2] += word_correct_len_add[idx][2]
        top_error_len_add[0] += word_error_len_add[idx][0]
        top_error_len_add[1] += word_error_len_add[idx][1]
        top_error_len_add[2] += word_error_len_add[idx][2]

        top_correct_len_size[0] += word_correct_len_size[idx][0]
        top_correct_len_size[1] += word_correct_len_size[idx][1]
        top_correct_len_size[2] += word_correct_len_size[idx][2]

        top_error_len_size[0] += word_error_len_size[idx][0]
        top_error_len_size[1] += word_error_len_size[idx][1]
        top_error_len_size[2] += word_error_len_size[idx][2]


    print('correct')
    print [float(x)/y for (x,y) in zip(top_correct_len_add, top_correct_len_size)]
    print('error')
    print [float(x)/y for (x,y) in zip(top_error_len_add, top_error_len_size)]

if __name__ == '__main__':
    StatisticLog();

