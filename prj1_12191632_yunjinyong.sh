#! /bin/bash
echo "User Name: yunjinyong"
echo "Student Number: 12191632"
echo "[Menu]"
echo "1. Get the data of the movie identified by a specific 'movie id' from 'u.item'"
echo "2. Get the data of action genre movies from 'u.item'"
echo "3. Get the average rating of the movie identified by specific 'movie id' form 'u.data'"
echo "4. Delete the 'IMdb URL' from 'u.item'"
echo "5. Get the data about users from 'u.user'"
echo "6. Modify the format of 'release date' in 'u.item'"
echo "7. Get the data of movies rated by a specific 'user id' from 'u.data'"
echo "8. Get the averages rating of movies rated by users with 'age' between 20 and 29 and 'occupation' as 'programmer'"
echo "9. Exit"
echo "-------------------------------------"
     stop="N"
     until [ $stop = "Y" ]
     do
	read -p "Enter your choice [ 1-9 ]" choicenum
        if [ $choicenum -eq 1 ];then
            read -p "Please enter 'movie id' (1~1682):" id
	    cat $1 | awk -F'|' -v id=$id '$1==id {print $0}'
	elif [ $choicenum -eq 2 ];then
		read -p "Do you want to get the data of 'action' genre movies from 'u.item'?(y/n):" answer
		if [ $answer = "y" ];then
                   cat $1 | awk -F'|' 'NR <= 35 && $7==1 {print $1 $2}'
	        else
                   continue
		fi
	elif [ $choicenum -eq 3 ];then
		read -p "Please enter the 'movie id'(1~1682):" id
		cat $2 | awk -v id=$id '$2==id {sum+=$3; count++} END {if(count > 0) printf "average rating of %d : %.5f \n", id, sum/count}'
	elif [ $choicenum -eq 4 ];then
		read -p "Do you want to delete the 'IMDb URL' from 'u.item'?(y/n):" answer
		if [ $answer = "y" ];then
                     cat $1 | sed 's|http://[^|]*||' | head -n 10 
		else
                     continue
		fi
	elif [ $choicenum -eq 5 ];then
		read -p "Do you want to get the data about users from 'u.user'?(y/n):" answer
		if [ $answer = "y" ];then
                    cat $3 | sed 's/F/female/g; s/M/male/g' | awk -F'|' 'NR <= 10 {printf "user %s is %s years old %s %s\n", $1, $2, $3, $4}' 
		else
			continue
		fi
	elif [ $choicenum -eq 6 ];then
		read -p "Do you want to Modify the format of 'release data' in 'u.item'?(y/n):" answer
		if [ $answer = "y" ];then
                        cat $1 | sed -n 's/\([0-9]\{2\}\)-\([A-Za-z]\{3\}\)-\([0-9]\{4\}\)/\3\2\1/p'| sed 's/Jan/01/g; s/Feb/02/g; s/Mar/03/g; s/Apr/04/g; s/May/05/g; s/Jun/06/g; s/Jul/07/g; s/Aug/08/g; s/Sep/09/g; s/Oct/10/g; s/Nov/11/g; s/Dec/12/g' | awk -F'|' '$1>1672 && $1<1683 {print $0}'
		else
			continue
		fi
	elif [ $choicenum -eq 7 ];then
		read -p "Please enter the 'user id'(1~943):" id
		tempfile=$(mktemp)
		cat $2 | sort -k2,2n | awk -v id=$id '$1==id {movieIds = movieIds $2 "|"} END {print substr(movieIds, 1, length(movieIds)-1)}'
		cat $2 | sort -k2,2n | awk -v id=$id '$1==id {movieIds = movieIds $2 "|"} END {print substr(movieIds, 1, length(movieIds)-1)}' | tr '|' '\n' > $tempfile
		echo -e "\n"
		awk -F'|' 'NR < 11 && NR==FNR{a[$1]++;next}{if($1 in a){printf "%d | %s\n", $1, $2}}' $tempfile $1
		rm $tempfile
	elif [ $choicenum -eq 8 ];then
		read -p "Do you want to get the average 'rating' of movies rated by users with 'age' between 20 and 29 and 'occupation' as 'programmer'?(y/n):" answer
		if [ $answer = "y" ];then
			tempfile=$(mktemp)
                         cat $3 | awk -F'|' '$2>19 && $2<30 && $4=="programmer" {printf "%d\n",$1}'>$tempfile
			 tempfile2=$(mktemp)
			 awk 'NR==FNR{a[$1]++;next}{if($1 in a){printf "%d  %d\n",$2,$3}}' $tempfile $2 | sort -k1 >$tempfile2
			 awk '{sum[$1] += $2;count[$1]++} END { for (key in sum) { printf "%d %.5f\n", key, sum[key]/count[key]}}' $tempfile2
		 else
			continue
		fi	
	elif [ $choicenum -eq 9 ];then
		stop="Y"
		echo "Bye!"
		break
	else
		echo "unknown answer"
	fi
     done
