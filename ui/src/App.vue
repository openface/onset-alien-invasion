<template>
  <router-view></router-view>
</template>

<script>
export default {
  name: 'app'
}
</script>

<style>
body { user-select: none; overflow: hidden; height: 100%; margin:0; }

#progress {
    position: fixed;
    top: 50%;
    left: 50%;
    transform: translate(-50%, -50%);
}
#progress >>> .vue-progress-path path {
    stroke-width: 12;
}
#progress >>> .vue-progress-path .progress {
    stroke: rgba(255, 255, 255, 0.6);
}
#progress >>> .vue-progress-path .background {
    stroke: rgba(0, 0, 0, 0.4);
}
</style>