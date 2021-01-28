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
                            type="inventory_item"
                            :key="item.index"
                        >
                            <img :src="getImageUrl(item)" />
                        </drag>
                    </template>

                    <template v-slot:feedback="{ data }">
                        <div class="item feedback" :key="data.index">
                            {{ data }}
                        </div>
                    </template>
                </drop-list>

                <div class="equipment">
                    Hands
                    <drop
                        class="equipment-dropzone"
                        @drop="onEquipHands"
                        accepts-type="inventory_item"
                    >
                        <img v-if="equipped_hands" :src="getImageUrl(equipped_hands)" />
                    </drop>

                    Head
                    <drop
                        class="equipment-dropzone"
                        @drop="onEquipHead"
                        accepts-type="inventory_item"
                    >
                        <img v-if="equipped_head" :src="getImageUrl(equipped_head)" />
                    </drop>

                    Body
                    <drop
                        class="equipment-dropzone"
                        @drop="onEquipBody"
                        accepts-type="inventory_item"
                    >
                        <img v-if="equipped_body" :src="getImageUrl(equipped_body)" />
                    </drop>
                </div>
            </div>
            <div v-else id="title">YOUR INVENTORY IS EMPTY</div>
        </div>
        <div id="hotbar">
            <drop-list
                :items="hotbar_items"
                class="grid"
                @insert="onInsertHotbar"
                @reorder="onReorderHotbar"
                accepts-type="inventory_item"
            >
                <template v-slot:item="{ item }">
                    <drag class="slot" :data="item" :key="item.index">
                        {{ item.slot }} <img :src="getImageUrl(item)" />
                    </drag>
                </template>

                <template v-slot:feedback="{ data }">
                    <div class="item feedback" :key="data.index">
                        {{ data }}
                    </div>
                </template>
            </drop-list>
        </div>
        <drop
            class="drop-area"
            @drop="onDropItem"
            accepts-type="inventory_item"
        >
        </drop>
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
            hotbar_items: [],
            equipped_hands: null,
            equipped_head: null,
            equipped_body: null,
            inventory_visible: false,
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
            this.hotbar_items = data.inventory_items.filter(
                (item) => item.slot
            );
            this.equipped_hands = data.equipped_hands;
            this.equipped_head = data.equipped_head;
            this.equipped_body = data.equipped_body;
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
        onReorderHotbar: function(e) {
            window.console.log("Reorder hotbar");
            e.apply(this.hotbar_items);
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
    },
    mounted() {
        this.EventBus.$on("SetInventory", this.SetInventory);
        this.EventBus.$on("ShowInventory", this.ShowInventory);
        this.EventBus.$on("HideInventory", this.HideInventory);

        if (!this.InGame) {
            this.EventBus.$emit("SetInventory", {
                equipped_head: null,
                equipped_hands: null,
                equipped_body: {
                        index: 7,
                        item: "vest",
                        name: "Kevlar Vest",
                        modelid: 14,
                        quantity: 1,
                        type: "equipable",
                        equipped: true,
                },
                inventory_items: [
                    {
                        index: 2,
                        item: "glock",
                        name: "Glock",
                        modelid: 2,
                        quantity: 1,
                        type: "weapon",
                        slot: 2,
                    },
                    {
                        index: 3,
                        item: "rifle",
                        name: "Rifle",
                        modelid: 2,
                        quantity: 1,
                        type: "weapon",
                        slot: 3,
                    },
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
                        use_label: "Drink",
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
.equipment-dropzone {
    width: 100px;
    height: 100px;
    float: left;
    border: 1px solid #000;
    padding: 5px;
}
.drop-area {
    width: 100%;
    height: 100%;
    position: fixed;
}
</style>
