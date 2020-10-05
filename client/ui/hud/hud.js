// Inventory component
Vue.component('inventory', {
    template: '#inventory',
    data() {
        return {
            resource_items: [],
            equipable_items: [],
            usable_items: [],
        }
    },
    computed: {
        AvailableSlots: function () {
            // 1-3 reserved for weapons (10-3=7)
            return 7 - this.usable_items.length;
        }
    },
    methods: {
        SetInventory: function (data) {
            this.resource_items = data.filter(item => item.type == 'resource')
            this.equipable_items = data.filter(item => item.type == 'equipable')
            this.usable_items = data.filter(item => item.type == 'usable')
        }
    },
    mounted() {
        EventBus.$on('SetInventory', this.SetInventory);
    }
})

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
        EmitEvent("SetInventory", [
          {
            name: "metal",
            modelid: 694,
            quantity: 2,
            type: "resource",
          },
          {
            name: "plastic",
            modelid: 627,
            quantity: 1,
            type: "resource",
          },
          {
            name: "vest",
            modelid: 14,
            quantity: 1,
            type: "equipable",
          },
          {
            name: "flashlight",
            modelid: 14,
            quantity: 2,
            type: "equipable",
          },
          {
            name: "beer",
            modelid: 15,
            quantity: 4,
            type: "usable",
          },
        ]);

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
