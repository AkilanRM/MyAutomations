#!/bin/bash
init() {
echo " STRUCTURE MIGRATION AND TABLE MIGRATION OF SCHEMAS "
jobpath=/home/vagrant/structure_migration
tunnel=/home/vagrant/.ssh/config
config=$jobpath/config
restorationhost=uat_schema
sourcehost=kreditbee_backup
host_ip=192.168.33.11
dest_ip=192.168.33.12
tabledump_option="--single-transaction --no-create-db --no-create-info --skip-triggers"
structuredump_option="--single-transaction --no-create-db --no-data --skip-triggers"
destination_path=/home/mydbops/structure_data
source_path=$jobpath/structure_data
mail="akirtawerosoo@gmail.com,madhavangs@mydbops.com"
dateval=`date +"%Y-%m-%d"`
}
init
mail_sub(){
        echo  "FROM: 'MYDBOPS' <Logical_migration@mydbops.com>"
        echo  "TO:${mail[@]}" 
        echo "Subject:LIVE LOGICAL MIGRATION TESTING" 
        echo  "Content-type: text/html" 
        echo  "Hi Team,<br><br>"
	echo  "<br><br>"
        echo "<h3>SOURCE_HOST     :     $sourcehost [$host_ip]</h3>" 
        echo "<h3>DESTINATION_HOST:     $restorationhost [$dest_ip]</h3>"
	echo  "<br><br>" 
	echo "KREDITBEE : LIVE MIGRATION AND RESTORATION STATUS TO UAT"
	echo  "<br><br>"
        echo "Please check the live migration status of complete schema structure and table data for $dateval."
}> /tmp/output_table.html
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
mail_sub
fail_mail(){
		unset mail
                mail=( "akirtawerosoo@gmail.com" "madhavangs@mydbops.com" )
                echo "<html><head>" >>/tmp/output_table.html
                echo  "<br><br>" >> /tmp/output_table.html
                echo "<body>" >>/tmp/output_table.html
		echo "<h4><p style="color:red">$f</p></h4>"  >>/tmp/output_table.html
                echo "<h2><p style="color:red">JOB FAILED </p></h2>" >>/tmp/output_table.html
                echo  "<br><br>" >> /tmp/output_table.html
                echo "Please check the errorlog file (logicalmigrate.log) for the exact status of failure. Live migration failed at $dateval for logical migration between $sourcehost to $restorationhost." >>/tmp/output_table.html
                echo  "<br><br>" >> /tmp/output_table.html
                echo "Please check the dependencies or errors from the logs and restart the job ." >> /tmp/output_table.html
                echo "</body>" >>/tmp/output_table.html
                echo "</head></html>" >> /tmp/output_table.html
                echo  "<br><br>" >> /tmp/output_table.html
                echo "thanks" >>/tmp/output_table.html
		echo  "<br><br>" >> /tmp/output_table.html
                echo "mydbops_team" >>/tmp/output_table.html
}
check() {
        if [ $? = 0 ]
        then
		x=`date +'%Y-%m-%d:%H:%M:%S'`
                output="[$x][CONTINUE][PROGRESSING]: $s"
		echo -e "\e[1;32m $output \e[0m "
        else
		x=`date +'%Y-%m-%d:%H:%M:%S'`
        	output="[$x][ERROR][EXIT]: $f"
		echo -e "\e[1;31m $output \e[0m "
		fail_mail
		send_mail
	        exit 0 
        fi
}
mail_header(){
	if [ ${arr[0]} = "structure" ]
        then
                {
                        echo  "<html><body>"
                        echo  "<br><br>"
                        echo "COMPLETE STRUCTURE MIGRATION STATUS FOR SCHEMAS."
			echo  "<br><br>" >> /tmp/output_table.html
                        echo "<foint size=2><table align='center' cellspacing='0' cellpadding='10' border='1' width=75%><tr bgcolor='#81c784' style='text-align: center;' style='font-weight:bold;'><th>SCHEMA</th><th>DUMP_STATUS</th><th>DUMP_TIME</th><th>MIGRATION_STATUS</th><th>MIGRATION_TIME</th><th>RESTORATION_STATUS</th><th>RESTORATION_TIME</th><th>JOB_TIME</th><th>JOB_STATUS</th></tr>"
                } >>/tmp/output_table.html
	elif [ ${arr[0]} = "table" ]
        then
		{
                        echo  "<html><body>"
                        echo  "<br><br>"
                        echo "COMPLETE TABLE DATA MIGRATION STATUS FOR   ${db}   DATABSE."
			echo  "<br><br>" >> /tmp/output_table.html
                        echo "<font size=2><table align='center' cellspacing='0' cellpadding='10' border='1' width=75%><tr bgcolor='#81c784' style='text-align: center;' style='font-weight:bold;'><th>SCHEMA</th><th>TABLE</th><th>DUMP_STATUS</th><th>DUMP_TIME</th><th>MIGRATION_STATUS</th><th>MIGRATION_TIME</th><th>RESTORATION_STATUS</th><th>RESTORATION_TIME</th><th>JOB_TIME</th><th>STATUS</th></tr>"
                } >>/tmp/output_table.html
	fi
}
mail_build(){
	if [ ${arr[0]} = "structure" ]
	then
		if [ -z "$dump_status" ] 
		then 
			echo "<tr bgcolor='#d9d9d9'><td style='color:black'>${val}</td><td style='color:red'>NOT DONE</td><td style='color:black'>-</td><td style='color:red'>NOT DONE</td><td style='color:balck'>-</td><td style='color:red'>NOT DONE</td><td style='color:black'>-</td><td style='color:black'>-</td><td style='color:red'>FAILED</td></tr>" >> /tmp/output_table.html		
		elif [ ! -z "$dump_status" ] && [ -z "$migrate_status" ]
		then	
			echo "<tr bgcolor='#d9d9d9'><td style='color:black'>${val}</td><td style='color:green'>DONE</td><td style='color:black'>$dump_time SECS</td><td style='color:red'>NOT DONE</td><td style='color:balck'>-</td><td style='color:red'>NOT DONE</td><td style='color:black'>-</td><td style='color:black'>-</td><td style='color:red'>FAILED</td></tr>" >> /tmp/output_table.html
		elif [ ! -z "$dump_status" ] && [ ! -z "$migrate_status" ] && [ -z "$restore_status" ]
		then
			echo "<tr bgcolor='#d9d9d9'><td style='color:black'>${val}</td><td style='color:green'>DONE</td><td style='color:black'>$dump_time SECS</td><td style='color:green'>DONE</td><td style='color:balck'>$migrate_time SECS</td><td style='color:red'>NOT DONE</td><td style='color:black'>-</td><td style='color:black'>-</td><td style='color:red'>FAILED</td></tr>" >> /tmp/output_table.html
		elif [ ! -z "$dump_status" ] && [ ! -z "$migrate_status" ] && [ ! -z "$restore_status" ]
		then
			let "total_time=dump_time+migrate_time+restore_time"
			echo "<tr bgcolor='#d9d9d9'><td style='color:black'>${val}</td><td style='color:green'>DONE</td><td style='color:black'>$dump_timeSECS</td><td style='color:green'>DONE</td><td style='color:balck'>$migrate_time SECS</td><td style='color:green'>DONE</td><td style='color:black'>$restore_time SECS</td><td style='color:black'>$total_time SECS</td><td style='color:green'>SUCCESS</td></tr>" >> /tmp/output_table.html
		fi
		if [ $z = "1" ]
		then
			{
				echo "</table>"
				echo "</head></html>" 
			}>>/tmp/output_table.html
		fi
	elif [ ${arr[0]} = "table" ]
	then
		if [ -z "$dump_status" ] 
		then 
			echo "<tr bgcolor='#d9d9d9'><td style='color:black'>${db}</td><td style='color:black'>${val}</td><td style='color:red'>NOT DONE</td><td style='color:black'>-</td><td style='color:red'>NOT DONE</td><td style='color:balck'>-</td><td style='color:red'>NOT DONE</td><td style='color:black'>-</td><td style='color:black'>-</td><td style='color:red'>FAILED</td></tr>" >> /tmp/output_table.html		
		elif [ ! -z "$dump_status" ] && [ -z "$migrate_status" ]
		then	
			echo "<tr bgcolor='#d9d9d9'><td style='color:black'>${db}</td><td style='color:black'>${val}</td><td style='color:green'>DONE</td><td style='color:black'>$dump_time SECS</td><td style='color:red'>NOT DONE</td><td style='color:balck'>-</td><td style='color:red'>NOT DONE</td><td style='color:black'>-</td><td style='color:black'>-</td><td style='color:red'>FAILED</td></tr>" >> /tmp/output_table.html
		elif [ ! -z "$dump_status" ] && [ ! -z "$migrate_status" ] && [ -z "$restore_status" ]
		then
			echo "<tr bgcolor='#d9d9d9'><td style='color:black'>${db}</td><td style='color:black'>${val}</td><td style='color:green'>DONE</td><td style='color:black'>$dump_time SECS</td><td style='color:green'>DONE</td><td style='color:balck'>$migrate_time SECS</td><td style='color:red'>NOT DONE</td><td style='color:black'>-</td><td style='color:black'>-</td><td style='color:red'>FAILED</td></tr>" >> /tmp/output_table.html
		elif [ ! -z "$dump_status" ] && [ ! -z "$migrate_status" ] && [ ! -z "$restore_status" ]
		then
			let "total_time=dump_time+migrate_time+restore_time"
			echo "<tr bgcolor='#d9d9d9'><td style='color:black'>${db}</td><td style='color:black'>${val}</td><td style='color:green'>DONE</td><td style='color:black'>$dump_time SECS</td><td style='color:green'>DONE</td><td style='color:balck'>$migrate_time SECS</td><td style='color:green'>DONE</td><td style='color:black'>$restore_time SECS</td><td style='color:black'>$total_time SECS</td><td style='color:green'>SUCCESS</td></tr>" >> /tmp/output_table.html
		fi
		if [ $z = "1" ]
                then
                        {
                                echo "</table>"
                                echo "</head></html>" 
                        }>>/tmp/output_table.html
                fi		
	fi
}
tunnelling_restore(){
	restore(){
		restore_status=""
		echo "[NOTE]: Restoration  started for $val"
        	s="$file restored to destination_host $restorationhost , completed ...SUCCESS"
        	f="$file not restored to destination_host $restorationhost , not completed ...FAILED"
        	start=$SECONDS
        	`ssh -q -o "StrictHostKeyChecking no" $restorationhost  "mysql $database < $destination_path/$file" >> restoreerr < /dev/null`
         	check
        	stop=$SECONDS
		restore_status="SUCCESS"
        	let "restore_time=stop-start"
       		echo "[NOTE]: Restoration completed for $val"
	}
	migrate_status=""
	echo "[NOTE]: Tunnelling  started"
	s="$file migrated to $destination_path ...SUCCESS"
	f="$file failed migration to $destination_path , please check the #tunnelerr# file ...FAILED"
	start=$SECONDS
	`rsync -a $source_path/$file uat_schema:$destination_path/   >> tunnelerr`
	check 
	stop=$SECONDS
	migrate_status="SUCCESS"
	let "migrate_time=stop-start"
	echo "[NOTE]: Tunnelling completed for $val"
	restore
}
tables() {
	l=${#table[@]}
	z=0
	for (( a=0 ; a < l ; a++ ))
	do
		dump_status=""
		unset val
		val=${table[a]}
		echo "[NOTE]: DUMP STARTED FOR ${db}.${val}"
		s="Dump successful completed for ${db}.${val} ...SUCCESS"
		f="Dump failed for ${db}.${val} ,Please check the #dumperr# file ...FAILED"
		file=kb_${db}_${val}.sql 
		start=$SECONDS
		`mysqldump $tabledump_option $db $val > $source_path/$file 2>>dumperr`
		check
		stop=$SECONDS
		dump_status="SUCCESS"
		let "dump_time=stop-start"
		#echo "dumptime"
		echo "[NOTE]: Dump completed for ${db}.${val}"
		tunnelling_restore
		let "q=l-1"
		if [ $a = "$q" ]
		then
			z=1
		fi
		mail_build
		continue
	done		
}
structures() {
        l=${#structure[@]}
	z=0
        for (( a=0 ; a < l ; a++ ))
        do
		dump_status=""
		unset val
                val=${structure[a]}
		database=${structure[a]}
                echo "[NOTE]: DUMP STARTED FOR ${val}"
                s="Structure Dump successful completed for ${val} ...SUCCESS"
                f="Structure Dump failed for ${val} , Please check the #dumperr# file ...FAILED"
		file=kb_${val}.sql
                start=$SECONDS
                `mysqldump $structuredump_option $val > $source_path/$file | 2>dumperr`
                check
                stop=$SECONDS
		dump_status="SUCCESS"
                let "dump_time=stop-start"
                #echo "dumptime"
		echo "[NOTE]: DUMP completed for ${val}"
                tunnelling_restore
		let "p=l-1"
                if [ $a = "$p" ]
                then
                        z=1
                fi
		mail_build
		continue
        done
}
array() {
	while IFS= read -r v
	do
		tab_val=0
		struct_val=0
                unset arr
                unset table
                unset structure
		unset database
		arr=($v)
		len=${#arr[@]}
		if [ ${arr[0]} = "table" ]
                then
			db=${arr[1]}
			f="Table migration cancelled , now exit state "
                        s="Ready for table migration"
			for (( i = 2 ; i < len ; i++ ))
			do
				#echo "${arr[i]}"
				table+=(${arr[i]})
			done
			check
			database=${arr[1]}
			echo "$database"
			mail_header
			tables
		fi
		if [ ${arr[0]} = "structure" ]
                then
			f="schema structure migration cancelled , now exit state "
                        s="Ready for schema structure migration "
                        for (( j = 1 ; j < len ; j++ ))
                        do
                                #echo "${arr[j]}"
				structure+=(${arr[j]})
                        done
                        check
			echo "$database"
			mail_header
			structures
                fi
	done <$config
}
validate() {
	s=""
	f=""
	src_check=`pgrep mysqld`
	x=`date +'%Y-%m-%d:%H:%M:%S'`
	if [ -z "$src_check" ]
	then
		f="SOURCE  MYSQL service not  running , now exit state"
		echo -e "\e[1;31m [$x][ERROR]: SOURCE  MYSQL service not  running , now exit state \e[0m"
		fail_mail
		send_mail
		exit 0 
	else
		echo -e "\e[1;32m [$x][CONTINUE]: SOURCE  MYSQL service  running  \e[0m"
	fi
	if [ -f "$tunnel" ]
	then
		echo -e "\e[1;32m [$x][CONTINUE]: SSH TUNNELLING config exist \e[0m"
		f="NOT CONNECTING the end server , check the tunnelling config "	
		s="CONNECTING the end server" 
		`ssh $restorationhost "exit 0 " `
		check      
	else
		f="SSH TUNNELLING config doesnot exist"
		echo -e "\e[1;31m [$x][ERROR]: SSH TUNNELLING config doesnot exist \e[0m " 
		fail_mail
		send_mail
		exit 0
	fi
	dest_check=`ssh $restorationhost "pgrep mysqld"`
	x=`date +'%Y-%m-%d:%H:%M:%S'`
	if [ -z "$dest_check" ]
	then
		f=" DESTINATON MYSQL serivce not running , now exit state"
		echo -e "\e[1;31m [$x][ERROR]: DESTINATON MYSQL serivce not running , now exit state \e[0m " 
		fail_mail
		send_mail
		exit 0 
	else
		echo -e "\e[1;32m [$x][CONTINUE]: DESTINATION  MYSQL service  running \e[0m"
	fi 
	binlogdump=`which mysqldump | grep -i 'no mysqldump' `
	remotebinlogdump=`ssh $restorationhost "which mysqldump | grep -i 'no mysqlbinlog'"`
	x=`date +'%Y-%m-%d:%H:%M:%S'`
	if [ -z "$binlogdump" ]
	then
		echo -e "\e[1;32m [$x][CONTINUE]: source mysqldump utility exist \e[0m"
	else
		f="Source host Needs Mysqlbinlog Utility , now exit state"
		echo -e "\e[1;31m [$x][ERROR]: source host Need Mysqldump Utility , now exit state \e[0m "
		fail_mail
		send_mail
		exit 0
	fi
	x=`date +'%Y-%m-%d:%H:%M:%S'`
	if [ -z "$remotebinlogdump" ]
        then
                echo -e "\e[1;32m [$x][CONTINUE]: destination mysqldump utility exist \e[0m  "
        else
		f="Destination host Need Mysqlbinlog Utility , now exit state"
                echo -e "\e[1;31m [$x][ERROR]: destination host Need Mysqldump Utility , now exit state \e[0m   "
                fail_mail
		send_mail
		exit 0
        fi
	array
}
validate
echo "<br><br>" >> /tmp/output_table.html
echo "thanks" >> /tmp/output_table.html
echo "mydbops_team" >> /tmp/output_table.html 
send_mail