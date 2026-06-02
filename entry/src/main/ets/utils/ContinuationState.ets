export const CONTINUE_OUTBOUND_STATE_KEY: string = 'snail_continue_outbound_state';
export const CONTINUE_INCOMING_STATE_KEY: string = 'snail_continue_incoming_state';
export const CONTINUE_STATE_PARAM_KEY: string = 'snailContinueState';
export const CONTINUE_STATE_VERSION: number = 1;
export const CONTINUE_HISTORY_LIMIT: number = 80;

export interface SnailContinueState {
  version: number;
  currentView: number;
  levelIndex: number;
  playerKey: string;
  boxKeys: string[];
  deadlockedBoxKeys: string[];
  moveCount: number;
  pushCount: number;
  history: string[];
  isCleared: boolean;
  lastClearStars: number;
  clearOverlayProgress: number;
  statusText: string;
  statusTone: number;
  saveDataText: string;
}

export function parseContinueState(text: string): SnailContinueState | undefined {
  if (text.length === 0) {
    return undefined;
  }

  try {
    const raw = JSON.parse(text) as SnailContinueState;
    return {
      version: safeNumber(raw.version, CONTINUE_STATE_VERSION),
      currentView: safeNumber(raw.currentView, 0),
      levelIndex: safeNumber(raw.levelIndex, 0),
      playerKey: safeString(raw.playerKey),
      boxKeys: safeStringArray(raw.boxKeys),
      deadlockedBoxKeys: safeStringArray(raw.deadlockedBoxKeys),
      moveCount: Math.max(0, safeNumber(raw.moveCount, 0)),
      pushCount: Math.max(0, safeNumber(raw.pushCount, 0)),
      history: safeStringArray(raw.history),
      isCleared: raw.isCleared === true,
      lastClearStars: Math.max(0, safeNumber(raw.lastClearStars, 0)),
      clearOverlayProgress: Math.max(0, safeNumber(raw.clearOverlayProgress, 0)),
      statusText: safeString(raw.statusText),
      statusTone: safeNumber(raw.statusTone, 0),
      saveDataText: safeString(raw.saveDataText)
    };
  } catch (error) {
    return undefined;
  }
}

function safeNumber(value: number, fallback: number): number {
  const nextValue = Number(value);
  if (Number.isNaN(nextValue)) {
    return fallback;
  }
  return nextValue;
}

function safeString(value: string): string {
  if (typeof value !== 'string') {
    return '';
  }
  return value;
}

function safeStringArray(values: string[]): string[] {
  const nextValues: string[] = [];
  if (!Array.isArray(values)) {
    return nextValues;
  }

  for (let index = 0; index < values.length; index++) {
    const value = values[index];
    if (typeof value === 'string' && value.length > 0) {
      nextValues.push(value);
    }
  }
  return nextValues;
}
