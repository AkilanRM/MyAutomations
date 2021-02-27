#!/bin/bash
set -x
echo "HI"
day=`date +"%Y%B%d"`
s_name="kreditbee_slave1"
s_host="172.25.12.217"
dir=("$day")
#echo "$dir"
orginal=/data/mysql
#end="mysql-bin.010529"
name="binlog"
file_name=mysql-bin.
mail=( "dba-group@mydbops.com" "hackerboy0403@gmail.com" )
copy=/data/mybin/$name
tar_path=/data/mybin/bin
script_path=/usr/local/mydbops/binlog_migration
list=$script_path/binlog_list
cd $orginal
ls  | grep -i $file_name  > $list
number=`ls  | grep -i $file_name | wc -l `
#if (( $number > 1000 ))
#then                                                                                          ###############################
#	echo "too many binary logs"                                                            #     AUTHOR : AKILAN RM      #  
#	exit 0                                                                                 ###############################
#fi
region="--region=ap-south-1"
s3_path=s3://kreditbee-binlog-backup
filetest=$script_path/last_file
partition="/data"
#echo "$partition"
cd $script_path
df -h $partition  > space
cat space
echo  "FROM: 'MYDBOPS' <BINLOG_BACKUP@mydbops.com>" > /tmp/output_table.html
echo  "TO:$to " >> /tmp/output_table.html
echo "Subject:BINLOG_BACKUP" >> /tmp/output_table.html
echo  "Content-type: text/html" >> /tmp/output_table.html
echo  "Hi Team,<br><br>" >> /tmp/output_table.html
echo "<h2> SERVER NAME : $s_name  <h2> " >> /tmp/output_table.html
echo "<h2>SERVER  IP : $s_host <h2>" >> /tmp/output_table.html
echo "<h3> TOTAL NO OF BINLOGS CURRENTLY IN THE SERVER : $number <h3>" >> /tmp/output_table.html				
echo "<font size=2><table align='center' cellspacing='0' cellpadding='10' border='1' width=75%><tr bgcolor='#81c784' style='text-align: center;' style='font-weight:bold;'><th>DATE</th><th>FILE_NAME</th><th>STATUS</th></tr>" >> /tmp/output_table.html
echo  "<html><body>" >> /tmp/output_table.html
echo  "<br><br>" >> /tmp/output_table.html	
while IFS= read -r n
do

        space_data=($n)
        l=${#space_data[@]}
        for (( m=0 ; m<l ; m++ ))
        do
                if [ "${space_data[0]}" = "Filesystem" ]
                then
                        break
                else
                        c=${#space_data[3]}
                        d=${#space_data[4]}
                        e=${#space_data[1]}
                        #echo $c $d
                        available=${space_data[3]:0:c-1}
                        percent=${space_data[4]:0:d-1}
                        #total=${space_data[1]:0:e-1}
                        #balance=$((total-available))
                        #echo "$balance"
                        if (( $available  < 80 ))
                        then
				#echo "USED SPACE : " $balance 
                                echo "DISK SPACE IS HIGH ______-_______-______ PLEASE ADD MORE SPACE"
                                exit 0
                        elif (( $percent > 98 ))
                        then
                                echo "DISK SPACE IS HIGH ______-_______-______ PLEASE ADD MORE SPACE"
				exit 0 
			else
				echo "SPACE AVAILABLE FOR PROGRESS"
				continue 
                        fi
                fi
        done

done < space
rm -f space
arr()
{
        while IFS= read -r file
        do
                binlog=($file)
                arr+=("$binlog")
        done < $list
}
arr
len=${#arr[@]}
echo "$len  FILES IN THE SERVER"
let "x=len-1"
let "z=x-1"
let "k=z-1"
dumping (){
        for (( i=0 ; i < $len ; i++ ))
        do
                migrate=${arr[i]}
                check=$migrate
                #echo "$check"
                if [ $i -eq $x ]
                then
                        #echo "${arr[i]}"
                        echo "NO NEED TO MIGRATE INDEX FILE"
                        continue
                else
                        while IFS= read -r t
                        do
                                #echo "$t"
                                check1=$t
                                echo "$check1"
                        done < $filetest
			echo "$check1"
                        if [  -z  "$check1" ]
                        then
				if [ $i = $z ]
				then
					continue
				fi
                                echo "$migrate" && echo "FULL MIGRATION"
                                cp $orginal/$migrate  $copy/$migrate
				cd $copy
                                tar -cvzf binlog_$dir.$i.tar.gz -P $migrate
                                echo $migrate "IS ZIPPED ---------->Success"
                                rm -f $migrate
				if [ $a -eq $k ]
                              	then
                                      continue
                                fi
				`mysql -e "purge binary logs to '$migrate'"`
				cd -
                                continue
                        elif [ $check1 = "$check" ]
                        then
                                let "y=i+1"
                                echo " ZIP STARTS FROM POSITION $y"
				`rm -f $orginal/$check1`
                                for (( a = $y ; a < $len ; a++ ))
                                do
					if [ $a = $z ]
					then
						continue
					fi
                                        if [ $a -eq $x ]
                                        then
                                                i=$z
                                                continue
                                        fi
                                        migrate=${arr[a]}
					#if [ $migrate = "$end" ]
					#then
					#	break
					#fi
                                        echo $migrate && echo "PARTIAL MIGRATION"
                                        cp $orginal/$migrate  $copy/$migrate
					cd $copy
                                        tar -cvzf binlog_$dir.$a.tar.gz -P $migrate
                                        echo $migrate "IS ZIPPED ---------->Success"
                                        rm -f $copy/$migrate
					if [ $a -eq $k ]
					then
						continue
					fi
					`mysql -e "purge binary logs to '$migrate'"`
					cd -
                                        continue
                                done
                        else
                                echo "SKIPPED" $migrate && echo "AlREADY_EXIST"
                                `mysql -e "purge binary logs to '$migrate'"`
				continue
                        fi
                fi

        done
        last=${arr[k]}
        #echo $last
        echo "$last" > $filetest
        if [ "$(ls -A $copy/)" ]
        then
                echo "ZIPPED FILE WAITING TO MIGRATE TO S3 BUCKET"
                echo "TARBALL"
                cd /data/mybin/
                tar cvzf  $tar_path/binlog_$dir.tar.gz  -P $name
                echo "TAR BALL COMPRESSED <----------------------> READY FOR S3 MIGRATION "
                if [ $? = 0 ]
                then
                        echo "Zipped"
                        rm -f $copy/*
                fi
                cd $tar_path
                aws s3 cp   $region binlog_$dir.tar.gz  $s3_path/   
                if [ $? = 0 ]
                then
                        echo "ZIP FILE WAS SUCCESSFULLY MOVED TO S3 BUCKET -------> SUCCESS"
                 	echo "<tr bgcolor='#d9d9d9'><td style='color:green'>$day</td><td style='color:green'>binlog_$dir.tar.gz</td><td style='color:green'>SUCCESS</td></tr>" >> /tmp/output_table.html
               		rm -f $tar_path/binlog_$dir.tar.gz 
		 else
                        echo "ZIP FILE WAS NOT MOVED -------> FAILED"
			 echo "<tr bgcolor='#d9d9d9'><td style='color:red'>$day</td><td style='color:red'>binlog_$dir.tar.gz</td><td style='color:red'>FAILED</td></tr>" >> /tmp/output_table.html
                fi
        else
                rm -f $copy/*
                echo "NO ZIPPED FILES TO MIGRATION"
		echo "<h3> NO BINLOGS TO MIGRATE <h3>" >> /tmp/output_table.html				
		 echo "<tr bgcolor='#d9d9d9'><td style='color:brown'>$day</td><td style='color:brown'>TAR NOT FOUND</td><td style='color:brown'>NO FILES TO MIGRATE !!</td></tr>" >> /tmp/output_table.html	
        fi
}
dumping
echo "</table>" >> /tmp/output_table.html
echo "  Thanks " >> /tmp/output_table.html
echo "Mydbops Team" >> /tmp/output_table.html
echo "</body></html>" >> /tmp/output_table.html
`scp /tmp/output_table.html root@172.25.12.34:/tmp/output_table.html`
for to in ${mail[@]} 	
do
	`ssh root@172.25.12.34 " cat /tmp/output_table.html | sendmail $to " `	
	 if [ $? = 0 ]
	 then
		echo "MAIL SUCCESSFULLY SENT TO $to "
	 else
		echo "MAIL NOT SENT TO $to"
	 fi
done