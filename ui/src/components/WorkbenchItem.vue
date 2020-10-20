<template>
  <div class="item" :class="isBusy ? 'blurred' : ''">
    <div class="pic">
      <img v-if="!InGame" src="http://placekitten.com/100/100" />
      <img v-if="InGame" :src="'http://game/objects/' + item.modelid" />
    </div>
    <div class="details">
      <div class="name">{{ item.name }}</div>
      <div class="info">
        <span v-for="(qty, resource) in recipe" :key="resource">
          <b>{{ qty }}</b> {{ resource }}
        </span>
      </div>
      <div class="action">
        <div v-if="isBuilding && !isBusy">
          <div class="meter">
            <span><span class="progress"></span></span>
          </div>
        </div>
        <div v-else-if="hasEnoughResources">
          <button class="build" @click="Build()">BUILD NOW</button>
        </div>
        <div v-else>
          <button class="need_scrap" disabled="true">NEED SCRAP</button>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  name: "WorkbenchItem",
  props: {
    player_resources: {},
    recipe: {},
    item: {},
  },
  data() {
    return {
      building_item: false,
    };
  },
  computed: {
    isBuilding() {
      return this.building_item !== false;
    },
    isBusy() {
      return this.isBuilding && this.building_item !== this.item.item;
    },
    numPlayerMetal() {
      return this.player_resources.metal > 0 ? this.player_resources.metal : 0;
    },
    numPlayerPlastic() {
      return this.player_resources.plastic > 0
        ? this.player_resources.plastic
        : 0;
    },
    numPlayerWood() {
      return this.player_resources.wood > 0 ? this.player_resources.wood : 0;
    },
    hasEnoughResources() {
      if (Object.keys(this.player_resources).length == 0) {
        // No resources at all
        return false;
      }
      for (const resource in this.recipe) {
        //console.log(`*** ${resource}: ${this.recipe[resource]}`);
        if (this.player_resources[resource]) {
          //console.log(`need ${this.recipe[resource]}, have: ${this.player_resources[resource]}`);
          if (this.player_resources[resource] < this.recipe[resource]) {
            // Not enough of that resource
            return false;
          }
        } else {
          // No resource
          return false;
        }
      }
      return true;
    },
  },
  methods: {
    Build() {
      // Use the bus to let siblings know what we're building
      this.EventBus.$emit("building_item", this.item.item)
      // Send building item back to client
      this.CallEvent("BuildItem", this.building_item);

      setTimeout(() => this.EventBus.$emit("building_item", false), 15000);
    }
  },
  mounted() {
    this.EventBus.$on("building_item", (item) => {
      this.building_item = item;
    });
  },
};
</script>

<style scoped>
.item {
  padding: 10px;
  width: 225px;
  margin: 10px;
  height: 75px;
  background: rgba(255, 255, 255, 0.1);
}
.item .pic {
  float: left;
  width: 90px;
}
.item .pic img {
  border-radius: 3px;
  width: 75px;
  border:1px solid rgba(0,0,0, 0.1)
}
.item .details {
  float: left;
  width: 100px;
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
  height: 25px;
  border: 1px solid #111;
}
button.build {
  background: #1770ff;
  color: #fff;
}
button.build:hover:not([disabled]) {
  cursor: pointer;
  background: #3684ff;
}
button:disabled,
button[disabled] {
  background: #444;
  color: #666666;
}

/* Progress Meter */
.meter {
  height: 25px;
  width: 100%;
  display: block;
  position: relative;
  background: #1770ff;
  overflow: hidden;
}

.meter span {
  display: block;
  height: 100%;
}

.progress {
  background-color: #669cf3;
  animation: progressBar 15s ease-in-out;
  animation-fill-mode: both;
}

@keyframes progressBar {
  0% {
    width: 0;
  }
  100% {
    width: 100%;
  }
}
</style>
