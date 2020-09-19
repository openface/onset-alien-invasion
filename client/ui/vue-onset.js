/*
 * Vue plugin to provide Onset UI integration
 */

/*
 * Call LUA client event from Vue component:
 * 
 *      Vue.CallEvent('WhateverClientEvent')
 */
Vue.config.devtools = true;
const VueOnsetPlugin = {
    install(Vue, options) {
        Vue.CallEvent = function (name, ...args) {
            if (typeof ue === 'undefined') {
                // for browser testing outside of game
                ue = { game: { callevent: console.log } };
                indev = true;
            }
            if (typeof name != "string") {
                return;
            }
            if (args.length == 0) {
                ue.game.callevent(name, "")
            } else {
                let params = []
                for (let i = 0; i < args.length; i++) {
                    params[i] = args[i];
                }
                ue.game.callevent(name, JSON.stringify(params));
            }
        }
    }
}
Vue.use(VueOnsetPlugin);

/*
 * Emit event to Vue component from LUA:
 * 
 * EmitEvent('LoadSomeData', data) 
 */
var EventBus = new Vue()

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
