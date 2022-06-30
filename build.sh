#!/bin/bash -x
while getopts "p:v:l:a:t:" opts;
do
   case "$opts" in
      p)  project=${OPTARG} ;;
      v)  version=${OPTARG} ;;
      l)  l=${OPTARG} ;;
      a)  a=${OPTARG} ;;
      t)  token=${OPTARG} ;;
      *) echo "usage: $0 [-p] [-v] [-l] [-a] [-t]" >&2
       exit 1 ;;
   esac
done

if [ -z "$project" ]
then
    echo 'Parameter -p missing (Project name)'
    exit
fi

if [ -z "$version" ]
then
    echo 'Parameter -v missing (Project version)'
    exit
fi

if [ -z "$l" ]
then
    echo 'Parameter -l missing (NewRelic License)'
    exit
fi

if [ -z "$a" ]
then
    echo 'Parameter -a missing (NewRelic App Name)'
    exit
fi

if [ -z "$token" ]
then
    echo 'Parameter -t missing (GitHub AccessToken)'
    exit
fi

#build image for aws deploy
image_name=$project:$version
echo "===== Building image $image_name ====="

#build image for aws deploy
docker build -t "$image_name" \
  --build-arg NEW_RELIC_LICENSE_KEY="$l" \
  --build-arg NEW_RELIC_APP_NAME="$a" \
  --build-arg GITHUB_ACCESS_TOKEN="$token" \
  -f docker/Dockerfile .

docker push "$image_name"
