# soal-shift-sisop-modul-1-C02-2021
Soal shift Sisop Modul 1 dan solusinya.

## Soal 1
### Penjelasan Soal.
Ryujin baru saja diterima sebagai IT support di perusahaan Bukapedia. Dia diberikan tugas untuk membuat laporan harian untuk aplikasi internal perusahaan, ticky. Terdapat 2 laporan yang harus dia buat, yaitu laporan daftar peringkat pesan error terbanyak yang dibuat oleh ticky dan laporan penggunaan user pada aplikasi ticky. Untuk membuat laporan tersebut, Ryujin harus melakukan beberapa hal berikut:
- Mengumpulkan informasi dari log aplikasi yang terdapat pada file syslog.log . Informasi yang diperlukan antara lain: jenis log (ERROR/INFO), pesan log, dan username pada setiap baris lognya. Karena Ryujin merasa kesulitan jika harus memeriksa satu per satu baris secara manual, dia menggunakan regex untuk mempermudah pekerjaannya. Bantulah Ryujin membuat regex tersebut.
- Kemudian, Ryujin harus menampilkan semua pesan error yang muncul beserta jumlah kemunculannya.
- Ryujin juga harus dapat menampilkan jumlah kemunculan log ERROR dan INFO untuk setiap user-nya.  
Setelah semua informasi yang diperlukan telah disiapkan, kini saatnya Ryujin menuliskan semua informasi tersebut ke dalam laporan dengan format file csv.
- Semua informasi yang didapatkan pada poin b dituliskan ke dalam file error_message.csv dengan header Error,Count yang kemudian diikuti oleh daftar pesan error dan jumlah kemunculannya diurutkan berdasarkan jumlah kemunculan pesan error dari yang terbanyak.  
Contoh:
```
Error,Count
Permission denied,5
File not found,3
Failed to connect to DB,2
```
- Semua informasi yang didapatkan pada poin c dituliskan ke dalam file user_statistic.csv dengan header Username,INFO,ERROR diurutkan berdasarkan username secara ascending.  
Contoh:
```
Username,INFO,ERROR
kaori02,6,0
kousei01,2,2
ryujin.1203,1,3
```
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