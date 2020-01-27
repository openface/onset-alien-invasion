// banner
function ShowBanner(message) {
    $("#notif").children().hide();

    $('#banner').html(message)
    $('#banner').show();
}

function HideBanner() {
    $('#banner').fadeOut();
}

// message
function ShowMessage(message) {
    $("#notif").children().hide();

    $('#message').html(`<span>${message}</span>`);
    $('#message').show();
}

function HideMessage() {
    $('#message').fadeOut();
}
