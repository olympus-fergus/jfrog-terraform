# JFrog Artifactory Terraform Project

## About this Project
This project sets up JFrog Artifactory repositories, groups and permissions using the [Atlassian Terraform Provider](https://github.com/atlassian/terraform-provider-artifactory/blob/master/website/docs/index.html.markdown). It is intended for use with docker repositories, but the patterns can be extended to any type of repo.
 
## Controlling Who and What
Production environments should be tamper free and deployments fully traceable. A critical part of this is a secure image and binary promotion pipeline. With a single repo accessible across all environments, the possibility of a mistaken or malicious deployment increases. Without safety controls these things can easily happen. Promotion pipelines are a pattern that can help reduce accidental deployments, and interference in scure deployments. By controlling access to repos, and promoting images through environment specific repositories we can go some way in achieving the goal of secure, traceable production artefacts. We need to own our deployments which means we need to know what is deployed in our environments. Repositories used correctly can provide these safety guard rails. By ensuring that all software deployments and releases come via repositories we can:
* stop random things being downloaded from the internet and deployed (or pulled in via scripts)
* show lineage of where things came from
* give confidence of stable versions (never use latest)
* enable regular scanning for vulnerabilities and licenses
* promoting immutable images through repositories means we know the built image is what we think it is

The following principles are at the base of this project:
* qa should not test dev images
* non-tested images should not be staged
* non-staged, non-tested or dev images should not go to prod
* all images come via Artifactory (or some other repository)

## Why are Permissions Important in Repositories?
Assuming repositories are the storage location for images and binaries, it is important to control who can create, read, update and delete. Permissions can also be used to control the promotion pipelines and so are useful for process flow, lineage and therefore audit.


## What is Created by the Terraform Scripts?
### Repositories
The following repos are created:
* `docker-dev-virtual` - A virtual repo including `docker-dev-local` and `docker-virtual`. The dev environment gets all images from here. No other cluster can access.
* `docker-dev-local` - for the newly built image. 
* `docker-stg-virtual` - A virtual repo including `docker-stg-local` and `docker-virtual`. Images can only be promoted here from dev by the `promote-to-docker-stg-local`. The stg environment gets all images from here. No other cluster can access.
* `docker-stg-local` - once tested in dev, promote the image to stg.
* `docker-prod-virtual` - A virtual repo including `docker-prod-local` and `docker-virtual`. Images can only be promoted here from stg by the `promote-to-docker-prod-local`. The prod environment gets all images from here. No other cluster can access.
* `docker-prod-local` - once testing in stg, promote the image to prod.
* `docker-remote` - proxy repo for docker hub
* `docker-virtual` - a single point of entry for all the repos, CI tools or developer connect to this repo to avoid multiple connections to internal repos.

Note that not all images will be promoted up to prod. The `dev` and `stg` repos are set up to prune more than 10 images.

### Groups and Permissions
The following groups are created:
* `read-docker-all` - group with permissions to read all docker repos, used by CI tool and developers
* `upload-docker-dev-local` - group with permission to upload to docker-dev-local, used by the CI tool to deploy builds
* `download-docker-remote` - group with permissions to download and cache images from docker hub
* `read-docker-dev-virtual` - group with permissions to read `docker-dev-virtual` only
* `read-docker-stg-virtual` - group with permissions to read `docker-stg-virtual` only
* `read-docker-prod-virtual` - group with permissions to read docker-prod-virtual only
* `promote-to-docker-stg-local` - group with permissions to read `docker-dev-local` and deploy to `docker-stg-local`, no delete means that no image tag update is possible
* `promote-to-docker-prod-local` - group with permissions to read `docker-stg-local` and deploy to `docker-prod-local`, no delete means that no image tag update is possible


The permissions mean that the only way to add an image to the pipeline is through the `deploy-docker-dev-local` group, there is no other method, giving us assurance of the pipeline integrity.

## Prerequisites
Terraform 11
jq
docker
jfrog cli

## Running the Project
From the root directory:
````bash
export ARTIFACTORY_ACCESS_TOKEN=""
export ARTIFACTORY_URL=""
terraform init
terraform plan
terraform apply
````

## Usage in a Promotion Pipeline
I'm assuming that the automation will be uploading/promoting artefacts between environments, once approved by whatever process is in place. JFrog can use a temporary user assigned to a group, and then assign a token for this purpose, obviating the need to create fake users. For usage look in the [test file](../test/test-permissions.sh). here is a snippet:
```bash
# this will be the assigned temporary username
username=username=read-docker-dev-virtual
# is a member of these groups, that already have the required permissions
scope=scope=member-of-groups:read-docker-dev-virtual

# get the token
get_access_token () {
  curl -u ${user_token} -d ${username} -d ${scope} -X POST ${token_url} | jq -r '.access_token'
}

# wrap inside a variable
access_token=$(get_access_token)

# upload the image to docker-dev-local
jfrog rt docker-push ${virtual_repo}/busybox:${docker_tag} docker-dev-local --access-token=${access_token} --url=${jfrog_artifactory}

```


## Running Tests
The tests are kind of brute force. I wanted testing but wasn't prepared to spend a day tidying them up. Tests check the following:
* `deploy-docker-dev-local` - group can tag and deploy an image to `docker-dev-local` via the virtual repo, is unable to promote to `docker-stg-local`
* `promote-to-docker-stg-local` - group can promote a tag to `docker-stg-local`, cannot promote to `docker-prod-local`
* `promote-to-docker-prod-local` - group can promote a tag to `docker-prod-local`, cannot promote to `docker-prod-local`
* `read-docker-all` - group can read from all repos
* `read-docker-dev-virtual` can only read from `docker-dev-virtual`, error thrown for other repos
* `read-docker-stg-virtual` can only read from `docker-stg-virtual`, error thrown for other repos
* `read-docker-prod-virtual` can only read from `docker-prod-virtual`, error thrown for other repos

This uses the [test file](../test/test-permissions.sh). Pass in your JFrog url and then the token when asked (the token you will need to get from the JFrog UI)
```
# for my user token I use the format username:apiToken
./test-permissions.sh yoururl.jfrog.io
'user token : ' user_token

```

## Further Information
[Atlassian JFrog Terraform Provider](https://github.com/atlassian/terraform-provider-artifactory/tree/master/website/docs)
[JFrog talk on pipeline promotion](https://jfrog.com/shownote/container-promotion-docker-chicago-01-20/)
[JFrog CLI](https://www.jfrog.com/confluence/display/CLI/CLI+for+JFrog+Artifactory#CLIforJFrogArtifactory-PromotingDockerImages)
[Promoting docker images API](https://www.jfrog.com/confluence/display/JFROG/Artifactory+REST+API#ArtifactoryRESTAPI-PromoteDockerImage)

## TODO
Upgrade to Terraform 0.13
