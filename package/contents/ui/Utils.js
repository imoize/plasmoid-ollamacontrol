function addToModel(...details) {
    models.append({
        modelName: details[0],
        modifiedTime: details[1],
        modelSize: details[2],
        modelFormat: details[3],
        modelArch: details[4],
        modelParam: details[5],
        modelQuant: details[6],
    });
}

function invokeDelayTimerCallback(callback, interval) {
    if (typeof delayTimerCallback === "function") {
        delayTimerCallback(callback, interval);
    }
}

function getModels() {
    const url = cfg.ollamaUrl + "/api/tags";
    models.clear();

    const xhr = new XMLHttpRequest();
    xhr.open("GET", url, true);
    xhr.setRequestHeader("Content-Type", "application/json");

    xhr.onreadystatechange = function () {
        if (xhr.readyState === XMLHttpRequest.DONE) {
            if (xhr.status === 200) {
                const response = JSON.parse(xhr.responseText);
                response.models.forEach((model) => {
                    const modelName = model.name;
                    const modifiedAt = new Date(model.modified_at);
                    const modelByte = model.size;
                    const modelFormat = model.details.format;
                    const modelArch = model.details.family;
                    const modelParam = model.details.parameter_size;
                    const modelQuant = model.details.quantization_level;
                    const modifiedTime = diffTime(modifiedAt);
                    const modelSize = bytesToSize(modelByte);

                    addToModel(
                        modelName,
                        modifiedTime,
                        modelSize,
                        modelFormat,
                        modelArch,
                        modelParam,
                        modelQuant
                    );
                });
                getRunningModels();
            } else {
                console.error("Error Get Models: " + xhr.status);
            }
        }
    };
    xhr.send();
}

function diffTime(date) {
    const now = new Date();
    const diffInMs = now - date;
    const diffInSeconds = Math.floor(diffInMs / 1000);
    const diffInMinutes = Math.floor(diffInSeconds / 60);
    const diffInHours = Math.floor(diffInMinutes / 60);
    const diffInDays = Math.floor(diffInHours / 24);

    if (diffInDays > 0) {
        return `${diffInDays} Day${diffInDays !== 1 ? "s" : ""} Ago`;
    } else if (diffInHours > 0) {
        return `${diffInHours} Hour${diffInHours !== 1 ? "s" : ""} Ago`;
    } else if (diffInMinutes > 0) {
        return `${diffInMinutes} Minute${diffInMinutes !== 1 ? "s" : ""} Ago`;
    } else if (diffInSeconds >= 10) {
        return `${diffInSeconds} Second${diffInSeconds !== 1 ? "s" : ""} Ago`;
    } else {
        return "Just now";
    }
}

function bytesToSize(bytes) {
    const sizes = ["Bytes", "KB", "MB", "GB", "TB"];
    const sizeIndex = Math.floor(Math.log(+bytes) / Math.log(2) / 10);
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
    const url = cfg.ollamaUrl + "/api/ps";
    runningModels.clear();

    const xhr = new XMLHttpRequest();
    xhr.open("GET", url, true);
    xhr.setRequestHeader("Content-Type", "application/json");

    xhr.onreadystatechange = function () {
        if (xhr.readyState === XMLHttpRequest.DONE) {
            if (xhr.status === 200) {
                const response = JSON.parse(xhr.responseText);

                response.models.forEach((model) => {
                    const models = model.model;

                    runningModels.append({
                        text: models,
                    });
                });
                if (runningModels.count > 0) {
                    listPage.modelsCombobox.currentIndex = 0;
                }
            } else {
                console.error("Error Get Running Model: " + xhr.status);
            }
        }
    };
    xhr.send();
}

