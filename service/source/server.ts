import { app } from "./app";

const PORT = 5050;

app.listen({
    host: "0.0.0.0",
    port: PORT,
}).then(() => {
    console.log(`Realtime drawing service running on http://localhost:${PORT}`)
})