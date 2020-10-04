// Computer terminal
new Vue({
    el: '#computer',
    data() {
        return {
            screen: null, // garage, satellite
            percentage: null
        }
    },
    methods: {
        SetComputerScreen: function (screen, percentage) {
            this.screen = screen;
            this.percentage = percentage;
        }
    },
    mounted() {
        EventBus.$on('SetComputerScreen', this.SetComputerScreen)
    }
});


// dev seeding
(function () {
    if (typeof indev !== 'undefined') {
//        EmitEvent('SetComputerScreen', 'satellite', 20);
        EmitEvent('SetComputerScreen', 'garage');
    }
})();
