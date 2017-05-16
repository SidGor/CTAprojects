######### Efficient Reshaping Using Data.Tables

#Discuss about melt (wide to long) and dcast(long to wide) functions
rm(list=ls())
setwd("C:/Users/sida/Desktop/¡Ë‘∆÷¡…∆/week 1/R-Training2016-master/class5-data.table")
DT = fread("melt_default.csv")
DT
## dob stands for date of birth.

str(DT)

DT.m1 <- melt(DT,id.vars = c("family_id","age_mother"), 
                measure.vars = c("dob_child1","dob_child2","dob_child3"))

DT.m1

#Now this function is just saying "Keep the family id and age of mother (id.vars), and show dob of children 
#base on the var keys.

str(DT.m1)


#if you want to put some name

DT.m1 = melt(DT, measure.vars = c("dob_child1", "dob_child2", "dob_child3"),
             variable.name = "child", value.name = "dob")
DT.m1

#When neither id.vars nor measure.vars are specified, as mentioned under ?melt,
#all non-numeric, integer, logical columns will be assigned to id.vars.

#b) Casting data.tables (long to wide)

dcast(DT.m1, family_id + age_mother ~ child, value.var = "dob")



DT = fread("melt_enhanced.csv")
DT
## 1 = female, 2 = male

DT.m1 = melt(DT, id = c("family_id", "age_mother"))
DT.m1

DT.m1[, c("variable", "child") := tstrsplit(variable, "_", fixed = TRUE)]
DT.m1

DT.c1 = dcast(DT.m1, family_id + age_mother + child ~ variable, value.var = "value")
DT.c1

str(DT.c1) ## gender column is character type now!
### went through a lot of troubles if we want to do it in previous scale

###3. Enhanced functionality

#a) Enhanced melt

#how do you melt multiple columns? use vectors

colA = paste("dob_child",1:3,sep="")
colA
colB = paste("gender_child",1:3,sep="")
DT.m2 = melt(DT,measure = list (colA,colB),value.name = c("dob","gender"))# using list to do it!
DT.m2
str(DT.m2)

#-Using patterns()
#or do it using this way
DT.m2 = melt(DT,measure = patterns("^dob","^gender"),value.name = c("dob","gender"))
DT.m2

#b)Enhanced dcast

DT.c2 = dcast(DT.m2, family_id + age_mother ~variable,value.var = c("dob","gender"))
DT.c2
DT.m2
