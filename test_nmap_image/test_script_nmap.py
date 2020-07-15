#!/usr/bin/env python3
from os import system
from subprocess import run, PIPE
from typing import List


def switch_list():
    switches = [
    "-Pn -sS",
    "-Pn -sT",
    "-Pn -sU"
    ]
    return switches


def command_builder(switches: List, targets: List):
    # Add nmap
    cmds = ["nmap -v " + s for s in switches]

    # Add ports
    tops = [c + " --top-ports 5" for c in cmds]
    ports = [c + " -p 80" for c in cmds]

    cmds = tops + ports

    # Add extra switches
    version = [c + " --version-all" for c in cmds]
    reason = [c + " --reason" for c in cmds]
    scripts = [c + " -sC" for c in cmds]
    vers = [c + " -sV" for c in cmds]

    # Combine lists
    cmds = cmds + version + reason + scripts + vers

    # Add target/s
    cmds = [c + " " + t for c in cmds for t in targets]
    
    # Dockerize
    cmds = ["docker run blairy/" + c for c in cmds]

    # Add cmd printer
    cmds = ["echo \'\n\nCommand: " + c + "\n\' && " + c for c in cmds]

    #[print(c) for c in cmds]
    return cmds


def command_executor(cmds):
    try:
        # Show nmap version info
        system("docker run blairy/nmap -V")
        # Run test commands
        [system(c) for c in cmds]
    except Exception as e:
        print("\n*******  ERROR! running nmap command: " + str(e))


def main():
    targets = ["scanme.nmap.org"]
    cmds = command_builder(switch_list(), targets)
    command_executor(cmds)


if __name__ == '__main__':
    main()


