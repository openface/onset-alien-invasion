Vue.component('build-button', {
    template: '#build-button',
    props: {
        player_scrap: { type: Number },
        scrap_needed: { type: Number },
        item: { type: String },
        building_item: { type: String, default: false }
    },
    computed: {
        isBuilding() {
            return this.building_item === this.item;
        },
        isDisabled() {
            return this.building_item !== false;
        }
    },
    methods: {
        build() {
            EventBus.$emit('building_item', this.item)
            setTimeout(function (scope) {
                EventBus.$emit('building_item', false)
                Vue.CallEvent('BuildItem', scope.item)
            }, 15000, this);
        }
    },
    created() {
        EventBus.$on('building_item', (item) => {
            this.building_item = item
        })
    },
})
    
new Vue({
    el: '#workbench',
    data() {
        return {
            items: [],
            player_scrap: 0
        }
    },
    methods: {
        LoadWorkbenchData: function (data) {
            this.items = data['item_data']
            this.player_scrap = data['player_scrap']
        },
        SetPlayerScrap: function (player_scrap) {
            this.player_scrap = player_scrap
        }
    },
    mounted() {
        EventBus.$on('LoadWorkbenchData', this.LoadWorkbenchData);
        EventBus.$on('SetPlayerScrap', this.SetPlayerScrap);
    }
});

// dev seeding
(function () {
    if (typeof indev !== 'undefined') {
        EmitEvent('LoadWorkbenchData', {
            "player_scrap": 15,
            "item_data": {
                armor: {
                    name: "Vest",
                    scrap_needed: 25,
                    modelid: 843
                },
                foobar: {
                    name: "Foobar",
                    scrap_needed: 15,
                    modelid: 843
                },
                food: {
                    name: "Food",
                    scrap_needed: 15,
                    modelid: 843
                }
            }
        });
    }
})();