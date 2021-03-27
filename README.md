# soal-shift-sisop-modul-1-C02-2021
Soal shift Sisop Modul 1 dan solusinya.

## Soal 1
### Penjelasan Soal.
Ryujin baru saja diterima sebagai IT support di perusahaan Bukapedia. Dia diberikan tugas untuk membuat laporan harian untuk aplikasi internal perusahaan, ticky. Terdapat 2 laporan yang harus dia buat, yaitu laporan daftar peringkat pesan error terbanyak yang dibuat oleh ticky dan laporan penggunaan user pada aplikasi ticky. Untuk membuat laporan tersebut, Ryujin harus melakukan beberapa hal berikut:
(a) Mengumpulkan informasi dari log aplikasi yang terdapat pada file syslog.log . Informasi yang diperlukan antara lain: jenis log (ERROR/INFO), pesan log, dan username pada setiap baris lognya. Karena Ryujin merasa kesulitan jika harus memeriksa satu per satu baris secara manual, dia menggunakan regex untuk mempermudah pekerjaannya. Bantulah Ryujin membuat regex tersebut.  
(b) Kemudian, Ryujin harus menampilkan semua pesan error yang muncul beserta jumlah kemunculannya.  
(c) Ryujin juga harus dapat menampilkan jumlah kemunculan log ERROR dan INFO untuk setiap user-nya.  

Setelah semua informasi yang diperlukan telah disiapkan, kini saatnya Ryujin menuliskan semua informasi tersebut ke dalam laporan dengan format file csv.
(d) Semua informasi yang didapatkan pada poin b dituliskan ke dalam file error_message.csv dengan header Error,Count yang kemudian diikuti oleh daftar pesan error dan jumlah kemunculannya diurutkan berdasarkan jumlah kemunculan pesan error dari yang terbanyak.  
Contoh:
```
Error,Count
Permission denied,5
File not found,3
Failed to connect to DB,2
```
(e) Semua informasi yang didapatkan pada poin c dituliskan ke dalam file user_statistic.csv dengan header Username,INFO,ERROR diurutkan berdasarkan username secara ascending.  
Contoh:
```
Username,INFO,ERROR
kaori02,6,0
kousei01,2,2
ryujin.1203,1,3
```
### Solusi dan Penjelasannya.
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


## Soal 2
### Penjelasan Soal.
Steven dan Manis mendirikan sebuah startup bernama “TokoShiSop”. Sedangkan kamu dan Clemong adalah karyawan pertama dari TokoShiSop. Setelah tiga tahun bekerja, Clemong diangkat menjadi manajer penjualan TokoShiSop, sedangkan kamu menjadi kepala gudang yang mengatur keluar masuknya barang.

Tiap tahunnya, TokoShiSop mengadakan Rapat Kerja yang membahas bagaimana hasil penjualan dan strategi kedepannya yang akan diterapkan. Kamu sudah sangat menyiapkan sangat matang untuk raker tahun ini. Tetapi tiba-tiba, Steven, Manis, dan Clemong meminta kamu untuk mencari beberapa kesimpulan dari data penjualan “Laporan-TokoShiSop.tsv”.

- Steven ingin mengapresiasi kinerja karyawannya selama ini dengan mengetahui Row ID dan profit percentage terbesar (jika hasil profit percentage terbesar lebih dari 1, maka ambil Row ID yang paling besar). Karena kamu bingung, Clemong memberikan definisi dari profit percentage, yaitu:
> Profit Percentage = (Profit / Cost Price) * 100

Cost Price didapatkan dari pengurangan Sales dengan Profit. (Quantity diabaikan).

- Clemong memiliki rencana promosi di Albuquerque menggunakan metode MLM. Oleh karena itu, Clemong membutuhkan daftar nama customer pada transaksi tahun 2017 di Albuquerque.
- TokoShiSop berfokus tiga segment customer, antara lain: Home Office, Customer, dan Corporate. Clemong ingin meningkatkan penjualan pada segmen customer yang paling sedikit. Oleh karena itu, Clemong membutuhkan segment customer dan jumlah transaksinya yang paling sedikit.
- TokoShiSop membagi wilayah bagian (region) penjualan menjadi empat bagian, antara lain: Central, East, South, dan West. Manis ingin mencari wilayah bagian (region) yang memiliki total keuntungan (profit) paling sedikit dan total keuntungan wilayah tersebut.

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


```bash
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
```

```
Transaksi terakhir dengan profit percentage terbesar yaitu CA-2017-121559 dengan prosentase 100%

Daftar nama customer di Albuquerque pada tahun 2017 antara lain:
Benjamin Farhat
David Wiener
Michelle Lonsdale
Susan Vittorini

Tipe segmen customer yang penjualannya paling sedikit adalah Home Office dengan 6744 transaksi

Wilayah bagian (region) yang memiliki total keuntungan (profit) yang paling sedikit adalah Central dengan total keuntungan 39706.4
```

