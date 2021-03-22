<template>
    <div id="container">
        <div id="inner" :class="IsBusy() ? 'blurred' : ''">
            <div id="title">GARAGE <a class="close" @click="CloseMechanic()">X</a></div>
            <div class="content">
                <div class="stats">
                    Model Name<br />
                    <span>{{ model_name }}</span>
                </div>
                <div class="license">
                    License<br />
                    <span>{{ license }}</span>
                </div>
                <br style="clear:both" />
            </div>
            <div class="section">
                <div class="heading">
                    <div class="subtitle">
                        Health <b>{{ health }}%</b>
                    </div>
                    <div class="action">
                        <button id="repair" @click="RepairVehicle()" :disabled="IsPristine() || IsBusy()">Repair Vehicle</button>
                    </div>
                    <br style="clear:both" />
                </div>
                <div id="car">
                    <img :src="require('@/assets/images/mechanic/car.png')" alt="" width="200" />
                    <div :class="{ dmg: true, good: IsGood(body_wheel_front_right) }" id="body_wheel_front_right">{{ body_wheel_front_right }}%</div>
                    <div :class="{ dmg: true, good: IsGood(body_wheel_front_left) }" id="body_wheel_front_left">{{ body_wheel_front_left }}%</div>
                    <div :class="{ dmg: true, good: IsGood(body_wheel_rear_left) }" id="body_wheel_rear_left">{{ body_wheel_rear_left }}%</div>
                    <div :class="{ dmg: true, good: IsGood(body_wheel_rear_right) }" id="body_wheel_rear_right">{{ body_wheel_rear_right }}%</div>
                    <div :class="{ dmg: true, good: IsGood(body_door_front_right) }" id="body_door_front_right">{{ body_door_front_right }}%</div>
                    <div :class="{ dmg: true, good: IsGood(body_door_front_left) }" id="body_door_front_left">{{ body_door_front_left }}%</div>
                    <div :class="{ dmg: true, good: IsGood(body_door_rear_right) }" id="body_door_rear_right">{{ body_door_rear_right }}%</div>
                    <div :class="{ dmg: true, good: IsGood(body_door_rear_left) }" id="body_door_rear_left">{{ body_door_rear_left }}%</div>
                </div>
            </div>
            <br />
            <div class="section">
                <div class="heading">
                    <div class="subtitle">
                        Vehicle Color
                    </div>
                    <div class="action">
                        <button id="paint" @click="PaintVehicle()">Paint Vehicle</button>
                    </div>
                    <br style="clear:both" />
                </div>
                <compact-picker v-model="color" style="width:100%;" @input="PreviewColor" />
            </div>
        </div>
    </div>
</template>

<script>
import { Compact } from "vue-color";

export default {
    name: "Mechanic",
    data() {
        return {
            modelid: null,
            model_name: null,
            health: null,
            license: null,
            damage: {},
            color: {},
            is_busy: false,
        };
    },
    components: {
        "compact-picker": Compact,
    },
    computed: {
        body_wheel_front_right: function() {
            return this.CalcPerc(this.damage["one"]);
        },
        body_wheel_front_left: function() {
            return this.CalcPerc(this.damage["two"]);
        },
        body_wheel_rear_left: function() {
            return this.CalcPerc(this.damage["three"]);
        },
        body_wheel_rear_right: function() {
            return this.CalcPerc(this.damage["four"]);
        },
        body_door_front_right: function() {
            return this.CalcPerc(this.damage["five"]);
        },
        body_door_front_left: function() {
            return this.CalcPerc(this.damage["six"]);
        },
        body_door_rear_right: function() {
            return this.CalcPerc(this.damage["seven"]);
        },
        body_door_rear_left: function() {
            return this.CalcPerc(this.damage["eight"]);
        },
    },
    methods: {
        IsBusy() {
            return this.is_busy;
        },
        IsGood: function(amt) {
            if (amt == 100.0) {
                return true;
            } else {
                return false;
            }
        },
        IsPristine: function() {
            if (this.health == 100) {
                return true;
            } else {
                return false;
            }
        },
        CalcPerc: function(dmg) {
            if (typeof dmg == "undefined") {
                return "N/A";
            }
            window.console.log(dmg);
            return (100 - dmg * 100).toFixed(2);
        },
        LoadVehicleData: function(data) {
            this.is_busy = false;
            this.modelid = data.modelid;
            this.model_name = data.model_name;
            this.health = data.health;
            this.license = data.license;
            this.damage = data.damage;
            this.color = data.color;
        },
        CloseMechanic: function() {
            this.CallEvent("CloseMechanic");
        },
        RepairVehicle: function() {
            this.is_busy = true;
            this.CallEvent("RepairVehicle");
        },
        PaintVehicle: function() {
            this.CallEvent("PaintVehicle", this.color.rgba["r"], this.color.rgba["g"], this.color.rgba["b"]);
        },
        PreviewColor: function() {
            this.CallEvent("PreviewColor", this.color.rgba["r"], this.color.rgba["g"], this.color.rgba["b"]);
        },
    },
    mounted() {
        this.EventBus.$on("LoadVehicleData", this.LoadVehicleData);

        if (!this.InGame) {
            this.EventBus.$emit("LoadVehicleData", {
                modelid: 23,
                model_name: "Whatev",
                health: 90,
                license: "ABC-123",
                damage: {
                    two: 0.079999998211861,
                    eight: 0,
                    seven: 0,
                    one: 0.019999999552965,
                    three: 0.019999999552965,
                    five: 0.03999999910593,
                    six: 0.019999999552965,
                    four: 0,
                },
                color: { r: 255, g: 255, b: 255 },
            });
        }
    },
};
</script>

