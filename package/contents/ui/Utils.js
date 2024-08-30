function addToModel(...details) {
    models.append({
        "modelName": details[0],
        "modifiedTime": details[1],
        "modelSize": details[2],
        "modelFormat": details[3],
        "modelArch": details[4],
        "modelParam": details[5],
        "modelQuant": details[6]
    });
}

function invokeDelayTimerCallback(callback, interval) {
    if (typeof delayTimerCallback === "function") {
        delayTimerCallback(callback, interval);
    } 
}

function getModels() {
    const url = cfg.ollamaUrl + '/api/tags';
    models.clear();

    const xhr = new XMLHttpRequest();
    xhr.open('GET', url, true);
    xhr.setRequestHeader('Content-Type', 'application/json');

    xhr.onreadystatechange = function() {
        if (xhr.readyState === XMLHttpRequest.DONE) {
            if (xhr.status === 200) {
                const response = JSON.parse(xhr.responseText);
                response.models.forEach(model => {
                    const modelName = model.name;
                    const modifiedAt = new Date(model.modified_at);
                    const modelByte = model.size;
                    const modelFormat = model.details.format;
                    const modelArch = model.details.family;
                    const modelParam = model.details.parameter_size;
                    const modelQuant = model.details.quantization_level;
                    const modifiedTime = diffTime(modifiedAt);
                    const modelSize = bytesToSize(modelByte);

                    addToModel(modelName, modifiedTime, modelSize, modelFormat, modelArch, modelParam, modelQuant);
                });
                getRunningModels();
            } else {
                console.error('Error Get Models: ' + xhr.status);
            }
        }
    };
    xhr.send();
}

function diffTime(date) {
    const now = new Date();
    const diffInMs = now - date;
    const diffInMinutes = Math.round(diffInMs / (60 * 1000));
    const diffInDays = Math.round(diffInMs / (24 * 60 * 60 * 1000));

    if (diffInDays === 0) {
        return `${diffInMinutes} Minute${diffInMinutes !== 1 ? 's' : ''} Ago`;
    } else {
        return `${diffInDays} Day${diffInDays !== 1 ? 's' : ''} Ago`;
    }
}

function bytesToSize(bytes) {
    const sizes = ["Bytes", "KB", "MB", "GB", "TB"];
    const sizeIndex = Math.floor((Math.log(+bytes) / Math.log(2)) / 10);
    const placeValue = Math.pow(10, 3 * sizeIndex);
    let value = bytes / placeValue;

    const firstDecimal = Math.floor((value * 10) % 10);
    const secondDecimal = Math.floor((value * 100) % 10);

    if (secondDecimal >= 5) {
        value = Math.round(value * 10) / 10;
    } else if (firstDecimal >= 5) {
        value = Math.ceil(value * 10) / 10;
    } else {
        value = Math.floor(value * 10) / 10;
    }
    return `${value.toFixed(1)} ${sizes[sizeIndex]}`;
}

function getRunningModels() {
    const url = cfg.ollamaUrl + '/api/ps';
    runningModels.clear();

    const xhr = new XMLHttpRequest();
    xhr.open('GET', url, true);
    xhr.setRequestHeader('Content-Type', 'application/json');

    xhr.onreadystatechange = function() {
        if (xhr.readyState === XMLHttpRequest.DONE) {
            if (xhr.status === 200) {
                const response = JSON.parse(xhr.responseText);

                response.models.forEach(model => {
                    const models = model.model;

                    runningModels.append({
                        text: models
                    });
                });
                if (runningModels.count > 0) {
                    listPage.modelsCombobox.currentIndex = 0;
                }
            } else {
                console.error('Error Get Running Model: ' + xhr.status);
            }
        }
    };
    xhr.send();
}

