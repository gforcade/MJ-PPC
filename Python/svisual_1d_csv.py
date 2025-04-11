import csv
import numpy as np
import math
import sys
import string

class csv_plot:
    def __init__(self,y):
        self.y = y
        
    def find_limits(self):
        self.max_y = np.max(self.y)
        self.min_y = np.min(self.y)

# Class to read in a csv file containing a 1D cut of data from an sdevice simulation.
# data is generated in svisual using the line:
#    export_variables -dataset C1(${dataset}) -filename n@node@_1ddata.csv -overwrite
# The resulting instance will contain a member .plots which is a dict indexed by variable name.

class svis_1d_csv:
    def __init__(self, filename):
        with open(filename, 'rb') as csvfile:
           reader = csv.reader(csvfile)

           # create an empty dict 
           self.plots = dict()

           # The first line of the csv contains the column names
           names = reader.next()

           # skip the second line
           reader.next()
           # count total number of records in the file
           num_records = 0
           num_cols = len(names)
           while True:
               try:
                   row = reader.next()
                   if len(row) == num_cols:
                      num_records += 1

               # a StopIteration exception is generated when we try to read past the end of the file.
               except StopIteration:
                    break

           # allocate arrays for all variables, and output all available plot names
           print 'Number of Plots', len(names)
           for i in names:
                 self.plots[i] = csv_plot(np.zeros(num_records))
                 print i

           # return to start of the file
           csvfile.seek(0)

           # advance to third line
           reader.next(); reader.next()
           
           # Read datasets from CSV file and make a dict of csv_plots
           for k in xrange(num_records):
               row = reader.next()
               if len(row) == len(names):
                  for i in range(len(names)):
                      self.plots[names[i]].y[k] = float(row[i])

           # determine max an min of each variable                    
           for i in names:
               self.plots[i].find_limits()



    def set_x_variable(self, name):
        assert name in self.plots
        self.x_plot = self.plots[name]
