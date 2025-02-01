import axios from "axios";

const FormAction = {
  SERVICE_START: "yuui_service_start",
  SERVICE_STOP: "yuui_service_stop",
  UPDATE_YUUI: "yuui_update"
};

class Response {}
class EngineResponse {
  public response?: Response;
  public loading?: EngineLoadingProgress;
}
class EngineLoadingProgress {
  public progress = 0;
  public message = "";

  constructor(progress?: number, message?: string) {
    if (progress) {
      this.progress = progress;
    }
    if (message) {
      this.message = message;
    }
  }
}

class Engine {
  public submit(action: string, payload: object | string | number | null | undefined = undefined, delay = 0): Promise<void> {
    return new Promise((resolve) => {
      const iframeName = "hidden_frame_" + Math.random().toString(36).substring(2, 9);
      const iframe = document.createElement("iframe");
      iframe.name = iframeName;
      iframe.style.display = "none";

      document.body.appendChild(iframe);

      const form = document.createElement("form");
      form.method = "post";
      form.action = "/start_apply.htm";
      form.target = iframeName;

      this.create_form_element(form, "hidden", "action_mode", "apply");
      this.create_form_element(form, "hidden", "action_script", action);
      this.create_form_element(form, "hidden", "modified", "0");
      this.create_form_element(form, "hidden", "action_wait", "");

      const amngCustomInput = document.createElement("input");
      if (payload) {
        const chunkSize = 2048;
        const payloadString = JSON.stringify(payload);
        const chunks = this.splitPayload(payloadString, chunkSize);
        chunks.forEach((chunk: string, idx) => {
          window.yuui.custom_settings[`eui_payload${idx}`] = chunk;
        });

        const customSettings = JSON.stringify(window.yuui.custom_settings);
        if (customSettings.length > 8 * 1024) {
          alert("Configuration is too large to submit via custom settings.");
          return;
        }

        amngCustomInput.type = "hidden";
        amngCustomInput.name = "amng_custom";
        amngCustomInput.value = customSettings;
        form.appendChild(amngCustomInput);
      }

      document.body.appendChild(form);

      iframe.onload = () => {
        document.body.removeChild(form);
        document.body.removeChild(iframe);

        setTimeout(() => {
          resolve();
        }, delay);
      };
      form.submit();
      if (form.contains(amngCustomInput)) {
        form.removeChild(amngCustomInput);
      }
    });
  }
  private splitPayload(payload: string, chunkSize: number): string[] {
    const chunks: string[] = [];
    let index = 0;
    while (index < payload.length) {
      chunks.push(payload.slice(index, index + chunkSize));
      index += chunkSize;
    }
    return chunks;
  }
  private create_form_element = (form: HTMLFormElement, type: string, name: string, value: string): HTMLInputElement => {
    const input = document.createElement("input");
    input.type = type;
    input.name = name;
    input.value = value;
    form.appendChild(input);
    return input;
  };

  public async getResponse(): Promise<EngineResponse> {
    const response = await axios.get<EngineResponse>("/ext/yuui/response.json");
    let responseConfig = response.data;
    return responseConfig;
  }

  public async executeWithLoadingProgress(action: Function, windowReload = true): Promise<void> {
    let loadingProgress = new EngineLoadingProgress(0, "Please, wait...");
    window.showLoading(null, loadingProgress);

    const progressPromise = this.checkLoadingProgress(loadingProgress, windowReload);

    const actionPromise = action();
    await Promise.all([actionPromise, progressPromise]);
  }

  private async checkLoadingProgress(loadingProgress: EngineLoadingProgress, windowReload = true): Promise<void> {
    return new Promise((resolve, reject) => {
      const checkProgressInterval = setInterval(async () => {
        try {
          const response = await this.getResponse();
          if (response.loading) {
            loadingProgress = response.loading;
            window.updateLoadingProgress(loadingProgress);
          } else {
            clearInterval(checkProgressInterval);
            window.hideLoading();
            if (windowReload) {
              window.location.reload();
            }
          }
        } catch (error) {
          clearInterval(checkProgressInterval);
          window.hideLoading();
          reject(new Error("Error while checking loading progress"));
        }
      }, 1000);
    });
  }
}

let engine = new Engine();
export default engine;
export { FormAction, Response, EngineResponse, EngineLoadingProgress };
