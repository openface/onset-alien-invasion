<template>
  <div class="grid">
    <slot />
  </div>
</template>

<script>
import { ContainerMixin } from "vue-slicksort";

export default {
  name: "InventoryGrid",
  mixins: [ContainerMixin],
};
</script>

<style scoped>
.grid {
  display: flex;
  flex-wrap: wrap;
  align-content: flex-start;
  margin: 0 auto;
}
</style>
