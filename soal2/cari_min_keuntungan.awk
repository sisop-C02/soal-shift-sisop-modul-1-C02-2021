#!/usr/bin/awk

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
        "sedikit adalah", region, "dengan total keuntungan", min_profit;
}
