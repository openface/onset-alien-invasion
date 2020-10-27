<template>
  <div id="container">
    <div id="inventory_screen" v-if="inventory_visible">
      <div v-if="items.length > 0">
        <div id="title">INVENTORY</div>

        <div>
          <div style="width:280px;float:left;">
            <div class="subtitle">WEAPONS</div>
            <div class="grid">
              <InventoryItem v-for="item in equipped_weapons" :index="item.index" :key="item.index" :item="item" />
              <div class="slot" v-for="n in FreeWeaponSlots" :key="'w'+n"></div>
            </div>
          </div>
          <div style="float:left;">
            <div class="subtitle">EQUIPMENT</div>
            <div class="grid">
              <InventoryItem v-for="item in equipped_items" :index="item.index" :key="item.index" :item="item" />
              <div class="slot" v-for="n in FreeEquipmentSlots" :key="'w'+n"></div>
            </div>
          </div>
          <br style="clear:both;" />
        </div>

        <div>
          <div class="subtitle">INVENTORY</div>
          <div class="grid">
            <draggable v-model="inventory_items" @sort="SortInventory" @start="dragging=true" @end="dragging=false" forceFallback="true">
              <InventoryItem v-for="item in inventory_items" :index="item.index" :key="item.index" :item="item" :dragging="dragging" />
            </draggable>
            <div class="slot" v-for="n in FreeInventorySlots" :key="'i'+n"></div>
          </div>
        </div>

      </div>
      <div v-else id="title">YOUR INVENTORY IS EMPTY</div>
    </div>
    <div id="hotbar" v-if="!inventory_visible">
      <div class="slot" v-for="n in range(1, 3)" :key="n">
        <div v-if="equipped_weapons[n - 1]">
          <img v-if="!InGame" src="http://placekitten.com/100/100" />
          <img v-if="InGame" :src="'http://game/objects/' + equipped_weapons[n - 1].modelid" />
          <span class="keybind">{{ n }}</span>
          <span class="name">{{ equipped_weapons[n - 1].name }}</span>
          <span v-if="equipped_weapons[n - 1].quantity > 1" class="quantity">
            x{{ equipped_weapons[n - 1].quantity }}
          </span>
        </div>
      </div>
      <div class="slot" v-for="n in range(4, 9)" :key="n">
        <div v-if="inventory_items[n - 4]">
          <img v-if="!InGame" src="http://placekitten.com/100/100" />
          <img v-if="InGame" :src="'http://game/objects/' + inventory_items[n - 4].modelid" />
          <span class="keybind">{{ n }}</span>
          <span class="name">{{ inventory_items[n - 4].name }}</span>
          <span v-if="inventory_items[n - 4].quantity > 1" class="quantity">
            x{{ inventory_items[n - 4].quantity }}
          </span>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import draggable from 'vuedraggable'
import InventoryItem from "./InventoryItem.vue";

export default {
  name: "Inventory",
  components: {
    draggable,
    InventoryItem
  },
  data() {
    return {
      items: [],
      equipped_weapons: [],
      equipped_items: [],
      inventory_items: [],
      inventory_visible: false,
      dragging: false
    };
  },
  computed: {
    FreeInventorySlots: function() {
      return 14 - this.inventory_items.length;
    },
    FreeWeaponSlots: function() {
      return 3 - this.equipped_weapons.length;
    },
    FreeEquipmentSlots: function() {
      return 4 - this.equipped_items.length;
    }
  },
  methods: {
    SetInventory: function(data) {
      this.items = data.items;
      //this.items = data.items.sort(function(a, b) { return a.index - b.index; });
      this.equipped_weapons = this.items.filter(item => item.type == 'weapon' && item.equipped == true);
      this.equipped_items = this.items.filter(item => item.type != 'weapon' && item.equipped == true);
      this.inventory_items = this.items.filter(item => !this.equipped_items.includes(item) && !this.equipped_weapons.includes(item));
      //this.items = data.items.sort(function(a, b) { return a.index - b.index; });

    },
    ShowInventory: function() {
      this.inventory_visible = true;
    },
    HideInventory: function() {
      this.inventory_visible = false;
    },
    range: function(start, end) {
      return Array(end - start + 1)
        .fill()
        .map((_, idx) => start + idx);
    },
    SortInventory: function() {
        //window.console.log(e.oldIndex);
        //window.console.log(e.newIndex);
        var data = this.inventory_items.map(function(item, index) {
            return { item: item.item, oldIndex: item.index, newIndex: index + 1 }
        })

        this.CallEvent("SortInventory", JSON.stringify(data));
    },
    log: function(evt) {
      window.console.log(evt);
    }
  },
  mounted() {
    this.EventBus.$on("SetInventory", this.SetInventory);
    this.EventBus.$on("ShowInventory", this.ShowInventory);
    this.EventBus.$on("HideInventory", this.HideInventory);

    if (!this.InGame) {
      this.EventBus.$emit("SetInventory", {
        items: [
          {
            index: 1,
            item: "glock",
            name: "Glock",
            modelid: 2,
            quantity: 1,
            type: "weapon",
            equipped: true,
          },
          {
            index: 2,
            item: "glock2",
            name: "Glock2",
            modelid: 2,
            quantity: 1,
            type: "weapon",
            equipped: true,
          },
          {
            index: 3,
            item: "glock3",
            name: "Glock3",
            modelid: 2,
            quantity: 1,
            type: "weapon",
            equipped: false,
          },
          {
            index: 4,
            item: "glock4",
            name: "Glock4",
            modelid: 2,
            quantity: 1,
            type: "weapon",
            equipped: false,
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
  width: 645px;
  z-index: 1000;
  background: rgba(0, 0, 0, 0.7);
  font-family: helvetica;
  font-size: 16px;
  color: #ccc;
  text-shadow: 3px black;
  padding: 10px;
}

#title {
  color: #fff;
  font-size: 40px;
  text-align: center;
  margin: 0;
  font-weight: bold;
  font-family: impact;
  text-shadow:2px 2px rgba(0, 0, 0, 0.1);
}
.subtitle {
  background:rgba(0, 0, 0, 0.3);
  padding:5px;
  text-shadow:1px 1px rgba(0, 0, 0, 0.1);
  font-weight:bold;
  font-size:11px;
}
.subtitle span {
  float:right;
}
.grid {
  display: flex;
  flex-wrap: wrap;
  align-content: flex-start;
  justify-content: center;
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
  background: rgba(0, 0, 0, 0.4);
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
  background: rgba(0, 0, 0, 0.9);
  cursor: pointer;
}
</style>
