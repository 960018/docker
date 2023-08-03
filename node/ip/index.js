import express from "express";
import {createServer} from "http";

const app = express();

app.set("trust proxy", ["loopback", "linklocal", "uniquelocal"]);

app.all("*", (req, res) => {
    let ip = req.headers["cf-connecting-ip"];
    app.set("title", ip);
    res.send(ip);
});

const httpServer = createServer(app).listen(process.env.HTTP_PORT || 80);

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
