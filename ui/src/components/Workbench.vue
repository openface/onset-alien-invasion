<template>
  <div id="container">
    <div id="inner">
      <div id="title">WORKBENCH</div>
      <div class="grid" :class="IsBusy() ? 'blurred' : ''">
        <div v-for="item in items" :key="item.item">
          <div class="item" @mouseenter="!IsBusy ? PlayClick() : null">
            <div class="pic">
              <img :src="getImageUrl(item)" />
            </div>
            <div class="details">
              <div class="name">{{ item.name }}</div>
              <div class="info">
                <span v-for="(qty, resource) in item.recipe" :key="resource">
                  <b>{{ qty }}</b> {{ resource }}
                </span>
              </div>
              <div class="action">
                <button class="build" @click="BuildItem(item.item)">BUILD NOW</button>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>

    <div id="progress" v-if="IsBusy()">
      <loading-progress :indeterminate="true" size="40" rotate fillDuration="3" rotationDuration="4" />
    </div>
  </div>
</template>

<script>
export default {
  name: "Workbench",
  data() {
    return {
      items: {},
      player_resources: {},
      is_busy: false,
    };
  },
  methods: {
    IsBusy() {
      return this.is_busy;
    },
    LoadWorkbenchData: function(data) {
      this.items = data["item_data"];
      this.player_resources = data["player_resources"];
    },
    CompleteBuild: function(data) {
      this.is_busy = false;
      this.player_resources = data['player_resources'];
    },
    BuildDenied: function() {
      this.is_busy = false;
    },
    BuildItem(item) {
      this.is_busy = true;
      this.CallEvent("BuildItem", item);

      if (!this.InGame) {
        setTimeout(() => this.EventBus.$emit("BuildDenied"), 5000);
        //setTimeout(() => this.EventBus.$emit("CompleteBuild", { player_resources: { plastic: 10, wood: 5 }}), 5000);
      }
    },
  },
  mounted() {
    this.EventBus.$on("LoadWorkbenchData", this.LoadWorkbenchData);
    this.EventBus.$on("CompleteBuild", this.CompleteBuild);
    this.EventBus.$on("BuildDenied", this.BuildDenied);

    if (!this.InGame) {
      this.EventBus.$emit("LoadWorkbenchData", {
        player_resources: {
          plastic: 2,
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
              plastic: 5
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
  display:flex;
  height:75vh;
}
#progress {
  position: fixed;
  top: 40%;
  left: 50%;
  transform: translate(-50%, -50%);
}
#progress >>> .vue-progress-path path {
  stroke-width: 16;
}
#progress >>> .vue-progress-path .progress {
  stroke: rgba(255,255,255, 0.6);
}
#progress >>> .vue-progress-path .background {
  stroke: rgba(0, 0, 0, 0.4);
}
#inner {
  margin:auto;
  width:780px;
  background: rgba(0, 0, 0, 0.9);
  font-family: helvetica;
  font-size: 16px;
  color: #ccc;
  text-shadow: 1px 1px black;
  padding: 10px;
}

#title {
  color: #fff;
  font-size: 36px;
  text-align: center;
  margin: 0;
  font-weight: bold;
  font-family: impact;
  text-shadow:2px 2px rgba(0, 0, 0, 0.4);
}

.grid {
  display: flex;
  flex-wrap: wrap;
  align-content: flex-start;
}
.blurred {
  filter: blur(3px) grayscale(100%);
}
.item {
  padding: 10px;
  width: 225px;
  margin: 5px;
  height: 60px;
  background: rgba(255, 255, 255, 0.1);
}
.grid:not(.blurred) item:hover {
  background: rgba(255, 255, 255, 0.2);
}
.item .pic {
  float: left;
  width: 70px;
}
.item .pic img {
  border-radius: 3px;
  width: 60px;
  border:1px solid rgba(0,0,0, 0.1)
}
.item .details {
  float: left;
  width: 150px;
}
.item .details .name {
  font-weight: bold;
  font-size: 14px;
  color: #fff;
}
.item .details .info {
  font-size: 11px;
}
.item .details .info b {
  font-weight: bold;
  color: #fff;
  font-size: 12px;
}
.item .details .action {
  margin-top: 10px;
}
.blurred {
  filter: blur(3px) grayscale(100%);
}
button {
  font-weight: bold;
  border: 0px;
  padding: 3px;
  display: block;
  font-size: 14px;
  width: 100%;
  height: 22px;
}
button.build {
  background: #1770ff;
  color: #fff;
}
.grid:not(.blurred) button.build:hover:not([disabled]) {
  background: rgba(255, 255, 255, 0.2);
  cursor: pointer;
  background: #3684ff;
}
button:disabled,
button[disabled] {
  background: #444;
  color: #666666;
}
</style>
