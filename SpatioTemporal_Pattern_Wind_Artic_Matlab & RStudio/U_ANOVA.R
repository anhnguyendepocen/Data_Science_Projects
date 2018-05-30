# Clear all variables
rm(list=ls(all=TRUE)) 

# Clear previous plots
graphics.off()

# get working directory
getwd()
# set working directory
setwd("C:/Babak/BackUp_Sep_29_2012/By Date/March 16_ 2013_ An excellent restart/Bel-Akhareh-dorost-mishe/2013/May 28/Wind_Model _Babak/R coding")


#read the dataset into an R variable using the read.csv(file) function
U_GLM=read.csv("U_GLM.csv",header=TRUE)
U_GLM=as.matrix(U_GLM)

#read the dataset into an R variable using the read.csv(file) function
U_Year=read.csv("U_Year.csv",header=TRUE)
U_Year=as.data.frame(U_Year)

#Testing the omnibus hypothesis
#Main effects and interaction effects 


Lat2=U_Year[,c(1)]
Lat2=as.matrix(Lat2)


Lng2=U_Year[,c(2)]
Lng2=as.matrix(Lng2)

U.1980=U_Year[,c(3)]
U.1980=as.matrix(U.1980)
U.1987=U_Year[,c(4)]
U.1987=as.matrix(U.1987)
U.1992=U_Year[,c(5)]
U.1992=as.matrix(U.1992)
U.2002=U_Year[,c(6)]
U.2002=as.matrix(U.2002)
U.2009=U_Year[,c(7)]
U.2009=as.matrix(U.2009)


Year=U_GLM[,c(2)]
Year=as.matrix(Year)

Lat=U_GLM[,c(3)]
Lat=as.matrix(Lat)

Lng=U_GLM[,c(4)]
Lng=as.matrix(Lng)


#U.all=U[,c(3:7)]
#U.all=as.matrix(U.all)
# U.all=as.numeric(U.all)

# General Linear Model of U=f(lat,Lng, Year)
glm_babak=glm(U_GLM~Lat+Lng+Year+Lat*Lng+Lat*Year+Lng*Year)
summary(glm_babak)

# Boxplots
# Box plots
#Use this command to draw seperate plots into one. I like this one!#
par(mfrow=c(3,2))

boxplot(U~Lat, las=1,  
        col=rainbow(11), main="Box-whiskers of all-years zonal surface wind versus latitudes at different years", 
        xlab="Latitude(°N)", ylab="Zonal wind speed(m/s)", cex.lab=1.25, U_GLM)

boxplot(U.1980~Lat2, las=1,  
        col=rainbow(11), main="Box-whiskers of 1980 zonal surface wind versus latitudes at different years", 
        xlab="Latitude(°N)", ylab="Zonal wind speed(m/s)", cex.lab=1.25, U_Year)

boxplot(U.1987~Lat2, las=1,  
        col=rainbow(11), main="Box-whiskers of 1987 zonal surface wind versus latitudes at different years", 
        xlab="Latitude(°N)", ylab="Zonal wind speed(m/s)", cex.lab=1.25, U_Year)

boxplot(U.1992~Lat2, las=1,  
        col=rainbow(11), main="Box-whiskers of 1992 zonal surface wind versus latitudes at different years", 
        xlab="Latitude(°N)", ylab="Zonal wind speed(m/s)", cex.lab=1.25, U_Year)

boxplot(U.2002~Lat2, las=1,  
        col=rainbow(11), main="Box-whiskers of 2002 zonal surface wind versus latitudes at different years", 
        xlab="Latitude(°N)", ylab="Zonal wind speed(m/s)", cex.lab=1.25, U_Year)

boxplot(U.2009~Lat2, las=1,  
        col=rainbow(11), main="Box-whiskers of 2009 zonal surface wind versus latitudes at different years", 
        xlab="Latitude(°N)", ylab="Zonal wind speed(m/s)", cex.lab=1.25, U_Year)

#subplot(2,1,2)
par(mfrow=c(3,2))
boxplot(U~Lng, las=1,  
        col=rainbow(144), main="Box-whiskers of zonal surface all-years winds versus longitudes at different years", 
        xlab="Latitude(°Positive relative to Greenwich Meridian (0° longitude))", ylab="Zonal wind speed(m/s)", cex.lab=1.25, U_GLM)

boxplot(U.1980~Lng2, las=1,  
        col=rainbow(144), main="Box-whiskers of zonal surface 1980 winds versus longitudes at different years", 
        xlab="Latitude(°Positive relative to Greenwich Meridian (0° longitude))", ylab="Zonal wind speed(m/s)", cex.lab=1.25, U_GLM)

boxplot(U.1987~Lng2, las=1,  
        col=rainbow(144), main="Box-whiskers of zonal surface 1987 winds versus longitudes at different years", 
        xlab="Latitude(°Positive relative to Greenwich Meridian (0° longitude))", ylab="Zonal wind speed(m/s)", cex.lab=1.25, U_GLM)

boxplot(U.1992~Lng2, las=1,  
        col=rainbow(144), main="Box-whiskers of zonal surface 1992 winds versus longitudes at different years", 
        xlab="Latitude(°Positive relative to Greenwich Meridian (0° longitude))", ylab="Zonal wind speed(m/s)", cex.lab=1.25, U_GLM)

boxplot(U.2002~Lng2, las=1,  
        col=rainbow(144), main="Box-whiskers of zonal surface 2002 winds versus longitudes at different years", 
        xlab="Latitude(°Positive relative to Greenwich Meridian (0° longitude))", ylab="Zonal wind speed(m/s)", cex.lab=1.25, U_GLM)

boxplot(U.2009~Lng2, las=1,  
        col=rainbow(144), main="Box-whiskers of zonal surface 2009 winds versus longitudes at different years", 
        xlab="Latitude(°Positive relative to Greenwich Meridian (0° longitude))", ylab="Zonal wind speed(m/s)", cex.lab=1.25, U_GLM)
