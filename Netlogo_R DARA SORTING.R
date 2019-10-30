## 1. mport data and inspect data from Netlogo Behavior space
# First, be sure you export behavior space data from Netlogo in "table" format. 
test <- read.table("//filestore.soton.ac.uk/users/yz7n15/mydesktop/ABM-internal validation/0930 WORKING-ON-mixed-level-equilibrium experiment perturbation-breed number-table.csv",
                   header = T,  
                   sep = ',',        # define the separator between columns
                   skip = 6,         # 6 header rows we don't need
                   quote = "\"",     # correct the column separator
                   fill = T)         # add blank fields if rows have unequal length
str(test)

# select and rename columns. new_name = old name. 
# renaming everything I keep, so can rename with select
test <- test %>% 
  select(run_num = X.run.number.,                  # each run number is an experimental unit
         total_time = X.step.,                     # length of time the experiment ran
         total_nutrient = total.nutrient.concentration,      # total concentration varies between 0.15-0.65
         water_temperature = water.temperature,                      
         n_diatom = count.diatom,            
         n_cyanobacteria = count.cyanobacteria,           
         n_greenalgae = count.greenalgae,                
         n_submerged_macrophytes = count.submerged.macrophytes,           
         n_floating_plants = count.floating.plants,
         n_zooplankton = count.zooplankton ,
         n_planktivore_fishes = count.planktivore.fishes ,
         n_omnivore_fishes = count.omnivore.fishes ,
         n_herbivore_fishes = count.herbivore.fishes, 
         n_piscivores = count.piscivores ) # list of size for each ind for each time step
###-----------------------------------------------------------------------------------------------------------------
## 2. Extract parameter values-- these are the 'treatments' and inputs of the model for each run
# I'll rejoin the output data with params later, after some summarizing/processing
params <- test[,1:14]
params$total_nutrient_num <- params$total_nutrient
params$water_temperature_num <- params$water_temperature
params$total_nutrient <- as.factor(params$total_nutrient)
params$water_temperature <- as.factor(params$water_temperature)
#nutrient has 6 levels, between 0.15-0.65
levels(params$total_nutrient) <- c("low","low", "med","med","high", "high" )  
# temperature range: 12,16,20,24,28,32,36 
levels(params$water_temperature) <- c("cool", "cool", "temperate", "temperate", "warm", "warm", "hot")

###-----------------------------------------------------------------------------------------------------------------
## 3. Parse Individuals 
#The 'sizes_x' columns have a time series of size for each individual (so each 'sizes_x' column has 50 individuals x 150 time steps values). 
# First, separate so that each individual has it's own column
test <- test %>% 
  separate(n_diatom,                                      # separate n_diatom
           into = paste("d_", c(1:test$n_dfly), sep = ""),  # levels for new var
           sep = "]") %>%                                   # every ] marks a new ind
  separate(sizes_fish, 
           into = paste("f_", c(1:test$n_fish), sep = ""), 
           sep = "]")

# Next, I'll gather individuals so that they appear in rows
# I separate this step by species because it's easier for me to catch errors

## FIRST, DRAGONFLIES 
# Select only unique dfly individuals and gather to long format
test_dfly <- test %>%
  select(run_num, d_1:d_50) %>% 
  unique(.) %>% 
  gather(d_1:d_50, key = "dfly_id", value = 'size_dfly') %>% 
  arrange(run_num)

# Remove the brackets
test_dfly$size_dfly <- gsub("[", "", test_dfly$size_dfly, fixed = T)

## NEXT, FISH
# Select only unique fish individuals and gather to long format
test_fish <- test %>%
  select(run_num, f_1:f_50) %>% 
  unique(.) %>% 
  gather(f_1:f_50, key = "fish_id", value = 'size_fish') %>% 
  arrange(run_num)

# Remove the brackets
test_fish$size_fish <- gsub("[", "", test_fish$size_fish, fixed = T)