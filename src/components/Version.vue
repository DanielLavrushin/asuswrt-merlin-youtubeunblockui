<template>
    <div class="version">
        [YoutubeUnblock by <a href="https://github.com/Waujito/youtubeUnblock" target="_blank">Waujito</a>]
        <a href="#" @click.prevent="open_update">
            <span class="button_gen button_gen_small button_info" title="a more recent update is available"
                v-if="hasUpdate">!</span>
            Youtube
            Unblock UI v{{ current_version }}</a>
    </div>
    <modal ref="updateModal" width="600" title="YutubeUnblock Version Log">
        <div class="modal-content">
            <p class="current-version">Current version: <strong>{{ current_version }}</strong></p>
            <div v-if="hasUpdate" class="update-details">
                <p>A newer version is available: <strong style="color:#FFCC00">{{ latest_version }}</strong></p>
                <input class="button_gen button_gen_small button-primary" type="button" value="update now"
                    @click.prevent="update" />
            </div>
            <p v-else class="no-updates">Your version is up-to-date!</p>

            <div class="textarea-wrapper">
                <div class="changelog" v-html="changelog"></div>
                open full <a target="_blank"
                    href="https://github.com/DanielLavrushin/asuswrt-merlin-youtubeunblockui/blob/main/CHANGELOG.md">changelog</a>
            </div>
        </div>
        <template v-slot:footer></template>
    </modal>
</template>

<script lang="ts">
import { defineComponent, ref } from "vue";
import Modal from "./Modal.vue";
import axios from "axios";
import vClean from 'version-clean'
import vCompare from 'version-compare'
import engine, { FormAction } from '../modules/Engine'
import markdownit from "markdown-it";

export default defineComponent({
    name: "Version",
    components: {
        Modal,
    },
    setup() {
        const md = markdownit({ html: true, breaks: true });
        let tempcurvers = window.yuui.custom_settings.yuui_version;
        if (tempcurvers.split('.').length === 2) {
            tempcurvers += ".0";
        }
        const current_version = ref<string>(tempcurvers);
        const latest_version = ref<string>();
        const updateModal = ref();
        const hasUpdate = ref(false);
        const changelog = ref<string>("");
        setTimeout(async () => {
            const gh_releases_url = "https://api.github.com/repos/daniellavrushin/asuswrt-merlin-youtubeunblockui/releases";

            const response = await axios.get(gh_releases_url);

            if (response.data.length > 0) {
                latest_version.value = vClean(response.data[0].tag_name)!;
                hasUpdate.value = vCompare(latest_version.value, current_version.value) === 1;
                if (hasUpdate.value === true) {

                    window.yuui.version_latest = latest_version.value;
                }

                changelog.value = md.render(response.data[0].body);
            }

        }, 2000);

        const open_update = () => {
            updateModal.value.show();
        }

        const update = async () => {
            await engine.executeWithLoadingProgress(async () => {
                await engine.submit(FormAction.UPDATE_YUUI);
            });
        }

        return {
            updateModal,
            current_version,
            latest_version,
            hasUpdate,
            changelog,
            open_update,
            update
        };
    },
});
</script>
<style scoped>
.version {
    float: right;
    font-size: 10px;
    margin-right: 25px;
}

.version a {
    text-decoration: underline;
    color: #FFCC00;
    font-weight: bold;

}

.textarea-wrapper .changelog {
    text-align: left;
    background-color: #2F3A3E;
    border: 1px solid #222;
    padding: 0 10px;
    min-height: 150px;
    font-family: 'Courier New', Courier, monospace;
}

.textarea-wrapper .changelog :deep(h2) {
    margin: 5px;
}

.textarea-wrapper .changelog :deep(ul) {
    margin: 5px;
    padding: 0 10px;

}

.textarea-wrapper .changelog :deep(ul li) {
    margin: 5px;
    padding-bottom: 5px;
    border-bottom: 1px dashed #222;
}

.textarea-wrapper .changelog :deep(ul li):last-child {
    border-bottom: none;
}

.textarea-wrapper .changelog :deep(code) {
    font-weight: bold;
}

.textarea-wrapper :deep(a) {
    color: #FFCC00;
    text-decoration: underline;
}

.modal-content :deep(strong),
.modal-content :deep(code) {

    text-shadow: 1px 1px 2px #ffcc00;
}
</style>