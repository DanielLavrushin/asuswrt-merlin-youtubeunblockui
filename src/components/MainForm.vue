<template>
  <form method="post" name="form" action="/start_apply.htm" target="hidden_frame">
    <input type="hidden" name="current_page" :value="page" />
    <input type="hidden" name="next_page" :value="page" />
    <input type="hidden" name="group_id" value="" />
    <input type="hidden" name="modified" value="0" />
    <input type="hidden" name="action_mode" value="apply" />
    <input type="hidden" name="action_wait" value="5" />
    <input type="hidden" name="first_time" value="" />
    <input type="hidden" name="action_script" value="" />
    <input type="hidden" name="amng_custom" value="" />
    <table class="content" align="center" cellpadding="0" cellspacing="0">
      <tbody>
        <tr>
          <td width="17">&nbsp;</td>
          <td valign="top" width="202">
            <main-menu></main-menu>
            <sub-menu></sub-menu>
          </td>
          <td valign="top">
            <tab-menu></tab-menu>
            <table width="98%" border="0" align="left" cellpadding="0" cellspacing="0">
              <tbody>
                <tr>
                  <td valign="top">
                    <table width="760px" border="0" cellpadding="4" cellspacing="0" id="FormTitle" class="FormTitle">
                      <tbody>
                        <tr bgcolor="#4D595D">
                          <td valign="top">
                            <div class="formfontdesc">
                              <div>&nbsp;</div>
                              <div class="formfonttitle" style="text-align: center">Youtube Unblock UI v{{ version }}
                              </div>

                              <div id="formfontdesc" class="formfontdesc"></div>
                              <div style="margin: 10px 0 10px 5px" class="splitLine"></div>
                              <control></control>
                              <version></version>
                            </div>
                          </td>
                        </tr>
                      </tbody>
                    </table>
                  </td>
                </tr>
              </tbody>
            </table>
          </td>
        </tr>
      </tbody>
    </table>
  </form>
</template>
<script lang="ts">
import { defineComponent } from "vue";

import MainMenu from "./asus/MainMenu.vue";
import TabMenu from "./asus/TabMenu.vue";
import SubMenu from "./asus/SubMenu.vue";

import Version from "./Version.vue";
import Control from "./Control.vue";

export default defineComponent({
  name: "MainForm",
  components: {
    TabMenu,
    MainMenu,
    SubMenu,
    Control,
    Version,

  },


  setup() {
    return {
      version: window.yuui.custom_settings.yuui_version,
      page: window.location.pathname.substring(1),
    };
  }
});
</script>
<style scoped></style>
