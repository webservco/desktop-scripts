# desktop-scripts

Small scripts for my Linux desktop (Fedora, KDE Plasma on Wayland). They lived in my notes; here they are cleaned of
host names and gathered in one place.

## Contents

| Path | What |
|---|---|
| `yakuake-sessions.sh` | opens Yakuake tabs from a list: a title each, and a folder, a command, or a command typed but not run |
| `yakuake-sessions.example` | an example list |
| `mouse-jiggler.sh` | moves the mouse pointer by one pixel at an interval, so that the session does not go idle |

## yakuake-sessions.sh

My work day starts with the same dozen terminal tabs: the projects' folders and a login to each server. Yakuake
answers on D-Bus, so a script opens them:

```sh
cp yakuake-sessions.example ~/.config/yakuake-sessions   # then edit
yakuake-sessions.sh
```

Each line of the list is `title|kind|argument`:

- `cd`: the tab changes to the folder;
- `run`: the tab runs the command;
- `type`: the command is typed but not run, for example an `ssh` login that starts only when I press Enter in that tab.

The first line uses the tab that is open when Yakuake starts. The script calls `qdbus-qt6` (Plasma 6; `qdbus` on Plasma
5). Typed text goes to the Konsole session behind the tab, which Konsole numbers from 1 while Yakuake numbers its
terminals from 0. A tab split later does not keep the folder.

## mouse-jiggler.sh

```sh
mouse-jiggler.sh 60
```

On Wayland the pointer is moved with `ydotool`, which needs its daemon `ydotoold` running and its socket reachable by
the user; on X11 the commented `xdotool` line does the same without a daemon. The setup I use on Fedora (check the
options against `ydotoold --help` of the installed version):

```sh
sudo dnf install ydotool
sudo tee /etc/profile.d/ydotool.sh << "EOF" > /dev/null
export YDOTOOL_SOCKET="/tmp/.ydotool_socket"
EOF
sudo mkdir -p /etc/systemd/system/ydotool.service.d
sudo tee /etc/systemd/system/ydotool.service.d/override.conf << "EOF" > /dev/null
[Service]
ExecStart=
ExecStart=/usr/bin/ydotoold -p /tmp/.ydotool_socket -P 660
EOF
sudo systemctl daemon-reload
sudo systemctl enable ydotool.service
sudo systemctl restart ydotool.service
sudo usermod -a -G input ${USER}
```

## Licence

MIT (see `LICENSE`).
