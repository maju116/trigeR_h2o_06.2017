# install.packages("h2o")
library(h2o)

# Tworzymy połączenie z H2O
localH2O <- h2o.init(ip = "localhost", # domyślnie
                      port = 54321, # domyślnie
                      nthreads = -1, # użyj wszystkich dostepnych CPU
                      min_mem_size = "8g")
 
# Przejdź do http://localhost:54321
 
h2o.clusterInfo() # Informacje o clustrze
 
h2o.shutdown() # Zamknięcie clustra
 
# WYSYŁANIE DANYCH DO H2O I Z H2O
h2o.ls() # Lista obiektów w H2O wraz z kluczami 

# 1. Z R
iris1_h2o <- as.h2o(iris) # Źle
iris2_h2o <- as.h2o(iris,
                    destination_frame = "iris2") # Dobrze
as.h2o(data.frame(x=1:3,y=4:6)) # Bardzo źle (za kazdym razem inny klucz!)
as.h2o(data.frame(x=1:3,y=4:6),
                    destination_frame = "nowe_dane") # Dobrze

# 2. Spoza R
card1 <- h2o.uploadFile(path = "creditcard.csv", # Tylko do małych danych
               destination_frame = "creditcard1")
card2 <- h2o.importFile(path = "creditcard.csv", # Do dużych danych
               destination_frame = "creditcard2")
# Analogiczne funkcje h2o.importHDFS, h2o.importURL, h2o.importFolder

# 3. Z H2O
h2o.exportFile(data = iris2_h2o,
               path = "irysy.csv",
               parts = 1) # Można podzielić plik na kilka części
irysy <- as.data.frame(iris2_h2o) # Wczytanie danych z H2O do R
# Analogiczne funkcje h2o.exportHDFS

h2o.getId(iris2_h2o) # Wyciąganie klucza
h2o.getFrame("nowe_dane") -> nowe_dane_h2o # Połączenie z istniejącymi danymi
# Analogiczne funkcje h2o.getModel, h2o.getGrid
h2o.rm("iris2") # Usuwanie z H2O obiektu 'iris2'
h2o.removeAll() # Usuwanie wszystkich obiektów z H2O

# MANIPULACJA DANYMI
x <- as.h2o(data.frame(id = 1:4,a = rnorm(4)),
            destination_frame = "x")
y <- as.h2o(data.frame(id = 1:4, b = letters[1:4]),
            destination_frame = "y")  

x$a # Powstanie tabela tymczasowa, która zniknie
y[,2] # Powstanie tabela tymczasowa, która zniknie 
x[1:2,"id"] # Powstanie tabela tymczasowa, która zniknie
y[1,2] <- "b" # Wrapper do x
x[3,2] <- 77  # Wrapper do y
x2 <- 3*x[1:2,] # Przypisanie (można ładniej)
x3 <- h2o.assign(3*x[1:2,], key = "x3") # Przypisanie
# http://rpubs.com/msamywang/178731
# https://groups.google.com/forum/#!topic/h2ostream/pPtWXVyD4eY
h2o.cbind(x,y)
h2o.rbind(x,x)
h2o.merge(x,y, by = "id")
# h2o:::.h2o.garbageCollect()
