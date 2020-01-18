#!/bin/bash -eu
# BASH echo colours
# Try use the ansible colour scheme - ERROR_COLOR=Error, Yellow=Change, Green=No Change
# Use Normal to clear
set -u
ERROR_COLOR="\e[31m"
SUCCESS_COLOR="\e[32m"
ACTION_COLOR="\e[33m"
SKIP_COLOR="\e[34m"
NORMAL_COLOR="\e[0m"
INFO_COLOR="\e[36m"

error () {
  echo -e $ERROR_COLOR "===> $@ " $NORMAL_COLOR
}

action () {
  echo -e $ACTION_COLOR "===> $@ " $NORMAL_COLOR
}

skip () {
  echo -e $SKIP_COLOR "===> $@ " $NORMAL_COLOR
}

success () {
  echo -e $SUCCESS_COLOR "===> $@  ... Done " $NORMAL_COLOR
}

info () {
  echo -e $INFO_COLOR "===# $@" $NORMAL_COLOR
}

# Print the name of the calling script here
info "[$0] Script executing...."

###########################################################################
# The purpose of this script is to tag and push images.                   #
# From the local kolla ansible deployment box to {{DRT}}             #
#                                                                         #
###########################################################################


# check if command line argument is empty or not present
function usage () {
  echo "Usage:"
  echo "  $0 -u USERNAME -p PASSWORD"
}

while (( "$#" )); do
   case $1 in
      -u)
         shift && USERNAME="$1"||die
         ;;
      -p)
         shift && PASSWORD="$1"||die
         ;;
      -h)
        usage
        exit 1;;
      *)
        echo "Invalid options"
        usage
        exit 1;;
   esac
   shift
done



info "pulling images using the globals.yml file"
kolla-ansible pull
success "images pulled successfully"


##############-Log In To Local DTR-################
echo "logging in to {{DRT}}"
docker login -u "$USERNAME" --password "$PASSWORD" {{DRT}}
if [ $? > 0 ] ;
     then  success "Logged in to dtr successfully"
        else
        error "There was a problem logging in to the dtr"
        exit 2
fi

exit 0

##############-Generate A List Of Local Images-################

imagelist=( $(docker images --format "{{.Repository}}") )
echo $imagelist

##############-Tag Local Images with {{DRT}} prefix-################

for ((i=0; i<${#imagelist[@]}; i++));
            do docker tag ${imagelist[i]}:queens "{{DRT}}"/openstack/${imagelist[i]}:queens;
done

##############-Generate A List Of Local Images To Push-################

ImagesToPush=( $(docker images | grep {{DRT}} |sed -e "s/ +/ /g"|tr -cs "a-zA-Z0-9"| cut -f 1,2 -d" "|sed -e "s/ /: /" -e "s/\(.*\) /\1/") )

##############-Push Tagged Images To The dtr-################

for ((i=0; i<${#ImagesToPush[@]}; i++));
            do echo "Pushing the following image ${ImagesToPush[i]} to {{DRT}}";
            docker push ${ImagesToPush[i]}
 done

 ##############-The End-################
