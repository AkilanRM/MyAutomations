#!/bin/bash
echo "hi"
cur_time=`date +"%H%M"`
echo "$cur_time"
scheduling ()
{
	delete=3
	while IFS= read -r file 
	do 
		arr=($file)
		job_time=${arr[0]}
		point=0
		if [ $cur_time = $job_time ]
		then
			echo " ITS TIME"
			length=${#arr[@]}
			user=${arr[1]}
                	path=${arr[2]}
			db=${arr[3]}
			output=${arr[4]}
			fail=${arr[5]}
			mysql --login-path=$user $db -e "source $path" 2>$fail | sed 's/\t/","/g;s/^/"/;s/$/"/;s/\n//g' > $output
			#echo "$output.$date.$delete"
			echo "success"
			for (( i = 6 ; i < length ; i++ ))
			do
				#echo "${arr[i]}"
				if [[ "${arr[i]}" =~ .*"com" ]]
                		then
                        		mail=("${arr[i]}")
					if [ -n "$output" ]
                                	then
                                        	echo "SUCCESSFUL" | sendmail -v $mail < $output
						echo "SUCCESS $mail"
					else 
						echo "FAILED" | sendmail -v $mail < $fail
						echo "FAILED $mail"
					fi
				else
					a=$i
					break
                		fi
			done
			for (( x = 0 ; x <= delete ; x++ ))
			do
				if [ $x = $delete ] 
				then
					x=-1
					`rm -f $output.*`
					`rm -f $fail.*`
					point=1
					echo "DELETED"
					continue
				fi
				if [ -f "$output.$x"  ] 
				then
					continue
				else
					if [ -n "$output" ]
					then
						mv $output $output.$x
						break
					else
						mv $fail $fail.$x
						break
					fi
				fi
			done
			#echo "$output.$x"
			if [ -n  "${arr[a]}" ]
               		then
				for (( j = $a ; j < length ; j++ ))
				do
					if [ $point -eq "1" ]
                                	then
						for (( y = 0 ; y < delete ; y++ ))
						do
                                        		cd ${arr[j]} && rm -f *.csv.$y && rm -f *.err.$y || echo " nothing removed"
						done
                                	fi
					if [ -f "$output.$x" ]
					then
						cp -uf $output.$x  ${arr[j]}
						echo "yes"
					else
						cp -uf $fail  ${arr[j]}
						echo "no"
					fi
				done
			fi
		fi
	 done < sample.txt
}
scheduling $1



