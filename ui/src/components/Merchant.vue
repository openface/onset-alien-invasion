<template>
  <div id="container">
    <div id="inner">
      <div id="title">MERCHANT</div>
      <div class="grid" :class="IsBusy() ? 'blurred' : ''">
        <div class="item" v-for="item in merchant_items" :key="item.item" @mouseenter="!IsBusy ? PlayClick() : null">
          <div class="pic">
            <img v-if="!InGame" src="http://placekitten.com/60/60" />
            <img v-if="InGame" :src="'http://game/objects/' + item.modelid" />
          </div>
          <div class="details">
            <div class="name">{{ item.name }}</div>
            <div class="info">$<b>{{ item.price }}</b></div>
            <div class="action">
              <div v-if="player_cash >= item.price">
                <button class="buy" @click="BuyItem(item.item)">BUY</button>
              </div>
              <div v-else>
                <button class="need_cash" disabled="true">NEED CASH</button>
              </div>
            </div>
          </div>
          <br style="clear:both;" />
        </div>
      </div>
    </div>

    <div id="progress" v-if="IsBusy()">
      <loading-progress :indeterminate="true" size="64" />
    </div>
  </div>
</template>

<script>
export default {
  name: "Merchant",
  data() {
    return {
      merchant_items: {},
      player_cash: 0,
      is_busy: false,
    };
  },
  methods: {
    LoadMerchantData: function(data) {
      this.merchant_items = data["merchant_items"];
      this.player_cash = data["player_cash"];
    },
    BuyItem: function(item) {
      this.is_busy = true;
      this.CallEvent('BuyItem', item)
    },
    CompletePurchase(data) {
      this.player_cash = data["player_cash"];
      this.is_busy = false;
    },
    PurchaseDenied() {
      this.is_busy = false;
    },
    IsBusy() {
      return this.is_busy;
    },
    PlayClick() {
      this.CallEvent("PlayClick")
    }
  },
  mounted() {
    this.EventBus.$on("LoadMerchantData", this.LoadMerchantData);
    this.EventBus.$on("CompletePurchase", this.CompletePurchase)
    this.EventBus.$on("PurchaseDenied", this.PurchaseDenied)

    if (!this.InGame) {
      //setTimeout(() => this.EventBus.$emit("CompletePurchase", { player_cash: 10 }), 5000);
      //setTimeout(() => this.EventBus.$emit("PurchaseDenied"), 5000);

      this.EventBus.$emit("LoadMerchantData", {
        player_cash: 100,
        merchant_items: [
          {
            item: 'armor',
            name: "Vest",
            price: 10,
            modelid: 843,
          },
          {
            item: 'foobar',
            name: "Foobar",
            price: 10,
            modelid: 843,
          },
          {
            item: 'food2',
            name: "Food",
            price: 10,
            modelid: 843,
          },
          {
            item: 'flashlight',
            name: "Flashlight",
            price: 150,
            modelid: 843,
          },
          {
            item: 'food4',
            name: "Food",
            price: 10,
            modelid: 843,
          },
          {
            item: 'food5',
            name: "Food",
            price: 10,
            modelid: 843,
          },
          {
            item: 'food6',
            name: "Food",
            price: 10,
            modelid: 843,
          },
          {
            item: 'food7',
            name: "Food",
            price: 10,
            modelid: 843,
          },
          {
            item: 'food20',
            name: "Food",
            price: 10,
            modelid: 843,
          },
          {
            item: 'flashlight0',
            name: "Flashlight",
            price: 10,
            modelid: 843,
          },
          {
            item: 'food40',
            name: "Food",
            price: 10,
            modelid: 843,
          },
          {
            item: 'food50',
            name: "Food",
            price: 10,
            modelid: 843,
          },
          {
            item: 'food60',
            name: "Food",
            price: 10,
            modelid: 843,
          },
          {
            item: 'food70',
            name: "Food",
            price: 10,
            modelid: 843,
          },
        ]
      });
    }
  },
};
</script>

<style scoped>
#container {
  display:flex;
  height:75vh;
}
#inner {
  margin:auto;
  width:780px;
  background: rgba(0, 0, 0, 0.9);
  font-family: helvetica;
  font-size: 16px;
  color: #ccc;
  text-shadow: 1px 1px black;
  padding: 10px;
}

#title {
  color: #fff;
  font-size: 36px;
  text-align: center;
  margin: 0;
  font-weight: bold;
  font-family: impact;
  text-shadow:2px 2px rgba(0, 0, 0, 0.4);
}
#progress {
  position: fixed;
  top: 40%;
  left: 50%;
  /* bring your own prefixes */
  transform: translate(-50%, -50%);
}
.grid {
  display: flex;
  flex-wrap: wrap;
  align-content: flex-start;
}
.blurred {
  filter: blur(3px) grayscale(100%);
}
.item {
  padding: 10px;
  width: 225px;
  margin: 5px;
  height: 60px;
  background: rgba(255, 255, 255, 0.1);
}
.grid:not(.blurred) item:hover {
  background: rgba(255, 255, 255, 0.2);
}
.item .pic {
  float: left;
  width: 70px;
}
.item .pic img {
  border-radius: 3px;
  width: 60px;
  border:1px solid rgba(0,0,0, 0.1)
}
.item .details {
  float: left;
  width: 150px;
}
.item .details .name {
  font-weight: bold;
  font-size: 14px;
  color: #fff;
}
.item .details .info {
  font-size: 11px;
  color: #fff;
  line-height:2em;
}
.item .details .info b {
  font-weight: bold;
}
button {
  font-weight: bold;
  border: 0px;
  padding: 3px;
  display: block;
  font-size: 14px;
  width: 100%;
  height: 22px;
}
button.buy {
  background: #1770ff;
  color: #fff;
}
button.buy:hover:not([disabled]) {
  cursor: pointer;
  background: #3684ff;
}
button:disabled,
button[disabled] {
  background: #444;
  color: #666666;
}
</style>
