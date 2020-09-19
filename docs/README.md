# JFrog Artifactory Terraform Project

## About this Project
This project sets up JFrog Artifactory repositories, groups and permissions using the [Atlassian Terraform Provider](https://github.com/atlassian/terraform-provider-artifactory/blob/master/website/docs/index.html.markdown). It is intended for use with docker repositories, but the patterns can be extended to any type of repo.
 
## Why are Permissions Important in Repositories?
Assuming repositories are the storage location for images and binaries, it is important to control who can add what, who can take out. Permissions can also be used to control the promotion pipelines and so are useful for process flow, lineage and therrefor audit.

### Controlling Who and What
Production environments should be secure for customer and employee confidence. Imagine if you found out that all your credit card data was accessible in production because someone added an image that could intercept http calls? Or by accident a developer image got deployed to production? Without safety controls these things can easily happen. We need to own our deployments which means we need to know what is deployed in to our environments. Repositories when used correctly can provide these safety. By ensuring that all software deployments and releases come via repositories we can:
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

## What is Created?
### Repositories
The following repos are created:
* `docker-dev-local` - for the newly built image. Dev environment gets all images from here.
* `docker-stg-local` - once tested in dev, promote the image to stg, for more in depth testing. Stg environment gets all images from here.
* `docker-prod-local` - once testing in stg, promote the image to prod, ready for public release. Prod environment gets all images from here.
* `docker-remote` - proxy repo for docker hub
* `docker-virtual` - a single point of entry for all the repos, CI tools or developer connect to this repo to avoid multiple connections to internal repos.

Note that not all images will be promoted up to prod, and so there is a natural funneling system. the `dev` and `stg` repos are set up to prune more than 10 images.

### Groups and Permissions
The following groups are created
* `read-docker-all` - group with permissions to read all docker repos, used by CI tool and developers
* `deploy-docker-dev-local` - group with permission to deploy to docker-dev-local, used by the CI tool to deploy builds
* `read-docker-dev-local` - group with permissions to read `docker-dev-local` only, used by the dev env and the promote to stg group
* `read-docker-stg-local` - group with permissions to read `docker-stg-local` only, used by the stg env and the promote to prod group
* `read-docker-prod-local` - group with permissions to read docker-prod-local only, used by the prod env
* `promote-to-docker-stg-local` - group with permissions to read `docker-dev-local` and deploy to `docker-stg-local`, no delete means that no image tag update is possible
* `promote-to-docker-prod-local` - group with permissions to read `docker-stg-local` and deploy to `docker-prod-local`, no delete means that no image tag update is possible
* `download-docker-remote` - group with permissions to download and cache images from docker hub

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

## Running Tests
The tests are kind of brute force. I wanted testing but wasn't prepared to spend a day tidying them up. Tests check the following:
* `deploy-docker-dev-local` - group can tag and deploy an image to `docker-dev-local` via the virtual repo, is unable to promote to `docker-stg-local`
* `promote-to-docker-stg-local` - group can promote a tag to `docker-stg-local`, cannot promote to `docker-prod-local`
* `promote-to-docker-prod-local` - group can promote a tag to `docker-prod-local`, cannot promote to `docker-prod-local`
* `read-docker-all` - group can read from all repos
* `read-docker-dev-local` can only read from `docker-dev-local`, error thrown for other repos
* `read-docker-stg-local` can only read from `docker-stg-local`, error thrown for other repos
* `read-docker-prod-local` can only read from `docker-prod-local`, error thrown for other repos

In the [test file](../test/test-permissions.sh) update the `jfrog_base_url=""` value to whatever your JFrog URL is, do not include http/s.
```
# for my user token I use the format username:apiToken
./test-permissions.sh 
'user token : ' user_token

```

## Further Information
[Atlassian JFrog Terraform Provider](https://github.com/atlassian/terraform-provider-artifactory/tree/master/website/docs)
[JFrog talk on pipeline promotion](https://jfrog.com/shownote/container-promotion-docker-chicago-01-20/)
[JFrog CLI](https://www.jfrog.com/confluence/display/CLI/CLI+for+JFrog+Artifactory#CLIforJFrogArtifactory-PromotingDockerImages)
[Promoting docker images CLI](https://www.jfrog.com/confluence/display/JFROG/Artifactory+REST+API#ArtifactoryRESTAPI-PromoteDockerImage)