jenkins-swarm-docker-client
===========================

Based on `csanchez/jenkins-swarm-slave`

Also provides docker in order to control the docker host.

The idea behind this is to expose a jenkins-slave to a jenkins-master,
with jobs managing docker containers and volumes in order to achieve the expected goal.

There is very few assumption about the actual host, except that it runs docker.

Usage of encaps
---------------

Along with this image is provided a script called 'encaps' (and 'encaps-cleanup') that are used to encapsulate a script execution within a container.

For instance, let's assume the following script:

    #!/bin/sh
    python setup.py bdist_egg

If you want to encapsulate that in some container, just replace the shebang:

    #!/usr/bin/encaps
    python setup.py bdist_egg

Behavior of the script is define by the following env variables:
 - `DOCKER_ENCAPS_IMG` : image used to instantiate the container
 - `DOCKER_ENCAPS_ARGS` : extra arguments that should be given to docker upon instantiation
 - `DOCKER_ENCAPS_NAME` : name used for the container, default to BUILD_TAG which is usually provided by Jenkins, format is `jenkins-<JOB>-<BUILD_ID>`
 - `DOCKER_ENCAPS_SHELL` : to control the actual program executing your script, default to /bin/sh

It needs a running container, if the script can't find one it will try to instantiate it.

In the example above, consider that you want to build your application with python 2.7.9.
Just inject the variable `DOCKER_ENCAPS_IMG=python:2.7.9` and it will use the image from https://registry.hub.docker.com/_/python/ to encapsulate your build.

Limitations:
 - Don't forget that even if the docker client is running in the Jenkins container, the server is still on the host.
   Therefore, paths, etc ... should be relative/accessible from the host
 - The workspace is considered as being a shared volume between the jenkins-slave container and the host for this reason

