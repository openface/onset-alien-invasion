<template>
  <div id="container">
    <h1>{{ msg }}</h1>
    <component v-bind:is="component" />
  </div>
</template>

<script>
import CharacterSelection from './components/CharacterSelection.vue'

export default {
  name: 'app',
  components: {
    CharacterSelection
  },
  data() {
    return {
      component: "CharacterSelection",
      msg: 'Welcome to the NEW Vue.js App!'
    }
  }
}
</script>

<style>
  #container {
    color: #56b983;
  }
</style>