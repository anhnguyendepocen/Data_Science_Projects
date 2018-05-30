# get working directory
getwd()
# set working directory
setwd("C:/Babak/BackUp_Sep_29_2012/By Date/March 16_ 2013_ An excellent restart/Bel-Akhareh-dorost-mishe/2013/June 03/PM_Model_Babak/R coding")


library(lattice)
my.wines = read.csv("wine.csv",header=T)

# Look at the correlations

library(gclus) # There is no such a library

my.abs = abs(cor(my.wines))
my.colors = dmat.color(my.abs)
my.ordered = order.single(cor(my.wines))
cpairs(my.wines,my.ordered,panel.colors=my.colors,gap=.5)

# Do the PCA 

my.prc = prcomp(my.wines,center=T,scale=T)
screeplot(my.prc,main="Scree Plot",xlab="Components")
screeplot(my.prc,type="line",main="Scree Plot")

# DotPlot PC1

load = my.prc$rotation
sorted.loadings = load[order(load[,1]),1]
Main="Loadings Plot for PC1" 
xlabs="Variable Loadings"
dotplot(sorted.loadings,main=Main,xlab=xlabs,cex=1.5,col="red")

# DotPlot PC2

sorted.loadings = load[order(load[,2]),2]
Main="Loadings Plot for PC2"
xlabs="Variable Loadings"
dotplot(sorted.loadings,main=Main,xlab=xlabs,cex=1.5,col="red")

# Now draw the BiPlot

biplot(my.prc,cex=c(1,0.7))

# Apply the Varimax Rotation

my.var = varimax(my.prc$rotation)

