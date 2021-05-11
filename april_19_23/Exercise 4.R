
# Sets the path to the parent directory of RR classes
setwd("C:\\Users\\whard\\OneDrive\\Desktop\\Reproducible research\\RR_classes\\RR_classes\\april_19_23")

#   Import data from the O*NET database, at ISCO-08 occupation level.
# The original data uses a version of SOC classification, but the data we load here
# are already cross-walked to ISCO-08 using: https://ibs.org.pl/en/resources/occupation-classifications-crosswalks-from-onet-soc-to-isco/

# The O*NET database contains information for occupations in the USA, including
# the tasks and activities typically associated with a specific occupation.

task_data = read.csv("Data\\onet_tasks.csv")
# isco08 variable is for occupation codes
# the t_* variables are specific tasks conducted on the job

# read employment data from Eurostat
# These datasets include quarterly information on the number of workers in specific
# 1-digit ISCO occupation categories. (Check here for details: https://www.ilo.org/public/english/bureau/stat/isco/isco08/)
library(readxl)                     

# Read all the sheets into one list
path <- "Data\\Eurostat_employment_isco.xlsx"
occupations <- excel_sheets(path)[-1]
num_occup <- length(occupations)
isco <- lapply(occupations, read_excel, path = path)

# Create one big data frame with all iscos
isco_all <- data.frame()
for (i in 1:num_occup) {
  df <- as.data.frame(isco[[i]])
  isco_all <- rbind(isco_all, df)
}

# Add Worker variable 
isco_all$Worker <- rep(seq(1,nrow(isco_all)/num_occup,1),num_occup)

# Add Occupation variable
isco_all$ISCO <- rep(1:num_occup, each=nrow(isco_all)/num_occup)

# We will focus on three countries, but perhaps we could clean this code to allow it
# to easily run for all the countries in the sample?
library(tidyverse)

# Worker totals for each country
worker_totals <- isco_all %>%
  select(3:(3 + num_occup)) %>%
  group_by(Worker) %>%
  summarise(across(everything(), sum)) %>%
  select(2:(num_occup + 1))

names(worker_totals) <- paste0("total_", names(worker_totals))

# Adding worker totals to the big data frame as new columns with rows repeated for each occupation
isco_all <- cbind(isco_all, worker_totals)

# Shares of each occupation among all workers in a period-country
shares <- isco_all[, 3:((3 - 1) + num_occup)] / isco_all[, names(isco_all) %in% names(worker_totals)]
names(shares) <- paste0("shares_", names(shares))
isco_all <- cbind(isco_all, shares)


# Now let's look at the task data. We want the first digit of the ISCO variable only
library(stringr)

task_data$isco08_1dig <- str_sub(task_data$isco08, 1, 1) %>% as.numeric()

# And we'll calculate the mean task values at a 1-digit level 
# (more on what these tasks are below)

aggdata <-aggregate(task_data, by=list(task_data$isco08_1dig),
                    FUN=mean, na.rm=TRUE)
aggdata$isco08 <- NULL

# We'll be interested in tracking the intensity of Non-routine cognitive analytical tasks
# Using a framework reminiscent of the work by David Autor.

# These are the ones we're interested in:
# Non-routine cognitive analytical
# 4.A.2.a.4 Analyzing Data or Information
# 4.A.2.b.2	Thinking Creatively
# 4.A.4.a.1	Interpreting the Meaning of Information for Others

#Let's combine the data.

combined <- left_join(isco_all, aggdata[,-1], by = c("ISCO" = "isco08_1dig"))

# Traditionally, the first step is to standardise the task values using weights 
# defined by share of occupations in the labour force. This should be done separately
# for each country. Standardisation -> getting the mean to 0 and std. dev. to 1.
# Let's do this for each of the variables that interests us:

#install.packages("Hmisc")
library(Hmisc)
library(data.table)
library(utils)

# Standarization of the mentioned 3 task items and all countries
for(task in c("t_4A2a4", "t_4A2b2", "t_4A4a1")){
  for(country in names(combined)[3:11]){
    task_values  <- combined[,task]
    share_values <- combined[,paste0("shares_", country)]
    temp_mean <- wtd.mean(task_values, share_values)
    temp_sd   <- wtd.var(task_values, share_values) %>% sqrt()
    temp_std  <- (task_values-temp_mean)/temp_sd
    
    combined  <- cbind(combined, temp_std)
    names(combined)[length(names(combined))] <- paste0("std_", country, "_", task)
  }
}

# The next step is to calculate the `classic` task content intensity, i.e.
# how important is a particular general task content category in the workforce
# Here, we're looking at non-routine cognitive analytical tasks, as defined
# by David Autor and Darron Acemoglu:

for(country in names(combined)[3:11]){
  std_col <- paste0("std_", country)
  country_tasks_sum <- rowSums(combined[, names(combined) %like% paste0("^", std_col)])
  combined  <- cbind(combined, country_tasks_sum)
  names(combined)[length(names(combined))] <- paste0(country, "_NRCA")
}


# And we standardise NRCA in a similar way.
for(country in names(combined)[3:11]){
  nrca_values  <- combined[,paste0(country, "_NRCA")]
  share_values <- combined[,paste0("shares_", country)]
  temp_mean <- wtd.mean(nrca_values, share_values)
  temp_sd   <- wtd.var(nrca_values, share_values) %>% sqrt()
  temp_std  <- (nrca_values-temp_mean)/temp_sd
  
  combined  <- cbind(combined, temp_std)
  names(combined)[length(names(combined))] <- paste0("std_", country, "_NRCA")
}

# Finally, to track the changes over time, we have to calculate a country-level mean
# Step 1: multiply the value by the share of such workers.
for(country in names(combined)[3:11]){
  std_nrca_values <- combined[,paste0("std_", country, "_NRCA")]
  share_values    <- combined[,paste0("shares_", country)]
  multi <- std_nrca_values*share_values
    
  combined  <- cbind(combined, multi)
  names(combined)[length(names(combined))] <- paste0("multip_", country, "_NRCA")
}

# Step 2: sum it up (it basically becomes another weighted mean)
aggregates <- combined %>%
  group_by(TIME) %>%
  summarise(across(starts_with(paste0("multip_")), sum)) 

aggregates_melt <- melt(aggregates, id.vars="TIME", 
                        variable.name="Country")

# We can plot it now!
ggplot(aggregates_melt, aes(x=TIME, y=value)) +
  geom_point() +
  facet_wrap(~Country, scales = "free") + 
  scale_x_discrete(breaks = 1)

# If this code gets automated and cleaned properly,
#  you should be able to easily add other countries as well as other tasks.
# E.g.:

# Routine manual
# 4.A.3.a.3	Controlling Machines and Processes
# 4.C.2.d.1.i	Spend Time Making Repetitive Motions
# 4.C.3.d.3	Pace Determined by Speed of Equipment

