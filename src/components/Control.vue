<template>
    <section>
        <div class="control" @click.prevent="toggle_yuui" title="Click to unblock Youtube">
            <img :src="yuui_img" alt="yuui" />
        </div>
    </section>
</template>
<script lang="ts">
import { defineComponent, ref } from 'vue';
import engine, { FormAction } from '../modules/Engine';

export default defineComponent({
    name: 'Control',
    setup() {
        const yuui_img = ref<string>(window.yuui.isRunning ? '/ext/yuui/assets/yuui-on.png' : '/ext/yuui/assets/yuui-off.png');
        const toggle_yuui = async () => {
            await engine.executeWithLoadingProgress(async () => {
                const action = window.yuui.isRunning ? FormAction.SERVICE_STOP : FormAction.SERVICE_START;
                await engine.submit(action);
            });
        };

        return {
            yuui_img,
            toggle_yuui,
        };
    },
});
</script>

<style scoped>
section {
    background-color: #424E55;
    padding: 25px;
    margin: 25px;
    box-shadow: 0 0 10px rgba(0, 0, 0, 0.5);
}

.control {
    cursor: pointer;
    text-align: center;
}

.control img {
    width: 25%;
}


.control:hover {
    filter: drop-shadow(0 0 10px red);
}
</style>