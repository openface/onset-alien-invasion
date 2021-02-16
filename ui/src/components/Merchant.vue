<template>
    <div id="container">
        <div id="inner" :class="IsBusy() ? 'blurred' : ''">
            <div id="title">MERCHANT</div>
            <div v-for="(items, category) in merchant_items" :key="category">
                <div class="category">{{ category }}</div>

                <div class="grid">
                    <div class="item" v-for="item in items" :key="item.item" @mouseenter="!IsBusy() ? PlayClick() : null">
                        <div class="pic">
                            <img :src="getImageUrl(item)" />
                        </div>
                        <div class="details">
                            <div class="name">{{ item.name }}</div>
                            <div class="action">
                                <div v-if="player_cash >= item.price">
                                    <button class="buy" @click="BuyItem(item.item)">
                                        BUY ($<b>{{ item.price }}</b
                                        >)
                                    </button>
                                </div>
                                <div v-else>
                                    <button class="need_cash" disabled="true">
                                        BUY ($<b>{{ item.price }}</b
                                        >)
                                    </button>
                                </div>
                            </div>
                        </div>
                        <br style="clear:both;" />
                    </div>
                </div>
            </div>
        </div>

        <div id="progress" v-if="IsBusy()">
            <loading-progress :indeterminate="true" size="40" rotate fillDuration="3" rotationDuration="4" />
        </div>
    </div>
</template>

<script>
import groupBy from "lodash/groupBy";
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
            this.merchant_items = groupBy(data["merchant_items"], function(item) {
                return item.category;
            });
            window.console.log(this.merchant_items);
            //this.merchant_items = data["merchant_items"];
            this.player_cash = data["player_cash"];
        },
        BuyItem: function(item) {
            this.is_busy = true;
            this.CallEvent("BuyItem", item);

            if (!this.InGame) {
                setTimeout(
                    () =>
                        this.EventBus.$emit("CompletePurchase", {
                            player_cash: 10,
                        }),
                    3000
                );
                //setTimeout(() => this.EventBus.$emit("PurchaseDenied"), 5000);
            }
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
            this.CallEvent("PlayClick");
        },
    },
    mounted() {
        this.EventBus.$on("LoadMerchantData", this.LoadMerchantData);
        this.EventBus.$on("CompletePurchase", this.CompletePurchase);
        this.EventBus.$on("PurchaseDenied", this.PurchaseDenied);

        if (!this.InGame) {
            this.EventBus.$emit("LoadMerchantData", {
                player_cash: 100,
                merchant_items: [
                    {
                        item: "vest",
                        name: "Kevlar Vest",
                        price: 10,
                        modelid: 843,
                        category: "Military Surplus",
                    },
                    {
                        item: "armyhat",
                        name: "Army Hat",
                        price: 10,
                        modelid: 843,
                        category: "Military Surplus",
                    },
                    {
                        item: "banana",
                        name: "Banana",
                        price: 10,
                        modelid: 843,
                        category: "Grocery",
                    },
                    {
                        item: "flashlight",
                        name: "Flashlight",
                        price: 150,
                        modelid: 843,
                        category: "Supplies",
                    },
                    {
                        item: "beer",
                        name: "Beer",
                        price: 10,
                        modelid: 843,
                        category: "Grocery",
                    },
                    {
                        item: "binoculars",
                        name: "Binoculars",
                        price: 10,
                        modelid: 843,
                        category: "Supplies",
                    },
                    {
                        item: "boxhead",
                        name: "Boxhead",
                        price: 10,
                        modelid: 843,
                        category: "Miscellaneous",
                    },
                    {
                        item: "chainsaw",
                        name: "Chainsaw",
                        price: 10,
                        modelid: 843,
                        category: "Supplies",
                    },
                    {
                        item: "fishing_rod",
                        name: "Fishing Rod",
                        price: 10,
                        modelid: 843,
                        category: "Supplies",
                    },
                    {
                        item: "headphones",
                        name: "Headphones",
                        price: 10,
                        modelid: 843,
                        category: "Miscellaneous",
                    },
                    {
                        item: "landmine",
                        name: "Landmine",
                        price: 10,
                        modelid: 843,
                        category: "Military Surplus",
                    },
                    {
                        item: "lantern",
                        name: "Lantern",
                        price: 10,
                        modelid: 843,
                        category: "Supplies",
                    },
                    {
                        item: "water_bottle",
                        name: "Water Bottle",
                        price: 10,
                        modelid: 843,
                        category: "Grocery",
                    },
                    {
                        item: "wooden_chair",
                        name: "Wooden Chair",
                        price: 10,
                        modelid: 843,
                        category: "Furniture",
                    },
                    {
                        item: "wooden_table",
                        name: "Wooden Table",
                        price: 10,
                        modelid: 843,
                        category: "Furniture",
                    },
                ],
            });
        }
    },
};
</script>

<style scoped>
#container {
    display: flex;
    height: 75vh;
}
#inner {
    margin: auto;
    width: 780px;
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
    text-shadow: 2px 2px rgba(0, 0, 0, 0.4);
}
#progress {
    position: fixed;
    top: 40%;
    left: 50%;
    transform: translate(-50%, -50%);
}
#progress >>> .vue-progress-path path {
    stroke-width: 16;
}
#progress >>> .vue-progress-path .progress {
    stroke: rgba(255, 255, 255, 0.6);
}
#progress >>> .vue-progress-path .background {
    stroke: rgba(0, 0, 0, 0.4);
}
.category {
    margin-top: 10px;
    text-transform: uppercase;
    font-size: 12px;
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
#inner:not(.blurred) .item:hover {
    background: rgba(255, 255, 255, 0.2);
}
.item .pic {
    float: left;
    width: 70px;
}
.item .pic img {
    border-radius: 3px;
    width: 60px;
    border: 1px solid rgba(0, 0, 0, 0.1);
}
.item .details {
    float: left;
    width: 150px;
}
.item .details .name {
    font-size: 18px;
    color: #fff;
    margin-bottom: 18px;
}
.item .details .info {
    font-size: 11px;
    color: #fff;
    line-height: 2em;
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
#inner:not(.blurred) button.buy:hover:not([disabled]) {
    cursor: pointer;
    background: #3684ff;
}
button:disabled,
button[disabled] {
    background: #444;
    color: #666666;
}
</style>
