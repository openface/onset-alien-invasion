<template>
  <div class="slot" @mouseenter="PlayClick();showOptions=true" @mouseleave="showOptions=false">
    <img v-if="!InGame" src="http://placekitten.com/100/100" />
    <img v-if="InGame" :src="'http://game/objects/' + item.modelid" />
    <span class="name">{{ item.name }}</span>
    <span v-if="item.quantity > 1" class="quantity">
      x{{ item.quantity }}
    </span>
    <div class="options" v-if="showOptions">
      <div v-if="item.type == 'weapon'">
        <a v-if="!item.equipped" @click="EquipItem(item.item)">Equip</a>
      </div>
      <div v-if="item.type == 'equipable'">
        <a v-if="!item.equipped" @click="EquipItem(item.item)">Equip</a>
        <a v-if="item.equipped" @click="UnequipItem(item.item)">Unequip</a>
      </div>
      <div v-else-if="item.type == 'usable'">
        <a @click="UseItem(item.item)">Use</a>
        <a v-if="item.equipped" @click="UnequipItem(item.item)">Put Away</a>
      </div>
      <a @click="DropItem(item.item)">Drop</a>
    </div>
  </div>
</template>

<script>
export default {
  name: "InventoryItem",
  props: ["item", "dragging"],
  data() {
    return {
      showOptions: false,
    };
  },
  methods: {
    DropItem: function(item) {
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

<style scoped>
.slot {
  margin: 5px;
  align-self: auto;
  background: rgba(0, 0, 0, 0.2);
  border: 2px solid rgba(0, 0, 0, 0.1);
  height: 75px;
  width: 75px;
  position: relative;
  font-family: Helvetica;
}
.slot:hover {
  background: rgba(0, 0, 0, 0.3);
  cursor: pointer;
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
  top: 75px;
  width: 75px;
  left: 0;
  border: 1px solid rgba(0, 0, 0, 0.4);
}

.slot .options a {
  color: #eee;
  display: block;
  padding: 5px 5px;
  text-decoration: none;
  font-size: 11px;
  font-weight: bold;
  text-transform: uppercase;
  text-shadow: 1px 1px rgba(0, 0, 0, 0.4);
}

.slot .options a:hover {
  background: rgba(0, 0, 0, 0.9);
}
</style>
