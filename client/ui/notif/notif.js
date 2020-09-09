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

// inventory
function SetInventory(data) {
    console.log(data);
    objects = JSON.parse(data);

    // clear inventory slots
    $('.slot').empty();

    // populate slot contents
    $.each(objects, function (i, object) {
        i = i + 1;
        let html = `<img src="http://game/objects/${object['modelid']}"></img>`;
        if (object['quantity'] > 1) {
            html += `<span class="quantity">${object['quantity']}</span>`;
        }
        $('#slot-' + i).html(html);
    });
}

$(document).ready(function () {
    /*SetInventory('[{"quantity":2,"modelid":662}]');*/
});