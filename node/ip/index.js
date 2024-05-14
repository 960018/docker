import express from "express";
import { createServer } from "http";
import sanitizeHtml from "sanitize-html";

const app = express();

app.set("trust proxy", true);

app.all("*", (req, res) => {
    let ip = req.headers["cf-connecting-ip"] || req.headers["x-forwarded-for"] || req.ip;

    const isIPv4 = (address) => /^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$/.test(address);

    const sanitizeIP = (ip) => sanitizeHtml(ip, {
        allowedTags: [],
        allowedAttributes: {}
    });

    if (ip && ip.includes(',')) {
        ip = ip.split(',').map(ip => ip.trim()).find(isIPv4) || ip.split(',')[0];
    }

    if (!isIPv4(ip) && req.ips.length > 0) {
        ip = req.ips.find(isIPv4) || req.ip;
    }

    ip = sanitizeIP(ip);
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
