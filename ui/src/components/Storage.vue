<template>
    <div id="container">
        <div class="section">
            <div id="title">{{ storage_name }}</div>

            <drop-list
                :items="storage_items"
                class="storage_items"
                :accepts-data="CanDropToStorage"
                @insert="onInsertToStorage"
                @reorder="onReorderStorage"
            >
                <template v-slot:item="{ item }">
                    <drag class="square" :data="item" :key="item.index">
                        <inventory-item :item="item" />
                    </drag>
                </template>

                <template v-slot:feedback="{ data }">
                    <div class="square" :key="'s_' + data.index">
                        <inventory-item :item="data" />
                    </div>
                </template>
            </drop-list>
        </div>

        <div class="section">
            <div id="title">INVENTORY</div>

            <drop-list
                :items="inventory_items"
                class="inventory_items"
                :accepts-data="CanDropToInventory"
                @reorder="onReorderInventory"
                @insert="onInsertToInventory"
            >
                <template v-slot:item="{ item }">
                    <drag class="square" :data="item" :key="item.index">
                        <inventory-item :item="item" />
                    </drag>
                </template>

                <template v-slot:feedback="{ data }">
                    <div class="square" :key="'i_' + data.index">
                        <inventory-item :item="data" />
                    </div>
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
            object: null,
            type: null,
            storage_items: [],
            inventory_items: [],
        };
    },
    methods: {
        CanDropToStorage: function(data) {
            if (this.inventory_items.findIndex((item) => item.index == data.index) > -1) {
                return true;
            } else {
                return false;
            }
        },
        CanDropToInventory: function(data) {
            if (this.storage_items.findIndex((item) => item.index == data.index) > -1) {
                return true;
            } else {
                return false;
            }
        },
        SetStorageData: function(data) {
            this.storage_name = data.storage_name;
            this.object = data.object;
            this.type = data.type;
            this.storage_items = data.storage_items;
            this.inventory_items = data.inventory_items;
        },
        onInsertToStorage: function(e) {
            window.console.log("Move inventory item to storage", e.data);
            this.CallEvent("MoveInventoryItemToStorage", this.object, this.type, e.data.item);
        },
        onInsertToInventory: function(e) {
            window.console.log("Move storage item to inventory", e.data);
            this.CallEvent("MoveStorageItemToInventory", this.object, this.type, e.data.item);
        },
        onReorderStorage: function(e) {
            window.console.log("onReorderStorage:", e);
            e.apply(this.storage_items);

            this.CallEvent("UpdateStorage", this.object, this.type, JSON.stringify(this.storage_items));
        },
        onReorderInventory: function(e) {
            window.console.log("Reorder inventory");
            e.apply(this.inventory_items);

            this.CallEvent("UpdateInventory", JSON.stringify(this.inventory_items));
        }
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
.section {
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
    min-height:146px;
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
    text-transform:uppercase;
}
.inventory_items, .storage_items {
    display: grid;
    grid-auto-flow: dense;
    grid-column-gap: 1px;
    grid-row-gap: 1px;
    grid-template-columns: repeat(7, 90px);
    height: 100%;
}
.square {
    background: rgba(255, 255, 255, 0.1);
    width: 80px;
    height: 80px;
    border: 1px solid rgba(0, 0, 0, 0.4);
    padding: 5px;
}
</style>
