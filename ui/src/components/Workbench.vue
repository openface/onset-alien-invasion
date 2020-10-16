<template>
  <div id="container">
    <div id="inner">
      <div id="title">WORKBENCH</div>
      <div class="grid">
        <div v-for="(item, key) in items" :key="key">
          <workbench-item
            :recipe="item.recipe"
            :player_resources="player_resources"
            :item="item"
          ></workbench-item>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import WorkbenchItem from "./WorkbenchItem.vue";

export default {
  name: "Workbench",
  components: {
    "workbench-item": WorkbenchItem,
  },
  data() {
    return {
      items: {},
      player_resources: {},
    };
  },
  methods: {
    LoadWorkbenchData: function(data) {
      this.items = data["item_data"];
      this.player_resources = data["player_resources"];
    },
    SetPlayerResources: function(data) {
      this.player_resources = data;
    },
  },
  mounted() {
    this.EventBus.$on("LoadWorkbenchData", this.LoadWorkbenchData);
    this.EventBus.$on("SetPlayerResources", this.SetPlayerResources);

    if (!this.InGame) {
      this.EventBus.$emit("LoadWorkbenchData", {
        player_resources: {
          metal: 1,
          wood: 2,
          computer_part: 1,
        },
        item_data: {
          armor: {
            name: "Vest",
            recipe: {
              wood: 2,
              metal: 1,
            },
            modelid: 843,
          },
          foobar: {
            name: "Foobar",
            recipe: {
              plastic: 2,
            },
            modelid: 843,
          },
          food: {
            name: "Food",
            recipe: {
              plastic: 2,
              wood: 2,
            },
            modelid: 843,
          },
        },
      });
    }
  },
};
</script>

<style scoped>
#container {
  display: flex;
  align-items: center;
  justify-content: center;
  height: 80vh;
}

#inner {
  width: 700px;
  background: rgba(0, 0, 0, 0.9);
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
</style>
