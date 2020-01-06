/*
$(document).ready(function () {
    if (typeof ue === 'undefined') {
        // for browser testing outside of game
        ue = { game: { callevent: console.log } };
    }
    (function (obj) {
        ue.game = {};
        ue.game.callevent = function (name, ...args) {
            if (typeof name != "string") {
                return;
            }
            if (args.length == 0) {
                obj.callevent(name, "")
            } else {
                let params = []
                for (let i = 0; i < args.length; i++) {
                    params[i] = args[i];
                }
                obj.callevent(name, JSON.stringify(params));
            }
        };
    })(ue.game);
    CallEvent = ue.game.callevent;
});
*/

function SetBannerMessage(message) {
    $('#banner').html(message)
}