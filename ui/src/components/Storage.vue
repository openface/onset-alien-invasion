<template>
    <div id="container">
        <div id="inner">
            <div id="title">{{ storage_name }}</div>

            <drop-list
                :items="storage_items"
                class="storage_items"
                :accepts-data="CanDropToStorage"
                @drop="onDropToStorage"
                @reorder="onReorderStorage"
            >
                <template v-slot:item="{ item }">
                    <drag class="square" :data="item" :key="item.index">
                        <inventory-item :item="item" />
                    </drag>
                </template>

                <template v-slot:feedback="{ data }">
                    <div class="feedback" :key="'feedback_' + data.index"></div>
                </template>
            </drop-list>
        </div>

        <div id="inner">
            <div id="title">INVENTORY</div>

            <drop-list
                :items="inventory_items"
                class="inventory_items"
                :accepts-data="CanDropToInventory"
                @drop="onDropToInventory"
            >
                <template v-slot:item="{ item }">
                    <drag class="square" :data="item" :key="item.index">
                        <inventory-item :item="item" />
                    </drag>
                </template>

                <template v-slot:feedback="{ data }">
                    <div class="feedback" :key="'feedback_' + data.index"></div>
                </template>
            </drop-list>
        </div>
    </div>
</template>

<script>
import { Drag, DropList } from "vue-easy-dnd";
import InventoryItem from "./InventoryItem.vue";

// TODO
//const MAX_STORAGE_SLOTS = 7;
//const MAX_INVENTORY_SLOTS = 14;

export default {
    name: "Storage",
    components: {
        InventoryItem,
        Drag,
        DropList,
    },
    data() {
        return {
            storage_name: null,
            storage_items: [],
            inventory_items: [],
        };
    },
    computed: {
    },
    methods: {
        CanDropToStorage: function() {
            return true;
        },
        CanDropToInventory: function() {
            return true;
        },
        SetStorageData: function(data) {
            this.storage_name = data.storage_name;
            this.object = data.object;
            this.type = data.type;
            this.storage_items = data.storage_items;
            this.inventory_items = data.inventory_items;
        },
        onDropToStorage: function(e) {
            window.console.log("Drop item to storage", e.data);

            let idx = this.storage_items.findIndex((item) => item.index == e.data.index);
            if (idx > -1) {
                this.storage_items[idx].equipped = false;
//                this.CallEvent("UnequipItem", this.storage_items[idx].item);
            }
        },
        onDropToInventory: function(e) {
            window.console.log("Drop item to inventory", e.data);

            let idx = this.inventory_items.findIndex((item) => item.index == e.data.index);
            if (idx > -1) {
                this.inventory_items[idx].equipped = false;
//                this.CallEvent("UnequipItem", this.inventory_items[idx].item);
            }
        },
        onReorderStorage: function(e) {
            window.console.log("onReorderStorage:", e);
            e.apply(this.storage_items);
/*             var data = this.storage_items.map(function(item, index) {
                return {
                    item: item.item,
                    quantity: item.quantity,
                    index: index + 1,
                };
            });

            this.CallEvent("UpdateStorage", object, type, JSON.stringify(data)); */
        },
    },
    mounted() {
        this.EventBus.$on("SetStorageData", this.SetStorageData);

        if (!this.InGame) {
            this.EventBus.$emit("SetStorageData", {
                object: 666,
                type: "object",
                storage_name: "Crate",
                storage_items: [
                    {
                        index: 1,
                        item: "lighter",
                        name: "Lighter",
                        modelid: 2,
                        quantity: 1,
                        type: "usable",
                    },
                    {
                        index: 2,
                        item: "boxhead",
                        name: "Boxhead",
                        modelid: 2,
                        quantity: 1,
                        type: "equipable",
                    },
                ],
                inventory_items: [
                    {
                        index: 1,
                        item: "metal",
                        name: "Metal",
                        modelid: 694,
                        quantity: 2,
                        type: "resource",
                        equipped: false,
                    },
                    {
                        index: 2,
                        item: "plastic",
                        name: "Plastic",
                        modelid: 627,
                        quantity: 1,
                        type: "resource",
                        equipped: false,
                    },
                    {
                        index: 3,
                        item: "flashlight",
                        name: "Flashlight",
                        modelid: 627,
                        quantity: 1,
                        type: "equipable",
                        equipped: true,
                    },
                ],
            });
        }
    },
};
</script>

<style scoped>
#container {
    display: flex;
    flex-direction: column;
    flex-wrap: wrap;
    align-content: space-around;
    align-items: flex-start;
    justify-content: center;
    height: 100vh;
}
#inner {
    order: 0;
    flex: 0 1 auto;
    align-self: auto;
    width: 610px;
    z-index: 1000;
    background: rgba(0, 0, 0, 0.6);
    font-family: helvetica;
    font-size: 16px;
    color: #ccc;
    text-shadow: 3px black;
    padding: 10px;
    margin-bottom: 25px;
}

#title {
    color: #fff;
    font-size: 36px;
    text-align: center;
    margin: 0;
    font-weight: bold;
    font-family: impact;
    background: rgba(0, 0, 0, 0.1);
    text-shadow: 2px 2px rgba(0, 0, 0, 0.4);
    margin-bottom:10px;
}
.inventory_items, .storage_items {
    display: grid;
    grid-auto-flow: dense;
    grid-column-gap: 1px;
    grid-row-gap: 1px;
    grid-template-columns: repeat(7, 90px);
}
.square {
    background: rgba(255, 255, 255, 0.1);
    width: 80px;
    height: 80px;
    border: 1px solid rgba(0, 0, 0, 0.4);
    padding: 5px;
}
</style>
