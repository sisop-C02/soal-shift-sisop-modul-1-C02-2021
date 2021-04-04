# lapres-sisop-modul-1-C02-2021
Laporan resmi berisi dokumentasi soal shift Sisop Modul 1.
---
Kelompok C-02:
- [Jason Andrew Gunawan](https://github.com/jasandgun): 05111940000085
- [Muchamad Maroqi Abdul Jalil](https://github.com/maroqijalil): 05111940000143
- [Muhammad Zhafran Musyaffa](https://github.com/franszhafran): 05111940000147
---

## Soal 1
### Penjelasan Soal.
Ryujin baru saja diterima sebagai IT support di perusahaan Bukapedia. Dia diberikan tugas untuk membuat laporan harian untuk aplikasi internal perusahaan, ticky. Terdapat 2 laporan yang harus dia buat, yaitu laporan daftar peringkat pesan error terbanyak yang dibuat oleh ticky dan laporan penggunaan user pada aplikasi ticky. Untuk membuat laporan tersebut, Ryujin harus melakukan beberapa hal berikut:  
- (a) Mengumpulkan informasi dari log aplikasi yang terdapat pada file syslog.log . Informasi yang diperlukan antara lain: jenis log (ERROR/INFO), pesan log, dan username pada setiap baris lognya. Karena Ryujin merasa kesulitan jika harus memeriksa satu per satu baris secara manual, dia menggunakan regex untuk mempermudah pekerjaannya. Bantulah Ryujin membuat regex tersebut.  
- (b) Kemudian, Ryujin harus menampilkan semua pesan error yang muncul beserta jumlah kemunculannya.  
- (c) Ryujin juga harus dapat menampilkan jumlah kemunculan log ERROR dan INFO untuk setiap user-nya.  

Setelah semua informasi yang diperlukan telah disiapkan, kini saatnya Ryujin menuliskan semua informasi tersebut ke dalam laporan dengan format file csv.
- (d) Semua informasi yang didapatkan pada poin b dituliskan ke dalam file error_message.csv dengan header Error,Count yang kemudian diikuti oleh daftar pesan error dan jumlah kemunculannya diurutkan berdasarkan jumlah kemunculan pesan error dari yang terbanyak.  
Contoh:
```
Error,Count
Permission denied,5
File not found,3
Failed to connect to DB,2
```
- (e) Semua informasi yang didapatkan pada poin c dituliskan ke dalam file user_statistic.csv dengan header Username,INFO,ERROR diurutkan berdasarkan username secara ascending.  
Contoh:
```
Username,INFO,ERROR
kaori02,6,0
kousei01,2,2
ryujin.1203,1,3
```
### Solusi dan Penjelasannya.
- (a) Untuk jawaban pada poin ini secara keseluruhan implementasinya digunakan untuk poin selanjutnya, jadi penjelasannya akan diterangkan bersamaan dengan penjelasan poin lainnya.
- (b) Penjelasan jawaban poin ini adalah sebagai berikut:
> Mendeklarasikan sebuah variable bertipe array map untuk menyimpan pesan error, kemudian juga array untuk menyimpan index pesan error tadi.
```bash
declare -A messages
...
index_result=()
```
> Untuk menghitung jumlah pesan error di setiap jenisnya, maka dideklarasikan juga sebuah fungsi bernama `checkLinesForError`. Didalamnya terdapat kondisi `[[ "$1" = *ERROR* ]]` untuk memastikan bahwa pesan yang akan disimpan adalah pesan ERROR. Jika memang benar pesan ERROR maka akan dilakukan pemotongan baris untuk mendapatkan pesannya, yaitu dengan `line=${1##*ERROR }` dan `message=${line% (*}`. Untuk setiap pesan yang didapat akan dilakukan pemeriksaan apakah pesan tersebut sudah ada dalam array map `[[ ! "${messages[@]}" = *${message}* ]]`. Jika tidak ditemukan, maka akan dilakukan penghitungan jumlah pesan tersebut pada file syslog.log `index=$(grep -wc "$message" $input_file)` dan penyimpanan pesan ke dalam array `messages+=([$index]="$message")` dan `index_result+=($index)`.
```bash
checkLinesForError()
{
    if [[ "$1" = *ERROR* ]]
    then
        line=${1##*ERROR }
        message=${line% (*}
        if [[ ! "${messages[@]}" = *${message}* ]]
        then
            index=$(grep -wc "$message" $input_file)
            messages+=([$index]="$message")
            index_result+=($index)
        fi
    fi
}
```
> Setelah deklarasi variable dan fungsi yang diperlukan selesai, maka fungsi `checkLinesForError` dapat dipanggil ketika pembacaan file syslog.log. Karena fungsi tersebut membutuhkan parameter berupa baris data dari file syslog.log, maka setiap pembacaan baris data akan di-*passing* ke fungsi tadi.
```bash
while read lines
do
    ...
    checkLinesForError "$lines"
done < $input_file
```
> Jika semua pesan sudah disimpan kedalam array, dilakukan pencetakan hasil.
```bash
for (( i = `expr ${#index_result[@]} - 1`; i >= 0; i--))
do
    echo "${messages[${index_result[$i]}]},${index_result[$i]}" ...
done
```
- (c) Berikut penjelasan poin ini:
> Mendeklarasikan sebuah variable bertipe array map untuk menyimpan jumlah pesan error beserta info per pengguna, kemudian juga array untuk menyimpan index dari jumlah pesan tersebut berdasarkan namanya.
```bash
declare -A users_info
declare -A users_error
...
users=()
```
> Untuk menghitung jumlah pesan error dan info di setiap penggunanya, maka dideklarasikan juga sebuah fungsi bernama `checkLinesForUser`. Sebelumnya dilakukan pemotongan baris untuk mendapatkan nama penggunanya, yaitu dengan `line=${1##*(}` dan `user=${line%)*}`. Untuk setiap nama pengguna akan dilakukan pemeriksaan apakah nama tersebut sudah ada dalam array map `[[ ! "${users[@]}" = *$user* ]]`. Jika tidak ditemukan, maka  nama penggunanya akan disimpan ke dalam array `users+=("$user")` kemudian dilakukan penghitungan jumlah pesan error `user_error=$(grep -i "($user)" $input_file | grep -wc "ERROR")` dan info `user_info=$(grep -i "($user)" $input_file | grep -wc "INFO")` pada file syslog.log. Lalu, hasil perhitungan jumlah tersebut akan disimpan kedalam array pesan `users_info+=(["$user"]=$user_info)` dan `users_error+=(["$user"]=$user_error)`.
```bash
checkLinesForUser()
{
    line=${1##*(}
    user=${line%)*}
    if [[ ! "${users[@]}" = *$user* ]]
    then
        users+=("$user")
        user_info=$(grep -i "($user)" $input_file | grep -wc "INFO")
        user_error=$(grep -i "($user)" $input_file | grep -wc "ERROR")
        users_info+=(["$user"]=$user_info)
        users_error+=(["$user"]=$user_error)
    fi
}
```
> Setelah deklarasi variable dan fungsi yang diperlukan selesai, maka fungsi `checkLinesForUser` dapat dipanggil ketika pembacaan file syslog.log. Karena fungsi tersebut membutuhkan parameter berupa baris data dari file syslog.log, maka setiap pembacaan baris data akan di-*passing* ke fungsi tadi.
```bash
while read lines
do
    checkLinesForUser "$lines"
    ...
done < $input_file
```
> Jika semua pesan sudah disimpan kedalam array, dilakukan pencetakan hasil.
```bash
for user in ${users[@]}
do
    echo "${user},${users_info[$user]},${users_error[$user]}" ...
done
```
- (d) Poin ini merupakan kelanjutan dari poin b, berikut lanjutannya:
> Mendeklarasikan input  dan output filenya.
```bash
input_file=syslog.log
output_file_1=error_message.csv
```
> Melakukan pengurutan pada data yang diperoleh dari poin b. Pengurutan ini dilakukan pada array index pesan error tadi. Jadi dalam array map tadi yang menjadi key adalah jumlah pesannya kemudian pesannya sendiri menjadi value dari map tersebut.
```bash
index_result=($(echo ${index_result[*]}| tr " " "\n" | sort -n))
```
> Setelah dilakukan pengurutan, maka hasil akan dicetak ke dalam file error_message.csv
```bash
echo "Error,Count" > $output_file_1
for (( i = `expr ${#index_result[@]} - 1`; i >= 0; i--))
do
    echo "${messages[${index_result[$i]}]},${index_result[$i]}" >> $output_file_1
done
```
- (e) Poin ini merupakan kelanjutan dari poin c, berikut lanjutannya:
> Mendeklarasikan output filenya.
```bash
output_file_2=user_statistic.csv
```
> Melakukan pengurutan pada data yang diperoleh dari poin c. Pengurutan ini dilakukan pada array index pesan error dan info tadi. Jadi dalam array map tadi yang menjadi key adalah nama penggunanya kemudian jumlah pesannya sendiri menjadi value dari dua map tersebut.
```bash
users=($(echo ${users[*]}| tr " " "\n" | sort -n))
```
> Setelah dilakukan pengurutan, maka hasil akan dicetak ke dalam file user_statistic.csv
```bash
echo "Username,INFO,ERROR" > $output_file_2
for user in ${users[@]}
do
    echo "${user},${users_info[$user]},${users_error[$user]}" >> $output_file_2
done
```
Berikut kode prgram lengkapnya:
```bash
#!/bin/bash

declare -A messages
declare -A users_info
declare -A users_error

index_result=()
users=()

input_file=syslog.log
output_file_1=error_message.csv
output_file_2=user_statistic.csv

checkLinesForUser()
{
    line=${1##*(}
    user=${line%)*}
    if [[ ! "${users[@]}" = *$user* ]]
    then
        users+=("$user")
        user_info=$(grep -i "($user)" $input_file | grep -wc "INFO")
        user_error=$(grep -i "($user)" $input_file | grep -wc "ERROR")
        users_info+=(["$user"]=$user_info)
        users_error+=(["$user"]=$user_error)
    fi
}

checkLinesForError()
{
    if [[ "$1" = *ERROR* ]]
    then
        line=${1##*ERROR }
        message=${line% (*}
        if [[ ! "${messages[@]}" = *${message}* ]]
        then
            index=$(grep -wc "$message" $input_file)
            messages+=([$index]="$message")
            index_result+=($index)
        fi
    fi
}

while read lines
do
    checkLinesForUser "$lines"
    checkLinesForError "$lines"
done < $input_file

index_result=($(echo ${index_result[*]}| tr " " "\n" | sort -n))
users=($(echo ${users[*]}| tr " " "\n" | sort -n))

echo "Error,Count" > $output_file_1
for (( i = `expr ${#index_result[@]} - 1`; i >= 0; i--))
do
    echo "${messages[${index_result[$i]}]},${index_result[$i]}" >> $output_file_1
done

echo "Username,INFO,ERROR" > $output_file_2
for user in ${users[@]}
do
    echo "${user},${users_info[$user]},${users_error[$user]}" >> $output_file_2
done

```
---

## Soal 2
### Penjelasan Soal.
Steven dan Manis mendirikan sebuah startup bernama “TokoShiSop”. Sedangkan kamu dan Clemong adalah karyawan pertama dari TokoShiSop. Setelah tiga tahun bekerja, Clemong diangkat menjadi manajer penjualan TokoShiSop, sedangkan kamu menjadi kepala gudang yang mengatur keluar masuknya barang.    

Tiap tahunnya, TokoShiSop mengadakan Rapat Kerja yang membahas bagaimana hasil penjualan dan strategi kedepannya yang akan diterapkan. Kamu sudah sangat menyiapkan sangat matang untuk raker tahun ini. Tetapi tiba-tiba, Steven, Manis, dan Clemong meminta kamu untuk mencari beberapa kesimpulan dari data penjualan “Laporan-TokoShiSop.tsv”.
- (a) Steven ingin mengapresiasi kinerja karyawannya selama ini dengan mengetahui Row ID dan profit percentage terbesar (jika hasil profit percentage terbesar lebih dari 1, maka ambil Row ID yang paling besar). Karena kamu bingung, Clemong memberikan definisi dari profit percentage, yaitu:
> Profit Percentage = (Profit / Cost Price) * 100    
> Cost Price didapatkan dari pengurangan Sales dengan Profit. (Quantity diabaikan).
- (b) Clemong memiliki rencana promosi di Albuquerque menggunakan metode MLM. Oleh karena itu, Clemong membutuhkan daftar nama customer pada transaksi tahun 2017 di Albuquerque.
- (c) TokoShiSop berfokus tiga segment customer, antara lain: Home Office, Customer, dan Corporate. Clemong ingin meningkatkan penjualan pada segmen customer yang paling sedikit. Oleh karena itu, Clemong membutuhkan segment customer dan jumlah transaksinya yang paling sedikit.
- (d) TokoShiSop membagi wilayah bagian (region) penjualan menjadi empat bagian, antara lain: Central, East, South, dan West. Manis ingin mencari wilayah bagian (region) yang memiliki total keuntungan (profit) paling sedikit dan total keuntungan wilayah tersebut.    
Agar mudah dibaca oleh Manis, Clemong, dan Steven, (e) kamu diharapkan bisa membuat sebuah script yang akan menghasilkan file “hasil.txt” yang memiliki format sebagai berikut:
```
Transaksi terakhir dengan profit percentage terbesar yaitu *ID Transaksi* dengan persentase *Profit Percentage*%.

Daftar nama customer di Albuquerque pada tahun 2017 antara lain:
*Nama Customer1*
*Nama Customer2* dst

Tipe segmen customer yang penjualannya paling sedikit adalah *Tipe Segment* dengan *Total Transaksi* transaksi.

Wilayah bagian (region) yang memiliki total keuntungan (profit) yang paling sedikit adalah 
*Nama Region* dengan total keuntungan *Total Keuntungan (Profit)*

```
### Solusi dan Penjelasannya.
- (a) Solusi dari poin ini adalah menggunakan sebuah perintah `awk`.
> Mendeklarasikan variabel yang digunakan untuk menyimpan id terbesar dan profit maksimal.
```bash
BEGIN   {
    max_profit = 0;
    max_id = 0;
}
```
> Menghitung prsesntase profit `profit=($21/($18-$21))*100;`, kemudian menyimpan nilainya ke dalam sebuah map dengan nilai row id yang menjadi key-nya `result[$1]=profit;`. Selain itu prosentasi profit terbesar akan disimpan ke dalam variabel `max_profit`.
```bash
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
```
> Setelah semua nilai prosentase dimasukkan ke dalam map, selanjutnya akan dilakukan penentuan row id terbesar. Hal ini dilakukan karena memungkinkan terdapat beberapa row id yang memililiki nilai profit yang sama dengan nilai `max_profit`.
```bash
END {
    for (i in result) {
        if (result[i] == max_profit) {
            if (i > max_id) {
                max_id = i;
            }
        }
    }
    ...
}
```
- (b) Solusi dari poin ini adalah menggunakan sebuah perintah `awk`, yaitu dengan mengambil sebuah baris yang mengandung kata Albuquerque `/Albuquerque/`, kemudian mencari lagi order id yang menganudung string 2017 `match($2, "2017")`. Jika ditemukan maka nama pelanggan akan disimpan ke dalam sebuah array map `result[$7]=1;`.
```bash
/Albuquerque/ {
    if (match($2, "2017")) {
        result[$7]=1;
    }
}
```
- (c) Solusi dari poin ini adalah menggunakan sebuah perintah `awk`.
> Mendeklarasikan variabel yang digunakan untuk menyimpan transaksi minimal.
```bash
BEGIN   {
    min_transaction = 999999;
}
```
> Menghitung jumlah transaksi setiap segment dengan menyimpan dan meng-increment nilainya setiap ditemukan segmen tersebut ke dalam sebuah map `segment_transaction[$8] = segment_transaction[$8] + 1;`.
```bash
{
    if (n) {
        segment_transaction[$8] = segment_transaction[$8] + 1;
    }

    ++n;
}
```
> Setelah semua jumlah transaksi disimpan dalam sebuah map, selanjutnya adalah mendapatkan jumlah paling kecil dengan meng-iterasi isi dari map segment tadi kemudian menyimpan nilai terkecil ke dalam variabel `min_transaction`.
```bash
END {
    for (i in segment_transaction) {
        if (segment_transaction[i] < min_transaction) {
            segment = i;
            min_transaction = segment_transaction[i];
        }
    }
    ...
}
```
- (d) Solusi dari poin ini adalah menggunakan sebuah perintah `awk`.
> Mendeklarasikan variabel yang digunakan untuk menyimpan porfit minimal.
```bash
BEGIN   {
    min_profit = 999999.0;
}
```
> Menghitung jumlah profit setiap region dengan menyimpan dan meng-increment nilainya dengan nilai profit setiap ditemukan region tersebut ke dalam sebuah map `region_profit[$13]=region_profit[$13]+$21;`.
```bash
{
    if (n) {
        region_profit[$13]=region_profit[$13]+$21;
    }

    ++n;
}
```
> Setelah semua jumlah profit disimpan dalam sebuah map, selanjutnya adalah mendapatkan jumlah paling kecil dengan meng-iterasi isi dari map region tadi kemudian menyimpan nilai terkecil ke dalam variabel `min_profit`.
```bash
END {
    for (i in region_profit) {
        if (region_profit[i] < min_profit) {
            region = i;
            min_profit = region_profit[i];
        }
    }
    ...
}
```
- (e) dari operasi yang dilakukan setiap poin akan disimpan ke dalam file bash dan dijalankan perintah `awk`-nya disertai dengan penambahan `-F '[\t]'` sebagai penentu separator setiap kolom dari setiap barisnya.
> Setiap poin akan dicetak hasilnya sesuai dengan ketentuan, kemudian akan dimasukkan ke dalam file `hasil.txt`.
```bash
#!/bin/bash

output_file=hasil.txt

awk -F '[\t]' '
...BEGIN

...rule(s)

END {
    ...operation

    print "Transaksi terakhir dengan profit percentage terbesar yaitu", max_id,
        "dengan prosentase", max_profit"%.";
}
' Laporan-TokoShiSop.tsv >> $output_file;

echo "" >> $output_file;

awk -F '[\t]' '
...BEGIN

...rule(s)

END {
    for (i in result) {
        print i;
    }
}
' Laporan-TokoShiSop.tsv >> $output_file;

echo "" >> $output_file;

awk -F '[\t]' '
...BEGIN

...rule(s)

END {
    ...operation
    
    print "Tipe segmen customer yang penjualannya paling sedikit adalah",
        segment, "dengan", min_transaction, "transaksi.";
}
' Laporan-TokoShiSop.tsv >> $output_file;

echo "" >> $output_file;

awk -F '[\t]' '
...BEGIN

...rule(s)

END {
    ...operation
    
    print "Wilayah bagian (region) yang memiliki total keuntungan (profit) yang paling",
        "sedikit adalah", region, "dengan total keuntungan", min_profit".";
}
' Laporan-TokoShiSop.tsv >> $output_file;
```
Berikut kode program bash yang lengkap:
```bash
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
```
Berikut adalah hasil dari eksekusi kode program yang disimpan ke dalam hasil.txt:
```
Transaksi terakhir dengan profit percentage terbesar yaitu 9952 dengan prosentase 100%.

Daftar nama customer di Albuquerque pada tahun 2017 antara lain:
Benjamin Farhat
David Wiener
Michelle Lonsdale
Susan Vittorini

Tipe segmen customer yang penjualannya paling sedikit adalah Home Office dengan 1783 transaksi.

Wilayah bagian (region) yang memiliki total keuntungan (profit) yang paling sedikit adalah Central dengan total keuntungan 39706.4.
```
---

## Soal 3
### Penjelasan Soal.
Kuuhaku adalah orang yang sangat suka mengoleksi foto-foto digital, namun Kuuhaku juga merupakan seorang yang pemalas sehingga ia tidak ingin repot-repot mencari foto, selain itu ia juga seorang pemalu, sehingga ia tidak ingin ada orang yang melihat koleksinya tersebut, sayangnya ia memiliki teman bernama Steven yang memiliki rasa kepo yang luar biasa. Kuuhaku pun memiliki ide agar Steven tidak bisa melihat koleksinya, serta untuk mempermudah hidupnya, yaitu dengan meminta bantuan kalian. Idenya adalah :
- (a) Membuat script untuk mengunduh 23 gambar dari "https://loremflickr.com/320/240/kitten" serta menyimpan log-nya ke file "Foto.log". Karena gambar yang diunduh acak, ada kemungkinan gambar yang sama terunduh lebih dari sekali, oleh karena itu kalian harus menghapus gambar yang sama (tidak perlu mengunduh gambar lagi untuk menggantinya). Kemudian menyimpan gambar-gambar tersebut dengan nama "Koleksi_XX" dengan nomor yang berurutan tanpa ada nomor yang hilang (contoh : Koleksi_01, Koleksi_02, ...)
- (b) Karena Kuuhaku malas untuk menjalankan script tersebut secara manual, ia juga meminta kalian untuk menjalankan script tersebut sehari sekali pada jam 8 malam untuk tanggal-tanggal tertentu setiap bulan, yaitu dari tanggal 1 tujuh hari sekali (1,8,...), serta dari tanggal 2 empat hari sekali(2,6,...). Supaya lebih rapi, gambar yang telah diunduh beserta log-nya, dipindahkan ke folder dengan nama tanggal unduhnya dengan format "DD-MM-YYYY" (contoh : "13-03-2023").
- (c) Agar kuuhaku tidak bosan dengan gambar anak kucing, ia juga memintamu untuk mengunduh gambar kelinci dari "https://loremflickr.com/320/240/bunny". Kuuhaku memintamu mengunduh gambar kucing dan kelinci secara bergantian (yang pertama bebas. contoh : tanggal 30 kucing > tanggal 31 kelinci > tanggal 1 kucing > ... ). Untuk membedakan folder yang berisi gambar kucing dan gambar kelinci, nama folder diberi awalan "Kucing_" atau "Kelinci_" (contoh : "Kucing_13-03-2023").  
Setelah semua informasi yang diperlukan telah disiapkan, kini saatnya Ryujin menuliskan semua informasi tersebut ke dalam laporan dengan format file csv.
- (d) Untuk mengamankan koleksi Foto dari Steven, Kuuhaku memintamu untuk membuat script yang akan memindahkan seluruh folder ke zip yang diberi nama “Koleksi.zip” dan mengunci zip tersebut dengan password berupa tanggal saat ini dengan format "MMDDYYYY" (contoh : “03032003”).
- (e) Karena kuuhaku hanya bertemu Steven pada saat kuliah saja, yaitu setiap hari kecuali sabtu dan minggu, dari jam 7 pagi sampai 6 sore, ia memintamu untuk membuat koleksinya ter-zip saat kuliah saja, selain dari waktu yang disebutkan, ia ingin koleksinya ter-unzip dan tidak ada file zip sama sekali.

### Solusi dan Penjelasannya.
- (a) Solusi untuk poin ini adalah sebagai berikut:
> Melakukan deklarasi directory untuk foto dan log yang bergantung dengan jumlah argumen pemanggilan script. Akan dibahas lebih lanjut di poin (b). Serta mendeklarasikan beberapa variabel lainnya.
```bash
if [ $# -gt 0 ]
then
  log_directory="$1/Foto.log"
  pic_directory="$1/"
  mkdir $pic_directory
else
  log_directory="Foto.log"
  pic_directory=""
fi

# URLs
pic_url="https://loremflickr.com/320/240/kitten"

# Picture count
pic_count=1
max_pic=23
```
> Berikut adalah perintah yang digunakan untuk mengunduh 23 gambar dari website yang disediakan. Perintah yang digunakan adalah command `wget` yang dijalankan menggunakan looping while. Tiap gambar akan disimpan di dalam `pic_directory` dengan nama angka yang mengindikasikan gambar ke-`pic_count` yang sudah diunduh. Log untuk masing-masing gambar disimpan ke 1 file log di dalam `log_directory`.
```bash
# Download pics and fill the log
while [ $pic_count -le $max_pic ]
do
    wget -a $log_directory -O $pic_directory$pic_count".jpeg" $pic_url
    let pic_count+=1
done
```
> Setelah itu, diperlukan sebuah perintah yang dapat menentukan keberadaan duplikat lalu menghapus file-file duplikat. Cara yang dipakai adalah menggunakan `md5sum` yang merupakan fungsi hash yang membandingkan hash dari satu file dengan file lainnya. `declare -A arr` adalah array map yang digunakan untuk menyimpan jumlah duplikat pada masing-masing indeks hash dari md5sum. Pertama dimulai looping untuk semua file dalam `pic_directory`, ada pengondisian yang menentukan apakah akan terjadi hashing atau tidak `-f: True if file exists and is a regular file.`. Kemudian variabel `cksm` akan digunakan untuk menyimpan hash dari sebuah file yang akan dimasukkan jadi key di `arr[$cksm]`. Array ini akan dimasukkan di dalam if statement lalu di increment untuk menunjukkan bahwa file dengan hash tersebut sudah ada. Bila `if ((arr[$cksm]++));` bernilai `true`, file tersebut akan dihapus dengan perintah `rm $file`, karena sebelumnya sudah ada.
```bash
# Detect and delete duplicates
declare -A arr
shopt -s globstar

for file in $pic_directory*; do
  [[ -f "$file" ]] || continue
   
  read cksm _ < <(md5sum "$file")
  if ((arr[$cksm]++)); then 
    rm $file
  fi
done
```
> Kemudian, file akan di rename sesuai permintaan soal, `Koleksi_XX` dimana `XX` merupakan urutan file. Proses rename ini dilakukan menggunakan for loop yang akan looping ke semua file dalam `$pic_directory` yang memiliki nama `.jpeg`. Kemudian file akan dipindah ke directory yang sama dengan nama baru. 
```bash
# Rename files
a_rep=1
for i in $pic_directory*.jpeg; do
  new=$(printf $pic_directory"Koleksi_%02d" "$a_rep")
  mv -- "$i" "$new"
  let a_rep=a_rep+1
done
```
- (b) Solusi untuk poin ini adalah sebagai berikut:
> Memanggil script dari soal 3a dengan argumen extra berupa tanggal hari ini. Argumen extra berupa tanggal akan membuat directory baru di script soal 3a sesuai dengan tanggal yang dimasukkan.
```bash
#!/bin/bash
bash soal3a.sh $(date '+%d-%m-%Y')
```
```bash
if [ $# -gt 0 ]
then
  log_directory="$1/Foto.log"
  pic_directory="$1/"
  mkdir $pic_directory
else
  log_directory="Foto.log"
  pic_directory=""
fi
```
> Untuk crontab 3b, diminta untuk menjalankan script soal 3b sehari sekali dengan aturan mulai dari tanggal 1-31 setiap 7 hari sekali dan dari tanggal 2-31 setiap 4 hari sekali. Perintah cron dipisah menjadi 3 perintah karena tanggal 1/7 dan 2/4 akan bertemu di tanggal 22. Sementara soal hanya meminta script untuk dijalankan sehari sekali.
```
0 20 1-31/7 * * bash soal3b.sh
0 20 2-18/4 * * bash soal3b.sh
0 20 26-31/4 * * bash soal3b.sh
```
- (c) Solusi untuk poin ini adalah sebagai berikut:
> Menambahkan variabel date handling untuk menentukan kapan akan diunduh gambar kucing, kapan akan diunduh gambar kelinci. Untuk menentukan hal ini, digunakan hari ke berapa dalam tahun bukan dalam bulan, karena setiap berganti hari maka akan berganti objek yang diunduh.
```bash
# Date handling
i=$(date "+%--j")
i=$((i % 2))
```
> Kemudian, beberapa variabel `URL` dan `directory` dideklarasikan untuk menyimpan URL dan directory dari masing-masing kucing dan kelinci.
```bash
# URLs
kucing_url="https://loremflickr.com/320/240/kitten"
kelinci_url="https://loremflickr.com/320/240/bunny"
# Directories
kucing_folder="Kucing_"$(date "+%d-%m-%Y")
kelinci_folder="Kelinci_"$(date "+%d-%m-%Y")
```
> Setelah itu, dijalankan if statement yang akan membagi hari-hari tertentu menjadi hari untuk mengunduh gambar kucing atau kelinci. Pembagian dilakukan dengan deklarasi variabel `$pic_url` dan `$pic_directory` sesuai dengan hasil dari if statement. `$log_directory` juga dideklarasikan disini.
```bash
# Date branching
if [ "$i" -eq "1" ]
then
  # kelinci
  mkdir $kelinci_folder
  pic_url=$kelinci_url
  pic_directory="$kelinci_folder/"
else
  # kucing
  mkdir $kucing_folder
  pic_url=$kucing_url
  pic_directory="$kucing_folder/"
fi
log_directory="$pic_directory/Foto.log"
```
> Sisanya adalah sama dengan script di soal 3a.
```bash
# Picture count
pic_count=1
max_pic=23

# Download pics and fill the log
while [ $pic_count -le $max_pic ]
do
    wget -a $log_directory -O $pic_directory$pic_count".jpeg" $pic_url
    let pic_count+=1
done

# Detect and delete duplicates
declare -A arr
shopt -s globstar

for file in $pic_directory*; do
  [[ -f "$file" ]] || continue
   
  read cksm _ < <(md5sum "$file")
  if ((arr[$cksm]++)); then 
    rm $file
  fi
done

# Rename files
a_rep=1
for i in $pic_directory*.jpeg; do
  new=$(printf $pic_directory"Koleksi_%02d" "$a_rep")
  mv -- "$i" "$new"
  let a_rep=a_rep+1
done
```
- (d) Solusi untuk poin ini adalah sebagai berikut:
> Menjalankan perintah untuk `zip` semua folder yang ada di dalam directory, atau semua folder berawalan `Kucing_` dan `Kelinci_` dengan password. Password merupakan tanggal hari ini dengan format MMDDYYY `password=$(date "+%m%d%Y")`. Setelah folder di-zip, hapus folder-folder tersebut menggunakan perintah `rm -R`.
```bash
# zip the folders
password=$(date "+%m%d%Y")
zip -P $password -r Koleksi.zip */

# delete the folders
rm -R -- */

# opsi 1
# password=$(date "+%m%d%Y")
# zip -P $password -r Koleksi.zip Kucing_* Kelinci_*
# rm -R -- Kucing_* Kelinci_*
```
- (e) Solusi untuk poin ini adalah sebagai berikut:
> Untuk melakukan zip, jalankan script 3d yang sudah memiliki perintah tersebut. Command zip akan dijalankan pukul 07:00 setiap hari Senin - Jumat.
```
#zip
0 7 * * 1-5 bash soal3d.sh
```
> Untuk melakukan unzip, jalankan perintah `unzip -P` dengan password tanggal hari ini dengan format MMDDYYY `$(date '+%m%d%Y')` pada file `Koleksi.zip`. Setelah unzip, gunakan perintah `&& rm Koleksi.zip` untuk menghapus file zip.
```
#unzip and delete
0 18 * * 1-5 unzip -P $(date '+%m%d%Y') Koleksi.zip && rm Koleksi.zip
```
---
