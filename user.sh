#!/bin/bash

set -x
mail=("akirtawerosoo@gmail.com" )
server_path=/home/vagrant/user/server
info_path=/home/vagrant/user/USERHOST
script_path=/home/vagrant/user
persisted=/home/vagrant/user/persisted_files
#set -x
user="user_collector"
password="User@2020"
dateval=`date +"%Y_%m_%d"`
value=$(date -d "-0 day" +%Y_%m_%d)
{
	echo  "FROM: 'MYDBOPS' <user_info@mydbops.com>"
        echo  "TO:${mail[@]}" 
        echo "Subject:USERINFO" 
        echo  "Content-type: text/html" 
        echo  "Hi Team,<br><br>"  
} > /tmp/output_table.html
nochange()
{
        echo "<h3> LAST UPDATED USER LIST <h3>" >> /tmp/output_table.html
        echo  "<html><body>" >> /tmp/output_table.html
        echo  "<br><br>" >> /tmp/output_table.html
        echo "<font size=2><table align='center' cellspacing='0' cellpadding='10' border='1' width=75%><tr bgcolor='#81c784' style='text-align: center;' style='font-weight:bold;'><th>USER</th><th>HOST</th><th>GRANTS</th></tr>" >> /tmp/output_table.html
        while IFS=  read -r userinfo
        do
                update=($userinfo)
                user_list=(${update[0]})
                host_list=(${update[1]})
                if [ $user_list = "user" ] && [ $host_list = "host" ]
                then
                        echo "USER,HOST,GRANTS" >> $info_path/$name.csv
                        continue
                else
                	G=`mysql -u $user -h $host -p$password -e "show grants for '$user_list'@'$host_list'" -s -N`
			echo $G
                	echo "<tr bgcolor='#d9d9d9'><td style='color:green'>$user_list</td><td style='color:green'>$host_list</td><td style='color:green'>$G</td></tr>" >> /tmp/output_table.html
                	echo $user_list","$host_list","$G >> $info_path/$name.csv
		fi
        done < $info_path/UserHost_${name}_${dateval}
        echo  "</body></html>" >> /tmp/output_table.html
        echo "</table>" >> /tmp/output_table.html
}
add()
{
        echo "<h3> NEW  USER  <h3> " >> /tmp/output_table.html
        echo  "<html><body>" >> /tmp/output_table.html
        echo  "<br><br>" >> /tmp/output_table.html
        echo "<font size=2><table align='center' cellspacing='0' cellpadding='10' border='1' width=75%><tr bgcolor='#81c784' style='text-align: center;' style='font-weight:bold;'><th>USER</th><th>HOST</th></tr>" >> /tmp/output_table.html
        echo "<tr bgcolor='#d9d9d9'><td style='color:green'>$add_user</td><td style='color:green'>$add_host</td></tr>" >> /tmp/output_table.html
        echo "##ADDED USER##" >> $info_path/$name.csv
        echo "USER,HOST" >> $info_path/$name.csv
        echo $add_user","$add_host >> $info_path/$name.csv
        echo  "</body></html>" >> /tmp/output_table.html
        echo "</table>" >> /tmp/output_table.html


}
drop()
{
	{
        	echo "<h3> DROPPED USER  <h3> " >> /tmp/output_table.html
        	echo  "<html><body>" >> /tmp/output_table.html
        	echo  "<br><br>" >> /tmp/output_table.html
       		echo "<font size=2><table align='center' cellspacing='0' cellpadding='10' border='1' width=75%><tr bgcolor='#81c784' style='text-align: center;' style='font-weight:bold;'><th>USER</th><th>HOST</th></tr>" >> /tmp/output_table.html
       		echo "<tr bgcolor='#d9d9d9'><td style='color:red'>$drop_user</td><td style='color:red'>$drop_host</td></tr>" >> /tmp/output_table.html
        	echo "##DROPPED USER##" >> $info_path/$name.csv
        	echo "USER,HOST" >> $info_path/$name.csv
        	echo $drop_user","$drop_host >> $info_path/$name.csv
        	echo  "</body></html>" >> /tmp/output_table.html
        	echo "</table>" >> /tmp/output_table.html
	}

}
while IFS= read -r server
do
        change=0
        j=0
        #echo $server
        arr=($server)
        #echo "${arr[1]}"
        name=${arr[0]}                                                                                                      ###########################
        host=${arr[1]}                                                                                                      ###  AUTHOR:AKILAN RM  ####
        if [ -f $info_path/UserHost_${name}_${value} ]                                                                      ###########################
        then
                old=($(md5sum $info_path/UserHost_${name}_${value}))
        else
              ` mysql -u $user -h $host -p$password -e "select user , host from mysql.user;" > $info_path/UserHost_${name}_${dateval}`
                #nochange
		continue 
        fi
        `mysql -u $user -h $host -p$password -e "select user , host from mysql.user;" > $info_path/UserHost_$name`
	new=($(md5sum $info_path/UserHost_$name))
        total=`cat $info_path/UserHost_$name | wc -l `
        old_total=`cat $info_path/UserHost_${name}_${value} | wc -l`
        let "total_user=total-1"
	{
		echo "<h2> SERVER NAME : $name  <h2> " 
        	echo "<h2>SERVER  IP : $host <h2>" 
        	echo "<h3> TOTAL NO OF USER IN THE SERVER : $total_user <h3>" 
        	echo  "<font face='verdana'>"
	} >> /tmp/output_table.html
        if [ ${old[0]} == "${new[0]}" ]
        then
                echo " NO CHANGE IN THE USER LIST "
                nochange
		rm -rf $info_path/UserHost_$name
                #change=0
        else
                echo "CHANGE IN USER LIST" 
                difference=`diff  $info_path/UserHost_${name}_${value} $info_path/UserHost_$name`
		mv $info_path/UserHost_${name}_${value}  $persisted/UserHost_${name}_${value}
		rm -f $info_path/UserHost_${name}_${value}
		mv $info_path/UserHost_$name $info_path/UserHost_${name}_${dateval}
                echo $difference  > $info_path/changes
                while IFS= read -r x
                do
                        c=($x)
                        len=${#c[@]}
                        for (( i=1; i<$len ;i++ ))
                        do
                                if [ ${c[i]} = ">" ]
                                then
                                        add_user=${c[i+1]}
                                        add_host=${c[i+2]}
                                        echo "$add_user $add_host"
                                        add
                                elif [ ${c[i]} = "<" ]
                                then
                                        drop_user=${c[i+1]}
                                        drop_host=${c[i+2]}
                                        echo "$drop_user $drop_host"
                                        drop
                                else
                                        continue
                                fi
                         done
                done < $info_path/changes
                nochange
        fi
echo "FROM: 'MYDBOPS' <user_info@kreditbee.com> "> $info_path/csv
echo " " >> $info_path/csv
echo "Hi Team, " >> $info_path/csv
echo " " >> $info_path/csv
echo "SERVER NAME : $name " >> $info_path/csv
echo "SERVER  IP : $host " >> $info_path/csv
echo "TOTAL NO OF USER IN THE SERVER : $total_user "  >> $info_path/csv
echo " " >> $info_path/csv
echo "THIS IS THE UPDATED USER LIST IN THE CSV FORMAT FILE  OF HOST_IP  $host " >> $info_path/csv
echo " " >> $info_path/csv
for t in ${mail[@]}
do
        `cat $info_path/csv | mail -a $info_path/$name.csv -s " USER INFO FILE : $name  
         $host"  $t .`
done
if [ $? = 0 ]
then
        echo "ok : MAIL SENT "
        `rm -f $info_path/$name.csv`
        `rm -f $info_path/csv`
else
        echo "not OK: MAIL NOT SENT "
fi

done < $server_path
echo "thanks" >> /tmp/output_table.html
echo "MYDBOPS_TEAM" >> /tmp/output_table.html
for to in ${mail[@]}
do
        `cat /tmp/output_table.html | /sbin/sendmail $to `
done
if [ $? = 0 ]
then
        echo "ok : MAIL SENT "
else
        echo "not OK: MAIL NOT SENT "
fi