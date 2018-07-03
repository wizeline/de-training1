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
    procFiles = {}
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

    def _detectNewFiles(self, fList):
        for f in fList:
            if f not in self.procFiles.keys():
                self.procFiles[f]=1

    def _parseFiles(self):
        for fName in self.procFiles:
            if(self.procFiles[fName]):
                with json_lines.open(fName) as f:
                    for client in f:
                        self.idList.append(client['id'])
                self.procFiles[fName] = 0
        
    def load(self):
        if(self.args['connection_type']=='JSON'):
            fList = self._getFiles(self.args['data_folder'])
            self._detectNewFiles(fList)
            self._parseFiles()
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
        
                    
            
    