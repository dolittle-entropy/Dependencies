#!/bin/bash

CYAN=`tput setaf 116`
GREY=`tput setaf 8`
BLUE=`tput setaf 12`
RED=`tput setaf 1`
NC=`tput sgr0`

process () {
    dependency="$1"
    dir="$2"
    repositories=`find $2 -type d | awk -F "/" '{print $1"/"$2"/"$3}' | sort -u | grep -E \./.+/.+ `
    parent=""
    package=`echo $dependency | awk -F"Dolittle." '{print $2}'`

    for r in $repositories # find the repository containing the dependency
    do
        sln=`find $r -type f | grep ".csproj$"`
        if [ -n "$sln" ]; then
            projects=$(cat $sln | grep "AssemblyName" | awk -F"</" '{print $1}' | awk -F">" '{print $2}' | grep -E .+)
            for p in $projects
            do
                if [ "$p" == "$dependency" ]; then
                    parent=`echo $r | awk -F "/" '{print "dolittle-"$2"/"$3}'`
                    break 2
                fi
            done
        fi
    done
    if [ -z "$parent" ]; then
        parent="Not Found"
        echo -e "${GREY}$d${NC} ${RED}$parent${NC}"
    else
        echo -e "${GREY}$d${NC} from ${BLUE}$parent${NC}"
    fi
}

run () {
    dir="$1"
    repositories=`find $dir -type d | awk -F "/" '{print $1"/"$2"/"$3}' | sort -u | grep -E \./.+/.+ `

    for sub in $repositories
    do
        fancy_f=`echo $sub | awk -F"/" '{print $2"/"$3}'`
        proj_files=`find $sub -type f | grep .csproj$`
        if [ -n "$proj_files" ]; then
            depends=`cat $proj_files | grep '<PackageReference Include=\"Dolittle.' | awk -F"\"" '{print $2}' | sort -u`
            if [ -n "$depends" ]; then
                echo -e "${CYAN}dolittle-$fancy_f depends on :${NC}"
            fi
        fi
            for d in $depends
            do 
                if [ -n "$d" ]; then
                    process "$d" "$dir"
                fi
            done
        if [ -n "$proj_files" ]; then
            echo ""
        fi
    done
}

contains() {
    string="$1"
    substring="$2"
    if test "${string#*$substring}" != "$string"
    then
        return 1    # $substring is in $string
    else
        return 0    # $substring is not in $string
    fi
}

short () {
    display=$1
    for each in display; do
        if [[ $(contains $each ":") -eq 1 ]]; then
            echo -e "\n$each"
        else
            line=`echo $display | awk '{print $3}' | sort -u`
            echo ${BLUE}$line${NC}
        fi
    done
}

main () {
    if [ "$#" -eq 1 ]; then
        dir="$1"
        run "$dir"
    else
        echo -e "Please specify the absolute path of the folder containing all your Dolittle's projects\n"
    fi
}
main $@