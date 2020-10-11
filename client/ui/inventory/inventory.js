// Inventory component
new Vue({
    el: '#inventory',
    data() {
        return {
            inventory: [],
            inventory_visible: false,
        }
    },
    computed: {
        FreeInventorySlots: function () {
            return 21 - Object.keys(this.inventory).length;
        },
        FreeHotbarSlots: function () {
            return 10 - Object.keys(this.inventory).length;
        }
    },
    methods: {
        SetInventory: function (data) {
            this.inventory = data
        },
        ShowInventory: function () {
            this.inventory_visible = true
        },
        HideInventory: function () {
            this.inventory_visible = false;
        }
    },
    mounted() {
        EventBus.$on('SetInventory', this.SetInventory)
        EventBus.$on('ShowInventory', this.ShowInventory)
        EventBus.$on('HideInventory', this.HideInventory)
    }
});


// dev seeding
(function () {
    if (typeof indev !== 'undefined') {
        EmitEvent("SetInventory", {
            glock: {
                name: "Glock",
                modelid: 2,
                quantity: 1,
                type: "weapon",
            },
            metal: {
                name: "Metal",
                modelid: 694,
                quantity: 2,
                type: "resource",
            },
            plastic: {
                name: "Plastic",
                modelid: 627,
                quantity: 1,
                type: "resource",
            },
            vest: {
                name: "Kevlar Vest",
                modelid: 14,
                quantity: 1,
                type: "equipable",
            },
            flashlight: {
                name: "Flashlight",
                modelid: 14,
                quantity: 2,
                type: "equipable",
            },
            beer: {
                name: "Beer",
                modelid: 15,
                quantity: 4,
                type: "usable",
            }
        });

        EmitEvent("ShowInventory");
        //setTimeout(function () { EmitEvent("HideInventory", 0); }, 7000);
    }
})();
