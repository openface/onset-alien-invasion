function ShowWorkbench() {
    $('#workbench').show();
}

function HideWorkbench() {
    $('#workbench').hide();
}

$(function() {
    $('.row').click(function () {
        var value = $(this).data('value');
        CallEvent("SelectBuild", value)
    });
});