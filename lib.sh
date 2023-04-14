#!/usr/bin/env bash

get_testscript_path() {
    grep -E '^temporary work directory: .*/testscript' err
}

filter_gomodproxy_path() {
    declare -a dirs=($(cut -d: -f2 | sed -e 's#^ *##'))
    find "${dirs[@]}" -type f | grep .gomodproxy | xargs dirname | sort -u
}

workspace() {
    workspace=$(get_testscript_path | filter_gomodproxy_path)
    echo $workspace
}

prepare_txtar_for_saves(){
    local txtar="$1"
    perl -pi -e '!m{^-- .gomodproxy/}i && s{^-- (.*)}{-- .gomodproxy/$1}i' $txtar
}

run_testscript() {
    local txtar="$1"

    prepare_txtar_for_saves $txtar
    GIT_PAGER=cat git diff

    # export WORK=$(mktemp -d /tmp/mytest.XXXX)
    ~/go/bin/testscript -v -work $txtar 2>err
}

create_single_txtar() {
    [[ ! -d cue ]] && git clone --depth 1 https://github.com/cue-lang/cue.git
    cd cue/doc/tutorial/basics/0_intro/
}

test() {
    create_single_txtar
    run_testscript 10_json.txtar
    cd $(workspace)

    # manually fiddle with json.cue to experiment
    # vim json.cue 
}
