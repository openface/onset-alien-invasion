import Vue from "vue";
import App from "./App.vue";

Vue.config.productionTip = false;
Vue.config.devtools = true;

/*
 * Vue plugin to allow calling Lua client from Vue component
 *
 * this.CallEvent('WhateverClientEvent')
 */

// eslint-disable-next-line
var VueOnset = {
  install(Vue) {
    if (typeof window.ue === "undefined") {
      // for browser testing outside of game
      // eslint-disable-next-line
      window.ue = { game: { callevent: console.log } };
      // eslint-disable-next-line
      var indev = true;
    }

    Vue.prototype.CallEvent = function (name, ...args) {
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
  }
}

Vue.use(VueOnset);

/*
 * Emit event from Lua client to Vue component
 *
 * EmitEvent('SomeEvent', data)
 */
var EventBus = new Vue();

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

// eslint-disable-next-line
window.app = new Vue({ el: '#app', render: h => h(App) });

