Vue.component('build-button', {
    props: {
        scrap_needed: { type: Number },
        item_name: { type: String },
        building_item: { type: String, default: false }
    },
    computed: {
        isBuilding() {
            return this.building_item === this.item_name;
        },
        isDisabled() {
            return this.building_item !== false;
        }
    },
    template: `
        <div v-if="isBuilding">
            <div class="meter"><span><span class="progress"></span></span></div>
        </div>
        <div v-else-if="25 > scrap_needed">
            <button class="build" :disabled="isDisabled" @click="build">BUILD {{item_name}}</button>
        </div>
        <div v-else>
            <button class="need_scrap" disabled="true">NEED {{ scrap_needed }} SCRAP</button>
        </div>
    `,
    methods: {
        build() {
            EventBus.$emit('building_item', this.item_name)
            Vue.CallEvent('BuildItem', this.item_name)
            setTimeout(function (scope) {
                EventBus.$emit('building_item', false)
            }, 15000, this);
        }
    },
    created() {
        EventBus.$on('building_item', (item_name) => {
            this.building_item = item_name
        })
        EventBus.$on('NotEnoughScrap', () => {
            this.building_item = false
        });
    },
})
    
new Vue({
    el: '#workbench',
    props: {
        items: { type: Array, default: [] }
    },
    data() {
        return {
            items: []
        }
    },
    created() {
        EventBus.$on('LoadWorkbenchData', (data) => {
            this.items = data;
        });
    }
});

// dev seeding
(function () {
    if (typeof indev === 'undefined') {
        EmitEvent('LoadWorkbenchData', [
            {
                name: "Foobar",
                scrap_needed: 15,
                modelid: 843
            },
            {
                name: "Foobar2",
                scrap_needed: 5,
                modelid: 843
            }
        ]);
    }
})();