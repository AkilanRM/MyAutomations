#!/bin/bash
echo "HI"
mysql_host=10.142.0.32
mysql_user=proxy_user
password=Proxy@123
port=6033
set -x 
declare -a types=( 'bulk' 'readalone' 'readwrite' ) 
l=${#types[@]}
arr=( 1 2 4 6 8 16 32 64 128 256 512 )
len=${#arr[@]}
#echo "$len"
no_table=20
t=300
size=1000000
inc=0
inc1=0
a=('thread' 'record') 
record=(1000000 20000000 30000000 40000000 80000000 280000000)
len1=${#record[@]}
echo "$len1"
	#echo "$type"
if [ "${types[0]}" = "bulk" ]
then
	sysbench bulk_insert prepare --events=10000000 --tables=$no_table --threads=64 --mysql-host=$mysql_host  --db-driver=mysql --mysql-user=$mysql_user --mysql-password=$password --mysql-port=$port --mysql-db=sbtest > bulkInsert_prepare | 2 > bulkInsert_prepare.fail
	if [ -s "bulkInsert_prepare" ]
	then
		#echo "IN"
		sysbench bulk_insert run --events=10000000 --tables=$no_table --threads=64 --mysql-host=$mysql_host  --db-driver=mysql --mysql-user=$mysql_user --mysql-password=$password --mysql-port=$port --mysql-db=sbtest > bulkInsert_run | 2>bulkInsert_run.fail
		if [ -s "bulkInsert_run" ]
		then
			#echo "IN1"
			sysbench bulk_insert cleanup --events=10000000 --tables=$no_table  --threads=64 --mysql-host=$mysql_host  --db-driver=mysql --mysql-user=$mysql_user --mysql-password=$password --mysql-port=$port --mysql-db=sbtest > bulkInsert_cleanup | 2>bulkInsert_cleanup.fail	
		else 
			echo "check run fail logs"
			sysbench bulk_insert cleanup --events=10000000 --tables=$no_table  --threads=64 --mysql-host=$mysql_host  --db-driver=mysql --mysql-user=$mysql_user --mysql-password=$password --mysql-port=$port --mysql-db=sbtest > bulkInsert_cleanup | 2>bulkInsert_cleanup.fail
		fi 
	else
		echo "check prepare fail logs"
	fi
fi 
if [ "${types[1]}" = "readalone" ]
then
	if [ "${a[0]}" = "thread" ]
	then
		sysbench oltp_read_only --tables=$no_table --table_size=$size  --mysql-host=$mysql_host --db-driver=mysql --mysql-user=$mysql_user --mysql-password=$password --mysql-port=$port --mysql-db=sbtest  --time=$t --report-interval=10 --threads=1 prepare > readOnly_thread_prepare | 2> readOnly_thread_prepare.fail
		if [ -s "readOnly_thread_prepare" ]
		then
			echo "SUCCESS PREPARING"
		else
			echo "CHECK PREAPRE ERROR LOGS"
		fi
		for (( j = 0 ; j<$len ; j++ ))
		do
			sysbench oltp_read_only --tables=$no_table --table_size=$size  --mysql-host=$mysql_host --db-driver=mysql --mysql-user=$mysql_user --mysql-password=$password --mysql-port=$port --mysql-db=sbtest  --time=$t --report-interval=10 --threads=${arr[j]} run > readOnly_${arr[j]}_run | 2> readOnly_${arr[j]}_prepare.fail		
			if [  -s  "readOnly_${arr[j]}_run" ]
			then
				inc1=$((inc1+1))
			fi
		done
		if [ $inc1 -eq $((len-1)) ]
             	then
			echo "SUCCESS RUNNING "
                	sysbench oltp_read_only --tables=$no_table --table_size=$size  --mysql-host=$mysql_host --db-driver=mysql --mysql-user=$mysql_user --mysql-password=$password --mysql-port=$port --mysql-db=sbtest  --time=$t --report-interval=10 --threads=512 cleanup > readOnly_thread__cleanup | 2> readOnly_thread_cleanup.fail
                else
                       	echo "check run error  logs"
			sysbench oltp_read_only --tables=$no_table --table_size=$size  --mysql-host=$mysql_host --db-driver=mysql --mysql-user=$mysql_user --mysql-password=$password --mysql-port=$port --mysql-db=sbtest  --time=$t --report-interval=10 --threads=512 cleanup > readOnly_thread_cleanup | 2> readOnly_thread_cleanup.fail
                fi
	fi
	if [ "${a[1]}" = "record" ]
	then
        	for (( i=0 ; i < $len1 ; i++ ))
                do
			sysbench oltp_read_only --tables=$no_table --table_size=${record[i]}  --mysql-host=$mysql_host --db-driver=mysql --mysql-user=$mysql_user --mysql-password=$password --mysql-port=$port --mysql-db=sbtest  --time=$t --report-interval=10 --threads=64 prepare > readOnly_${record[i]}_prepare | 2> readOnly_${record[i]}_prepare.fail
			if [ -s " readOnly_${record[i]}_prepare" ]
			then
				echo "SUCCESS PREPARING"
                   		sysbench oltp_read_only --tables=$no_table --table_size=${record[i]}  --mysql-host=$mysql_host --db-driver=mysql --mysql-user=$mysql_user --mysql-password=$password --mysql-port=$port --mysql-db=sbtest  --time=$t --report-interval=10 --threads=64 run > readOnly_${record[i]}_run | 2> readOnly_${record[i]}_prepare.fail
                               	if [ -s "readOnly_${record[i]}_run" ]
                               	then
					echo "SUCCESS RUNNING "
                                      	sysbench oltp_read_only --tables=$no_table --table_size=${record[i]}  --mysql-host=$mysql_host --db-driver=mysql --mysql-user=$mysql_user --mysql-password=$password --mysql-port=$port --mysql-db=sbtest  --time=$t --report-interval=10 --threads=64 cleanup > readOnly_${record[i]}_cleanup | 2> readOnly_${record[i]}_cleanup.fail
                               	else
                                       	echo "check run error logs"
				 	sysbench oltp_read_only --tables=$no_table --table_size=${record[i]}  --mysql-host=$mysql_host --db-driver=mysql --mysql-user=$mysql_user --mysql-password=$password --mysql-port=$port --mysql-db=sbtest  --time=$t --report-interval=10 --threads=64 cleanup > readOnly_${record[i]}_cleanup | 2> readOnly_${record[i]}_cleanup.fail
                               	fi
			else 
				echo "check prepare error logs"
			fi
               	done
	else 
		echo "CHECK THE VARIABLE DEFINITION (a)"
	fi
fi
if [ "${types[2]}" = "readwrite" ]
then
	sysbench oltp_read_write --tables=$no_table --table_size=$size  --mysql-host=$mysql_host --db-driver=mysql --mysql-user=$mysql_user --mysql-password=$password --mysql-port=$port --mysql-db=sbtest  --time=$t --report-interval=10 --threads=1 prepare > readwrite_1_prepare | 2> readwrite_1_prepare.fail
	if [ -s "readwrite_1_prepare" ]
	then
		echo "SUCCESS PREPARING"
	else
		echo "check prepare error logs"
	fi
        for (( i=0 ; i<$len ; i++ ))
        do
        	sysbench oltp_read_write --tables=$no_table --table_size=$size  --mysql-host=$mysql_host --db-driver=mysql --mysql-user=$mysql_user --mysql-password=$password --mysql-port=$port --mysql-db=sbtest  --time=$t --report-interval=10 --threads=${arr[i]} run > readwrite_${arr[i]}_run  | 2> readwirte_${arr[i]}_prepare.fail
		if [ -s "readwrite_${arr[i]}_run" ]
		then
			inc=$((inc+1))
		fi
        done
	if [ "$inc" = "$((len-1))" ]
       	then
		echo "SUCCESS RUNNING "
                 sysbench oltp_read_write --tables=$no_table --table_size=$size  --mysql-host=$mysql_host --db-driver=mysql --mysql-user=$mysql_user --mysql-password=$password --mysql-port=$port --mysql-db=sbtest  --time=$t --report-interval=10 --threads=512 cleanup > readwrite_thread_cleanup | 2> readwrite_thread_cleanup.fail
        else
                echo "check run  error logs"
		sysbench oltp_read_write --tables=$no_table --table_size=$size  --mysql-host=$mysql_host --db-driver=mysql --mysql-user=$mysql_user --mysql-password=$password --mysql-port=$port --mysql-db=sbtest  --time=$t --report-interval=10 --threads=512 cleanup > readwrite_thread_cleanup | 2> readwrite_thread_cleanup.fail
        fi		
else
	echo "CHECK THE VARIBALE DEFINITION  (types)"
fi  
echo "SYSBENCH"