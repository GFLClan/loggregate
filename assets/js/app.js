// We need to import the CSS so that webpack will load it.
// The MiniCssExtractPlugin is used to separate it out into
// its own CSS file.
import css from "../css/app.css"

// webpack automatically bundles all modules in your
// entry points. Those entry points can be configured
// in "webpack.config.js".
//
// Import dependencies
//
import "phoenix_html"
import bulmaCalendar from "bulma-calendar"

import { Socket } from "phoenix"
import LiveSocket from "phoenix_live_view"

let csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content");

let Hooks = {};
Hooks.Filter = {
    updated() {
        window.location.hash = this.el.value;
    }
};
Hooks.LiveConsole = {
    updated() {
        if (this.el.children.length > 100) {
            Array.prototype.slice.call(this.el.children, 100 - this.el.children.length).map((child) => this.el.removeChild(child));
        }
    }
};

let liveSocket = new LiveSocket("/live", Socket, {params: {_csrf_token: csrfToken, hash: window.location.hash}, hooks: Hooks});
liveSocket.connect();

// Import local files
//
// Local files can be imported directly using relative paths, for example:
// import socket from "./socket"

bulmaCalendar.attach('[type="date"]');