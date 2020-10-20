<template>
  <div id="container">
    <div id="inner">
      <div id="title">WORKBENCH</div>
      <div class="grid">
        <div v-for="item in items" :key="item.item">
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
        item_data: [
          {
            item: 'armor',
            name: "Vest",
            recipe: {
              wood: 2,
              metal: 1,
            },
            modelid: 843,
          },
          {
            item: 'foobar',
            name: "Foobar",
            recipe: {
              plastic: 2,
            },
            modelid: 843,
          },
          {
            item: 'food2',
            name: "Food",
            recipe: {
              plastic: 2,
              wood: 2,
            },
            modelid: 843,
          },
          {
            item: 'flashlight',
            name: "Flashlight",
            recipe: {
              computer_part: 1,
              metal: 1,
            },
            modelid: 843,
          },
          {
            item: 'food4',
            name: "Food",
            recipe: {
              plastic: 2,
              wood: 2,
            },
            modelid: 843,
          },
          {
            item: 'food5',
            name: "Food",
            recipe: {
              plastic: 2,
              wood: 2,
            },
            modelid: 843,
          },
          {
            item: 'food6',
            name: "Food",
            recipe: {
              plastic: 2,
              wood: 2,
            },
            modelid: 843,
          },
          {
            item: 'food7',
            name: "Food",
            recipe: {
              plastic: 2,
              wood: 2,
            },
            modelid: 843,
          },
          {
            item: 'food20',
            name: "Food",
            recipe: {
              plastic: 2,
              wood: 2,
            },
            modelid: 843,
          },
          {
            item: 'flashlight0',
            name: "Flashlight",
            recipe: {
              computer_part: 1,
              metal: 1,
            },
            modelid: 843,
          },
          {
            item: 'food40',
            name: "Food",
            recipe: {
              plastic: 2,
              wood: 2,
            },
            modelid: 843,
          },
          {
            item: 'food50',
            name: "Food",
            recipe: {
              plastic: 2,
              wood: 2,
            },
            modelid: 843,
          },
          {
            item: 'food60',
            name: "Food",
            recipe: {
              plastic: 2,
              wood: 2,
            },
            modelid: 843,
          },
          {
            item: 'food70',
            name: "Food",
            recipe: {
              plastic: 2,
              wood: 2,
            },
            modelid: 843,
          },
        ]
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
  height: 100%;
}

#inner {
  width: 800px;
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
