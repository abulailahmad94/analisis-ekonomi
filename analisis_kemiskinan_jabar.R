# ==========================================================================
# Replikasi analisis artikel: Kapabilitas dasar dan kemiskinan, 27 kab/kota
# Jawa Barat, 2015-2024 (R).
# ==========================================================================
library(readxl); library(dplyr); library(fixest); library(plm)

# Baca Dataset dari folder data/
d <- read_excel("data/dataset_10_tahun_GINI.xlsx")
d <- d %>% mutate(lnPDRB = log(X5_PDRB))

# ---- 1. Indeks Kapabilitas Dasar (PC1 dari RLS, HLS, UHH; matriks korelasi) ----
pc <- prcomp(d[, c("X2_RLS","X3_HLS","X4_UHH")], center = TRUE, scale. = TRUE)
if (sum(pc$rotation[, 1]) < 0) pc$x[, 1] <- -pc$x[, 1]   # tanda loading positif
d$IKD <- pc$x[, 1]
print(pc$rotation[, 1]); print(pc$sdev^2)               # eigenvector dan eigenvalue
print(summary(pc)$importance["Proportion of Variance", 1])

# ---- 2. Model utama: Two-Way Fixed Effects, SE klaster (df = G-1 = 26) ----
m_ow   <- feols(Y_Kemiskinan ~ IKD + lnPDRB + X6_TPT + Gini | g,         d, cluster = ~g)
m_twfe <- feols(Y_Kemiskinan ~ IKD + lnPDRB + X6_TPT + Gini | g + Tahun, d, cluster = ~g)
etable(m_ow, m_twfe, digits = 3)
r2(m_twfe, "wr2")                                        # R2 within (Tabel 5)

# ---- 3. Mundlak (CRE): within, delta (rata-rata wilayah), dan between = within + delta ----
d <- d %>% group_by(g) %>%
  mutate(IKD_m = mean(IKD), lnPDRB_m = mean(lnPDRB),
         TPT_m = mean(X6_TPT), Gini_m = mean(Gini)) %>% ungroup()
m_mun <- feols(Y_Kemiskinan ~ IKD + lnPDRB + X6_TPT + Gini +
                 IKD_m + lnPDRB_m + TPT_m + Gini_m | Tahun, d, cluster = ~g)
summary(m_mun)
b <- coef(m_mun); V <- vcov(m_mun)
between <- function(w, dl) {                              # efek between = w + delta
  est <- b[w] + b[dl]; se <- sqrt(V[w,w] + V[dl,dl] + 2*V[w,dl])
  c(est = unname(est), se = unname(se), p = 2*pt(abs(est/se), 26, lower.tail = FALSE))
}
print(between("IKD","IKD_m")); print(between("lnPDRB","lnPDRB_m"))
print(between("X6_TPT","TPT_m")); print(between("Gini","Gini_m"))

# Uji Wald gabungan rata-rata wilayah (uji Mundlak, Tabel 3)
idx <- c("IKD_m","lnPDRB_m","TPT_m","Gini_m")
W <- drop(t(b[idx]) %*% solve(V[idx, idx]) %*% b[idx]); c(chi2 = W, p = pchisq(W, 4, lower.tail = FALSE))

# ---- 4. Uji diagnostik (Tabel 3) ----
pd_ <- pdata.frame(as.data.frame(d), index = c("g","Tahun"))
f   <- Y_Kemiskinan ~ IKD + lnPDRB + X6_TPT + Gini
pool <- plm(f, pd_, model = "pooling"); fe1 <- plm(f, pd_, model = "within")
re1  <- plm(f, pd_, model = "random")
pFtest(fe1, pool)                                         # Chow
phtest(fe1, re1)                                          # Hausman
fe2 <- plm(f, pd_, model = "within", effect = "twoways")
pcdtest(fe2, test = "cd")                                 # Pesaran CD
pwartest(fe1)                                             # Wooldridge, autokorelasi
car::vif(lm(f, data = d))                                 # VIF

# ---- 5. Inferensi alternatif (Tabel 7) ----
lmtest::coeftest(fe2, vcov = function(x) plm::vcovSCC(x, maxlag = 2, type = "HC1"))

# ---- 6. Uji ketahanan (Tabel 6) ----
rob <- function(data, ...) feols(Y_Kemiskinan ~ IKD + lnPDRB + X6_TPT + Gini | g + Tahun, data, cluster = ~g, ...)
r_a <- rob(filter(d, Tahun != 2020))                       # (a) tanpa 2020
r_b <- rob(filter(d, Tahun <= 2019))                       # (b) 2015-2019
r_c <- rob(filter(d, Tahun >= 2020))                       # (c) 2020-2024
d <- d %>% arrange(g, Tahun) %>% group_by(g) %>%           # (d) lag 1 tahun
  mutate(IKD_l = lag(IKD), lnP_l = lag(lnPDRB), TPT_l = lag(X6_TPT), Gini_l = lag(Gini)) %>% ungroup()
r_d <- feols(Y_Kemiskinan ~ IKD_l + lnP_l + TPT_l + Gini_l | g + Tahun, d, cluster = ~g)
pc2 <- prcomp(d[, c("X2_RLS","X3_HLS")], center = TRUE, scale. = TRUE)   # (e) IKD tanpa UHH
d$IKD_noUHH <- if (sum(pc2$rotation[,1]) < 0) -pc2$x[,1] else pc2$x[,1]
r_e <- feols(Y_Kemiskinan ~ IKD_noUHH + lnPDRB + X6_TPT + Gini | g + Tahun, d, cluster = ~g)
r_f <- rob(filter(d, Tahun != 2016))                       # (f) tanpa 2016
etable(r_a, r_b, r_c, r_d, r_e, r_f, digits = 3)

# ---- 7. Interaksi ln PDRB x Gini (Tabel 8) ----
d <- d %>% mutate(lnP_c = lnPDRB - mean(lnPDRB), Gini_c = Gini - mean(Gini))
m_int <- feols(Y_Kemiskinan ~ IKD + lnP_c + X6_TPT + Gini_c + lnP_c:Gini_c | g + Tahun, d, cluster = ~g)
etable(m_int, digits = 3)

# ---- 8. Dinamika: FE dinamis dengan lag kemiskinan ----
d <- d %>% group_by(g) %>% mutate(Y_l = lag(Y_Kemiskinan)) %>% ungroup()
m_dyn <- feols(Y_Kemiskinan ~ Y_l + IKD + lnPDRB + X6_TPT + Gini | g + Tahun, d, cluster = ~g)
etable(m_dyn, digits = 3)
