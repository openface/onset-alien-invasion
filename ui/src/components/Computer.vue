<template>
  <div id="container">
    <div id="inner" v-if="screen">
      %DECW-W-NODEVICE, No graphics device found on this system<br />
      %SET-I-INTSET, login interactive limit = 64<br /><br />
      %%%%%%%%% OPCOM 13-SEPT-2020 10:14:18.10 %%%%%%%%%<br />
      Message from user DECNET<br /><br />
      *********************** IMPORTANT EMERGENCY INFORMATION
      **************************<br />
      ****************************** AUTHORIZED USE ONLY
      *******************************
      <br />
      <div id="content">
        <div v-if="screen == 'garage'">
          <p>READ THESE INSTRUCTIONS CAREFULLY!</p>

          <p>
            The surrounding area has been invaded by alien lifeform. If you are
            reading this message, you may be the last of the remaining human
            survivors. Follow these rules to stay alive:
          </p>

          <ul>
            <li>
              This house and it's perimeter is a SAFE ZONE from alien attack.
            </li>

            <li>
              The mainland has been infected with radiation. DO NOT ENTER THE
              OCEAN!
            </li>

            <li>
              THERE ARE ALIENS ON THIS ISLAND! If you are being chased, RUN TO
              SAFETY UNLESS YOU ARE ARMED!
            </li>

            <li>
              WATCH FOR SUPPLY DROPS! They contain armor, health, and weapons.
              You will see flares indicating where they drop. You can also craft
              supplies from scrap parts found on the island using the workbench
              in the garage.
            </li>

            <li>
              The mothership is on it's way to this island! YOUR MISSION IS TO
              DESTROY IT!. You will need supplies before you can fight back!
              If you are unable to fight, running away is your best chance for survival.
            </li>

            <li>
              FIND THE MISSING SATELLITE PARTS! Scavenge the area to find
              computer parts and bring them back to the satellite terminal. Once
              the satellite is operational, it will draw the mothership in for
              an attack.
            </li>
          </ul>

          <p>Good luck</p>
        </div>

        <div v-else-if="screen == 'satellite'">
          <div v-if="percentage == 100">
            <p><b>SATELLITE IS FULLY OPERATIONAL!</b></p>

            <p>
              Commencing satellite transmission... OK<br />
              Waiting for signal acknowledgement... OK
            </p>

            <p>Signal received. Standby for response.</p>
          </div>
          <div v-else>
            <p>Installing new component...</p>

            <p class="blinking">
              SATELLITE COMMUNICATIONS ARE NOW
              <b>{{ percentage }}%</b> OPERATIONAL.
            </p>

            <p><b>The chance of being attacked by aliens has INCREASED!</b></p>

            <p>
              Continue collecting satellite parts to initiate signal
              transmission from this satellite. Once enough parts are acquired,
              the satellite will be operational.
            </p>
          </div>
        </div>

        <div v-else-if="screen == 'satellite-transmission'">
          <p>
            Commencing satellite transmission... OK<br />
            Waiting for signal acknowledgement... OK
          </p>

          <p>Signal received. Standby for response...</p>
        </div>
      </div>
      <p>NO CARRIER</p>
    </div>
  </div>
</template>

<script>
export default {
  name: "Computer",
  data() {
    return {
      screen: null, // garage, satellite
      percentage: null,
    };
  },
  methods: {
    SetComputerScreen: function(screen, percentage) {
      this.screen = screen;
      this.percentage = percentage;
    },
  },
  mounted() {
    this.EventBus.$on("SetComputerScreen", this.SetComputerScreen);

    if (!this.inGame) {
      //this.EventBus.$emit("SetComputerScreen", "satellite", 20);
      this.EventBus.$emit('SetComputerScreen', 'garage');
    }
  },
};
</script>

<style scoped>
#container {
  display: flex;
  justify-content: center;
  flex-direction: column;
  align-items: center;
  height: 100%;
}

#inner {
  width: 800px;
  background-color: black;
  background-image: radial-gradient(rgba(0, 150, 0, 0.75), black 120%);
  border-radius: 25px;
  border: 2px solid #73ad21;
  box-shadow: 5px 5px 15px #000;
  color: white;
  font: 1.1rem Inconsolata, monospace;
  text-shadow: 0 0 5px #c8c8c8;
  padding: 20px 20px;
  margin-top: 50px;
}

.blinking {
  animation: blinkingText 1.2s infinite;
}

@keyframes blinkingText {
  0% {
    color: #fff;
  }
  49% {
    color: #fff;
  }
  60% {
    color: transparent;
  }
  99% {
    color: transparent;
  }
  100% {
    color: #fff;
  }
}
</style>
