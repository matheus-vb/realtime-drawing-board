import fastify from "fastify";
import fastifySocketIO from "fastify-socket.io";

export const app = fastify();

app.register(fastifySocketIO);

app.ready(err => {
    if (err) throw err;

    app.io.on("connect", (socket) => {
        console.log(`New connection: ${socket.id}`);

        socket.on("upload_lines", function(data) {
            console.log(`Lines transferred from ${socket.id}`);
            app.io.emit("download_lines", data);
        })
    });
})