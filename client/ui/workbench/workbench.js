function LoadWorkbenchData(items) {
    $('table > tbody').empty();
    jQuery.each(items, function(key, item) {
        $('table tbody').append(`
            <tr>
                <td class="pic"><img src="http://game/objects/${item.modelid}" /></td>
                <td>
                    <div class="name">${item.name}</div>
                    <div class="info">${item.scrap_needed} scrap needed</div>
                </td>
                <td class="action" id="action_${key}">
                    <button class="build" onClick="SelectItem('${key}');">BUILD</button>
                </td>
            </tr>
        `);
    });
}

function SelectItem(key) {
    CallEvent('SelectBuildItem', key);
}

function StartBuild(key) {
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

function NotEnoughScrap(key) {
    $('#action_' + key).html(`
        <button class="need_scrap" disabled="true">NEED SCRAP</button>
    `);
}

$(function () {
    LoadWorkbenchData(
        {
            "foobar": {
                "name": "Foobar",
                "scrap_needed": 15,
                "modelid": 843
            },
            "foobar2": {
                "name": "Foobar2",
                "scrap_needed": 15,
                "modelid": 843
            }
        }
    )
});