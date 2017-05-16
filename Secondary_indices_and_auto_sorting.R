rm(list=ls())
flights <- fread("flights14.csv")
head(flights)

#b) Set secondary index

setindex(flights,origin)
head(flights)

#index will not sort the original data set. It outputs a vector containing indexing information.

names(attributes(flights))

#setindex() and setindexv() allows a secondary index to the data.table
#setindex£¨flights,NULL) will remove all indexes

indices(flights) #get all indecise

#there could be only 1 key at the most

##########################3# "on" argument and secondary indices (fast subsetting)

#a)fast subsets in i
flights["JFK", on = "origin"]

key(flights)
indices(flights) #origin is now an index but key

## alternatively
# flights[.("JFK"), on = "origin"] (or) 
# flights[list("JFK"), on = "origin"]

setindex(flights, origin)
flights["JFK", on = "origin", verbose = TRUE][1:5]
# on= matches existing index, using index
# Starting bmerge ...done in 0 secs
#    year month day dep_delay arr_delay carrier origin dest air_time distance hour
# 1: 2014     1   1        14        13      AA    JFK  LAX      359     2475    9
# 2: 2014     1   1        -3        13      AA    JFK  LAX      363     2475   11
# 3: 2014     1   1         2         9      AA    JFK  LAX      351     2475   19
# 4: 2014     1   1         2         1      AA    JFK  LAX      350     2475   13
# 5: 2014     1   1        -2       -18      AA    JFK  LAX      338     2475   21

flights[.("JFK", "LAX"), on = c("origin", "dest")][1:5]
#Subsetting by two indecise

# b) select in j

flights[.("LGA", "TPA"), .(arr_delay), on = c("origin", "dest")]
#return delay data that involve with origin LGA and dest TPA


#c)chaning 

flights[.("LGA", "TPA"), .(arr_delay), on = c("origin", "dest")][order(-arr_delay)]

#d)compute or do in j
flights[.("LGA", "TPA"), max(arr_delay), on = c("origin", "dest")]

#e) sub-assign by reference using := in j

flights[.(24L), hour := 0L, on = "hour"]
flights[, sort(unique(hour))]
#  [1]  0  1  2  3  4  5  6  7  8  9 10 11 12 13 14 15 16 17 18 19 20 21 22 23


#f) Aggregation using by


ans <- flights["JFK", max(dep_delay), keyby = month, on = "origin"]
head(ans)

#g) mult argument

flights[c("BOS", "DAY"), on = "dest", mult = "first"]

flights[.(c("LGA", "JFK", "EWR"), "XNA"), on = c("origin", "dest"), mult = "last"]

flights[.(c("LGA", "JFK", "EWR"), "XNA"), mult = "last", on = c("origin", "dest"), nomatch = 0L]


#####################3.Auto Indexing

set.seed(1L)
dt = data.table(x = sample(1e5L, 1e7L, TRUE), y = runif(100L))
print(object.size(dt), units = "Mb")

## have a look at all the attribute names
names(attributes(dt))
# [1] "names"             "row.names"         "class"             ".internal.selfref"

## run thefirst time
(t1 <- system.time(ans <- dt[x == 989L]))
#    user  system elapsed 
#   0.156   0.012   0.170
head(ans)
#      x         y
# 1: 989 0.5372007
# 2: 989 0.5642786
# 3: 989 0.7151100
# 4: 989 0.3920405
# 5: 989 0.9547465
# 6: 989 0.2914710

## secondary index is created
names(attributes(dt))
# [1] "names"             "row.names"         "class"             ".internal.selfref"
# [5] "index"

indices(dt)
# [1] "x"

## successive subsets
(t2 <- system.time(dt[x == 989L]))
#    user  system elapsed 
#   0.000   0.000   0.001
system.time(dt[x %in% 1989:2012])
#    user  system elapsed 
#   0.000   0.000   0.001

