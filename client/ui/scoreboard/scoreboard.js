//
Vue.filter('elapsed_time', function (value) {
  d = Number(value);
  var h = Math.floor(d / 3600);
  var m = Math.floor(d % 3600 / 60);
  var s = Math.floor(d % 3600 % 60);

  var hDisplay = h > 0 ? h + "h " : "";
  var mDisplay = m > 0 ? m + "m " : "";
  var sDisplay = s > 0 ? s + "s" : "";
  return hDisplay + mDisplay + sDisplay; 
})

new Vue({
  el: '#scoreboard',
  data() {
    return {
      players: []
    }
  },
  methods: {
    LoadOnlinePlayers: function (players) {
      this.players = players
    }
  },
  mounted() {
    EventBus.$on('LoadOnlinePlayers', this.LoadOnlinePlayers);
  }
});

// dev seeding
(function () {
  if (typeof indev !== 'undefined') {
    EmitEvent('LoadOnlinePlayers', [
      {
        name: "foobar",
        player_kills: 0,
        alien_kills: 0,
        boss_kills: 1,
        parts_collected: 2,
        loot_collected: 0,
        deaths: 0,
        joined: 82398,
        ping: 1
      }
    ]);
  }
})();
