U=read.csv("U.csv")
fix(U)
attach(U)

boxplot(Obs.Percent.R.V~State.Name, las=1,  
        col=rainbow(54), main="Box-whiskers for restriced PM monitors with 75% coverage cut-off criteria over the United States", 
  	 xlab="State Name", ylab=" Annaul coverage percentage of all working monitors ", cex.lab=1.25)


# identify(Arithmetic.Mean~rep(1,length(Arithmetic.Mean)), n=1, labels="POC")

