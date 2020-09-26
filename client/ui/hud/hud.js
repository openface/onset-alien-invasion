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

/*
 *
 */
Vue.component('notif', {
    template: '#notif',
    data() {
        return {
            show_blood: false
        }
    },
    mounted() {
        EventBus.$on('ShowBlood', () => {
            this.show_blood = true;

            var that = this;
            setTimeout(function () {
                that.show_blood = false;
            }, 1000);
        })
    }
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
            items: [],
            show_blood: false
        }
    },
    mounted() {
        EventBus.$on('SetInventory', (data) => {
            this.items = data
        })
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

        EmitEvent('ShowBlood');
    }
})();
