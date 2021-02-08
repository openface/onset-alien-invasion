<template>
    <div id="container">
        <div id="inner" v-if="inventory_visible">
            <div v-if="HasInventory">
                <div id="title">INVENTORY</div>
                <drop-list
                    :items="inventory_items"
                    class="grid"
                    @reorder="onReorderInventory"
                >
                    <template v-slot:item="{ item }">
                        <drag
                            class="slot"
                            :data="item"
                            :type="item.type"
                            :key="item.index"
                            @cut="removeFromInventory"
                        >
                            {{ item.name }} <img :src="getImageUrl(item)" />
                        </drag>
                    </template>

                    <template v-slot:feedback="{ data }">
                        <div class="item feedback" :key="data.index">
                            <img :src="getImageUrl(data.item)" />
                        </div>
                    </template>
                </drop-list>

                <div class="equipment">
                    Hands
                    <drop
                        class="drop-area"
                        @drop="onEquipHands"
                        accepts-type="inventory_item"
                    >
                        <img
                            v-if="equipped_hands"
                            :src="getImageUrl(equipped_hands)"
                        />
                    </drop>

                    Head
                    <drop
                        class="drop-area"
                        @drop="onEquipHead"
                        accepts-type="inventory_item"
                    >
                        <img
                            v-if="equipped_head"
                            :src="getImageUrl(equipped_head)"
                        />
                    </drop>

                    Body
                    <drop
                        class="drop-area"
                        @drop="onEquipBody"
                        accepts-type="inventory_item"
                    >
                        <img
                            v-if="equipped_body"
                            :src="getImageUrl(equipped_body)"
                        />
                    </drop>
                </div>
            </div>
            <div v-else id="title">YOUR INVENTORY IS EMPTY</div>
        </div>
        <div id="hotbar">

            <!-- weapon slots -->

            <drop
                class="drop-area"
                @drop="onEquipWeapon1"
                accepts-type="weapon"
            >
                <drag
                    v-if="weapon_1"
                    class="slot"
                    :data="weapon_1"
                    type="weapon"
                    :key="weapon_1.index"
                >
                    {{ weapon_1.name }} <img :src="getImageUrl(weapon_1)" />
                </drag>
            </drop>
            <drop
                class="drop-area"
                @drop="onEquipWeapon2"
                accepts-type="weapon"
            >
                <drag
                    v-if="weapon_2"
                    class="slot"
                    :data="weapon_2"
                    type="weapon"
                    :key="weapon_2.index"
                >
                    {{ weapon_2.name }} <img :src="getImageUrl(weapon_2)" />
                </drag>
            </drop>
            <drop
                class="drop-area"
                @drop="onEquipWeapon3"
                accepts-type="weapon"
            >
                <drag
                    v-if="weapon_3"
                    class="slot"
                    :data="weapon_3"
                    type="weapon"
                    :key="weapon_3.index"
                >
                    {{ weapon_3.name }} <img :src="getImageUrl(weapon_3)" />
                </drag>
            </drop>

            <!-- hotbar slots -->

            <drop
                class="drop-area"
                @drop="onEquipHotbar4"
                mode="cut"
                :accepts-type="['equipable', 'usable']"
            >
                <drag
                    v-if="hotbar_4"
                    class="slot"
                    :data="hotbar_4"
                    :type="hotbar_4.type"
                    :key="hotbar_4.index"
                    @cut="removeHotbar4"
                >
                    <img v-if="hotbar_4" :src="getImageUrl(hotbar_4)" />
                </drag>
            </drop>
            <drop
                class="drop-area"
                @drop="onEquipHotbar5"
                mode="cut"
                :accepts-type="['equipable', 'usable']"
            >
                <drag
                    v-if="hotbar_5"
                    class="slot"
                    :data="hotbar_5"
                    :type="hotbar_5.type"
                    :key="hotbar_5.index"
                    @cut="removeHotbar5"
                >
                    <img v-if="hotbar_5" :src="getImageUrl(hotbar_5)" />
                </drag>
            </drop>
            <drop
                class="drop-area"
                @drop="onEquipHotbar6"
                :accepts-type="['equipable', 'usable']"
            >
                <img v-if="hotbar_6" :src="getImageUrl(hotbar_6)" />
            </drop>
            <drop
                class="drop-area"
                @drop="onEquipHotbar7"
                :accepts-type="['equipable', 'usable']"
            >
                <img v-if="hotbar_7" :src="getImageUrl(hotbar_7)" />
            </drop>
            <drop
                class="drop-area"
                @drop="onEquipHotbar8"
                :accepts-type="['equipable', 'usable']"
            >
                <img v-if="hotbar_8" :src="getImageUrl(hotbar_8)" />
            </drop>
            <drop
                class="drop-area"
                @drop="onEquipHotbar9"
                :accepts-type="['equipable', 'usable']"
            >
                <img v-if="hotbar_9" :src="getImageUrl(hotbar_9)" />
            </drop>
        </div>
    </div>
