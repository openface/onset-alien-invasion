function ShowCharacterSelect() {
    $('#character-select').show();
}

$(function() {
    $('.character').click(function () {
        var value = $(this).data('value');
        CallEvent("SelectCharacter", value);
    });
});