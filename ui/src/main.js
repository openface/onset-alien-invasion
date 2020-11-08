import Vue from "vue";
import App from "./App.vue";
import VueRouter from "vue-router";

Vue.config.productionTip = false;
Vue.config.devtools = true;

/*
 * For development outside of game, define
 * the ue.game to call the console.log()
 * and set an indev global variable.
 */
var InGame = true;
if (typeof window.ue === "undefined") {
  // for browser testing outside of game
  // eslint-disable-next-line
  window.ue = { game: { callevent: console.log } };
  // eslint-disable-next-line
  InGame = false;
}

/*
 * GLobal EventBus provides communication from
 * Lua client to Vue components and vice-versa.
 */
var EventBus = new Vue();

/*
 * Emit event from Lua client to Vue component
 *
 * EmitEvent('SomeEvent', data)
 */
// eslint-disable-next-line
function EmitEvent(name, ...args) {
  if (typeof name != "string") {
    return;
  }
  if (args.length == 0) {
    EventBus.$emit(name);
  } else {
    EventBus.$emit(name, ...args);
  }
}
window.EmitEvent = EmitEvent;


/*
 * Vue plugin to allow calling Lua client from Vue component
 *
 * this.CallEvent('WhateverClientEvent')
 */

// eslint-disable-next-line
var VueOnset = {
  install(Vue) {
    Vue.prototype.CallEvent = function(name, ...args) {
      if (typeof name != "string") {
        return;
      }
      if (args.length == 0) {
        window.ue.game.callevent(name, "");
      } else {
        let params = [];
        for (let i = 0; i < args.length; i++) {
          params[i] = args[i];
        }
        window.ue.game.callevent(name, JSON.stringify(params));
      }
    }
    Vue.prototype.EventBus = EventBus;
    Vue.prototype.InGame = InGame;

    // object image handler
    Vue.prototype.getImageUrl = function(item) {
      if (this.InGame) {
        if (item.image !== undefined) {
          return require('@/assets/images/objects/' + item.image)
        } else {
          return 'http://game/objects/' + item.modelid;
        }
      } else {
        return "http://placekitten.com/75/75"
      }
    }
  }
}

Vue.use(VueOnset);

/*
 * Progress Bar
 */
import 'vue-progress-path/dist/vue-progress-path.css'
import VueProgress from 'vue-progress-path'

Vue.use(VueProgress);


/* 
 * Routing
 */
Vue.use(VueRouter);

import Character from "./components/Character.vue";
import Inventory from "./components/Inventory.vue";
import Storage from "./components/Storage.vue";
import Hud from "./components/Hud.vue";
import Workbench from "./components/Workbench.vue";
import Merchant from "./components/Merchant.vue";
import Computer from "./components/Computer.vue";
import Scoreboard from "./components/Scoreboard.vue";

const routes = [
  { path: "/character", component: Character, name: "Character" },
  { path: "/inventory", component: Inventory, name: "Inventory" },
  { path: "/storage", component: Storage, name: "Storage" },
  { path: "/hud", component: Hud, name: "Hud" },
  { path: "/workbench", component: Workbench, name: "Workbench" },
  { path: "/merchant", component: Merchant, name: "Merchant" },
  { path: "/computer", component: Computer, name: "Computer" },
  { path: "/scoreboard", component: Scoreboard, name: "Scoreboard" },
];
const router = new VueRouter({ routes });

// eslint-disable-next-line
window.app = new Vue({ el: "#app", router, render: (h) => h(App) });

