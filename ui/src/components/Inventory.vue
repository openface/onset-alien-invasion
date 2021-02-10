<template>
    <drop class="item-drop-zone" @drop="onDropItem" :accepts-data="CanBeDropped">
        <drop-mask class="container">
            <div id="inner" v-if="inventory_visible">
                <div v-if="HasInventory">
                    <div id="title">INVENTORY</div>
                    <drop-list :items="inventory_items" class="grid" :accepts-data="DropsOnInventory" @drop="onDropInventory" @reorder="onReorderInventory">
                        <template v-slot:item="{ item }">
                            <drag class="slot" :data="item" :type="item.type" :key="item.index">
                                <inventory-item :item="item" />
                            </drag>
                        </template>

                        <template v-slot:feedback="{ data }">
                            <div class="feedback" :key="'feedback_' + data.index"></div>
                        </template>
                    </drop-list>
                    <div class="equipment">
                        <div id="title">EQUIPMENT</div>
                        <div style="float:left;">
                            HEAD<br />
                            <drop class="drop-area" @drop="onEquipHead" :accepts-data="EquipsToHead">
                                <drag v-if="equipped_head" class="slot" :data="equipped_head" :key="equipped_head.index">
                                    <inventory-item :item="equipped_head" />
                                </drag>
                            </drop>
                        </div>
                        <div style="float:left;">
                            BODY<br />
                            <drop class="drop-area" @drop="onEquipBody" :accepts-data="EquipsToBody">
                                <drag v-if="equipped_body" class="slot" :data="equipped_body" :key="equipped_body.index">
                                    <inventory-item :item="equipped_body" />
                                </drag>
                            </drop>
                        </div>
                    </div>
                </div>
                <div v-else id="title">YOUR INVENTORY IS EMPTY</div>
            </div>
            <div id="hotbar">
                <!-- weapon slots -->

                <drop class="drop-area" @drop="onEquipWeapon(1, $event)" :accepts-data="EquippableWeapon">
                    <drag v-if="weapon_1" class="slot" :data="weapon_1" type="weapon" :key="weapon_1.index">
                        <inventory-item :item="weapon_1" :keybind="weapon_1.slot" />
                    </drag>
                </drop>
                <drop class="drop-area" @drop="onEquipWeapon(2, $event)" :accepts-data="EquippableWeapon">
                    <drag v-if="weapon_2" class="slot" :data="weapon_2" type="weapon" :key="weapon_2.index">
                        <inventory-item :item="weapon_2" :keybind="weapon_2.slot" />
                    </drag>
                </drop>
                <drop class="drop-area" @drop="onEquipWeapon(3, $event)" :accepts-data="EquippableWeapon">
                    <drag v-if="weapon_3" class="slot" :data="weapon_3" type="weapon" :key="weapon_3.index">
                        <inventory-item :item="weapon_3" :keybind="weapon_3.slot" />
                    </drag>
                </drop>

                <div class="spacer" />

                <!-- hotbar slots -->

                <drop class="drop-area" @drop="onEquipHotbar(4, $event)" :accepts-data="UsableOnHotbar">
                    <drag v-if="hotbar_4" class="slot" :data="hotbar_4" :type="hotbar_4.type" :key="hotbar_4.index">
                        <inventory-item :item="hotbar_4" :keybind="hotbar_4.slot" />
                    </drag>
                </drop>
                <drop class="drop-area" @drop="onEquipHotbar(5, $event)" :accepts-data="UsableOnHotbar">
                    <drag v-if="hotbar_5" class="slot" :data="hotbar_5" :type="hotbar_5.type" :key="hotbar_5.index">
                        <inventory-item :item="hotbar_5" :keybind="hotbar_5.slot" />
                    </drag>
                </drop>
                <drop class="drop-area" @drop="onEquipHotbar(6, $event)" :accepts-data="UsableOnHotbar">
                    <drag v-if="hotbar_6" class="slot" :data="hotbar_6" :type="hotbar_6.type" :key="hotbar_6.index">
                        <inventory-item :item="hotbar_6" :keybind="hotbar_6.slot" />
                    </drag>
                </drop>
                <drop class="drop-area" @drop="onEquipHotbar(7, $event)" :accepts-data="UsableOnHotbar">
                    <drag v-if="hotbar_7" class="slot" :data="hotbar_7" :type="hotbar_7.type" :key="hotbar_7.index">
                        <inventory-item :item="hotbar_7" :keybind="hotbar_7.slot" />
                    </drag>
                </drop>
                <drop class="drop-area" @drop="onEquipHotbar(8, $event)" :accepts-data="UsableOnHotbar">
                    <drag v-if="hotbar_8" class="slot" :data="hotbar_8" :type="hotbar_8.type" :key="hotbar_8.index">
                        <inventory-item :item="hotbar_8" :keybind="hotbar_8.slot" />
                    </drag>
                </drop>
                <drop class="drop-area" @drop="onEquipHotbar(9, $event)" :accepts-data="UsableOnHotbar">
                    <drag v-if="hotbar_9" class="slot" :data="hotbar_9" :type="hotbar_9.type" :key="hotbar_9.index">
                        <inventory-item :item="hotbar_9" :keybind="hotbar_9.slot" />
                    </drag>
                </drop>
            </div>
        </drop-mask>
    </drop>
