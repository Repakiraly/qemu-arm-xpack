#!/usr/bin/env bash

# -----------------------------------------------------------------------------
# Safety settings (see https://gist.github.com/ilg-ul/383869cbb01f61a51c4d).

if [[ ! -z ${DEBUG} ]]
then
  set ${DEBUG} # Activate the expand mode if DEBUG is anything but empty.
else
  DEBUG=""
fi

set -o errexit # Exit if command failed.
set -o pipefail # Exit if pipe failed.
set -o nounset # Exit if variable not set.

# Remove the initial space and instead use '\n'.
IFS=$'\n\t'

# -----------------------------------------------------------------------------
# Identify the script location, to reach, for example, the helper scripts.

script_path="$0"
if [[ "${script_path}" != /* ]]
then
  # Make relative path absolute.
  script_path="$(pwd)/$0"
fi

script_name="$(basename "${script_path}")"

script_folder_path="$(dirname "${script_path}")"
script_folder_name="$(basename "${script_folder_path}")"

# =============================================================================

# This runs inside a Docker container.

# -----------------------------------------------------------------------------

image_name="$1"
echo "${image_name}"
shift

base_url="$1"
echo "${base_url}"
shift

while [ $# -gt 0 ]
do
  case "$1" in

    -*)
      echo "Unsupported option $1."
      exit 1
      ;;

  esac
done

# -----------------------------------------------------------------------------

# Make sure that the minimum prerequisites are met.
if [[ ${image_name} == *ubuntu* ]] || [[ ${image_name} == *debian* ]] || [[ ${image_name} == *raspbian* ]]
then
  apt-get -qq update 
  apt-get -qq install -y git-core curl tar gzip lsb-release binutils
elif [[ ${image_name} == *centos* ]]
then
  yum install -y -q git curl tar gzip redhat-lsb-core binutils
elif [[ ${image_name} == *opensuse* ]]
then
  zypper -q in -y git-core curl tar gzip lsb-release binutils
elif [[ ${image_name} == *manjaro* ]]
then
  pacman-mirrors -g
  pacman --noconfirm -Syyuq
  pacman --noconfirm -Sq git curl tar gzip lsb-release binutils
fi

# -----------------------------------------------------------------------------

source "${script_folder_path}/common-functions-source.sh"

# -----------------------------------------------------------------------------

detect_architecture

app_lc_name="qemu-arm"

prepare_env

install_archive

run_tests

good_bye

# Completed successfully.
exit 0

# -----------------------------------------------------------------------------
