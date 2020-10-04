/*
function ShowCharacterSelect() {
    $('#character-select').show();
}

$(function() {
    $('.character').click(function () {
        var value = $(this).data('value');
        CallEvent("SelectCharacter", value);
    });
});
*/

// Inventory component
new Vue({
    el: '#character-select',
    methods: {
        SelectCharacter: function (value) {
            CallEvent("SelectCharacter", value)
        }
    }
})