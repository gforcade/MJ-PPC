##  it makes a connecting to the SQL database and reads the last record,
##  then by comparing the last record with logged data, which would be in spreadsheet format,
##  it finds the latest logged data and then insert them to the desired SQL database and updates the table.
##  Just you need to create a simple macro, albeit in the testbed's PC, to run this code time by time (based on project's needs).

from datetime import datetime, timedelta
#import datetime
import time
import pytz
from pytz import timezone, utc
import urllib2
import calendar
import pyodbc
import csv
#from requests import session

# This script collects data from the Enphase Enlighten website for the
# past 7 full days.  
#
# 1. open Database connection and check time of most recent entry in database
# 2. download performance data file from Enlighten.  file is in JSON format which can be easily parsed to Python data structures.
# 3. convert data in JSON file to python lists
# 4. insert any new data points into the database table.

# requirements
#    python 2.6 or 2.7
#    pyodbc library (for SQL database access)
#    requests library (for http access)
#    pytz timezone handling library.

# ********* Configuration data ***************

# time zone of the system. Should match settings in Enlighten.
tz = timezone('US/Eastern')

# Database connection details
DB_connect_string = 'DRIVER={SQL Server Native Client 10.0};SERVER=J-PC\JAVADDB;DATABASE=logger;UID=sa;PWD=123'
db= 'logger'
DB_table = 'test1'
to_table = 'test1'
column = 'Date'

# ****** End config data ******

print '*** STC data logging'
print '*** for IDP', 

# open DB connection
dbconn = pyodbc.connect(DB_connect_string)
endRow = 'SELECT TOP 1 ' + column + ' FROM [' # Query template for ending row
lastRow_query = endRow + db + '].[dbo].' + DB_table + ' ORDER BY ' + column + ' DESC'
cursor = dbconn.cursor()
rowdb=dbconn.cursor().execute(lastRow_query).fetchone()

print"Script has successfully run!"

max_time = rowdb[0].replace(tzinfo=utc).astimezone(tz)
max_date = max_time.date().isoformat()
current_date = datetime.now(tz=tz).date()
print "latest timestamp in DB: ", max_time

with open("C:\Users\Javad\Desktop\dat.csv", 'rb') as f:  #import the required modules
    reader = csv.reader(f, delimiter=',')
    count=0 #variable of the date "number"
    for row in reader:
        if row[0] !="Dispatch date":  # we don't want to include the first line of the first column
##            date = datetime.datetime.strptime (row [0],"%Y-%m-%d %H:%M:%S") #creating the datetime object with the string agrument
            date = row [0]
            if date > max_time.isoformat(): #loop to calcul if the date is correct or not
                cursor.execute("insert into " + to_table + "( Date, Value) " +
                                    "values (?, ?)", date, row [2]) # this part extendable based on project's needs
                print ("Matched date is") , date   # Display the matched date 
                print ("Row is:"), row [2], "%"   #Display the row
                count = count+1     #increment the date
cursor.close()
dbconn.commit()
dbconn.close()
