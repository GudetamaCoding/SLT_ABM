## Code source link: https://rpubs.com/shannon_carter/477440 
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
## NEXT, FISH
# Select only unique fish individuals and gather to long format
test_fish <- test %>%
  select(run_num, f_1:f_50) %>% 
  unique(.) %>% 
  gather(f_1:f_50, key = "fish_id", value = 'size_fish') %>% 
  arrange(run_num)

# Remove the brackets
test_fish$size_fish <- gsub("[", "", test_fish$size_fish, fixed = T)

###Parse Time Series
## FIRST, DRAGONFLIES 
# Separate the size time series- each space represents a new time point
test_dfly <- test_dfly %>% 
  separate(size_dfly, into = as.character(c(0:149)), sep = " ") %>% 
  select(-c(as.character(0))) # I drop this because there's only a value for ind 1

# Gather to long format, so we now have one line per dfly per time step
test_dfly <- test_dfly %>% 
  group_by(run_num) %>% 
  gather(as.character(1:149), key = "time", value = 'current_size_dfly') %>%
  arrange(run_num, dfly_id)

## NEXT, FISH
# Separate the size time series- each space represents a new time point
test_fish <- test_fish %>% 
  separate(size_fish, into = as.character(c(0:149)), sep = " ") %>% 
  select(-c(as.character(0))) # I drop this because there's only a value for ind 1

# Gather to long format, so we now have one line per dfly per time step
test_fish <- test_fish %>% 
  group_by(run_num) %>% 
  gather(as.character(1:149), key = "time", value = 'current_size_fish') %>%
  arrange(run_num, fish_id)

### Compile & Tidy
###Now, join the two species’ dataframes together, rejoin with the treatment information, and write a csv. This csv has one line per individual per time step. So nrow should be max(run_num) x (ndfly + nfish) x total_time
# Paste dfs together and remove redundant variables
test <- cbind(test_dfly, test_fish)
test <- test %>% 
  select(-c(run_num1, time1)) 

# This is clunkier than it needs to be, but allows some double checking
test$dfly <- paste(test$dfly_id, test$current_size_dfly)
test$fish <- paste(test$fish_id, test$current_size_fish)
test1 <- test %>% 
  select(run_num, time, dfly, fish)
test2 <- test1 %>% 
  gather(key = "species", "size", dfly, fish)
test2$time <- as.numeric(test2$time)

test2 <- test2 %>% 
  separate(size, into = c("id", "size"), sep = " ") %>% 
  separate(id, into = c("sp", "id"), sep = "_") %>% 
  select(-sp) %>% 
  arrange(run_num, id, time)
test2$size <- as.numeric(test2$size)

# Rejoin with treatment identifiers for each run number
test <- left_join(test2, params, by = "run_num")
ind_time <- test %>%
  select(run_num, n_fish, n_dfly, sync_fish, sync_dfly, mean_dfly,
         surv_fish, surv_dfly, time, species,
         id, size)

write.csv(ind_time, "individual_time.csv")

###Summarize by Individual
###Now, I want to make some summarised datasets. First with one row per individual, then with one row per run number
ind_time <- read.csv("individual_time.csv", header = T)

ind <- ind_time %>% 
  group_by(run_num, species, id, sync_fish, sync_dfly, mean_dfly, surv_dfly, surv_fish) %>%
  summarise(max_size = max(size),
            meta = if_else(max_size >= 10, 1, 0),
            hatch_date = min(time[size > 0]),
            # use base R ifelse here, so we can have 2 data types for T/F
            meta_date = ifelse(meta == 1, min(time[size >= 10]), NA), 
            death_date = ifelse(meta == 0, min(time[size = max(max_size)]), NA),
            growth_time = meta_date - hatch_date)

# Currently, number of metamorphs doesn't match raw data. think it might be a >= mismatch. check.
check <- ind %>% 
  group_by(run_num, species, surv_dfly, surv_fish) %>%
  summarise(no_meta = sum(meta))
ggplot(subset(check, subset = (species == "fish")), aes(x = surv_fish, y = no_meta)) +
  geom_point() + theme_bw() +
  geom_abline(slope = 1, intercept = 0)

###Summarize by Treatment
###Now, make a df with 1 row per unique treatment with means/se’s
trt <- params %>% 
  group_by(sync_dfly, mean_dfly, mean_dfly_num, sync_dfly_num) %>% 
  summarise(mean_surv_dfly = mean(surv_dfly),
            mean_surv_fish = mean(surv_fish),
            se_surv_dfly   = sd(surv_dfly)/sqrt(length(surv_dfly)),
            se_surv_fish   = sd(surv_fish)/sqrt(length(surv_fish)))

ind$sync_dfly <- factor(ind$sync_dfly, levels = c("low", "med", "high"))
ind$mean_dfly <- factor(ind$mean_dfly, levels = c("dfly v early", "dfly early", "same", "fish early", "fish v early"))
trt$sync_dfly <- factor(trt$sync_dfly, levels = c("low", "med", "high"))
trt$mean_dfly <- factor(trt$mean_dfly, levels = c("dfly v early", "dfly early", "same", "fish early", "fish v early"))

### Plots
