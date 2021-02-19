<template>
    <div id="hud">
        <div id="banner" v-if="banner">
            <span class="message">{{ banner }}</span>
        </div>
        <div id="boss-health" v-if="boss_health">
            <div class="health-bar" :style="{ width: boss_health + '%' }"></div>
        </div>
        <div id="interaction-message" v-if="interaction_message && !show_spinner">
            <span class="key">E</span><br />
            {{ interaction_message }}
        </div>
        <div id="progress" v-if="show_spinner">
            <loading-progress :indeterminate="true" size="40" rotate fillDuration="3" rotationDuration="4" />
        </div>
    </div>
</template>

<script>
export default {
    name: "Hud",
    data() {
        return {
            banner: null,
            boss_health: null,
            interaction_message: null,
            show_spinner: false,
        };
    },
    methods: {
        ShowMessage: function(message) {
            this.$toasted.show(message, {
                className: "toast-message",
                position: "bottom-right",
                duration: 5000,
            });
        },
        ShowBanner: function(banner) {
            this.banner = banner;

            var that = this;
            setTimeout(function() {
                that.banner = null;
            }, 5000);
        },
        SetBossHealth: function(percentage) {
            this.boss_health = percentage;
        },
        ShowInteractionMessage: function(message) {
            this.interaction_message = message;
        },
        HideInteractionMessage: function() {
            this.interaction_message = null;
        },
        ShowSpinner: function(ms) {
            this.show_spinner = true;
            setTimeout(() => (this.show_spinner = false), ms);
        },
    },
    mounted() {
        this.EventBus.$on("ShowMessage", this.ShowMessage);
        this.EventBus.$on("ShowBanner", this.ShowBanner);
        this.EventBus.$on("SetBossHealth", this.SetBossHealth);
        this.EventBus.$on("ShowInteractionMessage", this.ShowInteractionMessage);
        this.EventBus.$on("HideInteractionMessage", this.HideInteractionMessage);
        this.EventBus.$on("ShowSpinner", this.ShowSpinner);

        if (!this.InGame) {
            this.EventBus.$emit("ShowMessage", "You have found an important piece! Take this to the satellite!");
            this.EventBus.$emit("ShowBanner", "Welcome to the invasion!");

            this.EventBus.$emit("ShowInteractionMessage", "Search");
            setTimeout(() => this.EventBus.$emit("HideInteractionMessage"), 1000);

            this.EventBus.$emit("ShowSpinner", 5000);
            setTimeout(() => this.EventBus.$emit("ShowSpinner", 2000), 7000);

            this.EventBus.$emit("SetBossHealth", 100);
            setTimeout(() => this.EventBus.$emit("SetBossHealth", 80), 1000);
            setTimeout(() => this.EventBus.$emit("SetBossHealth", 60), 3000);
            setTimeout(() => this.EventBus.$emit("SetBossHealth", 40), 5000);
            setTimeout(() => this.EventBus.$emit("SetBossHealth", 20), 8000);
            setTimeout(() => this.EventBus.$emit("SetBossHealth", 0), 10000);
        }
    },
};
</script>

<style>
#hud {
    height: 100%;
    position: relative;
}

/**
 * Banner
 */
#banner {
    width: 80%;
    position: fixed;
    top: 30%;
    left: 50%;
    transform: translate(-50%, -50%);
    text-align: center;
    text-shadow: 10px 10px rgba(0, 0, 0, 0.2);
    color: #fff;
    font-size: 150px;
    font-weight: bold;
    font-family: Impact;
    text-transform: uppercase;
}

/**
 * Interaction Message
 */

#interaction-message {
    text-transform: uppercase;
    position: fixed;
    top: 50%;
    left: 50%;
    transform: translate(-50%, -50%);
    color: rgba(255, 255, 255, 0.9);
    font-size: 14px;
    font-weight: bold;
    font-family: Helvetica;
    text-shadow: 3px 3px rgba(0, 0, 0, 0.1);
    width: 300px;
    text-align: center;
}

#interaction-message .key {
    color: #000;
    font-size: 18px;
    padding: 0 5px;
    background: rgba(255, 255, 255, 0.9);
    box-shadow: 3px 3px rgba(0, 0, 0, 0.1);
    border-radius: 20%;
    line-height: 1.5em;
}

/*
 * Toast messages
 */

.toast-message {
    background: rgba(0, 0, 0, 0.4) !important;
    text-shadow: 2px 2px rgba(0, 0, 0, 0.5);
    color: #fff;
    font-size: 22px;
    font-weight: normal;
    font-family: Helvetica !important;
}

/*
 * Boss health
 */
#boss-health {
    position: absolute;
    top: 50px;
    left: 0;
    right: 0;
    background: rgba(0, 0, 0, 0.5);
    height: 20px;
    width: 500px;
    margin: auto;
    border: solid 2px rgba(0, 0, 0, 0.1);
    border-radius: 15px;
}

#boss-health .health-bar {
    background-image: linear-gradient(#cc243d 35%, #740a15);
    width: inherit;
    height: 20px;
    position: relative;
    opacity: 0.9;
    border-radius: 20px;
    transition: all 3s cubic-bezier(0.4, 0, 0.2, 1);
}

#progress {
    position: fixed;
    top: 50%;
    left: 50%;
    transform: translate(-50%, -50%);
}
#progress >>> .vue-progress-path path {
    stroke-width: 16;
}
#progress >>> .vue-progress-path .progress {
    stroke: rgba(255, 255, 255, 0.6);
}
#progress >>> .vue-progress-path .background {
    stroke: rgba(0, 0, 0, 0.4);
}
</style>
