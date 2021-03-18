<template>
    <div id="container">
        <div id="inner">
            <div id="title">AUTO MECHANIC <a class="close" @click="CloseMechanic()">X</a></div>
            <div class="content">
                <table>
                    <th colspan="2">Vehicle Stats</th>
                    <tr>
                        <td>Model Name:</td>
                        <td>{{ model_name }}</td>
                    </tr>
                    <tr>
                        <td>Overall Health:</td>
                        <td>{{ health }}</td>
                    </tr>
                </table>
            </div>
            <div class="content">
                <table>
                    <th colspan="2">Damage Inspection</th>
                    <tr>
                        <td>Right Front Wheel</td>
                        <td>{{ damage['one'] }}</td>
                    </tr>
                    <tr>
                        <td>Front Body</td>
                        <td>{{ damage['two'] }}</td>
                    </tr>
                    <tr>
                        <td>Rear Body</td>
                        <td>{{ damage['three'] }}</td>
                    </tr>
                    <tr>
                        <td>Rear Body</td>
                        <td>{{ damage['four'] }}</td>
                    </tr>
                    <tr>
                        <td>Left Body</td>
                        <td>{{ damage['five'] }}</td>
                    </tr>
                    <tr>
                        <td>Left Body</td>
                        <td>{{ damage['six'] }}</td>
                    </tr>
                    <tr>
                        <td>Right Body</td>
                        <td>{{ damage['seven'] }}</td>
                    </tr>
                    <tr>
                        <td>Rear Right Wheel</td>
                        <td>{{ damage['eight'] }}</td>
                    </tr>
                </table>
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
            damage: {}
        };
    },
    methods: {
        LoadVehicleData: function(data) {
            this.modelid = data.modelid,
            this.model_name = data.model_name,
            this.health = data.health,
            this.damage = data.damage
        },
        CloseMechanic: function() {
            this.CallEvent("CloseMechanic")
        }
    },
    mounted() {
        this.EventBus.$on("LoadVehicleData", this.LoadVehicleData);

        if (!this.InGame) {
            this.EventBus.$emit("LoadVehicleData", {
                modelid: 23,
                model_name: "Whatev",
                health: 100,
                damage: {
                    one: 0.0,
                    two: 0.0,
                    three: 0.0,
                    four: 0.0,
                    five: 0.0,
                    six: 0.0,
                    seven: 0.0,
                    eight: 0.0,
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
    width: 510px;
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
    color:#fff;
    font-size:18px;
    font-family:arial;
    float:right;
    background:#1770ff;
    border-radius:2px;
    margin-right:10px;
    padding:0 5px;
}
a.close:hover {
    cursor: pointer;
}
.content {
    color:#fff;
    text-shadow: 2px 2px rgba(0, 0, 0, 0.2);
    background: rgba(255,255,255, 0.1);
    margin:10px;
    padding:10px;
}
table th {
    text-transform: uppercase;
    text-align:left;
}
</style>
