#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Wed Jun 27 11:36:08 2018

@author: luis.dealba
"""
#import os

#_DEFAULT_DATA_FOLDER = './resources/clients'
#_DEFAULT_CONNECTION = 'JSON'
#_PROBABILITY_OF_SELECTION = .99

#os.chdir('/Users/luis.dealba/X/de-training/alimazon/tools')


import glob
import json_lines
import random

class clientSampler:
    
    args = {}
    idList = []
    index = 0
    listSize = 0
    
    def __init__(self, data_folder, connection_type, probability):
        self.args = {
            'data_folder': data_folder,
            'connection_type': connection_type,
            'probability': probability }
        
    def _getFiles(self, fDirectory):
        fList = [f for f in glob.glob(fDirectory + "/*.jsonl.gz")]
        return fList


    def _parseFiles(self, fList):
        idList = []
        for fName in fList:
            with json_lines.open(fName) as f:
                for item in f:
                    idList.append(item['id'])
        return idList
        
    def load(self):
        if(self.args['connection_type']=='JSON'):
            fList = self._getFiles(self.args['data_folder'])
            self.idList = self._parseFiles(fList)
            self.listSize = len(self.idList)
        # implement load on SQLite DB
    
    def sample(self):
        while(random.random()>self.args['probability']):
            self.index += 1
        if (self.index < self.listSize):
            self.index += 1
            return self.idList[self.index]
        else:
            self.index = 0
        
                    
            
    