function LoadOnlinePlayers(players) {
  $('table > tbody').empty();
  jQuery.each(players, function (i, p) {
    $('table tbody').append(`<tr>
      <td>${p.name}</td>
      <td class="stats">
        <span>${p.player_kills}</span> players,
        <span>${p.alien_kills}</span> aliens,
        <span>${p.boss_kills}</span> motherships
      </td>
      <td class="stats">
        <span>${p.parts_collected}</span> parts,
        <span>${p.loot_collected}</span> lootboxes
      </td>
      <td>${p.deaths}</td>
      <td>${SecondsToTime(p.joined)}</td>
      <td>${p.ping}ms</td>
    </tr>`);
  });
}

function SecondsToTime(d) {
  d = Number(d);
  var h = Math.floor(d / 3600);
  var m = Math.floor(d % 3600 / 60);
  var s = Math.floor(d % 3600 % 60);

  var hDisplay = h > 0 ? h + ":" : "";
  var mDisplay = m > 0 ? m + ":" : "";
  var sDisplay = s > 0 ? s : "";
  return hDisplay + mDisplay + sDisplay; 
}

$(function () {
  if (indev) {
    LoadOnlinePlayers(
      [
        {
          "name": "foobar",
          "player_kills": 0,
          "alien_kills": 0,
          "boss_kills": 1,
          "parts_collected": 2,
          "loot_collected": 0,
          "deaths": 0,
          "joined": 82398,
          "ping": 1
        }
      ]
    )
  }
});
