# Plasmoid Ollama Control

## Screenshots

![](./images/screenshot1.png)
![](./images/screenshot2.png)

## Installation

### KDE Store

[Store link](https://store.kde.org/p/2196368/)

### Build it Yourself

```bash
git clone https://github.com/imoize/plasmoid-ollamacontrol.git
cd plasmoid-ollamacontrol
kpackagetool6 -t Plasma/Applet -i package
```

Restart plasmashell
```bash
systemctl --user restart plasma-plasmashell
```

Go to Configure System Tray > Entries > System Services then choose "Show when relevant" or "Always shown"