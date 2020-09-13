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
    items = JSON.parse(data);

    // remove inventory child nodes
    $('#inventory').empty();

    let html = "";
    // populate slot contents
    $.each(items, function (i, item) {
        i = i + 1;
        html += `<div class="slot" id="slot-${i}">`;
        html += `<img src="../images/${item['item']}.png" />`;
        if (item['quantity'] > 1) {
            html += `<span class="quantity">${item['quantity']}</span>`;
        }
        html += `</div>`;
    });

    $('#inventory').html(html);
}

$(document).ready(function () {
    SetInventory('[{"quantity":2,"item":"scrap"}]');
});