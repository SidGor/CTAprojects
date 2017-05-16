rm(list=ls())
flights <- fread("flights14.csv")
flights


DF = data.frame(ID = c("b","b","b","a","a","c"), a = 1:6, b = 7:12, c = 13:18)
DF

#add/update/delete columns by reference

#a)adding columns:
flights[,`:=`(speed = distance/(air_time/60),             #speed in mph
              delay = arr_delay + dep_delay)]             #delay in min

flights

#using the 'LHS := RHS' form
# flights[, c("speed", "delay") := list(distance/(air_time/60), arr_delay + dep_delay)]
#We  don't have to assign the functions back to flights, the change has been done.

#Replace the rows where hour == 24 with the value 0

flights[hour == 24, hour := 0L]

# check again for '24'
flights[, sort(unique(hour))]
#  [1]  0  1  2  3  4  5  6  7  8  9 10 11 12 13 14 15 16 17 18 19 20 21 22 23


#Delete columns
flights[,c("delay") := NULL]
#same as flights[,delay := NULL] when there is only one line to delete

#  ":=" along with grouping using "by"
# allocate the max speed for each group of origin-destination
flights[, max_speed := max(speed), by = .(origin, dest)]
flights

#what if we want to allocate multiple max columns
in_cols = c("dep_delay","arr_delay")
out_cols = c("max_dep_delay","max_arr_delay")
flights[,c(out_cols) := lapply(.SD,max), by = month, .SDcols = in_cols] #SD出现的时候需要有SDcols来搭配，主要是进行多个列的运算


# RHS gets automatically recycled to length of LHS
flights[, c("speed", "max_speed", "max_dep_delay", "max_arr_delay") := NULL]


#":=" & copy()  COPY is a deep copy method so that it creats "DT" inside the function, any further
#alteration caused by ":=" will not affact the original input.

foo <- function(DT) {
  DT <- copy(DT)                              ## deep copy
  DT[, speed := distance / (air_time/60)]     ## doesn't affect 'flights'
  DT[, .(max_speed = max(speed)), by = month]
}