all: docker

DOCKER_IMAGE_TAG := $(shell python get_docker_build_version.py)
DOCKER_GIT_RELEASE_TAG := $(shell python get_latest_git_release_tag.py)
DOCKER_REPO=www.dockerhub.us
DOCKER_IMAGE=kafka

docker:
	docker build -t ${DOCKER_REPO}/${DOCKER_IMAGE}:$(DOCKER_IMAGE_TAG) .

publish: docker
	docker tag ${DOCKER_REPO}/${DOCKER_IMAGE}:$(DOCKER_IMAGE_TAG) ${DOCKER_REPO}/${DOCKER_IMAGE}:$(DOCKER_GIT_RELEASE_TAG)
	docker push ${DOCKER_REPO}/${DOCKER_IMAGE}:$(DOCKER_GIT_RELEASE_TAG)

