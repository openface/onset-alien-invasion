<template>
  <div id="container">
    <div id="inner">
        <div id="title">STORAGE</div>
        <div class="grid">
          <draggable ghost-class="ghost" v-model="storage_items" class="draggable" group="storage_inventory" @sort="SortInventory" @start="dragging=true" @end="dragging=false" draggable=".slot" forceFallback="true">
            <InventoryItem v-for="item in storage_items" :index="item.index" :key="item.index" :item="item" :dragging="dragging" :show_options="false" />
          </draggable>
        </div>
    </div>

    <div id="inner">
        <div id="title">INVENTORY</div>
        <div class="grid">
          <draggable ghost-class="ghost" v-model="inventory_items" class="draggable" group="storage_inventory" @sort="SortInventory" @start="dragging=true" @end="dragging=false" draggable=".slot" forceFallback="true">
            <InventoryItem v-for="item in inventory_items" :index="item.index" :key="item.index" :item="item" :dragging="dragging" :show_options="false" />
          </draggable>
        </div>
    </div>
  </div>
</template>

<script>
import draggable from 'vuedraggable'
import InventoryItem from "./InventoryItem.vue";

export default {
  name: "Storage",
  components: {
    draggable,
    InventoryItem
  },
  data() {
    return {
      storage_items: [],
      inventory_items: [],
      dragging: false
    };
  },
  computed: {
    FreeStorageSlots: function() {
      return 14 - this.storage_items.length;
    },
    FreeInventorySlots: function() {
      return 14 - this.inventory_items.length;
    },
  },
  methods: {
    SetInventory: function(data) {
      this.storage_items = [];
      this.inventory_items = data.items.filter(item => item.type != 'weapon');
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
    }
  },
};
</script>

<style scoped>
#container {
  display: flex;
  flex-direction: column;
  flex-wrap: wrap;
  align-content: space-around;
  align-items: flex-start;
  justify-content: center;
  height:100vh;
}
#inner {
  order: 0;
  flex: 0 1 auto;
  align-self: auto;
  width: 645px;
  z-index: 1000;
  background: rgba(0, 0, 0, 0.6);
  font-family: helvetica;
  font-size: 16px;
  color: #ccc;
  text-shadow: 3px black;
  padding: 10px;
  margin-bottom:25px;
}

#title {
  color: #fff;
  font-size: 36px;
  text-align: center;
  margin: 0;
  margin-bottom:5px;
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
.ghost {
    opacity: 0.1;
}
.draggable:empty {
    text-align:center;
    height:85px;
    width:85px;
    border:3px dotted rgba(0, 0, 0, 0.2);
    background:rgba(0, 0, 0, 0.1);
}
</style>
