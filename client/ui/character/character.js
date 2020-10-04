// Inventory component
new Vue({
    el: '#character-select',
    methods: {
        SelectCharacter: function (value) {
            CallEvent("SelectCharacter", value)
        }
    }
})