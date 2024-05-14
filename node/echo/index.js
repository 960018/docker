import express from "express";
import morgan from "morgan";
import http from "http";
import os from "os";
import jwt from "jsonwebtoken";
import concat from "concat-stream";

const app = express();

const sleep = ms => new Promise(resolve => setTimeout(resolve, ms));

app.set("json spaces", 4);
app.set("trust proxy", true);

app.use(morgan("combined"));

app.use(function (req, res, next) {
    req.pipe(
        concat(function (data) {
            req.body = data.toString("utf8");
            next();
        })
    );
});

app.all("*", (req, res) => {
    const echo = {
        body: req.body,
        cookies: req.cookies,
        headers: req.headers,
        fresh: req.fresh,
        hostname: req.hostname,
        os_hostname: os.hostname(),
        ip: req.ip,
        ips: req.ips,
        method: req.method,
        path: req.path,
        protocol: req.protocol,
        query: req.query,
        servername: req.socket.servername,
        subdomains: req.subdomains,
        xhr: req.xhr,
        navigator: navigator,
    };

    if (req.is("application/json")) {
        echo.json = JSON.parse(req.body);
    }

    if (process.env.JWT_HEADER) {
        let token = req.headers[process.env.JWT_HEADER.toLowerCase()];
        if (!token) {
            echo.jwt = token;
        } else {
            token = token.split(" ").pop();
            echo.jwt = jwt.decode(token, {complete: true});
        }
    }

    const setResponseStatusCode = parseInt(
        req.headers["x-set-response-status-code"],
        10
    );
    if (100 <= setResponseStatusCode && setResponseStatusCode < 600) {
        res.status(setResponseStatusCode);
    }

    const sleepTime = parseInt(req.headers["x-set-response-delay-ms"], 0);
    sleep(sleepTime).then(() => {
        if (
            process.env.ECHO_BACK_TO_CLIENT !== undefined &&
            process.env.ECHO_BACK_TO_CLIENT === "false"
        ) {
            res.end();
        } else {
            res.json(echo);
        }

        if (process.env.LOG_IGNORE_PATH !== req.path) {
            console.log("-----------------");

            let spacer = 4;
            if (process.env.LOG_WITHOUT_NEWLINE) {
                spacer = null;
            }

            console.log(JSON.stringify(echo, null, spacer));
        }
    });
});

const httpServer = http.createServer(app).listen(process.env.HTTP_PORT || 80);

let shuttingDown = false;

process.on("SIGINT", shutDown);
process.on("SIGTERM", shutDown);

async function shutDown() {
    if (shuttingDown) {
        return;
    }
    shuttingDown = true;
    httpServer.close(function () {
        process.exit();
    });
}
