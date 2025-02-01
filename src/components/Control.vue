<template>
    <div class="control" @click.prevent="toggle_yuui">
        <img :src="yuui_img" alt="yuui" />
    </div>
</template>
<script lang="ts">
import { defineComponent, ref } from 'vue';

export default defineComponent({
    name: 'Control',
    setup() {
        const yuui_img = ref('/ext/yuui/assets/yuui-off.png');
        const toggle_yuui = () => {
            yuui_img.value = "/ext/yuui/assets/yuui-on.png";
        };

        return {
            yuui_img,
            toggle_yuui,
        };
    },
});
</script>

<style scoped>
.control {
    cursor: pointer;
    text-align: center;
    margin: 10px 0 10px 5px;
}

.control img {
    width: 25%;
}


.control:hover {
    box-shadow: 0 0 10px 0 rgb(255, 0, 0);
}
</style>