<template>
    <div id="container">
        <div id="inner" v-if="inventory_visible">
            <div v-if="HasInventory">
                <div id="title">INVENTORY</div>
                <draggable
                    ghost-class="ghost"
                    v-model="inventory_items"
                    @sort="UpdateInventory"
                    @start="dragging = true"
                    @end="dragging = false"
                    draggable=".slot"
                    forceFallback="true"
                >
                    <transition-group tag="div" class="grid" name="grid">
                        <InventoryItem
                            v-for="item in inventory_items"
                            :index="item.index"
                            :key="item.index"
                            :item="item"
                            :dragging="dragging"
                            :show_options="true"
                        />
                        <div
                            class="freeslot"
                            v-for="n in FreeInventorySlots"
                            :key="'hw' + n"
                        ></div>
                    </transition-group>
                </draggable>

                <div id="weapons" v-if="HasWeapons">
                    <div class="subtitle">WEAPONS</div>
                    <div class="grid">
                        <InventoryItem
                            v-for="weapon in weapons"
                            :index="weapon.slot"
                            :key="weapon.slot"
                            :item="weapon"
                            :show_options="true"
                        />
                    </div>
                </div>
            </div>
            <div v-else id="title">YOUR INVENTORY IS EMPTY</div>
        </div>
        <div id="hotbar" v-if="!inventory_visible || !InGame">
            <div class="grid">
                <!-- weapons 2,3 -->
                <InventoryItem
                    v-for="weapon in weapons"
                    :index="weapon.slot"
                    :key="weapon.slot"
                    :item="weapon"
                    :keybind="weapon.slot"
                    :show_options="false"
                />
                <div
                    class="freeslot"
                    v-for="n in FreeWeaponSlots"
                    :key="'hw' + n"
                ></div>

                <!-- usable_items 4,5,6,7,8,9 -->
                <InventoryItem
                    v-for="(item, i) in usable_items"
                    :index="item.index"
                    :key="item.index"
                    :item="item"
                    :keybind="i + 4"
                    :show_options="false"
                />
                <div
                    class="freeslot"
                    v-for="n in FreeUsableSlots"
                    :key="'hi' + n"
                ></div>
            </div>
        </div>
    </div>
</template>

<script>
import draggable from "vuedraggable";
import InventoryItem from "./InventoryItem.vue";

