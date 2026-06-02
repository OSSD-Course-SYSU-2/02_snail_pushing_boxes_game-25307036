import { AbilityConstant, UIAbility, Want } from '@kit.AbilityKit';
import { window } from '@kit.ArkUI';
import {
  CONTINUE_INCOMING_STATE_KEY,
  CONTINUE_OUTBOUND_STATE_KEY,
  CONTINUE_STATE_PARAM_KEY
} from '../utils/ContinuationState';

export default class EntryAbility extends UIAbility {
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    this.restoreContinuedState(want, launchParam);
  }

  onNewWant(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    this.restoreContinuedState(want, launchParam);
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    windowStage.loadContent('pages/Index', (err) => {
      if (err && err.code) {
        console.error(`Failed to load the content. Code: ${err.code}, message: ${err.message}`);
        return;
      }
      console.info('Succeeded in loading the content.');
    });
  }

  onWindowStageDestroy(): void {}
  onForeground(): void {}
  onBackground(): void {}

  onContinue(wantParam: Record<string, Object>): AbilityConstant.OnContinueResult {
    const stateText = AppStorage.get<string>(CONTINUE_OUTBOUND_STATE_KEY);
    if (stateText !== undefined && stateText.length > 0) {
      wantParam[CONTINUE_STATE_PARAM_KEY] = stateText;
    }
    return AbilityConstant.OnContinueResult.AGREE;
  }

  private restoreContinuedState(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    if (launchParam.launchReason !== AbilityConstant.LaunchReason.CONTINUATION || want.parameters === undefined) {
      return;
    }

    const stateText = want.parameters[CONTINUE_STATE_PARAM_KEY];
    if (typeof stateText === 'string' && stateText.length > 0) {
      AppStorage.setOrCreate(CONTINUE_INCOMING_STATE_KEY, stateText);
    }
  }
}