## Soal 3
### Penjelasan Soal.
Kuuhaku adalah orang yang sangat suka mengoleksi foto-foto digital, namun Kuuhaku juga merupakan seorang yang pemalas sehingga ia tidak ingin repot-repot mencari foto, selain itu ia juga seorang pemalu, sehingga ia tidak ingin ada orang yang melihat koleksinya tersebut, sayangnya ia memiliki teman bernama Steven yang memiliki rasa kepo yang luar biasa. Kuuhaku pun memiliki ide agar Steven tidak bisa melihat koleksinya, serta untuk mempermudah hidupnya, yaitu dengan meminta bantuan kalian. Idenya adalah :
- Membuat script untuk mengunduh 23 gambar dari "https://loremflickr.com/320/240/kitten" serta menyimpan log-nya ke file "Foto.log". Karena gambar yang diunduh acak, ada kemungkinan gambar yang sama terunduh lebih dari sekali, oleh karena itu kalian harus menghapus gambar yang sama (tidak perlu mengunduh gambar lagi untuk menggantinya). Kemudian menyimpan gambar-gambar tersebut dengan nama "Koleksi_XX" dengan nomor yang berurutan tanpa ada nomor yang hilang (contoh : Koleksi_01, Koleksi_02, ...)
```bash
#!/bin/bash

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

- Karena Kuuhaku malas untuk menjalankan script tersebut secara manual, ia juga meminta kalian untuk menjalankan script tersebut sehari sekali pada jam 8 malam untuk tanggal-tanggal tertentu setiap bulan, yaitu dari tanggal 1 tujuh hari sekali (1,8,...), serta dari tanggal 2 empat hari sekali(2,6,...). Supaya lebih rapi, gambar yang telah diunduh beserta log-nya, dipindahkan ke folder dengan nama tanggal unduhnya dengan format "DD-MM-YYYY" (contoh : "13-03-2023").
```
0 20 1-31/7 * * bash soal3b.sh
0 20 2-18/4 * * bash soal3b.sh
0 20 26-31/4 * * bash soal3b.sh
```
```bash
#!/bin/bash
bash soal3a.sh $(date '+%d-%m-%Y')
```

- Agar kuuhaku tidak bosan dengan gambar anak kucing, ia juga memintamu untuk mengunduh gambar kelinci dari "https://loremflickr.com/320/240/bunny". Kuuhaku memintamu mengunduh gambar kucing dan kelinci secara bergantian (yang pertama bebas. contoh : tanggal 30 kucing > tanggal 31 kelinci > tanggal 1 kucing > ... ). Untuk membedakan folder yang berisi gambar kucing dan gambar kelinci, nama folder diberi awalan "Kucing_" atau "Kelinci_" (contoh : "Kucing_13-03-2023").  
Setelah semua informasi yang diperlukan telah disiapkan, kini saatnya Ryujin menuliskan semua informasi tersebut ke dalam laporan dengan format file csv.
```bash
#!/bin/bash

# Date handling
i=$(date "+%--j")
i=$((i % 2))

# URLs
kucing_url="https://loremflickr.com/320/240/kitten"
kelinci_url="https://loremflickr.com/320/240/bunny"
# Directories
kucing_folder="Kucing_"$(date "+%d-%m-%Y")
kelinci_folder="Kelinci_"$(date "+%d-%m-%Y")

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

- Untuk mengamankan koleksi Foto dari Steven, Kuuhaku memintamu untuk membuat script yang akan memindahkan seluruh folder ke zip yang diberi nama “Koleksi.zip” dan mengunci zip tersebut dengan password berupa tanggal saat ini dengan format "MMDDYYYY" (contoh : “03032003”).
```bash
#!/bin/bash

password=$(date "+%m%d%Y")
zip -P $password -r Koleksi.zip */

rm -R -- */
```

- Karena kuuhaku hanya bertemu Steven pada saat kuliah saja, yaitu setiap hari kecuali sabtu dan minggu, dari jam 7 pagi sampai 6 sore, ia memintamu untuk membuat koleksinya ter-zip saat kuliah saja, selain dari waktu yang disebutkan, ia ingin koleksinya ter-unzip dan tidak ada file zip sama sekali.
```
#zip
0 7 * * 1-5 bash soal3d.sh

#unzip and delete
0 18 * * 1-5 unzip -P "date '+%m%d%Y'" Koleksi.zip && rm Koleksi.zip
```
