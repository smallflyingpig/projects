### intro
This project is for English Spell Correction based on python 2.7.

### dependencies
python 2.7 (3.0 may be not OK)

import random
import copy
import string
import re
import sys
import numpy as np

### how to run
1. change current fold to 'EnglishTextProfreading'
2. open 'proofreading.py'
3. run 'proofreading.py'
4. by default, it is console test. that is input a word and output the top 3 candidates
5. change the main function to switch other test mode
6. when the proofreading is running, it will write the log to file 'test_log.log', you can run 'Statistic.py' to analysis the log.

### file
proofreading.py: test the algorothm
Data.py: read the vocabulary
Distance.py: calculate the edit distance and cut-off diatance
searchTree.py: difinitin for class 'SearchTree'
Statistic.py: analysis the log

### author

lijiguo

### email

lijiguo16@mails.ucas.ac.cn

### data
20170713

### specific

CSDN: smallflyingpig
