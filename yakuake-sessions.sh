#!/bin/bash
#
# yakuake-sessions.sh: open Yakuake tabs from a list, each with a title and a folder or a command
#
# Usage: yakuake-sessions.sh [sessions_file]   (default: ~/.config/yakuake-sessions)
#
# One session per line, fields separated by "|":
#   title|cd|folder      a tab that changes to the folder
#   title|run|command    a tab that runs the command
#   title|type|command   a tab with the command typed but not run (for example an ssh login, started with Enter)
# Empty lines and lines starting with "#" are skipped. The first line uses the tab that is open when Yakuake starts.

sessions_file=${1:-$HOME/.config/yakuake-sessions}
[ ! -f "$sessions_file" ] && { echo "Error: File '$sessions_file' not found!"; exit 1; }

# Arguments: SessionID
# Returns the terminal id of the session's first terminal.
function terminalId {
qdbus-qt6 org.kde.yakuake /yakuake/sessions org.kde.yakuake.terminalIdsForSessionId "$1" | cut -d, -f1
}

# Returns the id of the session that is open.
function activeSession {
qdbus-qt6 org.kde.yakuake /yakuake/sessions org.kde.yakuake.activeSessionId
}

# Create new session.
# Returns session Id.
function newSession {
qdbus-qt6 org.kde.yakuake /yakuake/sessions org.kde.yakuake.addSession
};

# Arguments: SessionID, Command
function runCommand {
qdbus-qt6 org.kde.yakuake /yakuake/sessions org.kde.yakuake.runCommandInTerminal "$(terminalId "$1")" "$2"
};

# Arguments: SessionID, Text
# Konsole numbers its sessions from 1, Yakuake its terminals from 0.
function sendText {
local i=$(( $(terminalId "$1") + 1 ))
qdbus-qt6 org.kde.yakuake /Sessions/$i org.kde.konsole.Session.sendText "$2"
}

# Arguments: SessionID, Title
function setTitle {
qdbus-qt6 org.kde.yakuake /yakuake/tabs org.kde.yakuake.setTabTitle "$1" "$2"
};

first=1
while IFS='|' read -r title kind argument || [ -n "$title" ]; do
    [ -z "$title" ] && continue
    [ "${title:0:1}" = "#" ] && continue

    if [ $first -eq 1 ]; then
        session=$(activeSession)
        first=0
    else
        session=$(newSession)
    fi

    setTitle "$session" "$title"
    case "$kind" in
        cd)   runCommand "$session" "cd $argument" ;;
        run)  runCommand "$session" "$argument" ;;
        type) sendText "$session" "$argument" ;;
        *)    echo "Unknown kind '$kind' for '$title'" ;;
    esac
done < "$sessions_file"
