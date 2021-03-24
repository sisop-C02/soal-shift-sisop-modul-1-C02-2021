#!/usr/bin/awk

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
