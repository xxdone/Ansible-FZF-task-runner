# Ansible FZF task runner

![Ansible FZF task runner](./demo.gif)

### Prerequisites

- [fzf](https://github.com/junegunn/fzf)
- [bat](https://github.com/sharkdp/bat) (for highlighting tasks)

### Install

```
git clone https://github.com/xxdone/Ansible-fzf-task-runner
sudo make install
```

### Usage

`atr $ARGS`

where `$ARGS` you specify ansible playbook args

for running against specific host: `atr -i inventory -u root --limit=node1`

for running locally: `atr -i localhost, -c local`

### Notes

To select multiple tasks press 'TAB'.
