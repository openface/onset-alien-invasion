<template>
  <div id="container">
    <div id="inventory_screen" v-if="inventory_visible">
      <div v-if="InventoryItems.length > 0">
        <div id="title">INVENTORY</div>
        <div class="grid">
          <div class="slot" v-for="item in InventoryItems" :key="item.name" @mouseenter="PlayClick()">
            <img v-if="!InGame" src="http://placekitten.com/100/100" />
            <img v-if="InGame" :src="'http://game/objects/' + item.modelid" />
            <span class="name">{{ item.name }}</span>
            <span v-if="item.quantity > 1" class="quantity">
              x{{ item.quantity }}
            </span>
            <div class="options">
              <div v-if="item.type == 'equipable' || item.type == 'weapon'">
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
          <div class="slot" v-for="n in FreeInventorySlots" :key="n"></div>
        </div>
      </div>
      <div v-else id="title">YOUR INVENTORY IS EMPTY</div>
    </div>
    <div id="hotbar" v-if="!inventory_visible">
      <div class="slot" v-for="n in range(1, 3)" :key="n">
        <div v-if="weapons[n - 1]">
          <img v-if="!InGame" src="http://placekitten.com/100/100" />
          <img v-if="InGame" :src="'http://game/objects/' + weapons[n - 1].modelid" />
          <span class="keybind">{{ n }}</span>
          <span class="name">{{ weapons[n - 1].name }}</span>
          <span v-if="weapons[n - 1].quantity > 1" class="quantity">
            x{{ weapons[n - 1].quantity }}
          </span>
        </div>
      </div>
      <div class="slot" v-for="n in range(4, 9)" :key="n">
        <div v-if="items[n - 4]">
          <img v-if="!InGame" src="http://placekitten.com/100/100" />
          <img v-if="InGame" :src="'http://game/objects/' + items[n - 4].modelid" />
          <span class="keybind">{{ n }}</span>
          <span class="name">{{ items[n - 4].name }}</span>
          <span v-if="items[n - 4].quantity > 1" class="quantity">
            x{{ items[n - 4].quantity }}
          </span>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  name: "Inventory",
  data() {
    return {
      items: [],
      weapons: [],
      inventory_visible: false,
    };
  },
  computed: {
    FreeInventorySlots: function() {
      return 21 - this.InventoryItems.length;
    },
    InventoryItems: function() {
      return this.weapons.concat(this.items);
    },
  },
  methods: {
    SetInventory: function(data) {
      this.items = data.items;
      this.weapons = data.weapons;
    },
    ShowInventory: function() {
      this.inventory_visible = true;
    },
    HideInventory: function() {
      this.inventory_visible = false; 
    },
    DropItem: function(item) {
      this.CallEvent('DropItem', item);
    },
    EquipItem: function(item) {
      this.CallEvent('EquipItem', item);
    },
    UnequipItem: function(item) {
      this.CallEvent('UnequipItem', item);
    },
    UseItem: function(item) {
      this.CallEvent('UseItem', item);
    },
    range: function(start, end) {
      return Array(end - start + 1)
        .fill()
        .map((_, idx) => start + idx);
    },
    PlayClick() {
      this.CallEvent("PlayClick")
    }
  },
  mounted() {
    this.EventBus.$on("SetInventory", this.SetInventory);
    this.EventBus.$on("ShowInventory", this.ShowInventory);
    this.EventBus.$on("HideInventory", this.HideInventory);

    if (!this.InGame) {
      this.EventBus.$emit("SetInventory", {
        weapons: [
          {
            item: "glock",
            name: "Glock",
            modelid: 2,
            quantity: 1,
            type: "weapon",
            equipped: true,
          },
          {
            item: "glock2",
            name: "Glock2",
            modelid: 2,
            quantity: 1,
            type: "weapon",
            equipped: true,

          },
          {
            item: "glock3",
            name: "Glock3",
            modelid: 2,
            quantity: 1,
            type: "weapon",
            equipped: true,
          },
          {
            item: "glock4",
            name: "Glock4",
            modelid: 2,
            quantity: 1,
            type: "weapon",
          },
        ],
        items: [
          {
            item: "metal",
            name: "Metal",
            modelid: 694,
            quantity: 2,
            type: "resource",
          },
          {
            item: "plastic",
            name: "Plastic",
            modelid: 627,
            quantity: 1,
            type: "resource",
          },
          {
            item: "vest",
            name: "Kevlar Vest",
            modelid: 14,
            quantity: 1,
            type: "equipable",
            equipped: true,
          },
          {
            item: "flashlight",
            name: "Flashlight",
            modelid: 14,
            quantity: 2,
            type: "equipable",
            equipped: false,
          },
          {
            item: "beer",
            name: "Beer",
            modelid: 15,
            quantity: 4,
            type: "usable",
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
  height: 120vh;
}

#inventory_screen {
  width: 640px;
  z-index: 1000;
  background: rgba(0, 0, 0, 0.7);
  font-family: helvetica;
  font-size: 16px;
  color: #ccc;
  text-shadow: 3px black;
  padding: 20px;
}

#title {
  color: #fff;
  font-size: 40px;
  text-align: center;
  margin: 0;
  font-weight: bold;
  font-family: impact;
}

.grid {
  display: flex;
  flex-wrap: wrap;
  align-content: flex-start;
  margin: 0 auto;
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
#hotbar .slot:nth-child(3) {
  margin-right: 25px;
}

.slot {
  margin: 5px;
  align-self: auto;
  background: rgba(0, 0, 0, 0.2);
  border: 2px solid rgba(0, 0, 0, 0.1);
  height: 75px;
  width: 75px;
  display: inline-block;
  position: relative;
  font-family: Helvetica;
}
.slot:hover {
  background: rgba(0, 0, 0, 0.3);
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

.slot:hover .options {
  display: block;
  width: 75px;
}

.slot .options {
  display: none;
  position: relative;
  z-index: 1;
  background: rgba(0,0,0, 0.4);
  padding: 0 1px;
  top: -3px;
}

.slot .options a {
  color: #eee;
  display: block;
  padding: 5px 5px;
  text-decoration: none;
  font-size: 12px;
  font-weight: bold;
  text-transform: uppercase;
  text-shadow: 1px 1px rgba(0, 0, 0, 0.4);
}

.slot .options a:hover {
  background: rgba(0,0,0, 0.9);
  cursor: pointer;
}
</style>
