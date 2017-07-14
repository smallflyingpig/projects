# ! /usr/bin/env/ python2
# -*- coding:utf-8 -*-

import copy
import  Distance
START = ''

class Node:
    def __init__(self, key, end_flag = False):
        self.m_child = [];
        self.m_end_flag = end_flag;
        self.m_key = key

    def AddChild(self, node):
        if type(node) == 'Node':
            self.m_child.appendix(node)
        else:
            self.m_child.appendix(Node(node))

    def AddUniqueChild(self, node, change_end_flag = False):
        find_flag, find_idx = self.FindChild(node)

        if find_flag:
            cur_node = self.m_child[find_idx]
            if change_end_flag:
                self.m_child[find_idx].m_end_flag = node.m_end_flag

        else:
            self.m_child.append(node)
            cur_node = self.m_child[-1]

        return cur_node


    def FindChild(self, node):
        find_flag = False;
        find_idx = 0
        for idx in range(0, len(self.m_child)):
            child = self.m_child[idx]
            if node.m_key == child.m_key:
                find_flag = True;
                find_idx = idx
                break

        return find_flag, find_idx

class Pair:
    def __init__(self, node, str, dis):
        self.m_node = node
        self.m_str = str
        self.m_dis = dis


class SearchTree:
    def __init__(self):
        self.m_root = Node(START);

    def construct(self, vocabulary):
        vocabulary_temp = copy.deepcopy(vocabulary)
        vocab_len = len(vocabulary_temp)
        if vocab_len == 0:
            return

        word_len_list = []
        for word in vocabulary_temp:
            word_len_list.append(len(word))

        word_len_max = max(word_len_list)

        for idx in range(0, word_len_max):
            for word in vocabulary_temp:
                word_len = len(word)
                cur_node = self.m_root;
                for word_idx in range(0, word_len-1):
                    cur_node = cur_node.AddUniqueChild(Node(word[word_idx]))

                cur_node.AddUniqueChild(Node(word[-1],end_flag=True), change_end_flag=True);

    def Trace(self):
        self._Trace(self.m_root);

    def _Trace(self, node):
        print node.m_key;

        for child in node.m_child:
            self._Trace(child)

    def Candidate(self, target, top=3, threshold=2):
        candidate_list = []#node string edit_dis

        recoder_list = []
        recoder_list.append([self.m_root, self.m_root.m_key])

        while True:
            if len(recoder_list) == 0:
                break

            [cur_node, str] = recoder_list.pop()

            cut_off_distance_list = []#distance, string
            for child in cur_node.m_child:
                str_temp = str+child.m_key
                cut_off_distance = Distance.CutOffDistance(target, str_temp, threshold)
                if cut_off_distance<=threshold:
                    cut_off_distance_list.append([cut_off_distance, str_temp])
                    recoder_list.append([child, str_temp])

                if child.m_end_flag:
                    edit_distance = Distance.EditDistance(target, str_temp)
                    candidate_list.append([child, str_temp, edit_distance]);


        #sort
        candidate_list.sort(key=lambda d:d[2])

        for candidate in candidate_list:
            if candidate[2]>threshold:
                candidate_list.remove(candidate)

        rtn_len = 0
        if len(candidate_list)>top:
            rtn_len = top
        else:
            rtn_len = len(candidate_list)

        rtn_list = []
        for idx in range(0, rtn_len):
            if candidate_list[idx][2]<threshold:
                #print(candidate_list[idx])
                rtn_list.append([candidate_list[idx][1], candidate_list[idx][2]])

        return rtn_list




