# ! /usr/bin/env/ python2
# -*- coding:utf-8 -*-
# prepare data


def ReadData(path, filename):
    content = ''
    with open(path+filename) as data:
        content = data.read()

    lines = content.split('\n')

    vocabulary = []
    for word in lines:
        if word.encode('utf-8').isalpha():
           vocabulary.append(word)
        else:
            print(word)

    return vocabulary
