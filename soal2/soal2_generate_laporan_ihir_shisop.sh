#!/bin/bash

awk -F '[\t]' -f cari_max_profit.awk Laporan-TokoShiSop.tsv >> hasil.txt; 
echo "" >> hasil.txt;
awk -F '[\t]' -f cari_customer_albuquerque.awk Laporan-TokoShiSop.tsv >> hasil.txt;
echo "" >> hasil.txt;
awk -F '[\t]' -f cari_min_transaksi.awk Laporan-TokoShiSop.tsv >> hasil.txt;
echo "" >> hasil.txt;
awk -F '[\t]' -f cari_min_keuntungan.awk Laporan-TokoShiSop.tsv >> hasil.txt;
