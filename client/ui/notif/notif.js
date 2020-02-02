// banner
function ShowBanner(message) {
    $("#notif").children().hide();

    $('#banner').html(message)
    $('#banner').show();
}

// message
function ShowMessage(message) {
    $("#notif").children().hide();

    $('#message').html(`<span>${message}</span>`);
    $('#message').show();
}

function HideNotifs() {
    $("#notif").children().fadeOut(250);
}