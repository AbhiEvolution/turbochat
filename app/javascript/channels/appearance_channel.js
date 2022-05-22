import consumer from "channels/consumer"

let resetfunc;
let timer = 0;


consumer.subscriptions.create("AppearanceChannel", {
    initialized() {},
    connected() {
        // Called when the subscription is ready for use on the server
        console.log("connected");
        resetfunc = () => this.resetTimer(this.uninstall);
        this.install();
        window.addEventListener("turbo:load", () => this.resetTimer());
    },

    disconnected() {

        console.log("connected");
        this.uninstall();
    },

    rejected() {
        console.log("Rejected");
        this.uninstall();
    },

    received(data) {
        // Called when there's incoming data on the websocket for this channel
    },
    online() {
        console.log("online");
        this.perform("online");
    },
    away() {
        console.log("away");
        this.perform("away");
    },
    offline() {
        console.log("offline");
        this.perform("offline");
    },
    uninstall() {
        const shouldRun = document.getElementById("appearance_channel");
        if (!shouldRun) {
            clearTimeout(timer);
            this.perform("offline");
        }
    },
    install() {
        console.log("install");
        window.removeEventListener("load", resetfunc);
        window.removeEventListener("DOMContentLoaded", resetfunc);
        window.removeEventListener("click", resetfunc);
        window.removeEventListener("keydown", resetfunc);

        window.addEventListener("load", resetfunc);
        window.addEventListener("DOMContentLoaded", resetfunc);
        window.addEventListener("click", resetfunc);
        window.addEventListener("keydown", resetfunc);
        this.resetTimer();
    },
    resetTimer() {
        this.uninstall();
        const shouldRun = document.getElementById("appearance_channel")

        if (!!shouldRun) {
            this.online();
            clearTimeout(timer);
            const timeInseconds = 5;
            const milliseconds = 1000;
            const timeInMilliseconds = timeInseconds * milliseconds;
            timer = setTimeout(this.away.bind(this), timeInMilliseconds);
        }

    }
});