export default {
    name: "Inventory",
    components: {
        draggable,
        InventoryItem,
    },
    data() {
        return {
            weapons: [],
            inventory_items: [],
            usable_items: [],
            inventory_visible: false,
            dragging: false,
        };
    },
    computed: {
        HasInventory: function() {
            return this.inventory_items.length > 0 || this.weapons.length > 0;
        },
        HasWeapons: function() {
            return this.weapons.length > 0;
        },
        FreeInventorySlots: function() {
            return 14 - this.inventory_items.length;
        },
        FreeWeaponSlots: function() {
            return 2 - this.weapons.length;
        },
        FreeUsableSlots: function() {
            return 6 - this.usable_items.length;
        },
    },
    methods: {
        SetInventory: function(data) {
            this.weapons = data.weapons;
            this.inventory_items = data.items;
            this.usable_items = data.items.filter(
                (item) => item.type == "usable" || item.type == "equipable"
            );
        },
        ShowInventory: function() {
            this.inventory_visible = true;
        },
        HideInventory: function() {
            this.inventory_visible = false;
        },
        UpdateInventory: function(e) {
            window.console.log(e);

            var data = this.inventory_items.map(function(item, index) {
                return {
                    item: item.item,
                    quantity: item.quantity,
                    index: index + 1,
                };
            });

            this.CallEvent("UpdateInventory", JSON.stringify(data));
        },
        log: function(evt) {
            window.console.log(evt);
        },
    },
    mounted() {
        this.EventBus.$on("SetInventory", this.SetInventory);
        this.EventBus.$on("ShowInventory", this.ShowInventory);
        this.EventBus.$on("HideInventory", this.HideInventory);

        if (!this.InGame) {
            this.EventBus.$emit("SetInventory", {
                weapons: [
                    {
                        item: "glock",
                        name: "Glock",
                        modelid: 2,
                        quantity: 1,
                        type: "weapon",
                        slot: 2,
                    },
                    {
                        item: "rifle",
                        name: "Rifle",
                        modelid: 2,
                        quantity: 1,
                        type: "weapon",
                        slot: 3,
                    },
                ],
                items: [
                    {
                        index: 5,
                        item: "metal",
                        name: "Metal",
                        modelid: 694,
                        quantity: 2,
                        type: "resource",
                        equipped: false,
                    },
                    {
                        index: 6,
                        item: "plastic",
                        name: "Plastic",
                        modelid: 627,
                        quantity: 1,
                        type: "resource",
                        equipped: false,
                    },
                    {
                        index: 7,
                        item: "vest",
                        name: "Kevlar Vest",
                        modelid: 14,
                        quantity: 1,
                        type: "equipable",
                        equipped: true,
                    },
                    {
                        index: 9,
                        item: "flashlight",
                        name: "Flashlight",
                        modelid: 14,
                        quantity: 2,
                        type: "equipable",
                        equipped: true,
                    },
                    {
                        index: 8,
                        item: "beer",
                        name: "Beer",
                        modelid: 15,
                        quantity: 4,
                        type: "usable",
                        equipped: false,
                        use_label: "Drink"
                    },
                    {
                        index: 10,
                        item: "wooden_chair",
                        name: "Wooden Chair",
                        modelid: 15,
                        quantity: 4,
                        type: "prop",
                        equipped: false,
                    },
                ],
            });

            this.EventBus.$emit("ShowInventory");
            //this.EventBus.$emit("HideInventory");
        }
    },
};
</script>

<style scoped>
#container {
    display: flex;
    align-items: center;
    justify-content: center;
    height: 100vh;
}

#inner {
    width: 610px;
    z-index: 1000;
    background: rgba(0, 0, 0, 0.6);
    font-family: helvetica;
    font-size: 16px;
    color: #ccc;
    text-shadow: 3px black;
    padding: 10px;
}

#title {
    color: #fff;
    font-size: 36px;
    text-align: center;
    margin: 0;
    font-weight: bold;
    font-family: impact;
    text-shadow: 2px 2px rgba(0, 0, 0, 0.4);
}
.subtitle {
    color: #fff;
    font-size: 20px;
    text-align: center;
    margin: 0;
    font-weight: bold;
    font-family: impact;
    text-shadow: 2px 2px rgba(0, 0, 0, 0.4);
    background: rgba(255, 255, 255, 0.1);
}
.grid {
    display: grid;
    grid-template-columns: repeat(7, 77px);
    grid-template-rows: repeat(2, 77px);
    grid-gap: 0.7em;
    grid-auto-flow: row;
}
#hotbar .grid {
    grid-template-columns: repeat(8, 77px);
    grid-template-rows: repeat(1, 77px);
}
#weapons .grid {
    grid-template-columns: repeat(3, 77px);
    grid-template-rows: repeat(1, 77px);
    margin-top: 5px;
}
#weapons {
    margin: 10px 0;
}
.grid-move {
    transition: transform 0.2s;
}
.ghost {
    opacity: 1;
}
.draggable {
    padding: 5px;
    width: 97%;
    border: 3px dotted rgba(0, 0, 0, 0.2);
}
.draggable:empty {
    text-align: center;
    height: 85px;
    width: 100%;
    border: 3px dotted rgba(255, 255, 255, 0.1);
    background: rgba(255, 255, 255, 0.1);
}
#hotbar {
    display: flex;
    flex-direction: row;
    justify-content: center;
    align-content: flex-start;
    align-items: flex-start;
    width: 100%;
    position: fixed;
    bottom: 1vh;
}
</style>
