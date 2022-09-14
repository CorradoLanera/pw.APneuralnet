library(tidyverse)
library(here)

source(here("R/functions.R"))

df_nn_raw <- read.table(
  here("data-raw/df_nn.tsv"),
  sep = "\t"
)


df_nn <- prepare_data(df_nn_raw)
write_rds(df_nn, here("data/df_nn.rds"))
