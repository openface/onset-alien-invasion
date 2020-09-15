function LoadWorkbenchData(items) {
    $('table > tbody').empty();
    jQuery.each(items, function (i, item) {
        $('table tbody').append(`<tr>
      <td class="pic"><img src="http://game/objects/${item.modelid}" /></td>
      <td>
        <div class="name">${item.name}</div>
        <div class="info">${item.scrap_needed} scrap needed</div>
      </td>
      <td class="action" id="action_${item.key}"><button class="build" onClick="SelectItem('${item.key}');">BUILD</button></td>
    </tr>`);
    });
}

function SelectItem(key) {
    CallEvent('SelectBuildItem', key);
    $('td.action > button').prop('disabled', true);
    $('#action_' + key).html(`
        <div class="meter">
            <span><span class="progress"></span></span>
        </div>
    `);
    setTimeout(function () {
        $('td.action > button').prop('disabled', false);
        $('#action_'+key).html(`
            <button class="build" onClick="SelectItem('${key}');">BUILD</button>
        `);
    }, 15000);
}

$(function () {
    LoadWorkbenchData(
        [
            {
                "name": "Foobar",
                "key": "foobar",
                "scrap_needed": 15,
                "modelid": 843
            },
            {
                "name": "Foobar2",
                "key": "foobar2",
                "scrap_needed": 15,
                "modelid": 843
            }

        ]
    )
});