#!/bin/bash
timestamp=`date +'%Y-%m-%d:%H:%M:%S'`
echo -e "\e[1;34m[$timestamp]\e[0m \e[1;34m DATA DIFFERENCE - JOB STARTS  \e[0m"
mailid="hacker_boy0403@gmail.com"
notify() {
	echo "Thanks , " >> /tmp/output_table.html
	echo "Mydbops." >> /tmp/output_table.html
	echo "</table></body>" >> /tmp/output_table.html
	echo "</html>" >> /tmp/output_table.html
	if [ -f "$csv" ]
	then
		` cat /tmp/output_table.html | mail -a $csv  -s "Data Difference and Restoration Status for ${source_db}.${source_table}" $mailid . `
		if [ $? = 0 ]
        	then
                	echo "Mail SENT  success "
        	else
                	echo "Mail SENT failed "
        	fi
	else
		` cat /tmp/output_table.html | mail -s "Data Difference and Restoration Status for ${source_db}.${source_table}" $mailid . `
		if [ $? = 0 ]
        	then
               		 echo "Mail SENT  success "
        	else
                	echo "Mail SENT failed "
        	fi
	fi
}
mail_header() {
	
	echo "FROM: 'MYDBOPS' <kreditbee@mydbops.com>"
        echo  "Content-type: text/html" 
        echo  "Hi Team,<br><br>"
} > /tmp/output_table.html
mail_header
table_header() {
	echo "<h3> Please check the Restoration Status and Data Difference for ${source_db}.${source_table} on $day <h3>" >> /tmp/output_table.html
	echo  "<br><br>" >> /tmp/output_table.html
	echo "<h3> note : Table which exceed 7 days in the restoration_db will be dropped .<h3>" >>   /tmp/output_table.html
        echo  "<html><body>" >> /tmp/output_table.html
        echo  "<br><br>" >> /tmp/output_table.html
        echo "<font size=2><table align='center' cellspacing='0' cellpadding='10' border='1' width=75%><tr bgcolor='#81c784' style='text-align: center;' style='font-weight:bold;'><th>Source_host</th><th>Database_name</th><th>Table_name</th><th>Restoration_host</th><th>Database_name></th><th>Table_name></th><th>Drop_table</th><th>Restoration_type</th><th>Restoration_Status</th></tr>" >> /tmp/output_table.html
}
mail_build() {
	if [ $restoration_type = "local" ] 
	then
		if [ $drop_status = "0" ] && [ $restore_status = "0" ]
		then
			echo "<tr bgcolor='#d9d9d9'><td style='color:balck'>$host</td><td style='color:black'>$source_db</td><td style='color:black'>$source_table</td><td style='color:black'>$host</td><td style='color:black'>$restoration_db</td><td style='color:black'>$old_table Dropped</td><td style='color:green'>${source_table}_${day} added</td><td style='color:black'>$restoration_type</td><td style='color:green'>SUCCESS</td></tr>" >> /tmp/output_table.html	
		elif [ $drop_status = "1" ] && [ $restore_status = "1" ]	
		then
			echo "<tr bgcolor='#d9d9d9'><td style='color:balck'>$host</td><td style='color:black'>$source_db</td><td style='color:black'>$source_table</td><td style='color:black'>$host</td><td style='color:black'>$restoration_db</td><td style='color:black'>$old_table not Dropped</td><td style='color:green'>${source_table}_${day} not added</td><td style='color:black'>$restoration_type</td><td style='color:red'>FAILED</td></tr>" >> /tmp/output_table.html
		elif [ $drop_status = "2" ] && [ $restore_status = "0" ]
		then
			echo "<tr bgcolor='#d9d9d9'><td style='color:balck'>$host</td><td style='color:black'>$source_db</td><td style='color:black'>$source_table</td><td style='color:black'>$host</td><td style='color:black'>$restoration_db</td><td style='color:black'>No table exist</td><td style='color:green'>${source_table}_${day} added</td><td style='color:black'>$restoration_type</td><td style='color:green'>SUCCESS</td></tr>" >> /tmp/output_table.html 
		elif [ $drop_status = "2" ] && [ $restore_status = "1" ]
		then
		echo "<tr bgcolor='#d9d9d9'><td style='color:balck'>$host</td><td style='color:black'>$source_db</td><td style='color:black'>$source_table</td><td style='color:black'>$host</td><td style='color:black'>$restoration_db</td><td style='color:black'>NO table exist</td><td style='color:green'>${source_table}_${day} not added</td><td style='color:black'>$restoration_type</td><td style='color:red'>FAILED</td></tr>" >> /tmp/output_table.html
		fi
	elif [ $restoration_type = "remote" ]
	then
		if [ $drop_status = "0" ] && [ $restore_status = "0" ]
                then
                        echo "<tr bgcolor='#d9d9d9'><td style='color:balck'>$host</td><td style='color:black'>$source_db</td><td style='color:black'>$source_table</td><td style='color:black'>$restoration_host</td><td style='color:black'>$restoration_db</td><td style='color:black'>$old_table Dropped</td><td style='color:green'>${source_table}_${day} added</td><td style='color:black'>$restoration_type</td><td style='color:green'>SUCCESS</td></tr>" >> /tmp/output_table.html
                elif [ $drop_status = "1" ] && [ $restore_status = "1" ]
                then
                        echo "<tr bgcolor='#d9d9d9'><td style='color:balck'>$host</td><td style='color:black'>$source_db</td><td style='color:black'>$source_table</td><td style='color:black'>$restoration_host</td><td style='color:black'>$restoration_db</td><td style='color:black'>$old_table not Dropped</td><td style='color:green'>${source_table}_${day} not added</td><td style='color:black'>$restoration_type</td><td style='color:red'>FAILED</td></tr>" >> /tmp/output_table.html
                elif [ $drop_status = "2" ] && [ $restore_status = "0" ]
                then
                        echo "<tr bgcolor='#d9d9d9'><td style='color:balck'>$host</td><td style='color:black'>$source_db</td><td style='color:black'>$source_table</td><td style='color:black'>$restoration_host</td><td style='color:black'>$restoration_db</td><td style='color:black'>No table exist</td><td style='color:green'>${source_table}_${day} added</td><td style='color:black'>$restoration_type</td><td style='color:green'>SUCCESS</td></tr>" >> /tmp/output_table.html
                elif [ $drop_status = "2" ] && [ $restore_status = "1" ]
                then
                echo "<tr bgcolor='#d9d9d9'><td style='color:balck'>$host</td><td style='color:black'>$source_db</td><td style='color:black'>$source_table</td><td style='color:black'>$restoration_host</td><td style='color:black'>$restoration_db</td><td style='color:black'>NO table exist</td><td style='color:green'>${source_table}_${day} not added</td><td style='color:black'>$restoration_type</td><td style='color:red'>FAILED</td></tr>" >> /tmp/output_table.html
                fi
	fi
}
check() {
        if [ $status = "0" ]
        then
                timestamp=`date +'%Y-%m-%d:%H:%M:%S'`
                echo -e "\e[1;32m[$timestamp]\e[0m $state \e[1;32m [$success]  \e[0m"
                echo -e "\e[1;32m[$timestamp]\e[0m \e[1;34m JOB PROCEEDS  \e[0m"
        else
                timestamp=`date +'%Y-%m-%d:%H:%M:%S'`
                echo -e "\e[1;31m[$timestamp]\e[0m $state \e[1;31m [$failure]  \e[0m"
                let "skips=skips+1"
                echo -e "\e[1;31m[$timestamp]\e[0m \e[1;34m JOB SKIPS CURRENT CONFIG  \e[0m"
                mail_build
		notify 
                continue
        fi
}
exitcheck() {
        if [ $status = "0" ]
        then
                timestamp=`date +'%Y-%m-%d:%H:%M:%S'`
                echo -e "\e[1;32m[$timestamp]\e[0m $state \e[1;32m [$success]  \e[0m"
                echo -e "\e[1;32m[$timestamp]\e[0m \e[1;34m JOB PROCEEDS  \e[0m"
        else
                timestamp=`date +'%Y-%m-%d:%H:%M:%S'`
                echo -e "\e[1;31m[$timestamp]\e[0m $state \e[1;31m [$failure]  \e[0m"
                echo -e "\e[1;31m[$timestamp]\e[0m \e[1;34m JOB ENDS  \e[0m"
                table_header
                mail_build
                notify
                exit $status
        fi
}
data_diff() {
			if [ ! -f "$data_dir/${restoration_db}.${source_table}_count" ]
			then
				touch $data_dir/${restoration_db}.${source_table}_count
				state="count file missing for data difference validation , File would be generated now , will accomplish in the next run " 
				status=1
				check
			fi
			if [ ! -s "$data_dir/${restoration_db}.${source_table}_count" ]
			then
				state="count file exist but has zero size for data difference validation , File would be populated  now , will accomplish in the next run " 
                                status=1
                                check
			fi		
			o_count=`cat $data_dir/${restoration_db}.${source_table}_count`
			rest=${restoration_db}"."${source_table}"_"${day}
			echo " [NOTE] checking data difference" 
			if [  -f "$data_dir/${restoration_db}.${source_table}_diff1" ]
			then	
				echo "${source_table}_diff1 exist"
				if [ $restoration_type = "local" ]
				then
					`mysql -u $user -h $host -p$pass -e "select * from $rest" > $data_dir/${restoration_db}.${source_table}_diff0`
					n_count=`mysql -u $user -h $host -p$pass -e "select count(column_name) from information_schema.columns where table_schema='$restoration_db' and table_name='${source_table}_${day}'" -s -N `
				else
					`mysql -u $user -h $restoration_host -p$pass -e " select * from $rest" > $data_dir/${restoration_db}.${source_table}_diff0 `
					n_count=`mysql -u $user -h $restoration_host -p$pass -e "select count(column_name) from information_schema.columns where table_schema='$restoration_db' and table_name='${source_table}_${day}'" -s -N `
				fi
			else
				echo "${source_table}_diff1  not exist creating new diffdata_file  "
				echo "[NOTE] job skips current config , difference would be calculated in the next run ". 
				if [ $restoration_type = "local" ]
                                then
                                        `mysql -u $user -h $host -p$pass -e "select * from $rest" > $data_dir/${restoration_db}.${source_table}_diff1`
					continue
                                else
                                        `mysql -u $user -h $restoration_host -p$pass -e " select * from $rest" > $data_dir/${restoration_db}.${source_table}_diff1`
					continue 
                                fi
				
			fi	
			echo " PROCEEDING for validation of data difference " 
			old=($(md5sum $data_dir/${restoration_db}.${source_table}_diff1))
			new=($(md5sum $data_dir/${restoration_db}.${source_table}_diff0)) 
			echo "$n_count" > $data_dir/${restoration_db}.${source_table}_count
			csv="$csv_dir/${source_db}.${source_table}.csv" 
			echo "\\\\---DATA DIFFERENCE FOR ${source_db}.${source_table} on $day ---////" > $csv
			echo " " >> $csv
			if [ ${old[0]} = "${new[0]}" ]
        		then
				state="NO change for $source_db.$source_table" 
				success="No change"
				failure"No change"
				echo "\\\\---NO CHANGE FOUND IN ${source_db}.${source_table} ---////" >> $csv
				status=0
				check
			else
				changes="$data_dir/${restoration_db}.${source_table}_changes"
				echo "[NOTE] calculating data difference"
				`diff $data_dir/${restoration_db}.${source_table}_diff1 $data_dir/${restoration_db}.${source_table}_diff0 > $changes`		
				rm -f $data_dir/${restoration_db}.${source_table}_diff1
				mv $data_dir/${restoration_db}.${source_table}_diff0 $data_dir/${restoration_db}.${source_table}_diff1
				if [ $o_count -ge "$n_count" ] || [ $o_count -le "$n_count" ]
				then
					ping=0
					echo "[NOTE]: columns may be removed/added  from the table , searching for removed/added  column" 
					unset c
					unset field
					status=0
					status1=0
					unset added 
					unset dropped
					unset len
					ping=0
                                        while IFS= read -r x
                                        do
						if [ $status = "1" ] && [ $status1 = "1" ]
						then
							break
						fi
                                                c=($x)
                                                len=${#c[@]}
						if [ ${c[0]} = ">" ] || [ ${c[0]} = "<" ]
                                                then
                                                	echo "[NOTE] : READING LINE "
                                                else
                                                        continue
                                               	fi
                                                for (( p = 0 ; p < $len ; p++ ))
                                                do
                                                        if [ ${c[p]} = ">" ]
                                         		then	
								let "a=p+1"
								if [ $status = "1" ]		
								then
									break
								fi
								for (( j = a ; j<$len ; j++ )) 
								do
									field+=(${c[j]}) 
								done
								status=1
							elif [ ${c[p]} = "<" ]
							then
								let "b=p+1"
								if [ $status1 = "1" ]    
                                                                then
                                                                        break
                                                                fi
                                                                for (( k = b ; k<$len ; k++ ))
                                                                do
                                                                        field+=(${c[k]})
                                                                done
								status1=1
							else
								continue
							fi
                                                done
                                        done < $changes
					length=${#field[@]}
					#for (( t=0 ; t < $length ; t++ )) 
					#do
					#	echo "${field[t]}"
					#done
					let "g=length-1"
					for (( x=0 ; x < $length ; x++ )) 
					do
						count=0
						if [  ! -z "${field[x]}" ]
						then
							let "q=x+1"
							for (( y=q ; y < $length ; y++ ))
							do
								if [ ${field[x]} = "${field[y]}" ]
								then
									echo "${field[x]} ${field[y]}"
									unset -v field[x]
									unset -v field[y]
									echo "${field[x]} ${field[y]}"
									count=1
									break
								else
									if [ $x = $g ]
									then
										count=1 
										break
									else
										continue
									fi
								fi
							done
							if [ $count != "1" ] 
							then
								if [ $x -ge "$o_count" ]
								then
									added+=(${field[x]})	
									echo "added : ${field[x]}"
								else
									dropped+=(${field[x]})
									echo "dropped : ${field[x]}"
								fi
							else
								continue
							fi
						else
							continue
						fi
					done
					if [ -z "$added" ] && [ -z "$dropped" ]
					then
						echo "\\\\--- NO COLUMNS ADDED OR DROPPED ---////" >> $csv
						echo "" >> $csv
					else
						ping=1
						if [ ! -z "$added" ]
						then
							string_add=""
							let "leng=${#added[@]}-1"
							for (( l=0 ; l<${#added[@]} ; l++ )) 
							do
								if [  -z "${#added[@]}" ]
								then
									if [ $l = "$leng" ] 
                                                                	then
										string_add="$string_add'null'"
										continue
									else
										string_add="$string_add'null',"
                                                                                continue
									fi
								fi
								if [ $l = "$leng" ] 
								then
									string_add="$string_add'${added[l]}'"
								else
									string_add="$string_add'${added[l]}',"
								fi
							done
							echo "\\\\--- ADDED COLUMNS IN ${source_db}.${source_table} ---////" >> $csv
							echo " " >> $csv
							echo "$string_add" >> $csv
							echo " " >> $csv
						fi
						if [ ! -z "$dropped" ]
						then
							string_drop=""
                                                        let "leng1=${#dropped[@]}-1"
                                                        for (( m=0 ; m<${#dropped[@]} ; m++ )) 
                                                        do
								if [  -z "${#dropped[@]}" ]
                                                                then
                                                                        if [ $l = "$leng1" ]
                                                                        then
                                                                                string_drop="$string_drop'null'"
                                                                                continue
                                                                        else
                                                                                string_drop="$string_drop'null',"
                                                                                continue
                                                                        fi
                                                                fi
                                                                if [ $m = "$leng1" ]
                                                                then
                                                                        string_drop="${string_drop}'${dropped[m]}'"
                                                                else
                                                                        string_drop="${string_drop}'${dropped[m]}',"
                                                                fi
                                                        done
                                                        echo "\\\\--- DROPPED COLUMNS IN ${source_db}.${source_table} ---////" >> $csv
                                                        echo " " >>$csv
                                                        echo "$string_drop" >> $csv
							echo " " >> $csv
						fi
					fi
					if [ $ping  = "1" ] 
					then
						echo "\\\\--- MODIFIED COMPLETE RECORDS FROM  ${source_db}.${source_table} ---////" >>$csv
						echo " " >> $csv
						while IFS= read -r aa
						do
							qw=($aa)
							lg=${#qw[@]}
							let "lk=lg-1"
							for (( bb=0 ; bb<$lg ; bb++ )) 
							do
								unset string_add
								if [ -z "${qw[bb]}" ]	
								then
									if [ ${qw[bb]} = ">" ]
                                                                        then
										if [ $lk = "$bb" ]
										then
											string_add="$string_add'null'"
											continue
										else
											string_add="$string_add'null',"								
											continue
										fi
									fi
								fi 
								if [ ${qw[bb]} = ">" ]
								then
									for (( cc=1 ; cc < $lg ; cc++ ))
									do
										if [ $cc = "$lk" ]
										then
											string_add="$string_add'${qw[cc]}'"
										else
											string_add="$string_add'${qw[cc]}',"
										fi
									done
									echo "$string_add" >> $csv
									break
								else 
									continue
								fi
							done
						done < $changes
					fi
				fi
				if [ $ping = "0" ]
				then
					if [ $o_count = "$n_count" ]
                        	        then    
                                	        unset h
						unset x 
                                        	while IFS= read -r x
                                        	do
                                                	h=($x)
                                                	len=${#h[@]}
							let "lm=len-1"	
							if [ ${h[0]} = ">" ] || [ ${h[0]} = "<" ]
                                                        then
                                                        	echo "[NOTE] : READING LINE " 
                                                        else
                                                        	continue
                                                       	fi
							unset string_add
							unset string drop 
                                                	for (( i = 0 ; i < $len ; i++ ))
                                                	do
                                                        	if [ ${h[i]} = ">" ]
                                                        	then
                                                                	for (( dd=1 ; dd < $len ; dd++ ))
                                                                        do
                                                                                if [ $dd = "$lm" ]
                                                                                then
												if [ -z "${qw[dd]}" ]
												then
												string_add="$string_add'null'" 
												continue
												else 
                                                                                        	string_add="$string_add'${qw[dd]}'"
												continue
												fi
                                                                                else
												if [ -z "${qw[dd]}" ]
                                                                                                then
                                                                                                        string_add="$string_add'null'," 
                                                                                                        continue
                                                                                                else
                                                                                        	string_add="$string_add'${qw[dd]}',"
												continue
												fi
                                                                                fi
                                                                        done
                                                        	elif [ ${h[i]} = "<" ]
                                                        	then
                                                                	for (( dd=1 ; dd < $len ; dd++ ))
                                                                        do
										
                                                                                if [ $dd = "$lm" ]
                                                                                then
												if [ -z "${qw[dd]}" ]  
                                                                                             	then
                                                                                                        string_drop="$string_drop'null'"                                                      
                                                                                                        continue
                                                                                                else
                                                                                        	string_drop="$string_drop'${qw[dd]}'"
												continue
												fi
                                                                                else
												 if [ -z "${qw[dd]}" ]  
                                                                                             	 then
                                                                                                        string_drop="$string_drop'null',"                                                                    
                                                                                                        continue
                                                                                                else
                                                                        	                string_drop="$string_drop'${qw[dd]}',"
												continue
												fi
                                                                                fi
                                                                        done
                                                        	else
									continue
                                                        	fi
                                                	done
							if [ -z "$string_add" ] && [  -z "$string_drop" ]
							then
								echo "[NOTE] NO CHANGE ON DATA RECORDS FOR  $source_db}.${source_table} "
                                                               echo "\\\\--- NO CHANGE ON DATA RECORDS FOR  $source_db}.${source_table} ---////" >> $csv
							elif [ ! -z "$string_add" ] && [ -z "$string_drop" ]
							then
								echo "\\\\--- ADDED/UPDATED RECORDS RECORDS FROM TABLE ${source_db}.${source_table} ---////" >> $csv
                                                                        echo "" >> $csv
                                                                        echo "$string_add" >> $csv
									echo "" >> $csv
							elif [  -z "$string_add" ] && [ ! -z "$string_drop" ]
							then
								echo "\\\\--- DELETED/UPDATED RECORDS RECORDS FROM TABLE ${source_db}.${source_table} ---////" >> $csv
                                                                        echo "" >> $csv
                                                                        echo "$string_drop" >> $csv
									echo "" >> $csv
							else
								 echo "\\\\--- DELETED/UPDATED RECORDS RECORDS FROM TABLE ${source_db}.${source_table} ---////" >> $csv
                                                                        echo "" >> $csv
                                                                        echo "$string_drop" >> $csv
								 	echo " " >>  $csv
								echo "\\\\--- ADDED/UPDATED RECORDS RECORDS FROM TABLE ${source_db}.${source_table} ---////" >> $csv                         
                                                                        echo "" >> $csv
                                                                        echo "$string_add" >> $csv
									echo " " >> $csv
								
							fi
							echo " " >> $csv
							echo " " >> $csv
							echo  "\\\\--- END ---////" >> $csv
                                        	done < $changes
					fi
				fi
			fi	
}
restore() {
	restore_status=0
	if [ $restoration_type = "local" ]
	then
		echo "[NOTE] Query framing for restoration"
		if [ $condition = "fulltable" ]
		then
			query="create table $restoration_db.${source_table}_${day} as select * from $source_db.$source_table;"
		else	
			query="create table $restoration_db.${source_table}_${day} as select * from $source_db.$source_table where $condition;"
		fi
		if [ ! -z "$query" ]
		then
			success="Restoration completed for $restoration_db.${source_table}_${day}"
			failure="Restoration failed for $restoration_db.${source_table}_${day}"
			echo "[NOTE] Restoration_started"
			mysql -u $user -h $host -p$pass -e "$query" 
			if [ $? = 0 ]
			then
				status=0
				state="$restoration_db.${source_table}_${day} table created"
				restore_status=0
				check
			else
				status=1
				state="$restoration_db.${source_table}_${day} table not created"
				restore_status=1
				check
			fi
		fi
	elif [ $restoration_type = "remote" ]
	then
		echo "[NOTE] : Dump_started"
                success="Dump success"
                failure="Dump failed "
		if [ $condition = "fulltable" ]
                then
                        mysqldump --user $user --host $host -p$pass --no-create-db --single-transaction --skip-triggers $source_db  $source_table  > $data_dir/${restoration_db}.${source_table}_${day}.sql
			a=$?
                fi
		if [ "$a" = 0 ]
		then
			state="Dump successfully completed for ${source_db}.${source_table}"
			rm -f $data_dir/${restoration_db}.${source_table}_${day}.sql
			status=0
			check
		else
			state="Dump failed for ${source_db}.${source_table}"
			status=1
			restore_status=1
			check
		fi
		success="Name altered"
		failure="name not altered"
		sed -i 's/$source_table/${source_table}_${day}/g' $data_dir/${restoration_db}.${source_table}_${day}.sql
		if [ $? = 0 ]
		then
			state="$source_table altered as ${source_table}_${day}"
			status=0
			check
		else
			state="$source_table not altered as ${source_table}_${day}"
                        status=1
			restore_status=1
                        check	
		fi
		success="Restoration_completed"
		failure="Restoration_failed"
		mysql -u $user -h $restoration_host -p$pass $restoration_db < $data_dir/${restoration_db}.${source_table}_${day}.sql
		if [ $? = 0 ]
		then
			state="Restoration successfully completed for ${restoration_db}.${source_table}_${day}"
                        status=0
			restore_status=0
                        check
                else
                        state="Restoration failed for ${source_db}.${source_table}_${day}"
                        status=1
			restore_status=1
                        check
                fi
	fi
}
mysqlchecks() {
	drop_status=0
	if [ $restoration_type = "local" ] 
	then
		success="Source MySQL is Running" 
		failure="Source MySQL is Not Running"
		mysqlstatus=`mysqladmin ping -u $user -h $host -p$pass `
		#echo "$mysqlstatus"
		if [ "$mysqlstatus" = "mysqld is alive" ]
		then	
			echo "[NOTE] Mysql service is running on the  host [$host]"
			state=$mysqlstatus
			status=0
			exitcheck
		else 
			echo "[NOTE] Job exit Because Mysql service is not running in the  host"  
			state="Please check the mysql service is running on the  server [$host]"
			status=1
			exitcheck
		fi
	elif [ $restoration_type = "remote" ]
	then
		success="Source MySQL is Running"
                failure="Source MySQL is Not Running"
                mysqlstatus=`mysqladmin ping -u $user -h $host -p$pass `
                #echo "$mysqlstatus"
                if [ "$mysqlstatus" = "mysqld is alive" ]
                then    
                        echo "[NOTE] Mysql service is running on the remote host [$host]"
                        state=$mysqlstatus
                        status=0 
                        exitcheck
                else
                        echo "[NOTE] Job exit Because Mysql service is not running or user not created in the host"
                        state="Please check the mysql service is running on the  server or user not created  [$host]"
                        status=1
                        exitcheck
                fi
		success="Restoration server  MySQL is Running"
                failure="Restoration server MySQL is Not Running"
                mysqlstatus=`mysqladmin ping -u $user -h $restoration_host -p$pass `
                #echo "$mysqlstatus"
                if [ "$mysqlstatus" = "mysqld is alive" ]
                then    
                        echo "[NOTE] Mysql service is running on the remote host [$restoration_host]"
                        state=$mysqlstatus
                        status=0
                        exitcheck
                else
                        echo "[NOTE] Job exit Because Mysql service is not running or user not created in the remote host"
                        state="Please check the mysql service is running on the remote server or user not created on  [$restoration_host]"
                        status=1
                        exitcheck
                fi
	fi 
	success="$source_db db.$source_table table exist"
	failure="$source_db.$source_table not exist"
	source=`mysql -u $user -h $host -p$pass -e "select table_schema,table_name from information_schema.tables where table_schema='$source_db' and table_name='$source_table'" -s -N `
	#echo $source
	if [ -z "$source" ]
	then
		echo "[NOTE] database or table doesnot exist , please check the server for proper database or tables"
		state="$source_db db  or $source_table table mentioned is not present in the database"
		status=1 
		check
	else
		b=0
		for a in ${source[@]}
		do
			let "b=b+1"
			if [ $b = "1" ]
			then 
				if [ $a = "$source_db" ]
				then
					echo "[NOTE]: $source_db exist"
					state="$source_db  db present in the database"
					status=0
					check
				else
					echo "[NOTE]: $source_db db not exist in the database"
					state="$source_db db doesnot present in the database"
					status=1
					check
					break
				fi
			elif [ $b = "2" ]
			then
				if [ $a = "$source_table" ]
                                then
                                        echo "[NOTE]: $source_table exist"
					state="$source_table table is present in the database"
					status=0
					check
                                else
                                        echo "[NOTE]: $source_table  table not exist in the database"
					state="$source_table table doesnot present in the database"
                                        status=1
					check
                                        break
                                fi
			else
				break
			fi
		done
	fi
	if [ $restoration_type = "local" ]
	then
		success="$restoration_db exist"
		failure="$restoration_db doesnot exist"
		restoration=`mysql -u $user -h $host -p$pass -e " select schema_name from information_schema.schemata where schema_name='$restoration_db'" -s -N `
		old_table=`mysql -u $user -h $host -p$pass -e " select table_name from information_schema.tables where table_schema='$restoration_db' and table_name='${source_table}_${delete_day}'" -s -N` 
		if [ -z "$restoration" ]
		then
			status=1
			state="$restoration_db db doesnot present , please create a database or use different database for restoration" 
			echo "[NOTE] $restoration_db db doesnot present in the mentioned database " 
			check
		else
			status=0
                	state="$restoration_db db  present in the database "
                	echo "[NOTE] $restoration_db db present in the mentioned database " 
                	check
		fi
		if [ -z "$old_table" ]
		then
			drop_status=2
			status=1
                        state="table for deletion not found " 
			echo "[NOTE] ${source_table}_${delete_day}  table doesnot present in the mentioned database " 
		else
			if [ ${source_table}_${delete_day} = "$old_table" ]
			then
				status=0
                        	state="$old_table  present in the database "
                        	echo "[NOTE] $old_table  present in the mentioned database " 
                        	check
				`mysql -u $user -h $host -p$pass -e "drop table ${restoration_db}.${source_table}_${delete_day}"`
                        	if [ $? = 0 ]
                        	then
					drop_status=0
                                	echo "[NOTE] table dropped ${restoration_db}.${source_table}_${delete_day}"
                        	else
					drop_status=1
                                	echo "[NOTE] table not  dropped ${restoration_db}.${source_table}_${delete_day}"
                        	fi
			else
				continue
			fi
		fi
	elif [ $restoration_type = "remote" ]
	then
		old_table=`mysql -u $user -h $restoration_host -p$pass -e " select table_name from information_schema.tables where table_schema='$restoration_db' and table_name='${source_table}_${delete_day}'" -s -N`
		success="$restoration_db exist"
                failure="$restoration_db doesnot exist"
                restoration=`mysql -u $user -h $restoration_host -p$pass -e " select schema_name from information_schema.schemata where schema_name='$restoration_db'" -s -N `
                if [ -z "$restoration" ]
                then
                        status=1
                        state="$restoration_db db doesnot present , please create a database or use different database for restoration"
                        echo "[NOTE] $restoration_db db doesnot present in the mentioned database "
                else
                        status=0
                        state="$restoration_db db  present in the database "
                        echo "[NOTE] $restoration_db db present in the mentioned database "
                        check
                fi
		if [ -z "$old_table" ]
                then
			drop_status=2
                        status=1
                        state="table for deletion not found "
                        echo "[NOTE] ${source_table}_${delete_day}  table doesnot present in the mentioned database "
                        check
                else
                        if [ ${source_table}_${delete_day} = "$old_table" ]
                        then
                                status=0
                                state="$old_table  present in the database "
                                echo "[NOTE] $old_table  present in the mentioned database "
                                check
				`mysql -u $user -h $restoration_host -p$pass -e "drop table ${restoration_db}.${source_table}_${delete_day}"`
                        	if [ $? = 0 ]
                        	then
                                	drop_status=0
                                	echo "[NOTE] table dropped ${restoration_db}.${source_table}_${delete_day}"
                        	else
					drop_status=1
                                	echo "[NOTE] table not  dropped ${restoration_db}.${source_table}_${delete_day}"
                        	fi
                        else
                                continue
                        fi
                fi
	fi
}
init() 
{
	source_path="/home/vagrant/data_difference"
	config_path="$source_path/config"
	data_dir="$source_path/data_dir"
	csv_dir="$source_path/csv_dir"
	pass='Myuser@123'
	skips=0
	day=`date +"%Y_%m_%d_%S"`
	delete_day=`date -d "-7 days" +"%Y_%m_%d_%S"`
	array()
	{
        	while IFS= read -r config
        	do
                	input=($config)
			declare() {
                		user=${input[0]}
                		host=${input[1]}
                		source_db=${input[2]}
                		source_table=${input[3]}
				condition=${input[4]}
                		restoration_db=${input[5]}
				restoration_type=${input[6]}
				if [ $restoration_type = "remote" ]
				then
					echo -e "\e[1:34m REMOTE RESTORATION FOR $source_db.$source_table \e[0m"
					restoration_host=${input[7]}				
				elif [ $restoration_type = "local" ]
				then
					 echo -e "\e[1:34m LOCAL RESTORATION FOR $source_db.$source_table \e[0m"
				else
					echo -e "\e[1:34m PLEASE MENTION RESTORATION TYPE  $source_db.$source_table \e[0m"
					echo -e "\e[1;31m[$timestamp]\e[0m \e[1;34m JOB SKIPS CURRENT CONFIG  \e[0m"
                			continue
				fi
				echo -e "\e[1;34m JOB STARTS FOR $source_db.$source_table \e[0m" 
                		if [ "$condition" = "fulltable" ]
                		then
					echo "[NOTE] $source_table table have condition"
                		else
                        		echo "[NOTE] $source_table table dont have condition"
                		fi
                		if [ ! -z "$user" ] && [ ! -z "$host" ] && [ ! -z "$source_db" ] && [ ! -z "$source_table" ] && [ ! -z "$restoration_db" ]
                		then
					echo "[NOTE] SOURCE_DATABASE      : $source_db"
					echo "[NOTE] SOURCE_TABLE         : $source_table"
					echo "[NOTE] RESTORATION_DATABASE : $restoration_db"
					if [ ! -z $condition ] 
					then
						echo "[NOTE] CONDITION FOR $source_table : $condition"
					else
						echo "[NOTE] CONDITION FOR $source_table : $condition"
					fi	
					status=0
					state="Job proceeding for $source_table"
					success="Features Declared"
                		else
					status=1
					state="Job skipped for $source_table / Give proper config"
                                        success="Features Not Declared"
                		fi
				exitcheck
				echo "[NOTE]: Proceeding to mysqlchecks" 
				mysqlchecks
				restore
				data_diff
				table_header
				mail_build
				notify
        		}
			declare	
			#echo $user $host $source_db $restoration_db
        	done < $config_path
	}
	array
}
init 