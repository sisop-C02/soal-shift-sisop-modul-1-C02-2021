#!/bin/bash

output_file=hasil.txt

# call awk commands to search the max profit precentage
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
    }

    ++n;
}

END {
    for (i in result) {
        if (result[i] == max_profit) {
            if (i > max_id) {
                max_id = i;
            }
        }
    }
    print "Transaksi terakhir dengan profit percentage terbesar yaitu", max_id,
        "dengan prosentase", max_profit"%.";
}
' Laporan-TokoShiSop.tsv >> $output_file;

echo "" >> $output_file;

# use the awk for search the users which are the customer from Albuquerque
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

# call awk to find the min transaction which is based on the segment
awk -F '[\t]' '
BEGIN   {
    min_transaction = 999999;
}

{
    if (n) {
        segment_transaction[$8] = segment_transaction[$8] + 1;
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

# call awk to find the min profit from whole regions
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
