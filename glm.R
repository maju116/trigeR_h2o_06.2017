library(h2o)

# Tworzymy połączenie z H2O
localH2O <- h2o.init(ip = "localhost", 
                     port = 54321, 
                     nthreads = -1, 
                     min_mem_size = "8g")
# Wczytujemy dane
card <- h2o.importFile(path = "creditcard.csv",
                        destination_frame = "creditcard")
# Podsumowania
class(card)
colnames(card)
summary(card)
h2o.table(card$Class)

# Dzielimy na zbiór treningowy i testowy
h2o.splitFrame(card,
               ratios = 0.75,
               destination_frames = c("creditcard_train","creditcard_test"),
               seed = 1234)
h2o.ls()
card_train <- h2o.getFrame("creditcard_train")
card_test <- h2o.getFrame("creditcard_test")

# LASSO z over/under samplingiem
card_lasso_balanced <- h2o.glm(x = 2:29, # Nazwy lub indeksy
                      y = "Class", # Nazwa lub indeks
                      training_frame = "creditcard_train", 
                      family = "binomial", 
                      alpha = 1, 
                      lambda_search = TRUE, 
                      model_id = "creditcard_lasso_balanced", 
                      nfolds = 5,
                      balance_classes = TRUE, # Over/under sampling
                      class_sampling_factors = c(0.5,0.5), 
                      seed = 1234)

# Predykcje i miary dopasowania
pred_lasso_balanced <- h2o.predict(card_lasso_balanced, card_test)
perf_lasso_balanced <- h2o.performance(card_lasso_balanced, card_test)

cm_lasso_balanced <- h2o.confusionMatrix(card_lasso_balanced, 
                                newdata = card_test,
                                metrics = "f2")

# Zapisywanie i wczytywanie modeli
h2o.saveModel(card_lasso_balanced,
              path = getwd())
loaded_model <- h2o.loadModel(paste0(getwd(),"/creditcard_lasso_balanced"))
# Analogiczne funkcje h2o.saveMojo(), h2o.download_mojo()