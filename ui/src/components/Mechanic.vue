<template>
    <div id="container">
        <div id="inner">
            <div id="title">AUTO MECHANIC <a class="close" @click="CloseMechanic()">X</a></div>
            <div class="content">
                <div class="stats">
                    Model Name:<br />
                    <span>{{ model_name }}</span>
                </div>
                <div class="health">
                    Overall Health:<br />
                    <span>{{ health }}%</span>
                </div>
            </div>
            <br style="clear:both" />
            <div class="content" v-if="damage">
                <div id="car">
                    <img :src="require('@/assets/images/mechanic/car.png')" alt="" width="200" />
                    <div class="dmg" id="body_wheel_front_right">{{ body_wheel_front_right }}</div>
                    <div class="dmg" id="body_wheel_front_left">{{ body_wheel_front_left }}</div>
                    <div class="dmg" id="body_wheel_rear_left">{{ body_wheel_rear_left }}</div>
                    <div class="dmg" id="body_wheel_rear_right">{{ body_wheel_rear_right }}</div>
                    <div class="dmg" id="body_door_front_right">{{ body_door_front_right }}</div>
                    <div class="dmg" id="body_door_front_left">{{ body_door_front_left }}</div>
                    <div class="dmg" id="body_door_rear_right">{{ body_door_rear_right }}</div>
                    <div class="dmg" id="body_door_rear_left">{{ body_door_rear_left }}</div>
                </div>
            </div>
        </div>
    </div>
</template>

<script>
export default {
    name: "Mechanic",
    data() {
        return {
            modelid: null,
            model_name: null,
            health: null,
            damage: {},
        };
    },
    computed: {
        body_wheel_front_right: function() {
            return this.CalcPerc(this.damage['one'])
        },
        body_wheel_front_left: function() {
            return this.CalcPerc(this.damage['two'])
        },
        body_wheel_rear_left: function() {
            return this.CalcPerc(this.damage['three'])
        },
        body_wheel_rear_right: function() {
            return this.CalcPerc(this.damage['four'])
        },
        body_door_front_right: function() {
            return this.CalcPerc(this.damage['five'])
        },
        body_door_front_left: function() {
            return this.CalcPerc(this.damage['six'])
        },
        body_door_rear_right: function() {
            return this.CalcPerc(this.damage['seven'])
        },
        body_door_rear_left: function() {
            return this.CalcPerc(this.damage['eight'])
        }
    },
    methods: {
        CalcPerc: function(dmg) {
            if (typeof(dmg) == 'undefined') {
                return "N/A";
            }
            window.console.log(dmg);
            return (100 - (dmg * 100)).toFixed(2) + "%";
        },
        LoadVehicleData: function(data) {
            this.modelid = data.modelid
            this.model_name = data.model_name
            this.health = data.health
            this.damage = data.damage
        },
        CloseMechanic: function() {
            this.CallEvent("CloseMechanic");
        },
    },
    mounted() {
        this.EventBus.$on("LoadVehicleData", this.LoadVehicleData);

        if (!this.InGame) {
            this.EventBus.$emit("LoadVehicleData", {
                modelid: 23,
                model_name: "Whatev",
                health: 100,
                damage: {
                    two:0.079999998211861,
                    eight:0,
                    seven:0,
                    one:0.019999999552965,
                    three:0.019999999552965,
                    five:0.03999999910593,
                    six:0.019999999552965,
                    four:0
                }
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
    margin: auto;
    width: 600px;
    background: rgba(0, 0, 0, 0.9);
    font-family: helvetica;
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
    text-shadow: 2px 2px rgba(0, 0, 0, 0.4);
}
a.close {
    color: #fff;
    font-size: 18px;
    font-family: arial;
    float: right;
    background: #1770ff;
    border-radius: 2px;
    margin-right: 10px;
    padding: 0 5px;
}
a.close:hover {
    cursor: pointer;
}
.content {
    color: #fff;
    text-shadow: 2px 2px rgba(0, 0, 0, 0.2);
    background: rgba(255, 255, 255, 0.1);
    margin: 10px;
    padding: 10px;
    min-height:60px;
    font-size:14px;
    color:#999;
}
.content .stats {
    float:left;
}
.content .health {
    float:right;
}
.content span {
    font-size:40px;
    font-weight:bold;
    color:#fff;
}
table th {
    text-transform: uppercase;
    text-align: left;
}
#car {
    position: relative;
    text-align:center;
}
.dmg {
    position:absolute;
    background:red;
    color:#fff;
    font-size:14px;
    font-weight:bold;
    padding:2px 10px;
    text-shadow: 2px 2px rgba(0, 0, 0, 0.2);
}
#body_wheel_front_right {
    top:0;
    right:100px;
}
#body_wheel_front_left {
    top:0;
    left:100px;
}
#body_wheel_rear_left {
    bottom:0;
    left:100px;
}
#body_wheel_rear_right {
    bottom:0;
    right:100px;
}
#body_door_front_right {
    top:80px;
    right:100px;
}
#body_door_front_left {
    top:80px;
    left:100px;
}
#body_door_rear_right {
    bottom:80px;
    right:100px;
}
#body_door_rear_left {
    bottom:80px;
    left:100px;
}
</style>
