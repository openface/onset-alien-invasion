<template>
  <div id="container">
    <div id="inventory_screen" v-if="inventory_visible">
      <div v-if="HasInventory">

        <div id="title">INVENTORY</div>
        <div class="grid">
          <draggable v-model="inventory_items" @sort="SortInventory" @start="dragging=true" @end="dragging=false" draggable=".slot" forceFallback="true">
            <InventoryItem v-for="item in inventory_items" :index="item.index" :key="item.index" :item="item" :dragging="dragging" />
            <InventoryItem v-for="n in FreeInventorySlots" :key="'i'+n" />
          </draggable>
        </div>

        <div class="subtitle">WEAPONS</div>
        <div class="grid">
          <InventoryItem v-for="item in weapons" :index="item.index" :key="item.index" :item="item" />
          <div class="slot" v-for="n in FreeWeaponSlots" :key="'w'+n"></div>
        </div>

      </div>
      <div v-else id="title">YOUR INVENTORY IS EMPTY</div>
    </div>
    <div id="hotbar" v-if="!inventory_visible || !InGame">
      <div class="grid">
          <!-- weapons 1,2,3 -->
          <InventoryItem v-for="(item,i) in weapons" :index="item.index" :key="item.index" :item="item" :keybind="i+1" />
          <div class="slot" v-for="n in FreeWeaponSlots" :key="'hw'+n"></div>

          <!-- usable_items 4,5,6,7,8,9 -->
          <InventoryItem v-for="(item,i) in usable_items.slice(0, 6)" :index="item.index" :key="item.index" :item="item" :keybind="i+4" />
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
      weapons: [],
      inventory_items: [],
      usable_items: [],
      inventory_visible: false,
      dragging: false
    };
  },
  computed: {
    HasInventory: function() {
      return this.inventory_items.length > 0 || this.weapons.length > 0;
    },
    FreeInventorySlots: function() {
      return 14 - this.inventory_items.length;
    },
    FreeWeaponSlots: function() {
      return 3 - this.weapons.length;
    },
  },
  methods: {
    SetInventory: function(data) {
      this.weapons = data.items.filter(item => item.type == 'weapon');
      this.inventory_items = data.items.filter(item => !this.weapons.includes(item));

      this.usable_items = data.items.filter(item => item.type == 'usable' || item.type == 'equipable');
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
    SortInventory: function(e) {
        window.console.log(e);
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
            equipped: false,
          },
          {
            index: 2,
            item: "rifle",
            name: "Rifle",
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
          {
            index: 10,
            item: "medkit",
            name: "Medical Kit",
            modelid: 15,
            quantity: 4,
            type: "usable",
            equipped: false,
          },
          {
            index: 11,
            item: "medkit2",
            name: "Medical Kit2",
            modelid: 15,
            quantity: 4,
            type: "usable",
            equipped: false,
          },
          {
            index: 12,
            item: "medkit3",
            name: "Medical Kit",
            modelid: 15,
            quantity: 4,
            type: "usable",
            equipped: false,
          },          {
            index: 13,
            item: "medkit4",
            name: "Medical Kit",
            modelid: 15,
            quantity: 4,
            type: "usable",
            equipped: false,
          },          {
            index: 14,
            item: "medkit5",
            name: "Medical Kit",
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
.subtitle {
  color: #fff;
  font-size: 20px;
  text-align: center;
  margin: 0;
  font-weight: bold;
  font-family: impact;
  text-shadow: 2px 2px rgba(0, 0, 0, 0.4);
  background: rgba(255,255,255, 0.1);
}
.grid {
  display: flex;
  flex-wrap: wrap;
  align-content: flex-start;
  justify-content: center;
  align-items: flex-start;
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
</style>
