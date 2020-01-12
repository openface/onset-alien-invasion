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