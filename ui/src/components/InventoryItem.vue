<template>
    <div v-if="item" :class="{ item: true, equipped: currentlyEquipped }" @mouseenter="PlayClick()">
        <img :src="getImageUrl(item)" />
        <span class="keybind" v-if="keybind">{{ keybind }}</span>
        <span class="name">{{ item.name }}</span>
        <span v-if="item.quantity > 1" class="quantity"> x{{ item.quantity }} </span>
    </div>
</template>

<script>
export default {
    name: "InventoryItem",
    props: ["item", "keybind"],
    computed: {
        currentlyEquipped: function() {
            return this.item.equipped && this.keybind && this.item.type != 'weapon'
        }
    },
    methods: {
        PlayClick() {
            this.CallEvent("PlayClick");
        },
    },
};
</script>

<style scoped>
.item {
    background: rgba(255, 255, 255, 0.1);
    border: 2px solid rgba(0, 0, 0, 0.3);
    position: relative;
    font-family: Helvetica;
    width: 75px;
    height: 75px;
}
.item:hover {
    background: rgba(0, 0, 0, 0.3);
    border-color: rgba(255,255,255, 0.6);
}
.item:hover img {
    opacity: 1;
}
.item.equipped {
    border-color: rgba(255, 255, 0, 0.7);
}
.item img {
    object-fit: scale-down;
    width: 75px;
    height: 75px;
    opacity: 0.9;
}
.item .quantity {
    color: #fff;
    font-weight: bold;
    position: absolute;
    text-shadow: 2px 2px #000;
    bottom: -1px;
    right: -2px;
    z-index: 1;
    font-size: 12px;
    padding: 5px 7px;
    background: rgba(0, 0, 0, 0.5);
}
.item .keybind {
    position: absolute;
    top: 1px;
    left: 1px;
    color: #fff;
    background: rgba(255, 255, 255, 0.2);
    text-shadow: 1px 1px #000;
    padding: 0px 3px;
    font-weight: bold;
}
.item .name {
    position: absolute;
    bottom: 1px;
    left: 1px;
    font-size: 12px;
    color: #fff;
    text-shadow: 1px 1px #000;
}
</style>
