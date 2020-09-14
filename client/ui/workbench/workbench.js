function ShowWorkbench() {
    $('#workbench').show();
}

function HideWorkbench() {
    $('#workbench').hide();
}

$(function() {
    $('#workbench .build').click(function () {
        var value = $(this).data('value');
        CallEvent("SelectBuildItem", value);
    });
});