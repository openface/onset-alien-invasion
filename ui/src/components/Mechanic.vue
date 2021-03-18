<template>
    <div id="container">
        <div id="inner">
            <div id="title">AUTO MECHANIC</div>
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
                        <td>1</td>
                        <td>{{ damage['1'] }}</td>
                    </tr>
                    <tr>
                        <td>2</td>
                        <td>{{ damage['2'] }}</td>
                    </tr>
                    <tr>
                        <td>3</td>
                        <td>{{ damage['3'] }}</td>
                    </tr>
                    <tr>
                        <td>4</td>
                        <td>{{ damage['4'] }}</td>
                    </tr>
                    <tr>
                        <td>5</td>
                        <td>{{ damage['5'] }}</td>
                    </tr>
                    <tr>
                        <td>6</td>
                        <td>{{ damage['6'] }}</td>
                    </tr>
                    <tr>
                        <td>7</td>
                        <td>{{ damage['7'] }}</td>
                    </tr>
                    <tr>
                        <td>8</td>
                        <td>{{ damage['8'] }}</td>
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
    },
    mounted() {
        this.EventBus.$on("LoadVehicleData", this.LoadVehicleData);

        if (!this.InGame) {
            this.EventBus.$emit("LoadVehicleData", {
                modelid: 23,
                model_name: "Whatev",
                health: 100,
                damage: {
                    1: 0.0,
                    2: 0.0,
                    3: 0.0,
                    4: 0.0,
                    5: 0.0,
                    6: 0.0,
                    7: 0.0,
                    8: 0.0,
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
