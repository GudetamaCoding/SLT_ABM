# environment setup
install.packages("RNetLogo")
Sys.setenv(NOAWT=1) 
library(RNetLogo)
n1.path <- "C:/Program Files/NetLogo 6.0.4/app"
NLStart (n1.path, nl.jarname= "netlogo-6.0.4.jar")

# choose model to open
model.path <- "/models/Sample Models/Biology/Evolution/Bacterial Infection.nlogo"
NLLoadModel( paste( n1.path, model.path, sep="" ))
NLCommand("setup")

# quit
NLQuit()

### example code
## Not run: 
library(RNetLogo)
nl.path <- "C:/Program Files/NetLogo 6.0.4/app"
NLStart(nl.path)
NLCommand("create-turtles 10")
noturtles <- NLReport("count turtles")
print(noturtles)

# create a second NetLogo instance in headless mode (= without GUI) 
# stored in a variable
nlheadless1 <- "nlheadless1"
NLStart(nl.path, gui=F, nl.obj=nlheadless1)
model.path <- "/models/Sample Models/Earth Science/Fire.nlogo"
NLLoadModel(paste(nl.path,model.path,sep=""), nl.obj=nlheadless1)
NLCommand("setup", nl.obj=nlheadless1)
burned1 <- NLDoReport(20, "go", c("ticks","burned-trees"), 
                      as.data.frame=TRUE,df.col.names=c("tick","burned"), 
                      nl.obj=nlheadless1)
print(burned1)

# create a third NetLogo instance in headless mode (= without GUI) 
# with explicit name of stored object
nlheadless2 <- "nlheadless2"
NLStart(nl.path, gui=F, nl.obj=nlheadless2)
model.path <- "/models/Sample Models/Earth Science/Fire.nlogo"
NLLoadModel(paste(nl.path,model.path,sep=""), nl.obj=nlheadless2)
NLCommand("setup", nl.obj=nlheadless2)
burned2 <- NLDoReport(10, "go", c("ticks","burned-trees"), 
                      as.data.frame=TRUE,df.col.names=c("tick","burned"), 
                      nl.obj=nlheadless2)
print(burned2)               

## End(Not run)
###