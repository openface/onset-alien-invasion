<template>
    <drop class="item-drop-zone" @drop="onDropFromInventory" :accepts-data="CanDropFromInventory">
        <drop-mask class="container">
            <div id="inner" v-if="inventory_visible">
                <div v-if="HasInventory">
                    <div class="inventory-area">
                        <div id="title">INVENTORY</div>

                        <drop-list
                            :items="inventory_items"
                            class="inventory_items"
                            :accepts-data="CanDropToInventory"
                            @drop="onDropToInventory"
                            @reorder="onReorderInventory"
                        >
                            <template v-slot:item="{ item }">
                                <drag class="square" :data="item" :key="item.uuid">
                                    <inventory-item :item="item" />
                                </drag>
                            </template>

                            <template v-slot:feedback="{ data }">
                                <div class="feedback" :key="'feedback_' + data.uuid"></div>
                            </template>
                        </drop-list>
                    </div>
                    <div class="equipment-area">
                        <div id="title">EQUIPMENT</div>

                        <div class="equipped-slots">
                            <div>
                                HANDS<br />
                                <drop class="square" @drop="onEquipHands" :accepts-data="CanEquipToHands">
                                    <drag v-if="equipped_hands" :data="equipped_hands" :key="equipped_hands.uuid">
                                        <inventory-item :item="equipped_hands" />
                                    </drag>
                                </drop>
                            </div>
                            <div>
                                HEAD<br />
                                <drop class="square" @drop="onEquipHead" :accepts-data="CanEquipToHead">
                                    <drag v-if="equipped_head" :data="equipped_head" :key="equipped_head.uuid">
                                        <inventory-item :item="equipped_head" />
                                    </drag>
                                </drop>
                            </div>
                            <div>
                                BODY<br />
                                <drop class="square" @drop="onEquipBody" :accepts-data="CanEquipToBody">
                                    <drag v-if="equipped_body" :data="equipped_body" :key="equipped_body.uuid">
                                        <inventory-item :item="equipped_body" />
                                    </drag>
                                </drop>
                            </div>
                        </div>
                    </div>
                </div>
                <div v-else id="title">YOUR INVENTORY IS EMPTY</div>
            </div>
            <div id="hotbar" v-if="inventory_visible">
                <!-- weapon slots -->

                <drop class="square" @drop="onEquipWeapon(1, $event)" :accepts-data="CanEquipToWeaponSlot">
                    <drag v-if="weapon_1" :data="weapon_1" :key="weapon_1.uuid">
                        <inventory-item :item="weapon_1" :keybind="weapon_1.slot" />
                    </drag>
                </drop>
                <drop class="square" @drop="onEquipWeapon(2, $event)" :accepts-data="CanEquipToWeaponSlot">
                    <drag v-if="weapon_2" :data="weapon_2" :key="weapon_2.uuid">
                        <inventory-item :item="weapon_2" :keybind="weapon_2.slot" />
                    </drag>
                </drop>
                <drop class="square" @drop="onEquipWeapon(3, $event)" :accepts-data="CanEquipToWeaponSlot">
                    <drag v-if="weapon_3" :data="weapon_3" :key="weapon_3.uuid">
                        <inventory-item :item="weapon_3" :keybind="weapon_3.slot" />
                    </drag>
                </drop>

                <div class="spacer" />

                <!-- hotbar slots -->

                <drop class="square" @drop="onEquipHotbar(4, $event)" :accepts-data="CanEquipToHotbarSlot">
                    <drag v-if="hotbar_4" :data="hotbar_4" :key="hotbar_4.uuid">
                        <inventory-item :item="hotbar_4" :keybind="hotbar_4.slot" />
                    </drag>
                </drop>
                <drop class="square" @drop="onEquipHotbar(5, $event)" :accepts-data="CanEquipToHotbarSlot">
                    <drag v-if="hotbar_5" :data="hotbar_5" :key="hotbar_5.uuid">
                        <inventory-item :item="hotbar_5" :keybind="hotbar_5.slot" />
                    </drag>
                </drop>
                <drop class="square" @drop="onEquipHotbar(6, $event)" :accepts-data="CanEquipToHotbarSlot">
                    <drag v-if="hotbar_6" :data="hotbar_6" :key="hotbar_6.uuid">
                        <inventory-item :item="hotbar_6" :keybind="hotbar_6.slot" />
                    </drag>
                </drop>
                <drop class="square" @drop="onEquipHotbar(7, $event)" :accepts-data="CanEquipToHotbarSlot">
                    <drag v-if="hotbar_7" :data="hotbar_7" :key="hotbar_7.uuid">
                        <inventory-item :item="hotbar_7" :keybind="hotbar_7.slot" />
                    </drag>
                </drop>
                <drop class="square" @drop="onEquipHotbar(8, $event)" :accepts-data="CanEquipToHotbarSlot">
                    <drag v-if="hotbar_8" :data="hotbar_8" :key="hotbar_8.uuid">
                        <inventory-item :item="hotbar_8" :keybind="hotbar_8.slot" />
                    </drag>
                </drop>
                <drop class="square" @drop="onEquipHotbar(9, $event)" :accepts-data="CanEquipToHotbarSlot">
                    <drag v-if="hotbar_9" :data="hotbar_9" :key="hotbar_9.uuid">
                        <inventory-item :item="hotbar_9" :keybind="hotbar_9.slot" />
                    </drag>
                </drop>
            </div>
            <div v-else id="hotbar">
                <div class="square">
                    <inventory-item :item="weapon_1" :keybind="weapon_1.slot" v-if="weapon_1" />
                </div>
                <div class="square">
                    <inventory-item :item="weapon_2" :keybind="weapon_2.slot" v-if="weapon_2" />
                </div>                
                <div class="square">
                    <inventory-item :item="weapon_3" :keybind="weapon_3.slot" v-if="weapon_3" />
                </div>

                <div class="spacer" />

                <div class="square">
                    <inventory-item :item="hotbar_4" :keybind="hotbar_4.slot" v-if="hotbar_4" />
                </div>
                <div class="square">
                    <inventory-item :item="hotbar_5" :keybind="hotbar_5.slot" v-if="hotbar_5" />
                </div>
                <div class="square">
                    <inventory-item :item="hotbar_6" :keybind="hotbar_6.slot" v-if="hotbar_6" />
                </div>
                <div class="square">
                    <inventory-item :item="hotbar_7" :keybind="hotbar_7.slot" v-if="hotbar_7" />
                </div>
                <div class="square">
                    <inventory-item :item="hotbar_8" :keybind="hotbar_8.slot" v-if="hotbar_8" />
                </div>
                <div class="square">
                    <inventory-item :item="hotbar_9" :keybind="hotbar_9.slot" v-if="hotbar_9" />
                </div>
            </div>
        </drop-mask>

        <div id="inhand" v-if="!inventory_visible && equipped_hands">
            <div class="name">{{equipped_hands.name}}</div>
            <div class="use" v-if="equipped_hands.use_label">
                <img width="25" height="25" :src="require('@/assets/images/icons/lmb.png')" />
                {{equipped_hands.use_label}}
            </div>
        </div>
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
        equipped_hands: function() {
            return this.inventory_items.find((item) => item.equipped && (item.type == "weapon" || (item.bone == "hand_l" || item.bone == "hand_r")));
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
        CanEquipToHands: function(item) {
            return item.type == 'weapon' || (item.bone == "hand_l" || item.bone == "hand_r");
        },
        CanEquipToHead: function(item) {
            return item.bone == "head";
        },
        CanEquipToBody: function(item) {
            return item.bone == "spine_02";
        },
        CanDropToInventory: function() {
            return true;
        },
        CanEquipToHotbarSlot: function(item) {
            return !this.CanEquipToBody(item) && !this.CanEquipToHead(item) && (item.type == "equipable" || item.type == "usable");
        },
        CanEquipToWeaponSlot: function(item) {
            return item.type == "weapon";
        },
        CanDropFromInventory: function() {
            return true;
        },
        onReorderInventory: function(e) {
            window.console.log("Reorder inventory");
            e.apply(this.inventory_items);

            this.CallEvent("UpdateInventory", JSON.stringify(this.inventory_items));
        },
        onDropFromInventory: function(e) {
            window.console.log("Drop item from inventory", e.data);

            let idx = this.inventory_items.findIndex((item) => item.uuid == e.data.uuid);
            if (idx > -1) {
                this.CallEvent("DropItem", this.inventory_items[idx].uuid);
                this.inventory_items.splice(idx, 1);
            }
        },
        onEquipHands: function(e) {
            window.console.log("Equip item to hands", e.data);

            let idx = this.inventory_items.indexOf(this.equipped_hands);
            if (idx > -1) {
                this.inventory_items[idx].equipped = false;
            }

            idx = this.inventory_items.findIndex((item) => item.uuid == e.data.uuid);
            if (idx > -1) {
                this.inventory_items[idx].equipped = true;
                this.CallEvent("EquipItem", this.inventory_items[idx].uuid);
            }
        },
        onEquipHead: function(e) {
            window.console.log("Equip item to head", e.data);

            let idx = this.inventory_items.indexOf(this.equipped_head);
            if (idx > -1) {
                this.inventory_items[idx].equipped = false;
            }

            idx = this.inventory_items.findIndex((item) => item.uuid == e.data.uuid);
            if (idx > -1) {
                this.inventory_items[idx].equipped = true;
                this.CallEvent("EquipItem", this.inventory_items[idx].uuid);
            }
        },
        onEquipBody: function(e) {
            window.console.log("Equip item to body", e.data);

            let idx = this.inventory_items.indexOf(this.equipped_body);
            if (idx > -1) {
                this.inventory_items[idx].equipped = false;
            }

            idx = this.inventory_items.findIndex((item) => item.uuid == e.data.uuid);
            if (idx > -1) {
                this.inventory_items[idx].equipped = true;
                this.CallEvent("EquipItem", this.inventory_items[idx].uuid);
            }
        },
        onEquipWeapon: function(slot, e) {
            window.console.log("Equip item to weapon slot " + slot, e.data);

            this.clearInventorySlot(slot);

            let idx = this.inventory_items.findIndex((item) => item.uuid == e.data.uuid);
            if (idx > -1) {
                this.inventory_items[idx].slot = slot;
                this.CallEvent("UpdateInventory", JSON.stringify(this.inventory_items));
            }
        },
        onEquipHotbar: function(slot, e) {
            window.console.log("Equip item to hotbar slot " + slot, e.data);

            this.clearInventorySlot(slot);

            let idx = this.inventory_items.findIndex((item) => item.uuid == e.data.uuid);
            if (idx > -1) {
                this.inventory_items[idx].slot = slot;
                this.CallEvent("UpdateInventory", JSON.stringify(this.inventory_items));
            }
        },
        clearInventorySlot: function(slot) {
            let idx = this.inventory_items.findIndex((item) => item.slot == slot);
            if (idx > -1) {
                this.inventory_items[idx].slot = null;
            }
        },
        onDropToInventory: function(e) {
            window.console.log("Drop item back to inventory", e.data);

            let idx = this.inventory_items.findIndex((item) => item.uuid == e.data.uuid);
            if (idx > -1) {
                this.inventory_items[idx].equipped = false;
                this.CallEvent("UnequipItem", this.inventory_items[idx].uuid);
            }
        },
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
                        uuid: "c83c6b6d-5f46-4eb5-90a7-57e5b407648f",
                        name: "Glock",
                        modelid: 2,
                        quantity: 1,
                        type: "weapon",
                        equipped: false,
                        slot: 1,
                    },
                    {
                        index: 3,
                        item: "rifle",
                        uuid: "31a15d35-f138-434e-b450-9b25c8c7cc40",
                        name: "Rifle",
                        modelid: 2,
                        quantity: 1,
                        type: "weapon",
                        equipped: false,
                        slot: null,
                    },
                    {
                        index: 5,
                        item: "metal",
                        uuid: "f42cc4c6-c0c2-46af-b0bb-79930aa27477",
                        name: "Metal",
                        modelid: 694,
                        quantity: 2,
                        type: "resource",
                        equipped: false,
                        slot: null,
                    },
                    {
                        index: 6,
                        item: "plastic",
                        uuid: "95ce2f7d-e10e-49c2-8737-606e96d3bf71",
                        name: "Plastic",
                        modelid: 627,
                        quantity: 1,
                        type: "resource",
                        equipped: false,
                        slot: null,
                    },
                    {
                        index: 7,
                        item: "vest",
                        uuid: "42d1a6a4-6593-45ea-8820-700879446109",
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
                        uuid: "49bbd29a-e0fd-4989-97e5-89954f8b1684",
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
                        uuid: "7df6a835-d332-40a5-9a58-d94f9249f645",
                        name: "Flashlight",
                        modelid: 14,
                        quantity: 2,
                        type: "equipable",
                        bone: "hand_r",
                        equipped: false,
                        slot: 6,
                    },
                    {
                        index: 8,
                        item: "beer",
                        uuid: "c1f5a0f9-ec94-426d-b2f2-eb0ee1aaecbb",
                        name: "Beer",
                        modelid: 15,
                        quantity: 4,
                        type: "usable",
                        use_label: "Drink",
                        bone: "hand_r",
                        equipped: true,
                        slot: null,
                    },
                    {
                        index: 10,
                        item: "wooden_chair",
                        uuid: "e1115819-ade8-4b77-af01-72927e3cd104",
                        name: "Wooden Chair",
                        modelid: 15,
                        quantity: 4,
                        type: "prop",
                        bone: null,
                        equipped: false,
                        slot: null,
                    },
                    {
                        index: 11,
                        item: "chainsaw",
                        uuid: "727af402-02d6-4dc8-9a1e-17be10549d31",
                        name: "Chainsaw",
                        modelid: 15,
                        quantity: 1,
                        type: "usable",
                        bone: "hand_r",
                        equipped: false,
                        slot: null,
                    },
                    {
                        index: 12,
                        item: "headphones",
                        uuid: "67b377c8-818a-464e-b7eb-b685d42d8caa",
                        name: "Headphones",
                        modelid:15,
                        quantity: 1,
                        type: "equipable",
                        bone: "head",
                        equipped: false,
                        slot: null
                    }
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
    margin: 0;
    width: 100%;
    height: 100%;
}
.container {
    margin: 0 auto;
    width: 1000px;
    display: flex;
    align-items: center;
    justify-content: center;
    height: 100vh;
}
#inner {
    background: rgba(0, 0, 0, 0.6);
    font-family: helvetica;
    font-size: 16px;
    color: #ccc;
    text-shadow: 3px black;
    padding: 20px;
}
.equipment-area {
    margin-top: 10px;
}
.equipped-slots {
    display: flex;
    flex-direction: row;
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
.inventory_items {
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
.container .drop-allowed {
    background-color: rgba(0, 255, 0, 0.2);
}

#inhand {
    position:fixed;
    bottom:1vh;
    right:1vh;
    width:250px;
    background: rgba(255,255,255, 0.4);
    font-family:helvetica;
    font-weight:bold;
    padding:5px 10px;
}
#inhand .name {
    font-size:22px;
    float:left;
}
#inhand .use {
    float:right;
    text-transform:uppercase;
    font-size:18px;
}
#inhand .use img {
    vertical-align:middle;
}
</style>
