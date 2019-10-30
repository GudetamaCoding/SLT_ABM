###THIS IS A SCRIPT TO USE nlxr PACKAGE FOR NETLOGO MODEL STATISTICS AND DOCUMENTATION
#reference: Author(s) Jan Salecker jsaleck@gwdg.de 
# source code link: https://besjournals.onlinelibrary.wiley.com/action/downloadSupplement?doi=10.1111%2F2041-210X.13286&file=mee313286-sup-0001-suppinfo.pdf
# install the package if never
install.packages("nlrx")
##### bug solution unixtool
install.packages('unixtools', repos = 'http://www.rforge.net/')
library("unixtools")
unixtools::set.tempdir("C:/Users/yz7n15/RNetLogo script")
#######
# load the package nlrx 
library("nlrx")
?nlrx
## TAKE WOLF-SHEEP-PREDATION AS AN EXAMPLE HERE
#STEP 1: setup paths of model and create nl object


Sys.setenv(JAVA_HOME='C:/Program Files (x86)/Java/jre1.8.0_231/bin/java.exe')
setwd("C:/Users/yz7n15/RNetLogo script")
netlogopath <- file.path("C:/Program Files/NetLogo 6.0.4")
modelpath <- file.path(netlogopath, "app/models/Sample Models/Biology/Wolf Sheep Predation.nlogo")
outpath <- file.path("")
nl <- nl(nlversion = "6.0.4",
         nlpath = netlogopath,
         modelpath = modelpath,
         jvmmem = 1024)
#STEP 2: Attach an experiment
nl@experiment <- experiment(expname="wolf-sheep",
                            outpath=outpath,
                            repetition=1,
                            tickmetrics="true",
                            idsetup="setup",
                            idgo="go",
                            runtime=50,
                            evalticks=seq(40,50),
                            metrics=c("count sheep", "count wolves", "count patches with [pcolor = green]"),
                            variables = list('initial-number-sheep' = list(min=50, max=150, qfun="qunif"),
                                             'initial-number-wolves' = list(min=50, max=150, qfun="qunif")),
                            constants = list("model-version" = "\"sheep-wolves-grass\"",
                                             "grass-regrowth-time" = 30,
                                             "sheep-gain-from-food" = 4,
                                             "wolf-gain-from-food" = 20,
                                             "sheep-reproduce" = 4,
                                             "wolf-reproduce" = 5,
                                             "show-energy?" = "false"))
#STEP 3: Attach a simulation design
nl@simdesign <- simdesign_lhs(nl=nl,
                              samples=100,
                              nseeds=3,
                              precision=3)
#Step 4: Run simulations
results <- run_nl_all(nl = nl)
#Step 5: Attach results to nl and run analysis
# Attach results to nl object:
setsim(nl, "simoutput") <- results
# Write output to outpath of experiment within nl
write_simoutput(nl)
# Do further analysis:
analyze_nl(nl)

