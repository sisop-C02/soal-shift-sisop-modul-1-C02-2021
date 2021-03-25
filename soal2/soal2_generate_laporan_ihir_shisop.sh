#!/bin/bash

output_file=hasil.txt

awk -F '[\t]' '
BEGIN   {
    max_profit = 0;
    max_id = 0;
}

{
    if (n) {
        profit=($21/($18-$21))*100;
        if (profit > max_profit) {
            max_profit=profit;
        }
        result[$1]=profit;
        transaction_ids[$1]=$2;
    }

    ++n;
}

END {
    for (i in result) {
        if (result[i] == max_profit) {
            if (i > max_id) {
                max_id = i;
                transaction_id=transaction_ids[i];
            }
        }
    }
    print "Transaksi terakhir dengan profit percentage terbesar yaitu", transaction_id,
        "dengan prosentase", max_profit"%.";
}
' Laporan-TokoShiSop.tsv >> $output_file;
echo "" >> $output_file;
awk -F '[\t]' '
BEGIN   {
    print "Daftar nama customer di Albuquerque pada tahun 2017 antara lain:";
}

/Albuquerque/ {
    if (match($2, "2017")) {
        result[$7]=1;
    }
}

END {
    for (i in result) {
        print i;
    }
}
' Laporan-TokoShiSop.tsv >> $output_file;
echo "" >> $output_file;
awk -F '[\t]' '
BEGIN   {
    min_transaction = 999999;
}

{
    if (n) {
        segment_transaction[$8] = segment_transaction[$8] + $19;
    }

    ++n;
}

END {
    for (i in segment_transaction) {
        if (segment_transaction[i] < min_transaction) {
            segment = i;
            min_transaction = segment_transaction[i];
        }
    }

    print "Tipe segmen customer yang penjualannya paling sedikit adalah",
        segment, "dengan", min_transaction, "transaksi.";
}
' Laporan-TokoShiSop.tsv >> $output_file;
echo "" >> $output_file;
awk -F '[\t]' '
BEGIN   {
    min_profit = 999999.0;
}

{
    if (n) {
        region_profit[$13]=region_profit[$13]+$21;
    }

    ++n;
}

END {
    for (i in region_profit) {
        if (region_profit[i] < min_profit) {
            region = i;
            min_profit = region_profit[i];
        }
    }

    print "Wilayah bagian (region) yang memiliki total keuntungan (profit) yang paling",
        "sedikit adalah", region, "dengan total keuntungan", min_profit".";
}
' Laporan-TokoShiSop.tsv >> $output_file;
