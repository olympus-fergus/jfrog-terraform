#!/usr/bin/env bash
set -o nounset
#set -o errexit
#set -o pipefail
#set -x xtrace
set +e # continue on error!

# read the user token
#read -sp "user token : " user_token
user_token="eyJ2ZXIiOiIyIiwidHlwIjoiSldUIiwiYWxnIjoiUlMyNTYiLCJraWQiOiJndm5yVWJZb1FfXzZzOTc3eVNoTkdHdjE3anI4bkk0UU5oUXBIRHFjVkZZIn0.eyJzdWIiOiJqZmZlQDAwMFwvdXNlcnNcL2Zlcmd1cy5tYWNkZXJtb3RAb3NsLmNvbSIsInNjcCI6ImFwcGxpZWQtcGVybWlzc2lvbnNcL2FkbWluIGFwaToqIiwiYXVkIjoiKkAqIiwiaXNzIjoiamZmZUAwMDAiLCJpYXQiOjE2MjY2OTU0MDMsImp0aSI6ImEyNDY1ODE5LTk1YTEtNDc4Ny1iNDNhLTkxNDU0NWQ2NjAyNCJ9.ZHFlkgnw17Ttxkidgq9ugD_D1ABu2qlzsEr-N50s2TUpoZzkeLHNCagu3v-kyrK4RGCFgr9ebUBoYRTVsXf5sevq81Y6yUxOkPtZxvH0ZfASYW9r4Lq9gHmRw1E1UN81srkiRya0wf4tFYeFIm27KZhFPcLvvXjRut75SmrCxhUMfbDqxoa9XtqX4AUl9AuEA7nvrbQr-TCa2mx1j6a3dlgFSOOfqGH-L9biKZ9k5XvsAj5VbtnKjEjbd8qHsW-82z4lzGD8BEVZofC4c5Dc0hgNYAX-Wx8oXP-lJY95tkuUm8z2ZSMDbu5G7SpXRVLzTK-avyjARIl9DrFSAnSzmQ"
# JFrog URL
jfrog_base_url=$1
jfrog_account="https://${jfrog_base_url}"
jfrog_artifactory="${jfrog_account}/artifactory"
token_url="${jfrog_artifactory}/access/api/v1/tokens"

# repositories
virtual_repo=${jfrog_base_url}/docker-all-virtual
dev_repo=${jfrog_base_url}/docker-dev-local
stg_repo=${jfrog_base_url}/docker-stg-local
prod_repo=${jfrog_base_url}/docker-prod-local

virtual_dev_repo=${jfrog_base_url}/docker-dev-virtual
virtual_stg_repo=${jfrog_base_url}/docker-stg-virtual
virtual_prod_repo=${jfrog_base_url}/docker-prod-virtual

# users maps to groups
developer_identifier="read-docker-all"
bot_deployer="upload-docker-dev-local"
bot_downloader="download-docker-remote"
bot_reader_dev="read-docker-dev-virtual"
bot_reader_stg="read-docker-stg-virtual"
bot_reader_prod="read-docker-prod-virtual"
bot_promote_stg="promote-to-docker-stg-local"
bot_promote_prod="promote-to-docker-prod-local"

# Used later for creating the access token. This format means JFrog creates a transient user
user="${developer_identifier}"
username="username=${developer_identifier}"
scope="scope=member-of-groups:${developer_identifier}"

# Generate a random tag as can't find a good way to delete tags in the repo
docker_tag=$(echo $RANDOM | tr '[0-9]' '[a-z]')

get_access_token () {
  curl -u ${user_token} -d ${username} -d ${scope} -X POST ${token_url} | jq -r '.access_token'

  curl -H "Authorization: Bearer ${user_token}" -XPOST "http://localhost:8082/access/api/v1/tokens" -d ${scope}

}

docker_login () {
 echo ${access_token} | docker login ${jfrog_base_url} --username ${user} --password-stdin
}

# first pull in an image
docker pull docker.io/library/busybox:latest

# now tag with virtual repo
docker tag docker.io/library/busybox:latest ${virtual_repo}/busybox:${docker_tag}

################################################
## First let's run the upload and promote path
################################################
# Switch user group to deployers
echo "First let's run the upload and promote path"
username=username=${bot_deployer}
scope=scope=member-of-groups:${bot_deployer}

access_token=$(get_access_token)
# upload
jfrog rt docker-push ${virtual_repo}/busybox:${docker_tag} docker-dev-local --access-token=${access_token} --url=${jfrog_artifactory}
echo "now try to promote to stg with the deploy user"
# now try to promote to stg with the deploy user, should fail, throw away std error
jfrog rt docker-promote busybox docker-dev-local docker-stg-local --source-tag ${docker_tag} --access-token=${access_token} --url=${jfrog_artifactory} &> /dev/null

if [ $? -eq 0 ]; then
    echo echo ${username} able to write to docker-stg-local, this is bad, exit
    exit
else
    echo ${username} unable to write to docker-stg-local, this is good
fi

username=username=$bot_promote_stg
scope=scope=member-of-groups:$bot_promote_stg

access_token=$(get_access_token)
echo "now try to promote with the ${username} user, should succeed"
jfrog rt docker-promote busybox docker-dev-local docker-stg-local --source-tag ${docker_tag} --access-token=${access_token} --url=${jfrog_artifactory} &> /dev/null

if [ $? -eq 0 ]; then
    echo echo ${username} able to write to docker-stg-local, this is good
else
    echo ${username} unable to write to docker-stg-local, this is bad
    exit
fi

