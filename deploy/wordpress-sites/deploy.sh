#!/usr/bin/env bash

# script paths
root_path=$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd -P)
script_path="$root_path/scripts"
config_path="$root_path/configs"
template_path="$root_path/templates"
parameter_path="$root_path/parameters"

set -Eeuo pipefail
trap cleanup SIGINT SIGTERM ERR EXIT

usage() {
  cat <<EOF
Usage: $(basename "${BASH_SOURCE[0]}") [-h] [-v] [-t] -e env_value arg1 [arg2...]

Azure CLI deployment script.

Available options:

-h, --help      Print this help and exit
-v, --verbose   Print script debug info
-l, --list      Print a list of available deployment scripts.
-t, --test      Execute a deployment What-If operations at resource group scope.
-e, --env       Execute a deployment for the specified environment.
EOF
  exit
}

cleanup() {
  trap - SIGINT SIGTERM ERR EXIT
  # script cleanup here
}

msg() {
  echo >&2 -e "${1-}"
}

die() {
  local msg=$1
  local code=${2-1} # default exit status 1
  msg "$msg"
  exit "$code"
}

list_scripts() {
  scripts=("${script_path}"/*.sh)

  for f in "${scripts[@]}"; do
    fb="${f##*/}"
    msg "${fb%.*}"
  done

  exit
}

parse_params() {
  # default values of variables set from params
  test=false
  environment=''

  while :; do
    case "${1-}" in
    -h | --help) usage ;;
    -v | --verbose) set -x ;;
    -l | --list) list_scripts ;;
    -t | --test) test=true ;; # example flag
    -e | --env) # example named parameter
      environment="${2-}"
      shift
      ;;
    -?*) die "Unknown option: $1" ;;
    *) break ;;
    esac
    shift
  done

  args=("$@")

  # check required params and arguments
  [[ -z "${environment-}" ]] && die "Missing required parameter: -e or --env"
  #[[ ${#args[@]} -eq 0 ]] && die "Missing script arguments"

  return 0
}

parse_params "$@"

# ===[ script logic starts here ]===

# set the deployment action
if [ "$test" = true ] ; then
  action="what-if"
else
  action="create"
fi

msg "Deployment Type: ${action}"

# load config variables for the selected environment
config_file="$config_path/$environment.cfg"

if [[ -e $config_file ]]; then
  msg "Loading config: ${config_file##*/}"
  source $config_file
else
  msg "Config file not found. (${config_file})"
  exit 1
fi

# use nullglob in case there are no matching files
shopt -s nullglob

# create an array with all the script files
scripts=("${script_path}"/*.sh)

# run the scripts specified in the command-line arguments
for a in "${args[@]}"; do
   for f in "${scripts[@]}"; do
    if [[ "$f" == *"$a"* ]]; then
      msg "Running: ${f##*/}"
      source "$f"
    fi
   done
done

exit 0
