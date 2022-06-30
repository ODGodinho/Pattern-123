#!/bin/bash

read -p "Tipo de Projeto :
1 - Lumen (Recomendado)
2 - Laravel
3 - Outros (Não recomendado)
" project_id

isSource="$(ls -A source)";

case "$project_id" in
    1)
        name="Lumen";
        project="laravel/lumen";;
    2)
        name="Laravel";
        project="laravel/laravel";;
    3)
        name="Outros";
        project="";;
    *) echo "Invalid type"; exit;;
esac

echo "Você escolheu {$name}"

if [[ $project_id != "3" ]]
then
    mkdir source
fi

if [[ $project != "" && "$isSource" == "" ]]
then
    eval "composer create-project --prefer-dist $project source/"
fi

if [[ $project_id != "3" ]]
then
    cd "source";
fi
composer require illuminate/redis;
composer require --dev squizlabs/php_codesniffer=*;
composer require --dev slevomat/coding-standard=*;
composer require --dev phpcompatibility/php-compatibility=*;
composer require --dev laravel/tinker=*;
composer require --dev barryvdh/laravel-debugbar=*;
# composer global require "squizlabs/php_codesniffer=*"
composer config repositories.chemical-x '{"type": "vcs", "url": "git@github.com:plataforma13/Chemical-X-SDK.git", "name": "plataforma13/chemical-x-sdk"}'
composer require plataforma13/chemical-x-sdk=dev-master

if [[ $project_id != "3" ]]
then
    cd "../";
fi

# if lumen
if [[ $project_id == "1" ]]
then
    if [[ "$isSource" == "" ]]
    then
        cp -avr template/config source/
        cp -avr template/tests source/
        cp -avr template/Lumen/bootstrap/app.php source/bootstrap/app.php
    fi
fi

if [ "$isSource" == "" ] && [ $project_id != "3" ]
then
    mkdir -p source/app/Models/
    cp -avr template/ModelBase.stub.php source/app/Models/ModelBase.php
fi

if [[ $project_id != "3" ]]
then
    cp -avr ./phpcs.xml source/
fi

chmod +x template/pre-commit.bash
cp -avr template/pre-commit.bash .git/hooks/pre-commit

# if lumen and laravel
if [[ $project_id != "3" ]]
then
    sudo chmod 777 -R source/storage/

    source/vendor/bin/phpcbf --standard="./source/phpcs.xml" --colors --encoding=utf-8 -p source/*

    docker-compose up
fi