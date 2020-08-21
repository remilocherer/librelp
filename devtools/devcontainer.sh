#!/bin/bash
# This scripts uses an rsyslog development container to execute given
# command inside it.
# Note: command line parameters are passed as parameters to the container,
# with the notable exception that -ti, if given as first parameter, is
# passed to "docker run" itself but NOT the container.
#
# use env var DOCKER_RUN_EXTRA_OPTS to provide extra options to docker run
# command.
#
# TO MODIFIY BEHAVIOUR, use
# RSYSLOG_CONTAINER_UID, format uid:gid,
#                   to change the users container is run under
#                   set to "" to use the container default settings
#                   (no local mapping)
set -e
if [ "$1" == "--rm" ]; then
	optrm="--rm"
	shift 1
fi
if [ "$1" == "-ti" ]; then
	ti="-ti"
	shift 1
fi
# check in case -ti was in front...
if [ "$1" == "--rm" ]; then
	optrm="--rm"
	shift 1
fi

if [ "$PROJ_HOME" == "" ]; then
	export PROJ_HOME=$(pwd)
	echo info: PROJ_HOME not set, using $PROJ_HOME
fi

if [ -z "$DEV_CONTAINER" ]; then
	DEV_CONTAINER=$(cat $PROJ_HOME/devtools/default_dev_container)
fi

printf '/rsyslog is mapped to %s \n' "$PROJ_HOME"
printf 'using container %s\n' "$DEV_CONTAINER"
printf 'pulling container...\n'
printf 'user ids: %s:%s\n' $(id -u) $(id -g)
printf 'container_uid: %s\n' ${RSYSLOG_CONTAINER_UID--u $(id -u):$(id -g)}
docker pull $DEV_CONTAINER
docker run $ti $optrm $DOCKER_RUN_EXTRA_OPTS \
	-e PROJ_CONFIGURE_OPTIONS_EXTRA \
	-e PROJ_CONFIGURE_OPTIONS_OVERRIDE \
	-e CC \
	-e CFLAGS \
	-e LDFLAGS \
	-e LSAN_OPTIONS \
	-e TSAN_OPTIONS \
	-e UBSAN_OPTIONS \
	-e CI_MAKE_OPT \
	-e CI_MAKE_CHECK_OPT \
	-e CI_CHECK_CMD \
	-e CI_BUILD_URL \
	-e CI_CODECOV_TOKEN \
	-e CI_VALGRIND_SUPPRESSIONS \
	-e CI_SANITIZE_BLACKLIST \
	-e ABORT_ALL_ON_TEST_FAIL \
	-e USE_AUTO_DEBUG \
	-e RSYSLOG_STATSURL \
	-e VCS_SLUG \
	--cap-add SYS_ADMIN \
	--cap-add SYS_PTRACE \
	${RSYSLOG_CONTAINER_UID--u $(id -u):$(id -g)} \
	$DOCKER_RUN_EXTRA_FLAGS \
	-v "$PROJ_HOME":/rsyslog $DEV_CONTAINER $*
