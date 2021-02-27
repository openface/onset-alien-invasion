<template>
    <div id="container">
        <div class="section">
            <div id="title">{{ storage_name }}</div>
            <div class="storage_items">
                <drop class="square" v-for="slot in MAX_STORAGE_SLOTS" :key="slot" mode="cut" @drop="onDropToStorageSlot(slot, $event)" :accepts-data="CanDropToStorage">
                    <drag v-if="getItemByStorageSlot(slot)" @cut="onCutStorage" :data="getItemByStorageSlot(slot)" :key="getItemByStorageSlot(slot).uuid">
                        <inventory-item :item="getItemByStorageSlot(slot)" />
                    </drag>
                </drop>
            </div>
        </div>
        <div class="spacer" />
        <div class="section">
            <div id="title">INVENTORY</div>
            <div class="inventory_items">
                <drop class="square" v-for="slot in MAX_INVENTORY_SLOTS" :key="slot" mode="cut" @drop="onDropToInventorySlot(slot, $event)" :accepts-data="CanDropToInventory">
                    <drag v-if="getItemByInventorySlot(slot)" @cut="onCutInventory" :data="getItemByInventorySlot(slot)" :key="getItemByInventorySlot(slot).uuid">
                        <inventory-item :item="getItemByInventorySlot(slot)" />
                    </drag>
                </drop>
            </div>
        </div>
    </div>
</template>

<script>
import { Drag, Drop } from "vue-easy-dnd";
import InventoryItem from "./InventoryItem.vue";

export default {
    name: "Storage",
    components: {
        InventoryItem,
        Drag,
        Drop,
    },
    created() {
        this.MAX_STORAGE_SLOTS = 7;
        this.MAX_INVENTORY_SLOTS = 14;
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
        // storage
        CanDropToStorage: function(data) {
            if (this.inventory_items.findIndex((item) => item.uuid == data.uuid) > -1) {
                return true;
            } else {
                return false;
            }
            // todo: check storage limits
        },
        SetStorageData: function(data) {
            this.storage_name = data.storage_name;
            this.object = data.object;
            this.type = data.type;
            this.storage_items = data.storage_items;
            this.inventory_items = data.inventory_items;
        },
        SaveStorageData: function() {
            const data = this.storage_items.map(function(item, index) {
                return {
                    item: item.item,
                    uuid: item.uuid,
                    quantity: item.quantity,
                    used: item.used,
                    index: index + 1,
                    slot: item.slot,
                };
            });
            this.CallEvent("UpdateStorage", this.object, this.type, JSON.stringify(data));
        },
        onCutStorage: function(e) {
            window.console.log("onCutStorage:", e.data);

            this.storage_items.splice(this.storage_items.indexOf(e.data), 1);
            this.SaveStorageData();
        },
        onDropToStorageSlot: function(slot, e) {
            window.console.log("onDropToStorageSlot", e);
            this.storage_items.splice(e.index, 0, e.data);

            let idx = this.storage_items.indexOf(e.data);
            if (idx == -1) return;

            this.storage_items[idx].slot = slot;
            this.SaveStorageData();
        },
        getItemByStorageSlot: function(slot) {
            return this.storage_items.find((item) => item.slot == slot);
        },
        // inventory
        CanDropToInventory: function(data) {
            if (this.storage_items.findIndex((item) => item.uuid == data.uuid) > -1) {
                return true;
            } else {
                return false;
            }
            // todo: check inventory limits
        },
        SaveInventoryData: function() {
            const data = this.inventory_items.map(function(item, index) {
                return {
                    item: item.item,
                    uuid: item.uuid,
                    quantity: item.quantity,
                    used: item.used,
                    index: index + 1,
                    slot: item.slot,
                };
            });

            this.CallEvent("UpdateInventory", JSON.stringify(data));
        },
        onCutInventory: function(e) {
            window.console.log("onCutInventory:", e.data);
            this.inventory_items.splice(this.inventory_items.indexOf(e.data), 1);

            this.SaveInventoryData();
        },
        onDropToInventorySlot: function(slot, e) {
            window.console.log("onDropToInventorySlot", e);
            this.inventory_items.splice(e.index, 0, e.data);

            let idx = this.inventory_items.indexOf(e.data);
            if (idx == -1) return;

            this.inventory_items[idx].slot = slot;
            this.SaveInventoryData();
        },
        getItemByInventorySlot: function(slot) {
            return this.inventory_items.find((item) => item.slot == slot);
        },
    },
    mounted() {
        this.EventBus.$on("SetStorageData", this.SetStorageData);

        if (!this.InGame) {
            this.EventBus.$emit("SetStorageData", {
                object: 666,
                storage_type: "object",
                storage_name: "Crate",
                storage_items: [
                ],
                inventory_items: [
                    {
                        index: 1,
                        item: "metal",
                        uuid: "bdf427f4-76a7-431c-916b-7e96252d0c6f",
                        name: "Metal",
                        modelid: 694,
                        quantity: 2,
                        used: 0,
                        type: "resource",
                        slot: 3,
                    },
                    {
                        index: 2,
                        item: "plastic",
                        uuid: "a538d5da-3444-4b97-b1ff-eb9594cdd706",
                        name: "Plastic",
                        modelid: 627,
                        quantity: 1,
                        used: 0,
                        type: "resource",
                        slot: 4,
                    },
                    {
                        index: 3,
                        item: "flashlight",
                        uuid: "9c055cdf-ef2e-4b55-b4ca-036b13cafe36",
                        name: "Flashlight",
                        modelid: 627,
                        quantity: 1,
                        used: 0,
                        type: "equipable",
                        slot: 9,
                    },
                ],
            });
        }
    },
};
</script>

<style scoped>
#container {
    margin: 0 auto;
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
    background: rgba(0, 0, 0, 0.6);
    font-family: helvetica;
    font-size: 16px;
    color: #ccc;
    text-shadow: 3px black;
    padding:10px;
}
.spacer {
    height:50px;
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
    margin-bottom: 10px;
    text-transform: uppercase;
}
.inventory_items {
    display: grid;
    grid-auto-flow: dense;
    grid-column-gap: 1px;
    grid-row-gap: 1px;
    grid-template-columns: repeat(7, 90px);
}
.storage_items {
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
    padding:5px;
}
.drop-allowed {
    background-color: rgba(0, 255, 0, 0.2);
}
</style>
