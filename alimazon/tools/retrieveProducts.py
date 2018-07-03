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
import random
import csv

class productSampler:
    
    args = {}
    productList = []
    listSize = 0
    
    def __init__(self, data_folder):
        self.args = {
            'data_folder': data_folder }
        
    def _getFiles(self, fDirectory):
        fList = [f for f in glob.glob(fDirectory + "/*.tsv")]
        return fList


    def _parseFiles(self, fList):
        pList = []
        for fName in fList:
            with open(fName, 'r') as f:
                reader = csv.reader(f, delimiter='\t')
                for row in reader:
                    pList.append(row[0])
        return pList
        
    def load(self):
        fList = self._getFiles(self.args['data_folder'])
        self.productList = self._parseFiles(fList)
        self.listSize = len(self.productList)
    
    def sample(self, sampleSize=0):
        if sampleSize == 0:
            elements = random.randint(1,1000)
        else:
            elements = sampleSize
        p = random.sample( self.productList, min(elements,self.listSize) )
        return p
        
                    
            
    