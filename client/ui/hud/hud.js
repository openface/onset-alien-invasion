// Hud component
new Vue({
    el: '#hud',
    data() {
        return {
            show_blood: false,
            message: null,
            banner: null,
            boss_health: null,
        }
    },
    methods: {
        ShowBlood: function () {
            this.show_blood = true;

            var that = this;
            setTimeout(function () {
                that.show_blood = false;
            }, 3500);
        },
        ShowMessage: function (message) {
            this.message = message;

            var that = this;
            setTimeout(function () {
                that.message = null;
            }, 5000);
        },
        ShowBanner: function (banner) {
            this.banner = banner;

            var that = this;
            setTimeout(function () {
                that.banner = null;
            }, 5000);
        },
        SetBossHealth: function (percentage) {
            this.boss_health = percentage;
        }
    },
    mounted() {
        EventBus.$on('ShowBlood', this.ShowBlood)
        EventBus.$on('ShowMessage', this.ShowMessage)
        EventBus.$on('ShowBanner', this.ShowBanner)
        EventBus.$on('SetBossHealth', this.SetBossHealth)
    }
});


// dev seeding
(function () {
    if (typeof indev !== 'undefined') {
        EmitEvent('ShowBlood');
        EmitEvent('ShowMessage', 'You have found an important piece! Take this to the satellite!');
        EmitEvent('ShowBanner', 'Welcome to the invasion!');

        EmitEvent('SetBossHealth', 100);
        setTimeout(function () { EmitEvent('SetBossHealth', 80) }, 1000);
        setTimeout(function () { EmitEvent('SetBossHealth', 60) }, 3000);
        setTimeout(function () { EmitEvent('SetBossHealth', 40) }, 5000);
        setTimeout(function () { EmitEvent('SetBossHealth', 20) }, 8000);
        setTimeout(function () { EmitEvent('SetBossHealth', 0) }, 10000);
    }
})();
