Vue.component('build-button', {
    template: '#build-button',
    props: {
        player_resources: { type: Object },
        recipe: { type: Object },
        item: { type: String },
        building_item: { type: String, default: false }
    },
    computed: {
        isBuilding() {
            return this.building_item === this.item;
        },
        isDisabled() {
            return this.building_item !== false;
        },
        numPlayerMetal() {
            return this.player_resources.metal > 0 ? this.player_resources.metal : 0;
        },
        numPlayerPlastic() {
            return this.player_resources.plastic > 0 ? this.player_resources.plastic : 0;
        },
        numPlayerWood() {
            return this.player_resources.wood > 0 ? this.player_resources.wood : 0;
        },
        hasEnoughResources() {
            if (Object.keys(this.player_resources).length == 0) {
                // No resources at all
                return false;
            }
            for (const resource in this.recipe) {
                //console.log(`*** ${resource}: ${this.recipe[resource]}`);
                if (this.player_resources[resource]) {
                    //console.log(`need ${this.recipe[resource]}, have: ${this.player_resources[resource]}`);
                    if (this.player_resources[resource] < this.recipe[resource]) {
                        // Not enough of that resource
                        return false;
                    }
                } else {
                    // No resource
                    return false;
                }
            }
            return true;
        }
    },
    methods: {
        build() {
            EventBus.$emit('building_item', this.item)
            Vue.CallEvent('BuildItem', this.item)
            setTimeout(function (scope) {
                EventBus.$emit('building_item', false)
            }, 15000, this);
        }
    },
    mounted() {
        EventBus.$on('building_item', (item) => {
            this.building_item = item
        })
    },
})
    
new Vue({
    el: '#workbench',
    data() {
        return {
            items: {},
            player_resources: {}
        }
    },
    methods: {
        LoadWorkbenchData: function (data) {
            this.items = data['item_data']
            this.player_resources = data['player_resources']
        },
        SetPlayerResources: function (data) {
            this.player_resources = data
        }
    },
    mounted() {
        EventBus.$on('LoadWorkbenchData', this.LoadWorkbenchData);
        EventBus.$on('SetPlayerResources', this.SetPlayerResources);
    }
});

// dev seeding
(function () {
    if (typeof indev !== 'undefined') {
        EmitEvent('LoadWorkbenchData', {
            "player_resources": {
                metal: 1,
                wood: 2,
                computer_part: 1
            },
            "item_data": {
                armor: {
                    name: "Vest",
                    recipe: {
                        wood: 2,
                        metal: 1
                    },
                    modelid: 843
                },
                foobar: {
                    name: "Foobar",
                    recipe: {
                        plastic: 2
                    },
                    modelid: 843
                },
                food: {
                    name: "Food",
                    recipe: {
                        plastic: 2,
                        wood: 2
                    },
                    modelid: 843
                }
            }
        });
    }
})();