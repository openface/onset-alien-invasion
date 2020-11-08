<template>
  <div id="container">
    <div id="inner">
    <div class="title">WELCOME TO THE<br />INVASION!</div>
    <div class="info">
      You are now being deployed onto a deserted island that has been overrun
      with alien beings. <b>Find the safe zone until you discover further instructions!</b>
      We will send more information via a computer terminal located in the garage
      of an abandoned house.  Stay alive and thanks for testing this gamemode!
    </div>
    <div class="subtitle">Select a character to join...</div>
    <div id="character-select">
      <div class="character" @click="SelectCharacter(1)">
        <img :src="getImgUrl('1')" />
        <button>SELECT</button>
      </div>
      <div class="character" @click="SelectCharacter(2)">
        <img :src="getImgUrl('2')" />
        <button>SELECT</button>
      </div>
      <div class="character" @click="SelectCharacter(4)">
        <img :src="getImgUrl('4')" />
        <button>SELECT</button>
      </div>
      <div class="character" @click="SelectCharacter(5)">
        <img :src="getImgUrl('5')" />
        <button>SELECT</button>
      </div>
      <div class="character" @click="SelectCharacter(6)">
        <img :src="getImgUrl('6')" />
        <button>SELECT</button>
      </div>
      <div class="character" @click="SelectCharacter(7)">
        <img :src="getImgUrl('7')" />
        <button>SELECT</button>
      </div>
      <div class="character" @click="SelectCharacter(9)">
        <img :src="getImgUrl('9')" />
        <button>SELECT</button>
      </div>
      <div class="character" @click="SelectCharacter(10)">
        <img :src="getImgUrl('10')" />
        <button>SELECT</button>
      </div>
      <div class="character" @click="SelectCharacter(14)">
        <img :src="getImgUrl('14')" />
        <button>SELECT</button>
      </div>
      <div class="character" @click="SelectCharacter(15)">
        <img :src="getImgUrl('15')" />
        <button>SELECT</button>
      </div>
      <div class="character" @click="SelectCharacter(16)">
        <img :src="getImgUrl('16')" />
        <button>SELECT</button>
      </div>
      <div class="character" @click="SelectCharacter(18)">
        <img :src="getImgUrl('18')" />
        <button>SELECT</button>
      </div>
      <div class="character" @click="SelectCharacter(19)">
        <img :src="getImgUrl('19')" />
        <button>SELECT</button>
      </div>
      <div class="character" @click="SelectCharacter(20)">
        <img :src="getImgUrl('20')" />
        <button>SELECT</button>
      </div>
      <div class="character" @click="SelectCharacter(25)">
        <img :src="getImgUrl('25')" />
        <button>SELECT</button>
      </div>
    </div>
    </div>
  </div>
</template>

<script>
export default {
  name: "Character",
  methods: {
    SelectCharacter: function(value) {
      this.CallEvent("SelectCharacter", value);
    },
    getImgUrl(id) {
      return require('@/assets/images/characters/'+id+'.jpg')
    }
  },
};
</script>

<style scoped>
#container {
  display:flex;
  height:99vh;
}
#inner {
  margin:auto;
  width:620px;
  background: rgba(0, 0, 0, 0.9);
  font-family: helvetica;
  font-size: 16px;
  color: #ccc;
  text-shadow: 1px 1px black;
  padding: 10px;
}
.title {
  font-family: impact;
  font-size: 70px;
  text-shadow: 3px 3px black;
  color: #fff;
  text-align: center;
}
.info {
  font-size: 16px;
  line-height:1.4em;
  padding: 5px;
  color: #000;
  background: rgba(255,255,255, 0.9);
  text-shadow: none;
  text-align: center;
}
.subtitle {
  font-family: impact;
  text-transform:uppercase;
  font-size: 20px;
  color: #fff;
  text-align: center;
  text-shadow: 1px 1px black;
  margin: 20px 0;
}
#character-select {
  display: flex;
  flex-wrap: wrap;
  justify-content: center;
  align-items: center;
  align-content: center;
}
.character {
  text-align: center;
  background: rgba(0, 0, 0, 0.3);
  border-radius: 3px;
  padding: 5px;
  width: 100px;
  border: 1px solid #000;
}
.character:hover, button:hover {
  cursor: pointer;
  border: 1px solid #fff;
}
.character img {
  border-radius: 4px;
  width: 100px;
}
.character button {
  background: #3684ff;
  color: #fff;
  font-weight: bold;
  border: 0px;
  padding: 7px;
  width: 100%;
}
</style>
