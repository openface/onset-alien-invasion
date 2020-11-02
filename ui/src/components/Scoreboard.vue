<template>
  <div id="container">
    <div id="inner">
      <div id="title">PLAYERS ONLINE</div>
      <table>
        <thead>
          <tr>
            <th>NAME</th>
            <th>KILLS</th>
            <th>COLLECTED</th>
            <th>DEATHS</th>
            <th>PLAYTIME</th>
            <th>PING</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="p in players" :key="p.name">
            <td>{{ p.name }}</td>
            <td class="stats">
              <span>{{ p.player_kills }}</span> players,
              <span>{{ p.alien_kills }}</span> aliens,
              <span>{{ p.boss_kills }}</span> motherships
            </td>
            <td class="stats">
              <span>{{ p.parts_collected }}</span> parts,
              <span>{{ p.loot_collected }}</span> lootboxes
            </td>
            <td>
              <span>{{ p.deaths }}</span>
            </td>
            <td>{{ p.joined | elapsed_time }}</td>
            <td>{{ p.ping }}ms</td>
          </tr>
        </tbody>
      </table>
    </div>
  </div>
</template>

<script>
export default {
  name: "Hud",
  data() {
    return {
      players: [],
    };
  },
  filters: {
    elapsed_time: function(value) {
      let d = Number(value);
      let h = Math.floor(d / 3600);
      let m = Math.floor((d % 3600) / 60);
      let s = Math.floor((d % 3600) % 60);

      let hDisplay = h > 0 ? h + "h " : "";
      let mDisplay = m > 0 ? m + "m " : "";
      let sDisplay = s > 0 ? s + "s" : "";
      return hDisplay + mDisplay + sDisplay;
    }
  },
  methods: {
    LoadOnlinePlayers: function(players) {
      this.players = players;
    },
  },
  mounted() {
    this.EventBus.$on("LoadOnlinePlayers", this.LoadOnlinePlayers);

    if (!this.InGame) {
      this.EventBus.$emit("LoadOnlinePlayers", [
        {
          name: "foobar",
          player_kills: 0,
          alien_kills: 0,
          boss_kills: 1,
          parts_collected: 2,
          loot_collected: 0,
          deaths: 0,
          joined: 82398,
          ping: 1,
        },
      ]);
    }
  },
};
</script>

<style scoped>
#container {
  display: flex;
  align-items: center;
  justify-content: center;
  height: 80vh;
}

#inner {
  width: 65%;
  height: 580px;
  overflow-y: hidden;
  background: rgba(0, 0, 0, 0.9);
  border: solid 10px rgba(0, 0, 0, 0.2);
  font-family: helvetica;
  font-size: 16px;
  color: #fff;
  text-shadow: 3px black;
  padding: 20px;
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

table {
  width: 100%;
  border-spacing: 0;
  border-collapse: separate;
  color: #ccc;
}

table td {
  padding: 10px 5px;
  font-size: 16px;
}

table td.stats {
  font-size: 12px;
  color: #ddd;
}

table td span {
  font-weight: bold;
  font-size: 20px;
  color: #fff;
  vertical-align: middle;
}

table tr:nth-child(even) {
  background: #343434;
}

table thead tr th {
  text-align: left;
  background: #3684ff;
  text-transform: uppercase;
  font-weight: normal;
  font-size: 75%;
  text-shadow: 1px 1px #000;
  padding: 5px;
}

table thead tr td:first-child {
  width: 35%;
}
</style>
