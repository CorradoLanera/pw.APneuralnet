testing_data <- function() {
  structure(
    list(
      class = c(1L, 2L, 2L, 1L, 1L, 2L, 2L, 1L, 2L, 1L),
      Phocaeicola_vulgatus = c(
        1.268758526603, 24.2506297229219, 14.3079408772665,
        3.2855556677097, 0.395942940825514, 17.9270038167939,
        11.4425568672617, 8.03135179153094, 43.4212186199066,
        9.33062880324544
      ),
      Bacteroides_cellulosilyticus = c(
        0, 1.9647355163728, 0.149602058524325, 0, 0, 0,
        17.5295133890009, 0, 7.92229090450359, 0.415821501014199
      ),
      Phocaeicola_dorei = c(
        0.954979536152797, 0, 1.53790916163006, 0, 0, 0, 0, 0, 0, 0
      ),
      Bacteroides_uniformis = c(
        4.50204638472033, 5.90050377833753, 0.670217222188977,
        1.61501968305239, 0.0813581385257905, 1.19871183206107,
        3.5934350705442, 2.87561074918567, 0.74429166141037,
        6.10040567951318
      ),
      Alistipes_putredinis = c(
        2.04638472032742, 0, 1.8849859374065, 1.04471585747451,
        0.607474100992569, 19.149570610687, 0, 1.30293159609121,
        0.567680080736723, 0.750507099391481
      )
    ),
    row.names = c(
      "SRR5578947",  "ZOZOW1T.6033.4", "ZKVR426.1013", "ERR1598939",
      "ERR1598310", "ZJTKAE3.6012", "ZL9BTWF.6013", "ERR1599404",
      "ZN3TBJM.2024.AL1", "ERR1599485"
    ),
    class = "data.frame"
  )
}



prepare_data <- function(raw_db) {
  raw_db$class <- raw_db$class - 1

  var_to_scale <- setdiff(names(raw_db), "class")
  raw_db[var_to_scale] <- raw_db[var_to_scale] / 100

  round(raw_db, 2)
}


split_train_val_test <- function(db) {

  index1 <- sample(seq_len(nrow(db)), round(0.70 * nrow(db)))
  train <- db[index1, ]

  delta_df <- db[-index1, ]

  index2 <- sample(
    seq_len(nrow(delta_df)),
    round(0.65*nrow(delta_df))
  )
  valid <- delta_df[index2, ]
  test <- delta_df[-index2, ]

  list(
    train = train,
    val = valid,
    test = test
  )
}



eval_loss <- function(predicted, trues) {
  sum(
    -(
      trues * log(predicted) +
        (1 - trues) * log(1 - predicted + .Machine$double.eps)
    )
  )
}


eval_set_loss <- function(set, nn_mod, type = c("train", "validation")) {
  type <- match.arg(type)

  loss <- if (type == "train") {

    nn_mod[["result.matrix"]][["error", 1]]

  } else if (type == "validation") {

    val_y <- predict(nn_mod, newdata = set)
    eval_loss(val_y, set[["class"]])

  } else {
    stop(
      "L'argomento `type` deve essere solo 'train' o 'validation'.\n",
      "È stato inserito il valore: ", type, ".\n",
      "NOTA: questo errore non dovrebbe MAI succedere ",
      "(grazie a `match.arg`).\n"
    )
  }

  loss
}


run_my_nn <- function(
    formula,
    tr,
    val,
    weights,
    hidden,
    threshold,
    act.fct,
    linear.output
) {

  neuralnet::neuralnet(
    formula,
    data = tr,
    hidden = hidden,
    threshold = threshold,
    stepmax = 100,
    rep = 1,
    startweights = unlist(weights),
    act.fct = act.fct,
    err.fct = "ce",
    lifesign = "full",
    linear.output = linear.output
  )
}



run_once <- function(
    formula,
    tr,
    val,
    weights = NULL,
    hidden = c(4, 4),
    threshold = Inf,
    act.fct = "logistic",
    linear.output = FALSE
) {

  nn_mod <- run_my_nn(
    formula = formula, tr = tr, val = val, weights = weights,
    hidden = hidden, threshold = threshold,
    act.fct = act.fct, linear.output = linear.output
  )

  list(
    model = nn_mod,
    # gli originali valutano la loss come somma, quindi inconfrontabili
    # su insiemi di numerosità differente: dividiamo il risultato per
    # la corrispondente numerosità, ottenendo la media, in modo da poter
    # confrontare i risultati tra train e validation set
    loss_tr = eval_set_loss(tr, nn_mod, "train") / nrow(tr),
    loss_val = eval_set_loss(val, nn_mod, "validation") / nrow(val),
    weights = nn_mod[["weights"]]
  )
}


run_n <- function(
    formula,
    tr,
    val,
    n_epochs,
    weights = NULL,
    hidden = c(4, 4),
    threshold = Inf,
    act.fct = "logistic",
    linear.output = FALSE,
    starting_epoch = 0
) {

  perf_df <- data.frame(
    epoch = starting_epoch + seq_len(n_epochs),
    loss_tr = NA_real_,
    loss_val = NA_real_
  )

  current_epoch <- run_once(
    formula = formula, tr = tr, val = val, weights = weights,
    hidden = hidden, threshold = threshold,
    act.fct = act.fct, linear.output = linear.output
  )

  perf_df[1, c("loss_tr", "loss_val")] <- c(
    current_epoch[["loss_tr"]],
    current_epoch[["loss_val"]]
  )


  for (i in seq_len(n_epochs - 1)) {

    current_epoch <- run_once(
      formula = formula, tr = tr, val = val,
      weights = current_epoch[["model"]][["weights"]][[1]],
      hidden = hidden, threshold = threshold,
      act.fct = act.fct, linear.output = linear.output
    )

    perf_df[i + 1, c("loss_tr", "loss_val")] <- c(
      current_epoch[["loss_tr"]],
      current_epoch[["loss_val"]]
    )

  }

  list(
    model = current_epoch[["model"]],
    loss_tr = current_epoch[["loss_tr"]],
    loss_val = current_epoch[["loss_val"]],
    weights = current_epoch[["weights"]],
    perf_df = perf_df
  )
}


gg_learning_curves <- function(perfs) {
  perfs |>
    dplyr::rename(training = loss_tr, validation = loss_val) |>
    tidyr::pivot_longer(-epoch, names_to = "set") |>
    ggplot2::ggplot() +
    ggplot2::aes(x = epoch, y = value, colour = set) +
    ggplot2::geom_line() +
    ggplot2::labs(
      x = "Epochs",
      y = "Loss value",
      colour = "Set",
      title = "Learning curves for my super cool NN"
    )
}












