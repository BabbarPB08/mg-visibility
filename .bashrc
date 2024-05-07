# .bashrc

# Source global definitions
if [ -f /etc/bashrc ]; then
	. /etc/bashrc
fi

alias oc=omc
alias yank="yank -y"
#complete -o default -F __start_omg oc

# Uncomment the following line if you don't like systemctl's auto-paging feature:
# export SYSTEMD_PAGER=

# User specific aliases and functions


# to check the major components of nodes 
sosv ()
{
	for i in $(echo `pwd`/sos*/*); do echo "######################################" && xsos -ocmped $i/ 2>/dev/null | grep -E "Hostname|LoadAvg|Top CPU-using processes:|MEMORY|Top MEM-using processes:|Interface Errors:" -A 11| sed "2 s/.*/ /g" | sed '/\[os-release\]/,+9d' && echo -e "\n\n================" && grep balloon $i/lsmod && echo -e "================\n\n"; done
}

# to check install type
instmod ()
{
	oc get cm -n openshift-config | grep -q openshift-install-manifests && echo "IPI" || echo "UPI"
}

# to check the resource capacity oc master nodes
nodecap ()
{
	oc get $(oc get nodes --no-headers -o name -l node-role.kubernetes.io/master=) -o json | jq '.items[] | {name: .metadata.name, capacity: .status.capacity}'
}




function setup_omc_prompt() {
    mg_path=$(omc use | grep Must-Gather | awk '{print $3}')
    if [ -d "$mg_path" ]; then
        attachment=$(echo $mg_path | cut -d'/' -f5)
        case_num=$(basename $(dirname $(dirname "$mg_path")))
        echo -e "[\e[1;36mOMC $case_num\e[0m | \e[1;36m$attachment\e[0m]"
    fi
}


if [[ -z "$PROMPT_COMMAND" ]]; then
	export PROMPT_COMMAND="$PROMPT_COMMAND; setup_omc_prompt"
else
	export PROMPT_COMMAND="setup_omc_prompt"
fi

yankcd() {
    if [[ $# -eq 0 ]]; then
        echo "Usage: yankcd <directory_id>"
        return 1
    fi

    local dir_id="$1"
    yank "$dir_id" && cd ~/"$dir_id" || return 1
}
