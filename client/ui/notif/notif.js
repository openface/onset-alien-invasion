// banner
function ShowBanner(message) {
    $("#notif").children().hide();

    $('#banner').html(message)
    $('#banner').show().delay(5000).fadeOut('fast');
}

// message
function ShowMessage(message) {
    $("#notif").children().hide();

    $('#message').html(`<span>${message}</span>`);
    $('#message').show().delay(5000).fadeOut('fast');
}

// overlay
function ShowBlood() {
    $("#overlay").show().delay(500).fadeOut('slow');
}