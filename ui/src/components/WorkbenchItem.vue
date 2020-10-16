<template>
    <div class="item">
      <div class="pic">
          <!--<img src="https://via.placeholder.com/100" />-->
          <img v-bind:src="'http://game/objects/' + item.modelid" />
      </div>
      <div class="details">
          <div class="name">{{ item.name }}</div>
          <div class="info">
              <span v-for="(qty, resource) in item.recipe" :key="qty">
                  <b>{{ qty }}</b> {{ resource }}
              </span>
          </div>
          <div class="action">
              <div v-if="isBuilding">
                  <div class="meter"><span><span class="progress"></span></span></div>
              </div>
              <div v-else-if="hasEnoughResources">
                  <button class="build" :disabled="isDisabled" @click="build">BUILD</button>
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
  name: 'WorkbenchItem',
  props: {
      player_resources: { 
        type: Object, 
        default() { 
          return { 
            metal: 0,
            wood: 0,
            computer_part: 0 
          } 
        } 
      },
      recipe: Object,
      item: String,
  },
  data() {
    return {
      building_item: false
    }
  },
  computed: {
      isBuilding() {
          return this.building_item === this.item;
      },
      isDisabled() {
          return this.building_item !== false;
      },
      numPlayerMetal() {
          return this.player_resources.metal > 0 ? this.player_resources.metal : 0;
      },
      numPlayerPlastic() {
          return this.player_resources.plastic > 0 ? this.player_resources.plastic : 0;
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
      }
  },
  methods: {
      build() {
          this.EventBus.$emit('building_item', this.item)
          this.CallEvent('BuildItem', this.item)

          setTimeout(() => this.EventBus.$emit('building_item', false), 15000);
      }
  },
  mounted() {
      this.EventBus.$on('building_item', (item) => {
          this.building_item = item
      })
  }
}
</script>

<style scoped>
.item {
    padding:10px;
    width:305px;
    border:1px solid #333;
    margin:10px;
}
.item .pic {
    float:left;
    width:90px;
}
.item .pic img {
    border-radius: 4px;
    width: 75px;
}
.item .details {
    float:left;
    width:200px;
}
.item .details .name {
    font-weight:bold;
    font-size:20px;
    color:#fff;
}
.item .details .info {
    font-size:12px;
}
.item .details .info b {
    font-weight:bold;
    color:#fff;
    font-size:16px;
}
.item .details .action {
    margin-top:10px;
}
button {
    font-weight:bold;
    border:0px;
    padding:3px;
    display:block;
    font-size:14px;
    width:100%;
    height:30px;
}
button.need_scrap {
    background: #333;
    color: #666666;
}
button.build {
    background:#1770ff;
    color:#fff;
}
button.build:hover:not([disabled]) {
    cursor: pointer;
    background:#3684ff;
}
button:disabled, button[disabled] {
    background: #333;
    color: #666666;
}

/* Progress Meter */
.meter { 
    height:30px;
    width:100%;
    display:block;
    position: relative;
    background: #1770ff;
    overflow: hidden;
}

.meter span {
    display: block;
    height: 100%;
}

.progress {
    background-color: #fff;
    animation: progressBar 15s ease-in-out;
    animation-fill-mode:both; 
}

@keyframes progressBar {
    0% { width: 0; }
    100% { width: 100%; }
}
</style>