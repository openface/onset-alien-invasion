// Inventory component
new Vue({
  el: "#inventory",
  data() {
    return {
      inventory: [],
      weapons: [],
      inventory_visible: false,
    };
  },
  computed: {
    FreeInventorySlots: function () {
      return 21 - this.inventory.length;
    },
    FreeHotbarSlots: function () {
      return 10 - this.inventory.length;
    },
  },
  methods: {
    SetInventory: function (data) {
      this.items = data.items;
      this.weapons = data.weapons;
    },
    ShowInventory: function () {
      this.inventory_visible = true;
    },
    HideInventory: function () {
      this.inventory_visible = false;
    },
    range: function (start, end) {
      return Array(end - start + 1)
        .fill()
        .map((_, idx) => start + idx);
    },
  },
  mounted() {
    EventBus.$on("SetInventory", this.SetInventory);
    EventBus.$on("ShowInventory", this.ShowInventory);
    EventBus.$on("HideInventory", this.HideInventory);
  },
});

// dev seeding
(function () {
  if (typeof indev !== "undefined") {
    EmitEvent("SetInventory", {
      weapons: [
        {
          item: "glock",
          name: "Glock",
          modelid: 2,
          quantity: 1,
          type: "weapon",
        },
      ],
      items: [
        {
          item: "metal",
          name: "Metal",
          modelid: 694,
          quantity: 2,
          type: "resource",
        },
        {
          item: "plastic",
          name: "Plastic",
          modelid: 627,
          quantity: 1,
          type: "resource",
        },
        {
          item: "vest",
          name: "Kevlar Vest",
          modelid: 14,
          quantity: 1,
          type: "equipable",
        },
        {
          item: "flashlight",
          name: "Flashlight",
          modelid: 14,
          quantity: 2,
          type: "equipable",
        },
        {
          item: "beer",
          name: "Beer",
          modelid: 15,
          quantity: 4,
          type: "usable",
        },
      ],
    });

    EmitEvent("ShowInventory");
    //setTimeout(function () { EmitEvent("HideInventory", 0); }, 7000);
  }
})();
