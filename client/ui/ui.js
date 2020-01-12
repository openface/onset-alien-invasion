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

function ShowBanner(message) {
    $('#banner').html(message)
    $('#banner').show();
}

function HideBanner() {
    $('#banner').fadeOut();
}

function SetBossHealth(health, max_health) {
    var h = health * (100 / max_health);

    $('#health-box').show();
    $(".health-bar").animate({
        'width': h + "%"
    }, 500);
}

function HideBossHealth() {
    $('#health-box').fadeOut();
}

function ShowComputer() {
    $('#terminal-box').show();
    $('#terminal-box').click(function () {
        CallEvent('CloseComputer'); 
    });
}

function HideComputer() {
    $('#terminal-box').fadeOut();
}