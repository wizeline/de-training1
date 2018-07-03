#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Wed Jun 27 11:36:08 2018

@author: luis.dealba
"""
#import os

#_DEFAULT_DATA_FOLDER = './resources/products'
#_DEFAULT_CONNECTION = 'JSON'
#_PROBABILITY_OF_SELECTION = .99

#os.chdir('/Users/luis.dealba/X/de-training/alimazon/tools')


import glob
import random
import csv
import gzip

class productSampler:
    
    args = {}
    procFiles = {}
    productList = []
    listSize = 0
    
    def __init__(self, data_folder):
        self.args = {
            'data_folder': data_folder }
        
    def _getFiles(self, fDirectory):
        fList = [f for f in glob.glob(fDirectory + "/*.tsv.gz")]
        return fList

    def _detectNewFiles(self, fList):
        for f in fList:
            if f not in self.procFiles.keys():
                self.procFiles[f]=1

    def _parseFiles(self):
        for fName in self.procFiles:
            if(self.procFiles[fName]):
                with gzip.open(fName, 'rt') as f:
                    reader = csv.reader(f, delimiter='\t')
                    for row in reader:
                        self.productList.append(row[0])
                self.procFiles[fName] = 0
        
    def load(self):
        fList = self._getFiles(self.args['data_folder'])
        self._detectNewFiles(fList)
        self._parseFiles()
        self.listSize = len(self.productList)
    
    def sample(self, sampleSize=0):
        if sampleSize == 0:
            elements = random.randint(1,1000)
        else:
            elements = sampleSize
        p = random.sample( self.productList, min(elements,self.listSize) )
        return p
        
                    
            
    