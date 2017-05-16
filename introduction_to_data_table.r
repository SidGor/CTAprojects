rm(list=ls())

getwd()
setwd(paste(getwd(),"/data",sep=""))
flights<-fread("flights14.csv")
flights

flights[origin == "JFK" & month == 6L]  #changing i (where option)


#Sort flights first by column origin in ascending order, and then by dest in descending order:
ans <- flights [order(origin,-dest)]


#select a column but return it as a vector
ans <- flights [,arr_delay]
class(ans)
typeof(ans)
is.data.table(ans)

#select multiple columns
ans <- flights[, .(arr_delay, dep_delay)]
head(ans)
# or use ans <- flights[,list(arr_delay,dep_delay)]

#select and rename (just like how you name a list)

ans <- flights[,.(delay_arr = arr_delay,delay_dep =dep_delay)]

#Compute or do in j
#how many trips have had total delay <0
ans <- flights[,sum((arr_delay+dep_delay)<0)]


#subset and do

#calculate the average arrival and departure delay for all flights with "JFK" as origin in June.

ans <- flights[origin == "JFK" & month == 6L,.(m_arr = mean(arr_delay),m_dep = mean(dep_delay))]

#how many trips depart from JFK in June

ans <- flights[origin == "JFK" & month == 6L, length(dest)]

#same as using the special build in "count" function

ans == flights [origin == "JFK" & month == 6L, .N]  #.N holds the number of observations in the current group.

#how to use column names directly just as in data.frame

flights[,c("arr_delay","dep_delay"),with = FALSE]

#exclude ceratin columns by using "!" or "-"
flights[,!c("arr_delay","dep_delay"),with = FALSE]
flights[,-c("arr_delay","dep_delay"),with = FALSE]

#also we could use ":" to range operate it.

flights[,year:day,with = FALSE]

#Aggregations - grouping via "by"
ans <- flights [,.(.N),by = origin] #by = "origin", by= .(origin) also works

flights[,.N,by=origin]

#trips by origin and carrier code AA
flights[carrier == "AA",.N,by =origin]

#multiple by

flights[carrier == "AA",.N,by=.(origin,dest)]

#keyby, special ordering that is not original settings.

ans <- flights[carrier == "AA",
               .(mean(arr_delay), mean(dep_delay)),
               keyby = .(origin, dest, month)]
ans

#chaining expressions
ans <- flights[carrier == "AA", .N, by = .(origin, dest)][order(origin, -dest)] #group by first, and chain the sorting process
head(ans, 10)

#expressions in by arguments: looking for flights that depart late but arrive early or other situations.
ans <- flights[, .N, .(dep_delay>0, arr_delay>0)]
ans

#multiple columns in j - .SD
DT = data.table(ID = c("b","b","b","a","a","c"), a = 1:6, b = 7:12, c = 13:18)
DT[, lapply(.SD, mean), by = ID]


flights[carrier == "AA",                       ## Only on trips with carrier "AA"
        lapply(.SD, mean),                     ## compute the mean
        by = .(origin, dest, month),           ## for every 'origin,dest,month'
        .SDcols = c("arr_delay", "dep_delay")] ## for just those specified in .SDcols
  

#display first two rows for each month 
flights[,head(.SD,2),by = month]
