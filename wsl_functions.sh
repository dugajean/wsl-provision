colored_echo() {
    RED="\033[0;31m"
    GREEN='\033[0;32m'
    YELLOW='\033[1;33m'
    NC='\033[0m' # No Color
    printf "${!1}${2} ${NC}\n"
}

wsl_success() {
	CHECK=$'\u2713'
	echo ""
	colored_echo "GREEN" "[${CHECK}] $1"
}

wsl_error() {
	echo ""
	colored_echo "RED" "[!] $1" >&2
	exit 1
}

wsl_website_exists() {
	if [ ! -f $1 ]; then 
	    wsl_error "Requested website does not exist."
	fi
}

wsl_website_path_exists() {
	if [ ! -d /c/Users/Dugi/Code/${1} ]; then 
	    wsl_error "Requested website path does not exist."
	fi
}

wsl_validate_php_version() {
	PHP_VERSIONS=(7.0 7.1 7.2 7.3)
	if ! printf '%s\n' ${PHP_VERSIONS[@]} | grep -q -P "^"$1"$"; then
	    wsl_error "Invalid PHP version specified. Please choose from these options: 7.0, 7.1, 7.2, 7.3"
	fi
}