Build status badges

# Artifactory Terraform Project

This project sets up JFrog Artifactory repositories, groups, users and permissions, with best practice patterns for releasing to production environments.
Uses the []Atlassian Terraform Provider](https://github.com/atlassian/terraform-provider-artifactory/blob/master/website/docs/index.html.markdown)

Why is it necessary?
To stop random things being downloaded from the internet
To show lineage of where things came form
TO give confidence of stable version (never use latest)
To enable scanning for vulnerabilities and licenses before deploying to prod

Not all images go to prod, should be a pyramid, but the one tested in dev is immutable

Following pronciples
qa should not test dev images
non-tested images should not be staged
non-staged, non-tested or dev images should not go to prod
extreme examples - registry per environment
https://jfrog.com/shownote/container-promotion-docker-chicago-01-20/

## Table of Contents

1. [About the Project](#about-the-project)
1. [Getting Started](#getting-started)
	1. [Dependencies](#dependencies)
	1. [Building](#building)
	1. [Running Tests](#testing)
	1. [Installation](#installation)
	1. [Usage](#usage)
1. [Release Process](#release-process)
	1. [Versioning](#versioning)
	1. [Payload](#payload)
1. [How to Get Help](#how-to-get-help)


# About the Project
Based on many years experience in regulated environments, this project uses terraform to set up binary repositories, together with users, groups and permission.

The following repositories are created

| Repo name      | Repo type | Description
| ----------- | ----------- | --- |
| docker-dev-local      | local   | repo for project created binaries |
| docker-prod-local      | local   | repo for docker images promoted to prod |
| docker-remote   | remote        | repo for mirroring other repos |
| docker-virtual  | virtual |  Aggregates images from local and remote, for single point of entry |

virtual repo is the single point of entry
The each environment looks at the local repo itself

**[Back to top](#table-of-contents)**

# Getting Started
This section should provide instructions for other developers on how to run the project.

## Prerequisites
Any software or dependencies that should exist before attempting to run or install the project.
Terraform 11

## Building

Instructions for how to build your project, any build targets

```
mvn clean install
# to generate the site and reports
mvn site install -P reporting
# Start the server
mvn clean spring-boot:run
```

## Running Tests

Describe how to run unit tests for your project.

```
mvn clean test

```

### Other Tests

If you have formatting checks, coding style checks, or static analysis tests that must pass before changes will be considered, add a section for those and provide instructions

## Installation

Instructions for how to install your project's build artifacts

```
Examples should be included
```

## Usage

See [groups](https://github.com/atlassian/terraform-provider-artifactory/blob/master/website/docs/r/artifactory_group.html.markdown)
See [users](https://github.com/atlassian/terraform-provider-artifactory/blob/master/website/docs/r/artifactory_user.html.markdown)
See [permissions](https://github.com/atlassian/terraform-provider-artifactory/blob/master/website/docs/r/artifactory_permission_target.html.markdown)
See [repositories](https://github.com/atlassian/terraform-provider-artifactory/blob/master/website/docs/r/artifactory_local_repository.html.markdown)
See 
Instructions for using your project. Ways to run the program, how to include it in another project, etc.

```
Examples should be included
```

If your project provides an API, either provide details for usage in this document or link to the appropriate API reference documents

**[Back to top](#table-of-contents)**

## Versioning

How to create releases

## Payload

**[Back to top](#table-of-contents)**

# How to Get Help

Provide any instructions on how to get help.
