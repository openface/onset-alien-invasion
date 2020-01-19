function LoadOnlinePlayers(players) {
  $('#online table > tbody').empty();
  jQuery.each(players, function (i, p) {
    $('#online table tbody').append(`<tr>
      <td>${p.name}</td>
      <td>${p.kills}</td>
      <td>${p.deaths}</td>
      <td>${SecondsToTime(p.joined)}</td>
      <td>${p.ping}ms</td>
    </tr>`);
  });
}

function LoadHighscores(highscores) {

}

function SecondsToTime(d) {
  d = Number(d);
  var h = Math.floor(d / 3600);
  var m = Math.floor(d % 3600 / 60);
  var s = Math.floor(d % 3600 % 60);

  var hDisplay = h > 0 ? h + (h == 1 ? " hr, " : " hrs, ") : "";
  var mDisplay = m > 0 ? m + (m == 1 ? " min, " : " mins, ") : "";
  var sDisplay = s > 0 ? s + (s == 1 ? " sec" : " secs") : "";
  return hDisplay + mDisplay + sDisplay; 
}
