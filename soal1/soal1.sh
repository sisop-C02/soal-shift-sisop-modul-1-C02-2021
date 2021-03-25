#!/bin/bash

# Sangat bisa untuk disederhanakan lagi
# versi 2

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

echo "Error,Count" >> $output_file_1
for (( i = `expr ${#index_result[@]} - 1`; i >= 0; i--))
do
    echo "${messages[${index_result[$i]}]},${index_result[$i]}" >> $output_file_1
done

echo "Username,INFO,ERROR" >> $output_file_2
for user in ${users[@]}
do
    echo "${user},${users_info[$user]},${users_error[$user]}" >> $output_file_2
done
