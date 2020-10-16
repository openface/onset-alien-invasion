<template>
  <div id="hud">
    <div id="blood_overlay" v-if="show_blood"></div>
    <div id="banner" v-if="banner">
        <span class="message">{{ banner }}</span>
    </div>
    <div id="messages" v-if="message">
        <span class="message">{{ message }}</span>
    </div>
    <div id="boss-health" v-if="boss_health">
        <div class="health-bar" :style="{ width: boss_health + '%' }"></div>
    </div>
  </div>
</template>

<script>
export default {
  name: 'Hud',
  data() {
      return {
          show_blood: false,
          message: null,
          banner: null,
          boss_health: null,
      }
  },
  methods: {
      ShowBlood: function () {
          this.show_blood = true;

          var that = this;
          setTimeout(function () {
              that.show_blood = false;
          }, 3000);
      },
      ShowMessage: function (message) {
          this.message = message;

          var that = this;
          setTimeout(function () {
              that.message = null;
          }, 5000);
      },
      ShowBanner: function (banner) {
          this.banner = banner;

          var that = this;
          setTimeout(function () {
              that.banner = null;
          }, 5000);
      },
      SetBossHealth: function (percentage) {
          this.boss_health = percentage;
      }
  },
  mounted() {
      this.EventBus.$on('ShowBlood', this.ShowBlood)
      this.EventBus.$on('ShowMessage', this.ShowMessage)
      this.EventBus.$on('ShowBanner', this.ShowBanner)
      this.EventBus.$on('SetBossHealth', this.SetBossHealth)

      if (!this.InGame) {
          this.EventBus.$emit('ShowBlood');
          this.EventBus.$emit('ShowMessage', 'You have found an important piece! Take this to the satellite!');
          this.EventBus.$emit('ShowBanner', 'Welcome to the invasion!');

          this.EventBus.$emit('SetBossHealth', 100);
          setTimeout(() => this.EventBus.$emit('SetBossHealth', 80), 1000);
          setTimeout(() => this.EventBus.$emit('SetBossHealth', 60), 3000);
          setTimeout(() => this.EventBus.$emit('SetBossHealth', 40), 5000);
          setTimeout(() => this.EventBus.$emit('SetBossHealth', 20), 8000);
          setTimeout(() => this.EventBus.$emit('SetBossHealth', 0), 10000);
      }
  }
}
</script>

<style scoped>
/**
 * Banner
 */
#banner {
    display: flex;
    flex-direction: column;
    justify-content: center;
    align-items: center;
    height: 600px;
    text-align: center;
    text-shadow: 10px 10px rgba(0,0,0,0.2);
    color: #fff;
    font-size:150px;
    font-weight:bold;
    font-family: Impact;
    text-transform:uppercase;
}

/**
 * Toast-like message
 */
#messages {
    position:fixed;
    width:100%;
    bottom:30vh;
    text-align:center;
    z-index:10;
}
#messages .message {
    padding:10px 25px;
    text-shadow: 2px 2px rgba(0,0,0,0.5);
    background:rgba(0,0,0,0.4);
    color: #fff;
    font-size:22px;
    font-weight:normal;
    font-family: Helvetica;
    animation: fadeout 1s 4.5s;
    z-index:10;
}
@keyframes fadeout {
  from {opacity: 1; }
  to {opacity: 0; }
}

/*
 * Blood Splat
 */
#blood_overlay {
    background:url('../assets/images/blood_overlay.png') no-repeat center center fixed;
    background-size: cover;
    opacity: 0.5;
    width: 100%;
    height: 100%;
    top: 0;
    left: 0;
    position: fixed;
    animation: fadeSplat 3.5s;
    z-index:-100;
}
@keyframes fadeSplat {
    0% {opacity: 0.5;}
    100% {opacity: 0;}
}

/*
 * Boss health
 */
#boss-health {
    position:absolute;
    top:50px;
    left:0;
    right:0;
    background: rgba(0,0,0,0.5);
    height: 20px;
    width: 500px;
    margin: auto;
    border: solid 2px rgba(0,0,0,0.1);
    border-radius: 15px;
}

#boss-health .health-bar {
    background-image: linear-gradient(#cc243d 35%, #740a15);
    width: inherit;
    height: 20px;
    position: relative;
    opacity: 0.9;
    border-radius: 20px;
    transition: all 3s cubic-bezier(0.4, 0.0, 0.2, 1);
}
</style>