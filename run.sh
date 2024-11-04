#!/bin/bash

# TODO: add ctrl+r bind to reload python

alias bat=$(command -v bat || command -v batcat) \
  || { echo "Bat not found."; exit 1; }

command -v fzf > /dev/null || { echo "Fzf not found."; exit 1; } 

SHELL=bash
FZF_DEFAULT_OPTIONS="--height 40% --layout reverse --border --ansi"

export FIFO_PICK=/tmp/fzf_preview_pick
export FIFO_ANSWER=/tmp/py_preview_answer

mkfifo $FIFO_PICK > /dev/null 2>&1
mkfifo $FIFO_ANSWER > /dev/null 2>&1

# python process is running in memory
# and keeps parsed yaml for quick access of config
# to communicate, we use FIFO
python3 /opt/ansible-task-runner/runner.py &

function format() {
  cat | bat -l yaml --color=always --style=plain --theme=1337
}

function preview() {
  echo $1 $2 $3 > $FIFO_PICK
  cat $FIFO_ANSWER
}

export -f preview
export -f format

while true
do
  # list all yaml files == supposed to be playbooks (no validation yet)
  playbook=$(ls *.y*ml | fzf $FZF_DEFAULT_OPTIONS --preview 'preview {} tasks | format | nl -w1 -s". "')
  [ -z "$playbook" ] && break
  export playbook
  tasks=$(preview $playbook tasks | nl -w1 -s". " | fzf $FZF_DEFAULT_OPTIONS --multi --preview 'preview $playbook task {n} | format')
  tasks_ids=$(echo "$tasks"ansible-playbook -i localhost, -c local | grep -o '^[0-9]*' | paste -sd "," -)
  [ -z "$tasks_ids" ] && continue
  result_playbook=$(preview $playbook tasks $tasks_ids)
  # show created ansible config with specific tasks
  echo "$result_playbook" | format | less
  # run it from stdin
  ansible-playbook "$@" /dev/stdin <<< $result_playbook
  unset $playbook
done

# kills all descendants
pkill -P $$