<style scoped>
#container {
    display: flex;
    height: 75vh;
}
#inner {
    position: fixed;
    right: 5%;
    top: 20%;
    width: 405px;
    background: rgba(0, 0, 0, 0.9);
    font-family: helvetica;
    text-shadow: 1px 1px black;
    padding: 5px;
}
#title {
    color: #fff;
    font-size: 32px;
    text-align: center;
    margin: 0;
    font-weight: bold;
    font-family: impact;
    text-shadow: 2px 2px rgba(0, 0, 0, 0.4);
}
a.close {
    color: #fff;
    font-size: 22px;
    font-family: arial;
    float: right;
    background: #1770ff;
    border-radius: 2px;
    margin-top: 5px;
    margin-right: 10px;
    padding: 0 8px;
}
a.close:hover {
    cursor: pointer;
}
.content {
    color: #fff;
    padding: 10px;
    font-size: 12px;
    color: #999;
}
.content .stats {
    float: left;
}
.content .license {
    float: right;
}
.content span {
    font-size: 24px;
    font-weight: bold;
    color: #fff;
}
.section {
    padding: 10px;
    margin: 10px;
    text-shadow: 2px 2px rgba(0, 0, 0, 0.9);
    background: rgba(255, 255, 255, 0.1);
}
.section .heading {
    margin-bottom: 20px;
}
.section .subtitle {
    color: #fff;
    float: left;
    font-size: 26px;
    line-height: 1.5em;
}
.section .action {
    text-align: right;
    float: right;
}
table th {
    text-transform: uppercase;
    text-align: left;
}
#car {
    position: relative;
    text-align: center;
}
.dmg {
    position: absolute;
    background: red;
    color: #fff;
    font-size: 14px;
    font-weight: bold;
    padding: 2px 10px;
    text-shadow: 2px 2px rgba(0, 0, 0, 0.2);
}
.dmg.good {
    background: green;
}
#body_wheel_front_right {
    top: 0;
    right: 0;
}
#body_wheel_front_left {
    top: 0;
    left: 0;
}
#body_wheel_rear_left {
    bottom: 0;
    left: 0;
}
#body_wheel_rear_right {
    bottom: 0;
    right: 0;
}
#body_door_front_right {
    top: 80px;
    right: 0;
}
#body_door_front_left {
    top: 80px;
    left: 0;
}
#body_door_rear_right {
    bottom: 80px;
    right: 0;
}
#body_door_rear_left {
    bottom: 80px;
    left: 0;
}
button {
    font-weight: bold;
    border: 0px;
    padding: 10px;
    font-size: 14px;
    background: #1770ff;
    color: #fff;
    border-radius: 3px;
    border: 1px outset #1770ff;
}
button:hover:not([disabled]) {
    cursor: pointer;
    background: #3684ff;
    border: 1px outset #1770ff;
}
button:disabled,
button[disabled] {
    background: #999;
    color: #666666;
    border: 1px inset #666666;
}
</style>