function loadModel(models) {
    const url = cfg.ollamaUrl + '/api/generate';
    const data = JSON.stringify({
        "model": models
    });

    const xhr = new XMLHttpRequest();
    xhr.open('POST', url, true);
    xhr.setRequestHeader('Content-Type', 'application/json');

    xhr.onreadystatechange = function() {
        if (xhr.readyState === XMLHttpRequest.DONE) {
            if (xhr.status === 200) {

                invokeDelayTimerCallback(() => {
                    getRunningModels();
                });
            } else {
                console.error('Error Unload: ' + xhr.status + ' ' + xhr.statusText);
                console.error('Response Unload: ' + xhr.responseText);
            }
        }
    };
    xhr.send(data);
}

function unloadModel(models) {
    const url = cfg.ollamaUrl + '/api/generate';
    const data = JSON.stringify({
        "model": models, "keep_alive": 0
    });

    const xhr = new XMLHttpRequest();
    xhr.open('POST', url, true);
    xhr.setRequestHeader('Content-Type', 'application/json');

    xhr.onreadystatechange = function() {
        if (xhr.readyState === XMLHttpRequest.DONE) {
            if (xhr.status === 200) {

                invokeDelayTimerCallback(() => {
                    getRunningModels();
                });
            } else {
                console.error('Error Unload: ' + xhr.status + ' ' + xhr.statusText);
                console.error('Response Unload: ' + xhr.responseText);
            }
        }
    };
    xhr.send(data);
}

class Command {
    constructor(cmd, txt, callback) {
        this.cmd = cmd;
        this.txt = txt;
        this.callback = callback;
    }

    run(...args) {
        console.log("Command identifier:", this.txt);
    
        let newCmd;
        if (this.txt === 'start-ollama' || this.txt === 'stop-ollama') {
            newCmd = this.cmd.replace("{}", cfg.ollamaUrl);
        } else {
            newCmd = this.cmd.replace("{}", args[0]);
        }
        // console.log(`New Command: ${newCmd}`);
        this.exec(newCmd, ...args);
    }

    exec(cmd, ...args) {
        executable.exec(cmd, (_,stdout,stderr,_2) => {
            // console.log(`Command Output: \nOutput: ${stdout}\nstderr: ${stderr}`);

            const match = stdout.trim().match(/Response:(\d+)/);
            const resCode = match ? match[1] : "";

            // console.log("Response Code:", resCode || "No match found for response code");

            if (this.txt === 'start-ollama' || this.txt === 'stop-ollama') {
                const delay = this.txt === 'stop-ollama' ? 2000 : 5000;

                invokeDelayTimerCallback(() => {
                    this.callback();
                }, delay);
                
            } else {
                this.callback(resCode, ...args, stdout);
            }
        });
    }
}

let commands = {
    startOllama: new Command("systemctl start ollama.service",
        "start-ollama", checkStat
    ),
    stopOllama: new Command("systemctl stop ollama.service",
        "stop-ollama", checkStat
    ),
};

function endAll() {
    executable.endAll();
}

function checkStat() {
    const url = cfg.ollamaUrl + '/api/tags';

    const xhr = new XMLHttpRequest();
    xhr.open('GET', url, true);
    xhr.setRequestHeader('Content-Type', 'application/json');

    xhr.onreadystatechange = function() {
        if (xhr.readyState === XMLHttpRequest.DONE) {
            if (xhr.status === 200) {
                ollamaRunning = true;

                updateActionButton("Stop Ollama", Qt.resolvedUrl("icons/stop.svg"), "stopOllama");

                // console.log("Ollama Running: " + ollamaRunning + " | Ollama is running");
            } else {
                endAll();
                ollamaRunning = false;

                models.clear();
                runningModels.clear();
                
                updateActionButton("Start Ollama", Qt.resolvedUrl("icons/start.svg"), "startOllama");

                // console.log("Ollama Running: " + ollamaRunning + " | Ollama is not running");
                console.error('Error Check Status: ' + xhr.status);

            }
        }
    };
    xhr.send();
}

function updateActionButton(text, iconName, command) {
    if (typeof actionButton !== "undefined") {
        actionButton.text = i18n(text);
        actionButton.icon.name = iconName;
        actionButton.command = command;
    }
}