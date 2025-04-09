/* eslint-disable no-unused-vars */
import { EngineLoadingProgress } from "./modules/Engine";

export {};

interface Server {
  isRunning: boolean;
}
interface Global {
  custom_settings: Record<string, string>;
  isRunning: boolean;
  version_latest: string;
}
declare global {
  interface Window {
    yuui: Global;
    confirm: (message?: string) => boolean;
    hint: (message: string) => void;
    overlib: (message: string) => void;
    show_menu: () => void;
    showLoading: (delay?: number | null, flag?: string | EngineLoadingProgress) => void;
    updateLoadingProgress: (progress?: EngineLoadingProgress) => void;
    hideLoading: () => void;
    LoadingTime: (seconds: number, flag?: string) => void;
    showtext: (element: HTMLElement | null, text: string) => void;
    y: number;
    progress: number;
  }
}