</template>

<script>
import { Drag, Drop, DropList } from "vue-easy-dnd";

export default {
    name: "Inventory",
    components: {
        Drag,
        Drop,
        DropList,
    },
    data() {
        return {
            weapons: [],
            inventory_items: [],
            equipped_hands: null,
            equipped_head: null,
            equipped_body: null,
            inventory_visible: false,
            weapon_1: null,
            weapon_2: null,
            weapon_3: null,
            hotbar_4: null,
            hotbar_5: null,
            hotbar_6: null,
            hotbar_7: null,
            hotbar_8: null,
            hotbar_9: null,
        };
    },
    computed: {
        HasInventory: function() {
            return this.inventory_items.length > 0;
        },
    },
    methods: {
        SetInventory: function(data) {
            this.inventory_items = data.inventory_items;
            this.equipped_hands = data.inventory_items.find(
                (item) => item.bone == "hand_r" || item.bone == "hand_l"
            );
            this.equipped_head = data.inventory_items.find(
                (item) => item.bone == "head"
            );
            this.equipped_body = data.inventory_items.find(
                (item) => item.bone == "spine_02"
            );
            this.weapon_1 = data.inventory_items.find(
                (item) => item.type == 'weapon' && item.slot == 1
            );
            this.weapon_2 = data.inventory_items.find(
                (item) => item.type == 'weapon' && item.slot == 2
            );
            this.weapon_3 = data.inventory_items.find(
                (item) => item.type == 'weapon' && item.slot == 3
            );
            this.hotbar_4 = data.inventory_items.find(
                (item) => item.slot == 4
            );
            this.hotbar_5 = data.inventory_items.find(
                (item) => item.slot == 5
            );
            this.hotbar_6 = data.inventory_items.find(
                (item) => item.slot == 6
            );
            this.hotbar_7 = data.inventory_items.find(
                (item) => item.slot == 7
            );
            this.hotbar_8 = data.inventory_items.find(
                (item) => item.slot == 8
            );
            this.hotbar_9 = data.inventory_items.find(
                (item) => item.slot == 9
            );
        },
        ShowInventory: function() {
            this.inventory_visible = true;
        },
        HideInventory: function() {
            this.inventory_visible = false;
        },
        onInsertHotbar(e) {
            window.console.log("adding to hotbar");
            window.console.log(e.index, e.type, e.data);
            //this.inventory_items.splice(event.index, 0, event.data);
        },
        onReorderInventory: function(e) {
            window.console.log("Reorder inventory");
            e.apply(this.inventory_items);
        },
        onDropItem: function() {
            window.console.log("Drop item");
        },
        onEquipHands: function(e) {
            window.console.log("Equip item to hands");
            this.equipped_hands = e.data;
        },
        onEquipHead: function(e) {
            window.console.log("Equip item to head");
            this.equipped_head = e.data;
        },
        onEquipBody: function(e) {
            window.console.log("Equip item to body");
            this.equipped_body = e.data;
        },
        onEquipWeapon1: function(e) {
            window.console.log("Equip weapon1");
            this.weapon_1 = e.data;
            window.console.log(e.index, e.type, e.data);
        },
        onEquipWeapon2: function(e) {
            window.console.log("Equip weapon2");
            this.weapon_2 = e.data;
            window.console.log(e.index, e.type, e.data);
        },
        onEquipWeapon3: function(e) {
            window.console.log("Equip weapon3");
            this.weapon_3 = e.data;
            window.console.log(e.index, e.type, e.data);
        },
        onEquipHotbar4: function(e) {
            window.console.log("Equip item to hotbar4");
            window.console.log(e.index, e.type, e.data);
            this.hotbar_4 = e.data;
        },
        onEquipHotbar5: function(e) {
            window.console.log("Equip item to hotbar5");
            window.console.log(e.index, e.type, e.data);
            this.hotbar_5 = e.data;
        },
        onEquipHotbar6: function(e) {
            window.console.log("Equip item to hotbar6");
            window.console.log(e.index, e.type, e.data);
            this.hotbar_6 = e.data;
        },
        onEquipHotbar7: function(e) {
            window.console.log("Equip item to hotbar7");
            window.console.log(e.index, e.type, e.data);
            this.hotbar_7 = e.data;
        },
        onEquipHotbar8: function(e) {
            window.console.log("Equip item to hotbar8");
            window.console.log(e.index, e.type, e.data);
            this.hotbar_8 = e.data;
        },
        onEquipHotbar9: function(e) {
            window.console.log("Equip item to hotbar9");
            window.console.log(e.index, e.type, e.data);
            this.hotbar_9 = e.data;
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
        removeFromInventory: function(e) {
            window.console.log("removeFromInventory");
            window.console.log(e.index, e.type, e.data);
        },
        removeHotbar4: function(e) {
            window.console.log("remove hotbar4");
            window.console.log(e.index, e.type, e.data);
        },
        removeHotbar5: function(e) {
            window.console.log("remove hotbar5");
            window.console.log(e.index, e.type, e.data);
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
                        slot: 2,
                    },
                    {
                        index: 5,
                        item: "metal",
                        name: "Metal",
                        modelid: 694,
                        quantity: 2,
                        type: "resource",
                    },
                    {
                        index: 6,
                        item: "plastic",
                        name: "Plastic",
                        modelid: 627,
                        quantity: 1,
                        type: "resource",
                    },
                    {
                        index: 7,
                        item: "vest",
                        name: "Kevlar Vest",
                        modelid: 14,
                        quantity: 1,
                        type: "equipable",
                        bone: "spine_02",
                    },
                    {
                        index: 9,
                        item: "flashlight",
                        name: "Flashlight",
                        modelid: 14,
                        quantity: 2,
                        type: "equipable",
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
                    },
                    {
                        index: 10,
                        item: "wooden_chair",
                        name: "Wooden Chair",
                        modelid: 15,
                        quantity: 4,
                        type: "prop",
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
    width: 100%;
    position: fixed;
    bottom: 1vh;
}
.equipment {
    color: #fff;
    font-size: 16px;
    text-align: center;
    text-transform: uppercase;
    margin: 0;
    font-family: impact;
    text-shadow: 2px 2px rgba(0, 0, 0, 0.4);
    background: rgba(255, 255, 255, 0.1);
}
.drop-area {
    width: 100px;
    height: 100px;
    float: left;
    border: 1px solid #000;
    padding: 5px;
}
.drop-allowed {
    background-color: rgba(0, 255, 0, 0.2);
}

.drop-forbidden {
    background-color: rgba(255, 0, 0, 0.2);
}

.drop-in {
    box-shadow: 0 0 5px rgba(0, 0, 255, 0.4);
}
</style>
