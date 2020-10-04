// banner
function ShowBanner(message) {
    $("#notif").children().hide();

    $('#banner').html(message)
    $('#banner').show().delay(5000).fadeOut('fast');
}

Vue.component('inventory', {
    template: '#inventory',
    data() {
        return {
            items: []
        }
    },
    mounted() {
        EventBus.$on('SetInventory', (data) => {
            this.items = data
        })
    }
})

new Vue({
    el: '#hud',
    data() {
        return {
            show_blood: false,
            message: null
        }
    },
    methods: {
        ShowBlood: function () {
            this.show_blood = true;

            var that = this;
            setTimeout(function () {
                that.show_blood = false;
            }, 1000);
        },
        ShowMessage: function (message) {
            this.message = message;

            var that = this;
            setTimeout(function () {
                that.message = null;
            }, 5000);
        }
    },
    mounted() {
        EventBus.$on('ShowBlood', this.ShowBlood);
        EventBus.$on('ShowMessage', this.ShowMessage)
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
        EmitEvent('ShowMessage', 'You have found it!');


    }
})();
