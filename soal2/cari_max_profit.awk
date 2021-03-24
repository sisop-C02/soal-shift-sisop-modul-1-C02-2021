#!/usr/bin/awk

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
        "dengan prosentase", max_profit"%";
}
