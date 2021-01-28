<template>
    <div id="container">
        <div id="inner">
            <div id="title">{{ storage_name }}</div>

            <draggable
                ghost-class="ghost"
                v-model="storage_items"
                class="draggable storage"
                v-bind="storageDraggableOptions"
                @sort="UpdateStorage(object, type, $event)"
                @start="dragging = true"
                @end="dragging = false"
                draggable=".slot"
                forceFallback="true"
            >
                <transition-group tag="div" class="grid" name="grid">
                    <InventoryItem
                        v-for="item in storage_items"
                        :key="item.name"
                        :item="item"
                        :dragging="dragging"
                        :show_options="false"
                    />
                    <div
                        class="freeslot"
                        v-for="n in FreeStorageSlots"
                        :key="'hw' + n"
                    ></div>
                </transition-group>
            </draggable>
        </div>

        <div id="inner">
            <div id="title">INVENTORY</div>

            <drop-list
              :items="inventory_items"
              class="list"
              @insert="onInsert"
              @reorder="$event.apply(items)"
            >
                <template v-slot:item="{item}">
                    <drag class="item" :key="item">{{item}}</drag>
                </template>

            </drop-list>
        </div>
    </div>
</template>

<script>
import { Drag, DropList } from "vue-easy-dnd";
import InventoryItem from "./InventoryItem.vue";

const MAX_STORAGE_SLOTS = 7;
const MAX_INVENTORY_SLOTS = 14;

export default {
    name: "Storage",
    components: {
        Drag,
        DropList,
        InventoryItem,
    },
    data() {
        return {
            storage_name: null,
            storage_items: [],
            inventory_items: [],
            dragging: false,
            storageDraggableOptions: {
                group: {
                    name: "storage_inventory",
                    put: function(to) {
                        // allow drops if storage has less than 7
                        return (
                            to.el.getElementsByClassName("slot").length <
                            MAX_STORAGE_SLOTS
                        );
                    },
                },
            },
            inventoryDraggableOptions: {
                group: {
                    name: "storage_inventory",
                    put: function(to) {
                        // allow drops if inventory has less than 14
                        return (
                            to.el.getElementsByClassName("slot").length <
                            MAX_INVENTORY_SLOTS
                        );
                    },
                },
            },
        };
    },
    computed: {
        FreeStorageSlots: function() {
            return MAX_STORAGE_SLOTS - this.storage_items.length;
        },
        FreeInventorySlots: function() {
            return MAX_INVENTORY_SLOTS - this.inventory_items.length;
        },
    },
    methods: {
        SetStorageData: function(data) {
            this.storage_name = data.storage_name;
            this.object = data.object;
            this.type = data.type;
            this.storage_items = data.storage_items;
            this.inventory_items = data.inventory_items;
        },
        range: function(start, end) {
            return Array(end - start + 1)
                .fill()
                .map((_, idx) => start + idx);
        },
        UpdateStorage: function(object, type) {
            //window.console.log("object:" + object);

            var data = this.storage_items.map(function(item, index) {
                return {
                    item: item.item,
                    quantity: item.quantity,
                    index: index + 1,
                };
            });

            this.CallEvent("UpdateStorage", object, type, JSON.stringify(data));
        },
        UpdateInventory: function() {
            var data = this.inventory_items.map(function(item, index) {
                return {
                    item: item.item,
                    quantity: item.quantity,
                    index: index + 1,
                };
            });

            this.CallEvent("UpdateInventory", JSON.stringify(data));
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
                        item: "boxhead",
                        name: "Boxhead",
                        modelid: 2,
                        quantity: 1,
                        type: "equipable",
                    },
                ],
                inventory_items: [
                    {
                        item: "metal",
                        name: "Metal",
                        modelid: 694,
                        quantity: 2,
                        type: "resource",
                        equipped: false,
                    },
                    {
                        item: "plastic",
                        name: "Plastic",
                        modelid: 627,
                        quantity: 1,
                        type: "resource",
                        equipped: false,
                    },
                    {
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
    margin-bottom: 5px;
    font-weight: bold;
    font-family: impact;
    text-shadow: 2px 2px rgba(0, 0, 0, 0.4);
    text-transform: uppercase;
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
}
.grid-move {
    transition: transform 0.2s;
}
.no-move {
    transition: transform 0s;
}
.ghost {
    opacity: 1;
}
.draggable {
    padding: 5px;
    min-height: 80px;
    max-height: 165px;
    overflow: hidden;
    width: 97%;
    border: 3px dotted rgba(0, 0, 0, 0.2);
}
.draggable.storage {
    max-height: 75px;
}
.draggable:empty {
    text-align: center;
    height: 85px;
    width: 100%;
    border: 3px dotted rgba(255, 255, 255, 0.1);
    background: rgba(255, 255, 255, 0.1);
}
</style>
