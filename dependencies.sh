#!/bin/bash

CYAN=`tput setaf 116`
GREY=`tput setaf 8`
BLUE=`tput setaf 12`
RED=`tput setaf 1`
NC=`tput sgr0`

contains() {
    string="$1"
    substring="$2"
    if test "${string#*$substring}" != "$string"
    then
        echo "true"    # $substring is in $string
    else
        echo "false"   # $substring is not in $string
    fi
}

make_it_short () {
    element=$(echo "$1" | awk -F"from" '{print $2}')
    is_it=$(contains "$list" "$element")
    if [ "$is_it" = "false" ]; then
        list=$(echo "$list $element")
        echo -e "$element\n"
    fi
}

process () {
    dependency="$1"
    repositories=`find . -type d | awk -F "/" '{print $1"/"$2"/"$3}' | sort -u | grep -E \./.+/.+ `
    parent=""

    for r in $repositories
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

run_for_one () {
    dir="$1"
    to_find="$2"
    cd $dir
    repositories=`find . -type d | awk -F "/" '{print $1"/"$2"/"$3}' | sort -u | grep -E \./.+/.+ `

    for sub in $repositories
    do
        is_the_one=$(contains "$sub" "$to_find")
        if [ "$is_the_one" = "true" ]; then
            fancy_f=`echo $sub | awk -F"/" '{print $2"/"$3}'`
            proj_files=`find $sub -type f | grep .csproj$`
            if [ -n "$proj_files" ]; then
                depends=`cat $proj_files | grep '<PackageReference Include=\"Dolittle.' | awk -F"\"" '{print $2}' | sort -u`
                if [ -n "$depends" ]; then
                    echo -e "\n${CYAN}dolittle-$fancy_f depends on :${NC}"
                fi
            fi
            for d in $depends
            do 
                if [ -n "$d" ]; then
                    process "$d"
                fi
            done
            if [ -n "$proj_files" ]; then
                echo -n ""
            fi
        fi
    done   
}

run () {
    dir="$1"
    summary="$2"
    cd $dir
    repositories=`find . -type d | awk -F "/" '{print $1"/"$2"/"$3}' | sort -u | grep -E \./.+/.+ `

    for sub in $repositories
    do
        fancy_f=`echo $sub | awk -F"/" '{print $2"/"$3}'`
        proj_files=`find $sub -type f | grep .csproj$`
        if [ -n "$proj_files" ]; then
            depends=`cat $proj_files | grep '<PackageReference Include=\"Dolittle.' | awk -F"\"" '{print $2}' | sort -u`
            if [ -n "$depends" ]; then
                echo -e -n "\n${CYAN}dolittle-$fancy_f depends on :${NC}\n"
            fi
            for d in $depends
            do 
                if [ -n "$d" ]; then
                    if [ "$summary" = false ]; then
                        process "$d"
                    else
                        result=$(process "$d")
                        short_result=$(make_it_short "$result")
                        list+="$short_result"
                    fi
                fi
            done
            echo -e -n "$list\n" | tr ' ' '\n'
        fi
    done
}

main () {
    if [ "$#" -eq 1 ]; then
        dir="$1"
        run "$dir" false
    elif [ "$#" -eq 2 ] && [ "$2" = "--summary" ]; then
        echo -n "Processing summary... it can take a few minutes"
        dir="$1"
        run "$dir" true
    elif [ "$#" -eq 3 ] && [ "$2" = "--find" ]; then
        echo -e "Finding depencies of matching expression : \"$3\""
        dir="$1"
        run_for_one "$dir" "$3"
    else
        echo -e "\nUSAGE: ./dependencies.sh <path> [[--summary] || [--find <name>]] "
        echo -e "\n  Please specify the <path> of the folder containing all your Dolittle's projects\n"
        echo -e "  You can add --find <name> to find all the dependecies of repositories containing <name> in the name"
        echo -e "  You can also add --summary to have a shorter result when you don't use --find option\n"
    fi
}
main $@