library(tidyverse)
library(neuralnet)
library(here)

source(here("R/functions.R"))


df_nn <- read_rds(here("data/df_nn.rds"))
sets <- split_train_val_test(df_nn)

db_train <- sets$train
db_validation <- sets$val
db_test <- sets$test


# da capire come gestire threshold e stepmax per fare in modo che
# continui anche se la raggiunge (perchè se non la raggiunge si blocca
# e da errore)

first_50_runs <- run_n(
  formula = class ~.,
  tr = db_train,
  val = db_validation,
  n_epochs = 50,
  hidden = c(8, 8, 8),
  threshold = Inf
)
#
# first_50_runs_inonce <- run_once(
#   formula = class ~.,
#   tr = db_train,
#   val = db_validation,
#   hidden = c(8, 8, 8),
#   threshold = 3
# )

# come evidente, al momento NON addestra!
gg_learning_curves(first_50_runs$perf_df)
