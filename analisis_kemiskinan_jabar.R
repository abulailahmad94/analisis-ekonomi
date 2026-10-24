# Analisis Kemiskinan Jawa Barat
library(readxl)
library(dplyr)

# Baca data
data <- read_excel("data/dataset_10_tahun_GINI.xlsx")

# Tampilkan ringkasan
print(head(data))
print(summary(data))
