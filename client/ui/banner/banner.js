function ShowBanner(message) {
    $('#banner').html(message)
    $('#banner').show();
}

function HideBanner() {
    $('#banner').hide();
    $('#banner').html('');
}