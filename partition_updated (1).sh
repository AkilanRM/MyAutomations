!/bin/bash

echo -e "\e[1;34m THIS JOB IS FOR TAKING PARTITION DUMP IN MYSQL , PUSHING THE BACKUP TO S3 AND DROPPING THE PARTITION FROM THE SERVER AND ALSO ADD FUTURE PARTITION IN THE SERVER .\e[0m"

init() {
script_path="/home/vagrant/partition"
con="$script_path/config"
dump="$script_path/dump"
mon=`date +"%-m"`
mon_1=`date "-d -1 month" +"%-m"`
mon_2=`date "-d -2 month" +"%-m"`
mon_3=`date "-d -3 month" +"%-m"`
month1=`date "-d +1 month" +"%-m"`
month2=`date "-d +2 month" +"%-m"`
month3=`date "-d +3 month" +"%-m"`
y1=`date "-d +1 month" +"%Y"`
y2=`date "-d +2 month" +"%Y"`
y3=`date "-d +3 month" +"%Y"`
c=`date +"%a"`
b=`date +"%Y"`
mail=("hackerboy_0403@gmail.com")
}
init
send_mail(){
	for to in ${mail[@]}
	do
        	`cat /tmp/output_table.html | /sbin/sendmail $to`
		if [ $? = 0 ]
		then
			echo -e "\e[1;32m MAIL SENT FOR $to \e[0m "
		else
			echo -e "\e[1;31m MAIL NOT SENT FOR $to \e[0m "
		fi
	done
}
mail_header(){
        echo  "FROM: 'MYDBOPS' <swiggy@mydbops.com>"
        echo  "TO:${mail[@]}" 
        echo "Subject:PARTITION ARCHIVAL - SWIGGY " 
        echo  "Content-type: text/html" 
        echo  "Hi Team,<br><br>"
	echo  "<br><br>" 
	echo  "<br><br>" 
	echo "SWIGGY : PARTITION ARCHIVAL STATUS FOR MONTH ${mon}_${b} "
	echo  "<br><br>" 
        echo "This works on the basis of conditions . table name is given with db name . The job will read and automatically get the canditate key for condition and develope the condition for taking dump . once dump is taken , the file is pushed to s3 and droped from the server . now the tables are dropped . It will itself identifiy and add the future partitions as well . features could be further maximised . "
	echo  "<br><br>"
	echo "DROP STATUS"
	echo  "<br><br>"
	echo "<font size=2><table align='center' cellspacing='0' cellpadding='10' border='1' width=75%><tr bgcolor='#81c784' style='text-align: center;' style='font-weight:bold;'><th>SCHEMA</th><th>TABLE</th><th>DUMP STATUS</th><th>S3 UPLOAD STATUS</th><th>DROP STATUS</th><th>STATUS</th></tr>"

} >/tmp/output.html
add_mail() {
	echo "<br><br>"
	echo "ADD STATUS"
	echo  "<br><br>"
	echo "<font size=2><table align='center' cellspacing='0' cellpadding='10' border='1' width=75%><tr bgcolor='#81c784' style='text-align: center;' style='font-weight:bold;'><th>SCHEMA</th><th>TABLE</th><th>$month1</th><th>$month2</th><th>$month3</th></tr>"
	echo "<tr bgcolor='#d9d9d9'><td style='color:black'>$db</td><td style='color:black'>$table</td><td style='color:red'>$fu_status3</td><td style='color:red'>$fu_status2</td><td style='color:red'>$fu_status1</td></tr>"
} >> /tmp/output.html
mail_header
check_fun() {
	if [ $? = 0 ]
	then
		x=`date +'%Y-%m-%d:%H:%M:%S'`
		echo -e "\e[1;32m [$x][CONTINUE]: $a \n $s \e[0m"
		
	else
		x=`date +'%Y-%m-%d:%H:%M:%S'`
		echo -e "\e[1;31m [$x][ERROR]: $a \n $f \e[0m"	
		echo "<tr bgcolor='#d9d9d9'><td style='color:black'>$db</td><td style='color:black'>$table</td><td style='color:red'>$dump_status</td><td style='color:red'>$s3_status</td><td style='color:red'>$drop_status</td><td style='color:red'>NOT OK</td></tr>" >> /tmp/output_table.html
		echo "<br><br>" >> /tmp/output_table.html
		echo "thanks" >> /tmp/output_table.html
		echo "mydbops_team" >> /tmp/output_table.html 
		send_mail
		exit  
	fi
}
mail_builder(){
	echo "<tr bgcolor='#d9d9d9'><td style='color:black'>$db</td><td style='color:black'>$table</td><td style='color:green'>$dump_status</td><td style='color:green'>$s3_status</td><td style='color:green'>$drop_status</td><td style='color:green'>OK</td></tr>" >> /tmp/output.html
}
table_close(){
	echo "</table>" 
	echo "</body></html> "
} >> /tmp/output.html
drop () {
	drop_status=""
	echo -e "\e[1;33m DROP STARTED FOR PARTITION $cur_name in $db.$table\e[0m "
	s="DROP SUCCESSFULLY COMPLETED FOR PARTITION $cur_name in $db.$table"
	f="DROP FAILED FOR PARTITION $cur_name in $db.$table"
	a="DROP STATUS"
	mysql -e "alter table $db.$table drop partition $cur_name;"
	check_fun  
	drop_status="success"
	mail_builder
}
empty_drop() {
	drop_satus=""
	echo -e "\e[1;33m DROP STARTED FOR PARTITION $cur_name in $db.$table\e[0m" 
	s="DROP SUCCESSFULLY COMPLETED FOR PARTITION $cur_name in $db.$table"
        f="DROP FAILED FOR PARTITION $cur_name in $db.$table"
	a="DROP STATUS"
        mysql -e "use $db ; alter table $db.$table drop partition $cur_name ;"
        check_fun
	drop_status="success"
	mail_builder
}	
dump_and_s3() {
	dump_status=""
	s3_ststus=""
	echo -e "\e[1;33m DUMP STARTED \e[0m"
	s="DUMP COMPLETED FOR PARTITION $cur_name in $db.$table"
	f="DUMP FAILED FOR PARTITION $cur_name in $db.$table"
	a="DUMP STATUS"
	mysqldump --no-create-db --no-create-info --events --triggers --routines  --complete-insert --single-transaction $db $table --where="$canditate_key between '$min_range' and '$max_range'" | gzip > $dump/${table}_${cur_name}.sql.gz
	check_fun 
	dump_status="success"
	echo -e "\e[1;33m S3 UPLOAD STARTED  \e[0m"
        s="S3 UPLOAD COMPLETED FOR PARTITION $cur_name in $db.$table"
        f="S3 UPLOAD FAILED FOR PARTITION $cur_name in $db.$table"
	a="S3 upload status"
	#$aws
	check_fun
	s3_status="success"
	rm -f $dump/${table}_${cur_name}.sql.gz
	echo "DUMP FILE HAS BEEN REMOVED FROM THE SERVER " 
	drop
}
condition_check() {
	dump_status=""
	s3_status=""
	#echo "$cur_name"
	if [ $cur_name = "part_min" ]
	then
		x=`date +'%Y-%m-%d:%H:%M:%S'`
		s="NO NEED TO DROP THE $cur_name FROM THE TABLE $db.$table "
                echo -e "\e[1;32m [$x][CONTINUE]: $s \e[0m"
	else
		min_range=`mysql -e "select min($canditate_key) from $db.$table partition($cur_name)" -s -N`
		max_range=`mysql -e "select max($canditate_key) from $db.$table partition($cur_name)" -s -N`
		if [ -z "$min_range" ] && [ -z "$max_range" ]
		then
			x=`date +'%Y-%m-%d:%H:%M:%S'`
			s="DUMP FAILED BECAUSE OF CONDITION for $cur_name"
			echo -e "\e[1;32m [$x][CONTINUE]:  $s \e[0m"
			dump_status="no condition found"
			s3_status="no dump file to upload" 
			empty_drop
		else
			x=`date +'%Y-%m-%d:%H:%M:%S'`
			s="DUMP IS IN PROGRESS FOR $$cur_name"
			echo -e "\e[1;32m [$x][CONTINUE]:  $s , \n please check the condition for dump \e[0m"
			dump_and_s3 
		fi
	fi
}
add_partition() {
	unset add fu_val fu_name fu_total_days fu_days  fu1_days 
	unset val difference 
	unset year1 year2 year3 year 
	unset future fu_year
	fu_status1=""
        fu_status2=""
        fu_status3=""
	if [ $m1 = "1" ]
	then 
		future+=($month1)
		fu_year+=($y1)
	else
		echo -e "\e[1;32m [$x] [CONTINUE]:  NO NEED OF DROPPING $month1  PARTITION  \e[0m"
                fu_status1="$fu_status1 $month exist"
	fi
	if [ $m2 = "1" ]
	then
		future+=($month2)
		fu_year+=($y2)	
	else
		echo -e "\e[1;32m [$x] [CONTINUE]:  NO NEED OF DROPPING $month2  PARTITION  \e[0m"
                fu_status1="$fu_status1 $month exist"
	fi
	if [ $m3 = "1" ]
	then
		future+=($month3)
		fu_year+=($y3)
	else
		echo -e "\e[1;32m [$x] [CONTINUE]:  NO NEED OF DROPPING $month3  PARTITION  \e[0m"
                fu_status1="$fu_status1 $month exist"
	fi	
		for (( h=0 ; h < ${#future[@]} ; h++ )) 
		do
			if [ $expire = "1month" ]
			then
				fu_name=`date -d "${fu_year[h]}-${future[h]}-01" +"%m_%Y"`
				fu_val=`date -d "${fu_year[h]}-${future[h]}-01+1month" +"%Y-%m-%d"`	
                		x=`date +'%Y-%m-%d:%H:%M:%S'`
				fu_total_days=`mysql -e "select to_days('$fu_val') " -s -N `
                        	s="PARTITION $fu_name ADDED"
                       	 	f="PARTITION $FU_name NOT ADDED "
                        	`mysql -e "alter table ${db}.${table} reorganize partition p_max into  ( partition $fu_name values less than ($fu_total_days),partition $last_name values less than (MAXVALUE));"`
                        	check_fun
				if [ ${future[h]} = "$month1" ]
				then
					fu_status1="added $fu_name"
				elif [ ${future[h]} = "$month2" ]
				then
					fu_status2="added $fu_name"
				elif [ ${future[h]} = "$month3" ]
				then
					fu_status3="added $fu_name"
				fi
			fi
			if [ $expire = "10days" ] || [ $expire = "15days" ]
			then
				let "val=${future[h]}+1"
                		fu_val=`date -d"${fu_year[h]}-${future[h]}-01" +"%Y-%m-%d"`
                		fu_days=`date -d"${fu_year[h]}-${future[h]}-01" +"%-j"`
                		fu1_days=`date -d"${fu_year[h]}-${val}-01" +"%-j"`
                		let "difference=fu1_days-fu_days" 
			fi
			if [ $expire = "10days" ]
			then
				if [ $difference = "31" ]
				then
					fu=( 10 10 11 )
				elif [ $difference = "30" ]
				then
					fu=( 10 10 10 )
				elif [ $difference = "28" ] 
				then
				fu=( 10 10 8 ) 
				elif [ $difference = "29" ]
				then
					fu=( 10 10 9 )
				else
					x=`date +'%Y-%m-%d:%H:%M:%S'`
					echo -e "\e[1;31m [$x] [ERROR]: CANNOT ADD PARTITION ; CHECK CONSTRAINT FAILS  \e[0m" 
				fi
			fi
			if [ $expire = "15days" ]
			then
				if [ $difference = "31" ]
                        	then
                                	fu=( 15 16 )
                       	 	elif [ $difference = "30" ]
                        	then
                                	fu=( 15 15 )
                        	elif [ $difference = "28" ] 
                        	then
                                	fu=( 15 14 ) 
                        	elif [ $difference = "29" ]
                        	then
                               	 	fu=( 15 13 )
                        	else
                                	x=`date +'%Y-%m-%d:%H:%M:%S'`
                                	echo -e "\e[1;31m [$x] [ERROR]: CANNOT ADD PARTITION ; CHECK CONSTRAINT FAILS  \e[0m"
                        	fi
			fi
			x=`date +'%Y-%m-%d:%H:%M:%S'`
			for (( q=0 ; q < ${#fu[@]} ; q++ )) 
			do
				fu_val=`date -d"$fu_val+${fu[q]}days" +"%Y-%m-%d"`
				fu_name=`date -d"$fu_val-1days" +"%d_%m_%Y"`
				fu_total_days=`mysql -e "select to_days('$fu_val') " -s -N `
				s="PARTITION $fu_name ADDED"
				f="PARTITION $FU_name NOT ADDED " 
				`mysql -e "alter table ${db}.${table} reorganize partition p_max into  ( partition $fu_name values less than ($fu_total_days),partition $last_name values less than (MAXVALUE));"`
				check_fun
				if [ $h = 0 ]
                                then
                                        fu_status1="$fu_status1 added $fu_name"
                                elif [ $h = 1 ]
                                then
                                        fu_status2="$fu_status2 added $fu_name"
                                elif [ $h = 2 ]
                                then
                                        fu_status3="$fu_status3 added $fu_name"
                                fi
			done
		done
}
calculate(){
	m1=1
	m2=1
	m3=1
	len=${#name[@]}
	unset cur_val
	unset cur_name
	unset future fu_year
	let "ag=len-1"
	dump_status=""
	s3_status=""
	drop_status=""
	for (( i=0 ; i < len ; i++ ))
	do
		if [ ${value[i]} = "MAXVALUE" ]
		then
			last_name=${name[i]}
			continue
		fi 
		#echo "${name[i]} ${value[i]}"
		cur_val=${value[i]}
		cur_name=${name[i]}
		max_date=`mysql -e "select from_days($cur_val)" -s -N`
		cur_date=`mysql -e "select date_sub('$max_date',interval 1 day)" -s -N `
		cur_month=`mysql -e "select month('$cur_date')" -s -N`
		cur_year=`mysql -e "select year('$cur_date')" -s -N`
		#echo "$cur_month"
		x=`date +'%Y-%m-%d:%H:%M:%S'`
		if [ $cur_month = "$mon" ] || [ $cur_month = "$mon_1" ] || [ $cur_month = "$mon_2" ] || [ $cur_month = "$mon_3" ] || [ $cur_month = "$month1" ] || [ $cur_month = "$month2" ] || [ $cur_month = "$month3" ]
		then
			if [ $len = "$ag" ]
			then
				dump_status="no_dump"
				s3_status="no_s3_upload"
				drop_status="no_drop"
			fi
			echo -e "\e[1;32m [$x][CONTINUE]: PARTITION SHOULD BE PERSISTED , NOT YET EXPIRED , LEAVING PARTITION $cur_name in  $db.$table [ PROGRESSING] \e[0m"
			if [ $cur_month = "$month1" ] 
                        then
				m1=0
				continue
			elif [ $cur_month = "$month2" ]
			then
				m2=0
				continue
                        elif [ $cur_month = "$month3" ]
			then
				m3=0
				continue
			fi
		else
			echo -e "\e[1;32m [$x][CONTINUE]: PROCEED FOR CHECKING THE CONDITION FOR PARITION $cur_name in $db.$table [PROGRESSING] \e[0m"
			k=`mysql -e "select partition_expression from information_schema.partitions where table_name='$table' and table_schema='$db' limit 1" -s -N`
			#echo "$k"
			con_val()
			{ 
				length=${#k}
				#echo "$length"
				let "c=length-11"
				#echo "${k:9:$c}"
				canditate_key=${k:9:$c}
			}
			con_val
			condition_check
		fi  
	done
	table_close
	add_partition
	add_mail
	table_close
}

array(){
	unset name 
	unset value
	unset a
	a=name
	s=" ARRAY CREATED [PROGRESSING for $db.$table]"
	f=" ARRAY NOT CREATED [FAILED for $db.$table]" 
	for n in $check2
        do
     	   #echo "$n"
           name+=($n)
        done
	check_fun
	a=value
       	for v in $check3
        do
        	#echo "$v"
                value+=($v)
        done
	check_fun 
	calculate
 } 
derive() {
	while IFS= read -r config
	do
		unset arr
		arr=($config)
		db=${arr[0]}
		table=${arr[1]}
		expire=${arr[2]}
		#echo "$db $table $expire"
		unset check1
		unset check2
		unset check3
		validate(){
			check1=`mysql -e "select table_name from information_schema.tables where table_schema='$db' and table_name='$table'" -s -N`
			#echo "$check1"
			x=`date +'%Y-%m-%d:%H:%M:%S'`
			s="TABLE EXIST $db.$table "
			f="TABLE NOT EXIST $db.$table" 
			if [ ! -z "$check1" ] && [ $table = "$check1" ]
			then	
				echo -e "\e[1;32m [$x][CONTINUE]: $s \e[0m"
			else
				echo -e "\e[1;31m [$x][ERROR]: $f \e[0m"
			fi
			check2=`mysql -e "select partition_name from information_schema.partitions where table_schema='$db' and table_name='$table'" -s -N `
			#echo "$check2"
			x=`date +'%Y-%m-%d:%H:%M:%S'`
                        s="PARTITION EXIST for $db.$table"
                        f="PARTITION NOT EXIST $db.$table"
			part="$check2"
			if [ $part = 'NULL' ]
			then
				echo -e "\e[1;31m [$x][ERROR]: $f , NOW EXIT STATE  \e[0m"
				echo -e "partition not exist , table skipped"
			else
				echo -e "\e[1;32m [$x][CONTINUE]: $s  [PROGRESSING] \e[0m"
                                check3=`mysql -e "select partition_description from information_schema.partitions where table_schema='$db' and table_name='$table'" -s -N `
                                array
			fi
		}
		validate
	done < $con
}
derive
echo "<br><br> " >> /tmp/output_table.html 
echo "thanks" >> /tmp/output_table.html
echo "mydbops_team" >> /tmp/output_table.html 
send_mail