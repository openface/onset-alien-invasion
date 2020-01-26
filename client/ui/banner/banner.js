function ShowBanner(message) {
    $('#banner').html(message)
    $('#banner').show();
}

function HideBanner() {
    $('#banner').fadeout();
}