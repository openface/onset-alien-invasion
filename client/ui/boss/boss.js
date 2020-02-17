function SetBossHealth(health_percentage) {
    $('#health-box').show();
    $(".health-bar").animate({
        'width': health_percentage + "%"
    }, 500);
}

function HideBossHealth() {
    $('#health-box').fadeOut();
}