function handleModel(model, action) {
    const generateUrl = cfg.ollamaUrl + "/api/generate";
    const embedUrl = cfg.ollamaUrl + "/api/embed";
    const data = JSON.stringify({
        model: model,
        keep_alive: action === "unload" ? 0 : undefined,
    });

    isLoading = true;

    function sendRequest(url) {
        const xhr = new XMLHttpRequest();
        xhr.open("POST", url, true);
        xhr.setRequestHeader("Content-Type", "application/json");

        xhr.onreadystatechange = function () {
            if (xhr.readyState === XMLHttpRequest.DONE) {
                if (xhr.status === 200) {
                    invokeDelayTimerCallback(() => {
                        getRunningModels();
                    });
                    isLoading = false;
                } else if (xhr.status === 400 && url === generateUrl) {
                    sendRequest(embedUrl);
                } else {
                    console.error("Error " + action + ": " + xhr.status + " " + xhr.statusText + " " + xhr.responseText);
                    isLoading = false;
                }
            }
        };
        xhr.send(data);
    }
    sendRequest(generateUrl);
}

function copyModel(source, destination) {
    const url = cfg.ollamaUrl + "/api/copy";
    const data = JSON.stringify({
        source: source,
        destination: destination,
    });

    isLoading = true;

    const xhr = new XMLHttpRequest();
    xhr.open("POST", url, true);
    xhr.setRequestHeader("Content-Type", "application/json");

    xhr.onreadystatechange = function () {
        if (xhr.readyState === XMLHttpRequest.DONE) {
            if (xhr.status === 200) {
                getModels();
                isLoading = false;
            } else {
                console.error("Error copying model: " + xhr.status);
                getModels();
                isLoading = false;
            }
        }
    };
    xhr.send(data);
}

function deleteModelCallback(resCode, _, stdout) {
    if (resCode === "200") {
        endAll();
        getModels();
        isLoading = false;
    } else if (resCode !== "200" || resCode === "") {
        endAll()
        getModels();
        isLoading = false;
    }
}

class Command {
    constructor(cmd, txt, callback) {
        this.cmd = cmd;
        this.txt = txt;
        this.callback = callback;
    }

    run(...args) {
        // console.log("Command identifier:", this.txt);

        let newCmd;
        if (this.txt === "delete-model") {
            isLoading = true;
            const data = JSON.stringify({
                name: args[0],
            });
            newCmd = this.cmd.replace("{url}", cfg.ollamaUrl).replace("{data}", data);
        } else {
            newCmd = this.cmd.replace("{}", args[0]);
        }
        // console.log(`New Command: ${newCmd}`);
        this.exec(newCmd, ...args);
    }

    exec(cmd, ...args) {
        executable.exec(cmd, (_, stdout, stderr, _2) => {
            // console.log(`Command Output: \nOutput: ${stdout}\nstderr: ${stderr}`);

            const match = stdout.trim().match(/Response:(\d+)/);
            const resCode = match ? match[1] : "";

            // console.log("Response Code:", resCode || "No match found for response code");

            if (this.txt === "start-ollama" || this.txt === "stop-ollama") {
                const delay = this.txt === "stop-ollama" ? 2000 : 5000;

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
    startOllama: new Command(
        "systemctl start ollama.service",
        "start-ollama",
        checkStat
    ),
    stopOllama: new Command(
        "systemctl stop ollama.service",
        "stop-ollama",
        checkStat
    ),
    deleteModel: new Command(
        "curl --write-out 'Response:%{http_code}' -X DELETE {url}/api/delete -d '{data}'",
        "delete-model",
        deleteModelCallback
    ),
};

function endAll() {
    executable.endAll();
}

function checkStat() {
    const url = cfg.ollamaUrl + "/api/version";

    const xhr = new XMLHttpRequest();
    xhr.open("GET", url, true);
    xhr.setRequestHeader("Content-Type", "application/json");

    xhr.onreadystatechange = function () {
        if (xhr.readyState === XMLHttpRequest.DONE) {
            if (xhr.status === 200) {
                if (ollamaRunning === false) {
                    getModels();
                }
                ollamaRunning = true;

                // console.log("Ollama Running: " + ollamaRunning + " | Ollama is running");
            } else {
                endAll();
                ollamaRunning = false;
                models.clear();
                runningModels.clear();

                // console.log("Ollama Running: " + ollamaRunning + " | Ollama is not running");
                console.error("Error Check Status: " + xhr.status);
            }
        }
    };
    xhr.send();
}