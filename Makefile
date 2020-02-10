ROOT = $(shell git rev-parse --show-toplevel)

export ECR_BASE_URI = 760097843905.dkr.ecr.eu-west-1.amazonaws.com/uk.ac.wellcome
export ACCOUNT_ID   = 760097843905

ifneq ($(TRAVIS),true)
export DEV_ROLE_ARN := arn:aws:iam::760097843905:role/platform-developer
endif

include $(ROOT)/makefiles/functions.Makefile
include $(ROOT)/makefiles/formatting.Makefile

STACK_ROOT 	= $(ROOT)
PYTHON_APPS = loris
PROJECT_ID  = loris

$(val $(call stack_setup))

$(ROOT)/loris/requirements.txt: $(ROOT)/loris/requirements.in
	docker run --rm \
		--volume $(ROOT)/loris:/data \
		wellcome/build_tooling:latest \
		pip-compile

loris-run: loris-build
	$(ROOT)/docker_run.py -- --publish 8888:8888 loris