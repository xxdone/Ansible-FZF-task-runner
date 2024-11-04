import copy

import yaml

FIFO_PICK = "/tmp/fzf_preview_pick"
FIFO_ANSWER = "/tmp/py_preview_answer"

playbooks = {}


def read_playbook(fname):
    if fname not in playbooks:
        f = open(fname, "r")
        playbooks[fname] = yaml.safe_load(f)

    return playbooks[fname]


def get_tasks_names(fname):
    return [task["name"] for task in read_playbook(fname)[0]["tasks"]]


def get_nth_task(fname, idx):
    return read_playbook(fname)[0]["tasks"][idx]


def read_pick():
    fp = open(FIFO_PICK, "r")
    return fp.read()


def write_answer(data):
    fa = open(FIFO_ANSWER, "w")
    fa.write(data)


while True:
    pick = read_pick()
    if len(pick) == 0:
        continue

    fname, a, b, *z = [p.strip() for p in pick.split(" ")] + [
        None,
    ] * 2

    # filename tasks
    if a == "tasks" and b is None:
        # tasks = ["• " + t for t in get_tasks_names(fname)]
        tasks = [t for t in get_tasks_names(fname)]
        write_answer("\n".join(tasks))
        # print("\n".join(tasks))

    # filename task 1
    if a == "task" and (b is not None and b.isnumeric()):
        task = get_nth_task(fname, int(b))
        pretty_task = yaml.dump(task, default_flow_style=False, sort_keys=False)
        write_answer(pretty_task)
        # print(pretty_task)

    # filename tasks 1,2,3
    if a == "tasks" and (b is not None):
        tasks_ids = b.split(",")
        tasks = list(map(lambda idx: get_nth_task(fname, int(idx) - 1), tasks_ids))
        result_playbook = copy.deepcopy(read_playbook(fname))
        result_playbook[0]["tasks"] = tasks
        pretty_playbook = yaml.dump(
            result_playbook, default_flow_style=False, sort_keys=False
        )
        write_answer(pretty_playbook)
