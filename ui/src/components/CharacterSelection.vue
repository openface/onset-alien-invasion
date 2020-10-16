<template>
    <div id="container">
        <div class="title">WELCOME TO THE<br />INVASION!</div>
        <div class="info">
            You are now being deployed onto a deserted island that has been
            overrun with alien beings. Stay alive until you receive
            further instructions! We will send you more information
            via computer terminal located in the garage of an abandoned house.
        </div>
        <div class="subtitle">Select a character to join</div>
        <div id="character-select">
            <div class="character" v-on:click="SelectCharacter(1)">
                <img src="@/assets/images/1.jpg" />
                <button>SELECT</button>
            </div>
            <div class="character" v-on:click="SelectCharacter(2)">
                <img src="@/assets/images/2.jpg" />
                <button>SELECT</button>
            </div>
            <div class="character" v-on:click="SelectCharacter(4)">
                <img src="@/assets/images/4.jpg" />
                <button>SELECT</button>
            </div>
            <div class="character" v-on:click="SelectCharacter(5)">
                <img src="@/assets/images/5.jpg" />
                <button>SELECT</button>
            </div>
            <div class="character" v-on:click="SelectCharacter(6)">
                <img src="@/assets/images/6.jpg" />
                <button>SELECT</button>
            </div>
            <div class="character" v-on:click="SelectCharacter(7)">
                <img src="@/assets/images/7.jpg" />
                <button>SELECT</button>
            </div>
            <div class="character" v-on:click="SelectCharacter(9)">
                <img src="@/assets/images/9.jpg" />
                <button>SELECT</button>
            </div>
            <div class="character" v-on:click="SelectCharacter(10)">
                <img src="@/assets/images/10.jpg" />
                <button>SELECT</button>
            </div>
            <div class="character" v-on:click="SelectCharacter(14)">
                <img src="@/assets/images/14.jpg" />
                <button>SELECT</button>
            </div>
            <div class="character" v-on:click="SelectCharacter(15)">
                <img src="@/assets/images/15.jpg" />
                <button>SELECT</button>
            </div>
            <div class="character" v-on:click="SelectCharacter(16)">
                <img src="@/assets/images/16.jpg" />
                <button>SELECT</button>
            </div>
            <div class="character" v-on:click="SelectCharacter(18)">
                <img src="@/assets/images/18.jpg" />
                <button>SELECT</button>
            </div>
            <div class="character" v-on:click="SelectCharacter(19)">
                <img src="@/assets/images/19.jpg" />
                <button>SELECT</button>
            </div>
            <div class="character" v-on:click="SelectCharacter(20)">
                <img src="@/assets/images/20.jpg" />
                <button>SELECT</button>
            </div>
            <div class="character" v-on:click="SelectCharacter(25)">
                <img src="@/assets/images/25.jpg" />
                <button>SELECT</button>
            </div>
         </div>
    </div>
</template>

<script>
export default {
  name: 'CharacterSelection',
  methods: {
    SelectCharacter: function (value) {
        this.CallEvent("SelectCharacter", value)
    }
  }
}
</script>

<style scoped>
#container {
    width:600px;
    margin:50px auto;
    background: rgba(0,0,0,0.9);
    padding:10px 25px;
    padding-bottom:25px;
    border-radius:10px;
}
.title {
    font-family:impact;
    font-size:80px;
    text-shadow: 3px 3px black;
    color:#fff;
    text-align:center;
}
.info {
    background:rgba(0,0,0,0.3);
    border-radius:10px;
    font-family:monospace;
    font-size:14px;
    padding:5px;
    color:#fff;
    text-shadow: 1px 1px black;
    font: 1rem Inconsolata, monospace;
    text-align:center;
}
.subtitle {
    font-family:impact;
    font-size:20px;
    color:#fff;
    text-align:center;
    text-shadow: 1px 1px black;
    margin:20px 0;
}
#character-select {
    display: flex;
    flex-wrap: wrap;
    justify-content: center;
    align-items: center;
    align-content: center;
}
.character {
    text-align:center;
    background:rgba(0,0,0,0.3);
    border-radius:3px;
    padding:5px;
    width: 100px;
    border:1px solid #000;
}
.character:hover, button:hover {
    cursor: pointer;
    border:1px solid #fff;
}
.character img {
    border-radius: 4px;
    width: 100px;
}
.character button {
    background:#3684ff;
    color:#fff;
    font-weight:bold;
    border:0px;
    padding:7px;
    width:100%;
}
</style>