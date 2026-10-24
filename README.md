# Asosiasi Kapabilitas Dasar dengan Kemiskinan: Analisis Data Panel Kabupaten/Kota di Jawa Barat (2015–2024)

[![R-Econometrika](https://img.shields.io/badge/Language-R-blue.svg)](https://www.r-project.org/)
[![License-MIT](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![Reproducible-Research](https://img.shields.io/badge/Reproducible--Research-Yes-orange.svg)](#)

Repository ini berisi skrip analisis ekonometrika dan dataset panel seimbang (*balanced panel*) untuk mereplikasi penelitian mengenai dinamika kemiskinan regional di 27 Kabupaten/Kota Provinsi Jawa Barat selama periode 10 tahun (2015–2024, $N = 270$ observasi).

---

## 📌 Ringkasan Metodologi & Temuan Utama

* **Pendekatan Ekonometrika**: Menggunakan model *Two-Way Fixed Effects* (TWFE) dan *Correlated Random Effects* (Model Mundlak) with galat baku *cluster-robust* pada tingkat kabupaten/kota ($G = 27$).
* **Indeks Kapabilitas Dasar (IKD):' Dikonstruksi menggunakan *Principal Component Analysis* (PCA) dari indikator Rata-rata Lama Sekolah (RLS), Harapan Lama Sekolah (HLS), dan Umur Harapan Hidup (UHH). Komponen pengeluaran dieliminasi untuk menghindari bias tautologis matematis terhadap garis kemiskinan.
* **Hasil Estimasi Utama**:
  * **Efek Between vs. Within IKD**: IKD berasosiasi negatif dan sangat signifikan secara antar-wilayah (*between*, $\beta = -1,909; p < 0,001$), namun tidak signifikan secara dalam-wilayah (*within*, $p = 0,283$). Hal ini menunjukkan bahwa akumulasi modal manusia berdampak secara struktural jangka panjang.
  * **Pasar Kerja Informal**: Tingkat Pengangguran Terbuka (TPT) berasosiasi negatif secara *within* ($\beta = -0,129; p = 0,043$), mencerminkan peran sektor informal sebagai *safety valve* bagi angkatan kerja miskin di wilayah berkembang.
  * **Moderasi Ketimpangan**: Suku interaksi $\ln\text{PDRB}_c \times \text{Gini}_c$ bernilai positif signifikan ($\beta = 6,014; p = 0,013$), mengonfirmasi bahwa tingkat ketimpangan (Rasio Gini) meredam dampak pertumbuhan ekonomi terhadap penurunan kemiskinan.

---

## 🛠️ Persyaratan Pustaka R (Dependencies)

Sebelum menjalankan skrip, pastikan seluruh paket R berikut telah terinstal di lingkungan kamu:

```R
install.packages(c(
  "readxl",          # Membaca dataset Excel
  "dplyr",           # Manipulasi dan transformasi data
  "fixest",          # Estimasi Fast Fixed Effects (feols)
  "plm",             # Ekonometrika Data Panel & Uji Diagnostik
  "lmtest",          # Testing hipotesis & Coeftest
  "sandwich",        # Robust Covariance Matrix Estimation
  "car"              # Uji Multikolinearitas (VIF)
))
```
