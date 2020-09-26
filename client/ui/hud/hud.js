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
function aSetInventory(data) {
    //console.log(data);
    items = JSON.parse(data);

    // remove inventory child nodes
    $('#inventory').empty();

    let html = "";
    // populate slot contents
    // name, modelid, quantity
    $.each(items, function (i, item) {
        i = i + 1;
        html += `<div class="slot" id="slot-${i}">`;
        html += `<img src="http://game/objects/${item['modelid']}" />`;
        if (item['quantity'] > 1) {
            html += `<span class="quantity">${item['quantity']}</span>`;
        }
        html += `</div>`;
    });

    $('#inventory').html(html);
}

/*
 *
 */
Vue.component('notif', {
    template: '#notif'
})

Vue.component('inventory', {
    template: '#inventory',
    props: {
        items: { type: Array }
    }
})

new Vue({
    el: '#hud',
    data() {
        return {
            items: []
        }
    },
    mounted() {
        EventBus.$on('SetInventory', (data) => {
            this.items = data
        });
    }
});


// dev seeding
(function () {
    if (typeof indev !== 'undefined') {
        EmitEvent('SetInventory', [
            {
                "name": "scrap",
                "modelid": 694,
                "quantity": 2
            }
        ]);
    }
})();
