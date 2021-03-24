#!/usr/bin/awk

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
        segment, "dengan", min_transaction, "transaksi";
}
