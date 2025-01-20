#!/usr/bin/env bash

RUNCMD=`realpath $0`
RUNDIR=`dirname $RUNCMD`
cd "$RUNDIR"

# Colors
    BOLD="$(tput bold)"
    NORMAL="$(tput sgr0)"
    BG_BLACK="$(tput    setab 0)"
    BG_RED="$(tput      setab 1)"
    BG_GREEN="$(tput    setab 2)"
    BG_YELLOW="$(tput   setab 3)"
    BG_BLUE="$(tput     setab 4)"
    BG_MAGENTA="$(tput  setab 5)"
    BG_CYAN="$(tput     setab 6)"
    BG_WHITE="$(tput    setab 7)"

    FG_BLACK="$(tput    setaf 0)"
    FG_RED="$(tput      setaf 1)"
    FG_GREEN="$(tput    setaf 2)"
    FG_YELLOW="$(tput   setaf 3)"
    FG_BLUE="$(tput     setaf 4)"
    FG_MAGENTA="$(tput  setaf 5)"
    FG_CYAN="$(tput     setaf 6)"
    FG_WHITE="$(tput    setaf 7)"
# ------------------ Functions
 AGREE(){
    echo -e " This script checks for public ip and then installs in the dns server,
    then rebuilds the the whole compose." | tr -s " "
    read -p "$FG_RED Do you want to countinue ? [Y/N] $NORMAL" -N1 agrees && echo
 }
 GET_IP(){
    server_pub_ip=`curl -4 -s ifconfig.io | grep -oE "([0-9]{1,3}\.){3}[0-9]{1,3}"`
    validate_ip=`echo $server_pub_ip | grep -ocE "([0-9]{1,3}\.){3}[0-9]{1,3}"`
    if [ "$validate_ip" -eq "1" ] ; then
        echo -e " The detected public IP address is: $BG_WHITE$FG_BLACK$server_pub_ip$NORMAL"
    else
        echo -e "$BOLD$FG_RED Error : could not detect the public IP address of this server.$NORMAL"
        exit 1
    fi
  }
 BUILD_DNS_FILE(){
    cat ./mycoredns/Corefile.sample > ./mycoredns/Corefile
    sed -i -e "s/PUBLICIP/$server_pub_ip/g" ./mycoredns/Corefile
  }
 CHECK_DOCKER(){
    DOCKER_FOUND=`which docker 2> /dev/null | grep -icw docker`
    COMPOSE_FOUND=`docker compose version | grep -icw "docker compose version"`
    if [ "$DOCKER_FOUND" -eq "1" ] ; then
        if [ "$COMPOSE_FOUND" -eq "1" ] ; then
            echo "Docker and DockerCompose are found"
        else
            echo -e "Error: could not find docker COMPOSE"
            exit 1
        fi
    else
        echo -e "Error: could not find DOCKER "
        echo -e "follow the steps here: https://docs.docker.com/engine/install/ubuntu/ \n https://docs.docker.com/engine/install/fedora/"
        exit 1
    fi
  }
 REBUILD_COMPOSE(){
    docker compose -f ./dnsproxy.yml down -v
    docker compose -f ./dnsproxy.yml pull
    echo "waiting 3 seconds ... " ; sleep 3
    docker compose -f ./dnsproxy.yml up -d
  }
 MAIN(){
    AGREE # check if user agrees to run the script
    if [ "`echo $agrees | grep -ic y`" -ne "1" ]; then
        exit 0
    else
        GET_IP            # get the ip using curl and validate ipv4
        BUILD_DNS_FILE    # create dns proxy file
        CHECK_DOCKER      # check if docker and docker compose are installed
        REBUILD_COMPOSE   # will delete and stop current docker compose services and rebuilds them
    fi
 }

#

MAIN
