# Data.Table Keys and fast binary search based subset
library(data.table)
rm(list = ls())

setwd("D:/Rdata")
flights <- fread("flights14.csv")

#####Keys#####
#data.frame example
set.seed(1L)
DF = data.frame(ID1 = sample(letters[1:2],10,TRUE),
                ID2 = sample(1:3,10,TRUE),
                val = sample(10),
                stringsAsFactors = FALSE,
                row.names = sample(LETTERS[1:10]))

DF

rownames(DF)
DF["C",]
#Rownames should be unique
rownames(DF) = sample(LETTERS[1:5], 10, TRUE)  #hence here comes the error

DT = as.data.table(DF)
DT
rownames(DT)

# b) set,get and use keys on a data.table
setkey(flights,origin)
head(flights)
## alternatively we can provide character vectors to the function 'setkeyv()'
# setkeyv(flights, "origin") # useful to program with (like paste(something))

#once you key the data.table through certain column, you can use the keys to subset data

flights[.("JFK")]
flights["JFK"]
flights[c("JFK","LGA")]  ##same as flights[.("JFK")]

#want to check what keys do you have?

key(flights)

#c)keys and multiple columns

setkey(flights,origin,dest)
head(flights)

#you see, set functions will always sort data by the key you choose, in the input order

key(flights)


#subsetting multiple key data.table

flights[.("JFK","MIA")]


#Subset all rows where just the second key column dest matches "MIA"
flights[.(unique(origin),"MIA")]

######COMBINING KEYS WITH "j" and "by"
#a)select j
#rturn certain column that originate from LGA and land on TPA
key(flights)
flights[.("LGA","TPA"),.(arr_delay)]   # .() operator tells data.table to search


# b)Chaning

#applying chaning to re-order the columns
flights[.("LGA","TPA"),.(arr_delay)][order(-arr_delay)]

#c)compue or do j
flights[.("LGA","TPA"),max(arr_delay)]

#d)sub-assign by reference using := in j

#get all 'hours' in flight:
flights[,sort(unique(hour))]

setkey(flights,hour)
key(flights)  #interesting, the origin,dest key will be removed
flights[.(24),hour := 0L]

key(flights)   #and the hour key has been cancelled

flights[,sort(unique(hour))]

# e)aggregation using by 
setkey(flights,origin,dest)
key(flights)

#get the maximum departure delay for each month corresponding to origin = "JFK". Order the result by month
ans <- flights["JFK",max(dep_delay),keyby = month]
key(ans)




#################Additional Arguments - mult and nomatch####################

#a)mult
#you can choose to return all, first or last row(s) by altering mult argument.
flights[.("JFK","MIA"),mult = "first"]
flights[.(c("LGA","JFK","EWR"),"XNA"),mult = "last"]

#####    IMPORTANT : "JFK","XNA" combination doesn't exists but still got printed with lots of NAs

#b) nomatch argument
# This is for you to skip the important note above, you can choose to show NA as above or just skip them
flights[.(c("LGA", "JFK", "EWR"), "XNA"), mult = "last", nomatch = 0L]
#Now you don't have the JFK-XNA line
#default of nomatch is NA

#################4)Binary search vs vector scans.#######################

#instead of :
flights[.("JFK","MIA")]
#you can use below (old schools):
flights[origin == "JFK" & dest == "MIA"]

#why not? Binary search is way faster!

#Let's test with 20 million rows of data
set.seed(2L)
N = 2e7L
DT = data.table(x = sample(letters, N, TRUE),
                y = sample(1000L, N, TRUE),
                val = runif(N), key = c("x", "y"))
print(object.size(DT), units = "Mb")
key(DT)

t1 <- system.time(ans1 <- DT[x == "g" & y == 877L])
t1
head(ans1)
dim(ans1)


## (2) Subsetting using keys
t2 <- system.time(ans2 <- DT[.("g", 877L)])
t2

head(ans2)
#    x   y       val
# 1: g 877 0.3946652
# 2: g 877 0.9424275
# 3: g 877 0.7068512
# 4: g 877 0.6959935
# 5: g 877 0.9673482
# 6: g 877 0.4842585
dim(ans2)
# [1] 761   3

identical(ans1$val, ans2$val)
# [1] TRUE

#说到底就是用二分法跳过了搜索过程，所以快多了。
