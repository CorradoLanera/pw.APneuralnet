test_that("prepare_data works", {
  # setup
  data_sample <- testing_data()

  # esecuzione
  processed_data <- prepare_data(data_sample)


  # test
  expect_s3_class(processed_data, "data.frame")

  expect_true(all(c(0, 1) %in% processed_data$class))
  expect_true(all(processed_data$class %in% c(0, 1)))

  expect_equal(processed_data$class[[1]], 0)
  expect_equal(processed_data$class[[2]], 1)

  expect_true(all(processed_data[[2]] >= 0))
  expect_true(all(processed_data[[2]] <= 1))

  expect_equal(processed_data[[2]][[1]], 0.01) # arrotondato da 0.012
  expect_equal(processed_data[[4]][[6]], 0)
  expect_equal(processed_data[[6]][[9]], 0.01) # arrotondato da 0.0056
})




test_that("split_train_val_test works properly", {
  # setup
  data_processed <- testing_data() |>
    prepare_data()


  # esecuzione
  splitted <- split_train_val_test(data_processed)
  train <- splitted$train
  val <- splitted$val
  test <- splitted$test

  total_rows <- nrow(data_processed)
  produced_rows <- nrow(train) + nrow(val) + nrow(test)

  # test
  expect_type(splitted, "list")
  expect_s3_class(train, "data.frame")
  expect_s3_class(val, "data.frame")
  expect_s3_class(test, "data.frame")
  expect_equal(produced_rows, total_rows)

})




test_that("run_once works", {

  # setup
  splits <- testing_data() |>
    prepare_data() |>
    split_train_val_test()

  train <- splits$train
  val <- splits$val

  # esecuzione
  model <- run_once(class ~ ., train, val)

  # test
  expect_s3_class(model$model, "nn")
  expect_type(model$loss_tr, "double")
  expect_type(model$loss_val, "double")
  expect_type(model$weights[[1]][[1]], "double")
  expect_type(model$weights[[1]][[2]], "double")
  expect_type(model$weights[[1]][[3]], "double")
  expect_length(model$weights[[1]], 3)
  expect_equal(dim(model$weights[[1]][[1]]), c(ncol(train) - 1 + 1, 4))
  expect_equal(dim(model$weights[[1]][[2]]), c(4 + 1, 4))
  expect_equal(dim(model$weights[[1]][[3]]), c(4 + 1, 1))

})


test_that("run_once can pass weights correctly", {
  # setup
  splits <- testing_data() |>
    prepare_data() |>
    split_train_val_test()

  train <- splits$train
  val <- splits$val

  # esecuzione
  first_model <- run_once(class ~ ., train, val)
  first_final_weights <- first_model[["weights"]]

  second_model <- run_once(
    class ~ ., train, val, weights = first_final_weights[[1]]
  )

  # test
  expect_equal(
    second_model[["model"]][["startweights"]],
    first_final_weights
  )

})


test_that("run_n works", {
  # setup
  splits <- testing_data() |>
    prepare_data() |>
    split_train_val_test()

  train <- splits$train
  val <- splits$val

  # esecuzione
  mod_2 <- run_n(class ~ ., train, val, 2)

  # test
  expect_s3_class(mod_2$model, "nn")

})


test_that("run_n passa i neuroni correttamente dopo il secondo run", {
  # setup
  splits <- testing_data() |>
    prepare_data() |>
    split_train_val_test()

  train <- splits$train
  val <- splits$val

  # esecuzione
  mod_hidden <- run_n(class ~ ., train, val, 2, hidden = 3)

  # test
  expect_length(mod_hidden$model[["weights"]][[1]], 2) # 1 hidden + out
  expect_equal(
    dim(mod_hidden$model[["weights"]][[1]][[1]]),
    c(6, 3)
  ) # ho 5 + 1 var in ingresso, e 3 neuroni nel layer

})


