</template>

<script>
import { Drag, Drop, DropList, DropMask } from "vue-easy-dnd";
import InventoryItem from "./InventoryItem.vue";

export default {
    name: "Inventory",
    components: {
        InventoryItem,
        Drag,
        Drop,
        DropList,
        DropMask,
    },
    data: function() {
        return {
            inventory_items: [],
            inventory_visible: false,
        };
    },
    computed: {
        HasInventory: function() {
            return this.inventory_items.length > 0;
        },
        equipped_head: function() {
            return this.inventory_items.find((item) => item.equipped && item.bone == "head");
        },
        equipped_body: function() {
            return this.inventory_items.find((item) => item.equipped && item.bone == "spine_02");
        },
        weapon_1: function() {
            return this.inventory_items.find((item) => item.type == "weapon" && item.slot == 1);
        },
        weapon_2: function() {
            return this.inventory_items.find((item) => item.type == "weapon" && item.slot == 2);
        },
        weapon_3: function() {
            return this.inventory_items.find((item) => item.type == "weapon" && item.slot == 3);
        },
        hotbar_4: function() {
            return this.inventory_items.find((item) => item.slot == 4);
        },
        hotbar_5: function() {
            return this.inventory_items.find((item) => item.slot == 5);
        },
        hotbar_6: function() {
            return this.inventory_items.find((item) => item.slot == 6);
        },
        hotbar_7: function() {
            return this.inventory_items.find((item) => item.slot == 7);
        },
        hotbar_8: function() {
            return this.inventory_items.find((item) => item.slot == 8);
        },
        hotbar_9: function() {
            return this.inventory_items.find((item) => item.slot == 9);
        },
    },
    methods: {
        SetInventory: function(data) {
            this.inventory_items = data.inventory_items;
        },
        ShowInventory: function() {
            this.inventory_visible = true;
        },
        HideInventory: function() {
            this.inventory_visible = false;
        },
        EquipsToHead: function(item) {
            return item.bone == "head";
        },
        EquipsToBody: function(item) {
            return item.bone == "spine_02";
        },
        DropsOnInventory: function() {
            return true;
        },
        UsableOnHotbar: function(item) {
            return !this.EquipsToBody(item) && !this.EquipsToHead(item) && (item.type == "equipable" || item.type == "usable");
        },
        EquippableWeapon: function(item) {
            return item.type == 'weapon';
        },
        CanBeDropped: function() {
            return true;
        },
        onReorderInventory: function(e) {
            window.console.log("Reorder inventory");
            e.apply(this.inventory_items);
        },
        onDropItem: function(e) {
            window.console.log("Drop item");
            window.console.log(e);

            let idx = this.inventory_items.findIndex((item) => item.index == e.data.index);
            if (idx > -1) {
                this.inventory_items.splice(idx, 1);
            }
        },
        onEquipHead: function(e) {
            window.console.log("Equip item to head");
            window.console.log(e);

            let idx = this.inventory_items.findIndex((item) => item.index == e.data.index);
            if (idx > -1) {
                this.inventory_items[idx].equipped = true;
            }
        },
        onEquipBody: function(e) {
            window.console.log("Equip item to body");
            window.console.log(e);

            let idx = this.inventory_items.findIndex((item) => item.index == e.data.index);
            if (idx > -1) {
                this.inventory_items[idx].equipped = true;
            }
        },
        onEquipWeapon: function(slot, e) {
            window.console.log("Equip item to weapon slot " + slot);
            window.console.log(e);

            this.clearInventorySlot(slot);

            let idx = this.inventory_items.findIndex((item) => item.index == e.data.index);
            this.inventory_items[idx].slot = slot;
        },
        onEquipHotbar: function(slot, e) {
            window.console.log("Equip item to hotbar slot " + slot);
            window.console.log(e);

            this.clearInventorySlot(slot);

            let idx = this.inventory_items.findIndex((item) => item.index == e.data.index);
            this.inventory_items[idx].slot = slot;
        },
        clearInventorySlot: function(slot) {
            let idx = this.inventory_items.findIndex((item) => item.slot == slot);
            if (idx > -1) {
                this.inventory_items[idx].slot = null;
            }
        },
        onDropInventory: function(e) {
            window.console.log("Drop item back to inventory")
            window.console.log(e)

            let idx = this.inventory_items.findIndex((item) => item.index == e.data.index);
            this.inventory_items[idx].equipped = false;
            this.inventory_items[idx].slot = null;
        }
    },
    mounted() {
        this.EventBus.$on("SetInventory", this.SetInventory);
        this.EventBus.$on("ShowInventory", this.ShowInventory);
        this.EventBus.$on("HideInventory", this.HideInventory);

        if (!this.InGame) {
            this.EventBus.$emit("SetInventory", {
                inventory_items: [
                    {
                        index: 2,
                        item: "glock",
                        name: "Glock",
                        modelid: 2,
                        quantity: 1,
                        type: "weapon",
                        slot: 1,
                    },
                    {
                        index: 3,
                        item: "rifle",
                        name: "Rifle",
                        modelid: 2,
                        quantity: 1,
                        type: "weapon",
                        slot: null,
                    },
                    {
                        index: 5,
                        item: "metal",
                        name: "Metal",
                        modelid: 694,
                        quantity: 2,
                        type: "resource",
                        slot: null,
                    },
                    {
                        index: 6,
                        item: "plastic",
                        name: "Plastic",
                        modelid: 627,
                        quantity: 1,
                        type: "resource",
                        slot: null,
                    },
                    {
                        index: 7,
                        item: "vest",
                        name: "Kevlar Vest",
                        modelid: 14,
                        quantity: 1,
                        type: "equipable",
                        bone: "spine_02",
                        equipped: false,
                        slot: null,
                    },
                    {
                        index: 18,
                        item: "armyhat",
                        name: "Army Hat",
                        modelid: 15,
                        quantity: 1,
                        type: "equipable",
                        bone: "head",
                        equipped: false,
                        slot: null,
                    },
                    {
                        index: 9,
                        item: "flashlight",
                        name: "Flashlight",
                        modelid: 14,
                        quantity: 2,
                        type: "equipable",
                        equipped: false,
                        slot: 6,
                    },
                    {
                        index: 8,
                        item: "beer",
                        name: "Beer",
                        modelid: 15,
                        quantity: 4,
                        type: "usable",
                        use_label: "Drink",
                        slot: null,
                    },
                    {
                        index: 10,
                        item: "wooden_chair",
                        name: "Wooden Chair",
                        modelid: 15,
                        quantity: 4,
                        type: "prop",
                        slot: null,
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
.item-drop-zone {
    margin:0;
    width: 100%;
    height: 100%;
}
.container {
    margin:0 auto;
    border:1px solid red;
    width:1000px;
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
.grid-move {
    transition: transform 0.2s;
}
#hotbar {
    display: flex;
    flex-direction: row;
    justify-content: center;
    align-content: flex-start;
    align-items: flex-start;
    width: 800px;
    position: fixed;
    bottom: 1vh;
}
.spacer {
    width: 20px;
}
.equipment {
    margin-top: 10px;
}
.drop-area {
    width: 75px;
    height: 75px;
    float: left;
    border: 1px solid rgba(0, 0, 0, 0.4);
    padding: 5px;
}
.container .drop-allowed {
    background-color: rgba(0, 255, 0, 0.2);
}
.container .drop-forbidden {
    background-color: rgba(255, 0, 0, 0.2);
}
.container .drop-in {
    box-shadow: 0 0 5px rgba(0, 0, 255, 0.4);
}
</style>
