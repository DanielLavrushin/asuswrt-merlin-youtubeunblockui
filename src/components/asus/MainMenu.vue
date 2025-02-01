<template>
  <div id="mainMenu"></div>
</template>

<script lang="ts">
import { defineComponent, onMounted } from "vue";

export default defineComponent({
  name: "MainMenu",

  setup() {
    onMounted(async () => {
      window.show_menu();
    });
    return {};
  }
});
</script>

<style scoped></style>
