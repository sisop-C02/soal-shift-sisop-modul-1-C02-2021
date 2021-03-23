#!/bin/bash

# Sangat bisa untuk disederhanakan lagi
# versi 1

# 1.d
declare -A messages
index_result=()

input_file=syslog.log
output_file=error_message.csv

while read lines
do
    line=${lines##*ERROR }
    message=${line% (*}
    if [[ ! "${messages[@]}" = *${message}* ]]
    then
        index=$(grep -wc "${message}" syslog.log)
        messages+=([$index]="$message")
        index_result+=($index)
    fi
done < <(sed -n '/ERROR/p' $input_file)

index_result=($(echo ${index_result[*]}| tr " " "\n" | sort -n))

echo "Error,Count" >> $output_file
for (( i = `expr ${#index_result[@]} - 1`; i >= 0; i--))
do
    echo "${messages[${index_result[$i]}]},${index_result[$i]}" >> $output_file
done

# 1.e
declare -A users_info
declare -A users_error
users=()

input_file=syslog.log
output_file=user_statistic.csv

getUserLog()
{
    local name=$1
    local error_num=0
    local info_num=0

    while read lines
    do
        if [[ $lines = *ERROR* ]]
        then
            error_num=`expr $error_num + 1`
        fi

        if [[ $lines = *INFO* ]]
        then
            info_num=`expr $info_num + 1`
        fi
    done < <(grep -i "($name)" $input_file)

    users_info+=(["$name"]=$info_num)
    users_error+=(["$name"]=$error_num)
}

while read lines
do
    line=${lines##*(}
    user=${line%)*}
    if [[ ! "${users[@]}" = *$user* ]]
    then
        users+=("$user")
        getUserLog $user
    fi
done < $input_file

users=($(echo ${users[*]}| tr " " "\n" | sort -n))

echo "Username,INFO,ERROR" >> $output_file
for user in ${users[@]}
do
    echo "${user},${users_info[$user]},${users_error[$user]}" >> $output_file
done
