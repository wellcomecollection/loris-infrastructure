ROOT = $(shell git rev-parse --show-toplevel)

INFRA_BUCKET = wellcomecollection-platform-infra

# Test a Python project.
#
# Args:
#   $1 - Path to the Python project's directory, relative to the root
#        of the repo.
#
define test_python
	$(ROOT)/docker_run.py --aws --dind -- \
		wellcome/build_test_python:55 $(1)

	$(ROOT)/docker_run.py --aws --dind -- \
		--net=host \
		--volume $(ROOT)/shared_conftest.py:/conftest.py \
		--workdir $(ROOT)/$(1) --tty \
		wellcome/test_python_$(shell basename $(1)):latest
endef


# Build and tag a Docker image.
#
# Args:
#   $1 - Name of the image.
#   $2 - Path to the Dockerfile, relative to the root of the repo.
#
define build_image
	$(ROOT)/docker_run.py \
	    --dind -- \
	    wellcome/image_builder:23 \
            --project=$(1) \
            --file=$(2)
endef

# Publish a Docker image to ECR, and put its associated release ID in S3.
#
# Args:
#   $1 - Name of the Docker image
#   $2 - Stack name
#   $3 - ECR Repository URI
#   $4 - Registry ID
#
define publish_service
	$(ROOT)/docker_run.py \
	    --aws --dind -- \
	    wellcome/publish_service:86 \
	    	--service_id="$(1)" \
	        --project_id=$(2) \
	        --account_id=$(3) \
	        --region_id=eu-west-1 \
	        --namespace=uk.ac.wellcome \
	        --role_arn="$(DEV_ROLE_ARN)" \
	        --label=latest
endef

# Define a series of Make tasks (build, test, publish) for an ECS service.
#
# Args:
#	$1 - Name of the ECS service.
#	$2 - Path to the associated Dockerfile.
#	$3 - Stack name
#   $4 - ECS Base URI
#   $5 - Registry ID
#
define __python_target
$(1)-build:
	$(call build_image,$(1),$(2))

$(1)-test:
	$(call test_python,$(ROOT)/$(1))

$(1)-publish: $(1)-build
	$(call publish_service,$(1),$(3),$(4),$(5))
endef


# Define all the Make tasks for a stack.
#
# Args:
#
#	$STACK_ROOT             Path to this stack, relative to the repo root
#	$PYTHON_APPS            A space delimited list of ECS services
#
define stack_setup

# The structure of each of these lines is as follows:
#
#	$(foreach name,$(NAMES),
#		$(eval
#			$(call __target_template,$(arg1),...,$(argN))
#		)
#	)
#
# It can't actually be written that way because Make is very sensitive to
# whitespace, but that's the general idea.

$(foreach task,$(PYTHON_APPS),$(eval $(call __python_target,$(task),$(STACK_ROOT)/$(task)/Dockerfile,$(PROJECT_ID),$(ACCOUNT_ID))))
endef
