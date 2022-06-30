#!/bin/bash

PROJECT=`php -r "echo dirname(dirname(dirname(realpath('$0'))));"`
echo $PROJECT;
STAGED_FILES_CMD=`git diff --cached --name-only --diff-filter=ACMR HEAD | grep \\\\.php`

# Determine if a file list is passed
if [ "$#" -eq 1 ]
then
	oIFS=$IFS
	IFS='
	'
	SFILES="$1"
	IFS=$oIFS
fi
SFILES=${SFILES:-$STAGED_FILES_CMD}

echo -e "\e[5m\e[34mChecking PHP Lint...\n\e[35m"
for FILE in $SFILES
do
	php -l -d display_errors=0 $PROJECT/$FILE
	if [ $? != 0 ]
	then
		echo -e "\n\e[39m\e[101m\e[1mCorrija os erros antes do commit.\e[0m"
		exit 1
	fi
	FILES="$FILES $PROJECT/$FILE"
done

RULESET=$PROJECT/source/phpcs.xml

if [ "$FILES" != "" ]
then
	echo -e "\n\e[5m\e[34m\e[1mRunning Code Sniffer...\n\e[39m"
	./source/vendor/bin/phpcs --standard="$RULESET" --colors --encoding=utf-8 -p $FILES
	if [ $? != 0 ]
	then
		echo "Coding standards errors have been detected. Running phpcbf..."
		./source/vendor/bin/phpcbf --standard="$RULESET" --colors --encoding=utf-8 -p $FILES
		git add $FILES
		echo "Running Code Sniffer again..."
		./source/vendor/bin/phpcs --standard="$RULESET" --colors --encoding=utf-8 -n -p $FILES
		if [ $? != 0 ]
		then
			echo -e "\e[39m\e[101m\e[1mErrors found not fixable automatically\e[0m"
			exit 1
		fi
	fi
fi

if [ "$FILES" != "" ]
then
	echo -e "\n\e[5m\e[34m\e[1mRunning tests PHP Unit...\n\e[39m"
	docker-compose exec -T web ./vendor/bin/phpunit --testdox --no-interaction --colors=always
	if [ $? != 0 ]
	then
		echo -e "\n\e[39m\e[101m\e[1mAborting commit.\e[0m" >&2
		exit 1;
	fi
	cd "../"
fi

echo -e "\e[34m\e[102mCommit Realizado Com Sucesso!\e[0m"



exit $?