<template>
    <div
        v-if="item"
        :class="{ slot: true, equipped: IsEquipped }"
        @mouseenter="
            PlayClick();
            hover = true;
        "
        @mouseleave="hover = false"
    >
        <img :src="getImageUrl(item)" @mousedown="hover = false" />
        <span class="keybind" v-if="keybind">{{ keybind }}</span>
        <span class="name">{{ item.name }}</span>
        <span v-if="item.quantity > 1" class="quantity">
            x{{ item.quantity }}
        </span>
        <div class="options" v-if="OptionsVisible">
            <div v-if="item.type == 'equipable'">
                <a v-if="!item.equipped" @click="EquipItem(item.item)">Equip</a>
                <a v-if="item.equipped" @click="UnequipItem(item.item)"
                    >Unequip</a
                >
            </div>
            <div v-else-if="item.type == 'usable'">
                <a @click="UseItem(item.item)">{{ item.use_label || "Use" }}</a>
                <a v-if="item.equipped" @click="UnequipItem(item.item)"
                    >Put Away</a
                >
            </div>
            <a @click="DropItem(item.item)">Drop</a>
        </div>
    </div>
    <div v-else class="freeslot"></div>
</template>

<script>
export default {
    name: "InventoryItem",
    props: ["item", "dragging", "keybind", "show_options"],
    data() {
        return {
            hover: false,
        };
    },
    computed: {
        IsEquipped: function() {
            return this.item.equipped;
        },
        OptionsVisible: function() {
            return this.show_options && !this.dragging && this.hover;
        },
    },
    methods: {
        DropItem: function(item) {
            window.console.log("drop");
            this.CallEvent("DropItem", item);
        },
        EquipItem: function(item) {
            this.CallEvent("EquipItem", item);
        },
        UnequipItem: function(item) {
            this.CallEvent("UnequipItem", item);
        },
        UseItem: function(item) {
            this.CallEvent("UseItem", item);
        },
        PlayClick() {
            if (!this.dragging) {
                this.CallEvent("PlayClick");
            }
        },
    },
};
</script>

<style>
.slot,
.freeslot {
    background: rgba(255, 255, 255, 0.1);
    border: 2px solid rgba(0, 0, 0, 0.3);
    position: relative;
    font-family: Helvetica;
    width: 75px;
    height: 75px;
}
.slot:hover {
    background: rgba(0, 0, 0, 0.3);
}
.slot:hover img {
    opacity: 1;
}
.slot.equipped {
    border-color: rgba(255, 255, 0, 0.7);
}
.slot img {
    object-fit: scale-down;
    width: 75px;
    height: 75px;
    opacity: 0.5;
}
.slot .quantity {
    color: #fff;
    font-weight: bold;
    position: absolute;
    text-shadow: 2px 2px #000;
    bottom: -2px;
    right: -2px;
    z-index: 1;
    font-size: 12px;
    padding: 5px 7px;
    background: rgba(0, 0, 0, 0.5);
}
.slot .keybind {
    position: absolute;
    top: 1px;
    left: 1px;
    color: #fff;
    background: rgba(255, 255, 255, 0.2);
    text-shadow: 1px 1px #000;
    padding: 0px 3px;
}
.slot .name {
    position: absolute;
    bottom: 1px;
    left: 1px;
    font-size: 12px;
    color: #fff;
    text-shadow: 1px 1px #000;
}

/* options */

.slot .options {
    position: absolute;
    z-index: 1;
    background: rgba(0, 0, 0, 0.4);
    left: 0;
    width: 100%;
    border: 1px solid rgba(0, 0, 0, 0.4);
}

.slot .options a {
    color: #eee;
    display: block;
    padding: 6px 5px;
    text-decoration: none;
    font-size: 11px;
    font-weight: bold;
    text-transform: uppercase;
    text-shadow: 1px 1px rgba(0, 0, 0, 0.6);
}

.slot .options a:hover {
    background: rgba(0, 0, 0, 0.9);
    cursor: pointer;
}
</style>