echo "check to see if stg user can promote to prod"
jfrog rt docker-promote busybox docker-stg-local docker-prod-local --source-tag ${docker_tag} --access-token=${access_token} --url=${jfrog_artifactory} &> /dev/null

if [ $? -eq 0 ]; then
    echo echo ${username} able to write to docker-prod-local, this is bad
    exit
else
    echo ${username} unable to write to docker-prod-local, this is good
fi

echo "let's put promote to the prod repo"
username=username=${bot_promote_prod}
scope=scope=member-of-groups:${bot_promote_prod}

access_token=$(get_access_token)
echo "now try to promote with the promote prod group, should succeed"
jfrog rt docker-promote busybox docker-stg-local docker-prod-local --source-tag ${docker_tag} --access-token=${access_token} --url=${jfrog_artifactory} &> /dev/null

if [ $? -eq 0 ]; then
    echo echo ${username} able to write to docker-prod-local, this is good
else
    echo ${username} unable to write to docker-prod-local, this is bad
    exit
fi

echo "now try to promote with the promote prod group to stg, should fail"
jfrog rt docker-promote busybox docker-prod-local docker-stg-local --source-tag ${docker_tag} --access-token=${access_token} --url=# now try to promote with the promote prod group, should succeed &> /dev/null

if [ $? -eq 0 ]; then
    echo echo ${username} able to write to docker-stg-local, this is bad
    exit
else
    echo ${username} unable to write to docker-stg-local, this is good
fi

################################################
## Now let's try the read groups
################################################


echo "******* Now we move on to validating ${developer_identifier} user ********"
username=username=${developer_identifier}
scope=scope=member-of-groups:${developer_identifier}
access_token=$(get_access_token)
user=${developer_identifier}
docker_login
echo "let's test read me ability for the ${developer_identifier} user"
docker pull ${virtual_repo}/busybox:${docker_tag}
docker pull ${dev_repo}/busybox:${docker_tag}
docker pull ${stg_repo}/busybox:${docker_tag}
docker pull ${prod_repo}/busybox:${docker_tag}

echo "******* Now we move on to validating ${bot_reader_dev} user ********"
username=username=${bot_reader_dev}
scope=scope=member-of-groups:${bot_reader_dev}
echo "\t\t\t check that ${bot_reader_dev} cannot read stg and prod"
access_token=$(get_access_token)
user=${bot_reader_dev}
docker_login
docker pull ${virtual_repo}/busybox:${docker_tag}
docker pull ${virtual_dev_repo}/busybox:${docker_tag}
docker pull ${virtual_stg_repo}/busybox:${docker_tag}
if [ $? -eq 0 ]; then
    echo echo ${username} able to read from docker-stg-local, this is bad
    exit
else
    echo ${username} unable to read from docker-stg-local, this is good
fi

docker pull $virtual_prod_repo/busybox:${docker_tag}
if [ $? -eq 0 ]; then
    echo echo ${username} able to read from docker-prod-local, this is bad
    exit
else
    echo ${username} unable to read read docker-prod-local, this is good
fi

echo "******* Now we move on to validating ${bot_reader_stg} user ********"
username=username=${bot_reader_stg}
scope=scope=member-of-groups:${bot_reader_stg}
echo "\t\t\t check that ${username} cannot access dev and prod"
access_token=$(get_access_token)
user=${bot_reader_stg}
docker_login
docker pull ${virtual_dev_repo}/busybox:${docker_tag}
if [ $? -eq 0 ]; then
    echo echo ${username} able to read from ${virtual_dev_repo}, this is bad
    exit
else
    echo ${username} unable to read from ${virtual_dev_repo}, this is good
fi
docker pull ${virtual_stg_repo}/busybox:${docker_tag}
if [ $? -eq 0 ]; then
    echo echo ${username} able to read from ${virtual_stg_repo}, this is good
else
    echo ${username} unable to read from ${virtual_stg_repo}, this is bad
    exit
fi
docker pull ${virtual_prod_repo}/busybox:${docker_tag}
if [ $? -eq 0 ]; then
    echo echo ${username} able to read to ${virtual_prod_repo}, this is bad
    exit
else
    echo ${username} unable to write to ${virtual_prod_repo}, this is good
fi

# now check that prod-reader cannot access dev and stg
echo "******* Now we move on to validating ${bot_reader_prod} user ********"
username=username=${bot_reader_prod}
scope=scope=member-of-groups:${bot_reader_prod}
echo "now check that ${username} cannot access dev and stg"
access_token=$(get_access_token)
user=${bot_reader_prod}
docker_login
docker pull ${virtual_repo}/busybox:${docker_tag}
echo "\t\t\t check that ${username} cannot access dev and stg"
docker pull ${virtual_dev_repo}/busybox:${docker_tag}
if [ $? -eq 0 ]; then
    echo echo ${username} able to read from ${virtual_dev_repo}, this is bad
    exit
else
    echo ${username} unable to read from ${virtual_dev_repo}, this is good
fi


docker pull ${virtual_stg_repo}/busybox:${docker_tag}
if [ $? -eq 0 ]; then
    echo echo ${username} able to read from ${virtual_stg_repo}, this is bad
    exit
else
    echo ${username} unable to read from ${virtual_stg_repo}, this is good
fi
docker pull ${virtual_prod_repo}/busybox:${docker_tag}
if [ $? -eq 0 ]; then
    echo echo ${username} able to read to ${virtual_prod_repo}, this is good
else
    echo ${username} unable to write to ${virtual_prod_repo}, this is bad
    exit
fi

echo "******* If you see this message, permissions are good! ********"
## Phew. Ugly, but works.
