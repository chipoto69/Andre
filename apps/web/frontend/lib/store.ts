import { create } from 'zustand';
import { persist } from 'zustand/middleware';
import type {
  ListItem,
  DailyFocusCard,
  Suggestion,
  AntiTodoEntry,
  Board,
} from './api-client';

interface AppState {
  // ============================================================================
  // Lists State
  // ============================================================================
  lists: Board;
  setLists: (lists: Board) => void;

  // ============================================================================
  // Focus Card State
  // ============================================================================
  currentFocusCard: DailyFocusCard | null;
  setCurrentFocusCard: (card: DailyFocusCard | null) => void;

  // ============================================================================
  // Suggestions State
  // ============================================================================
  suggestions: Suggestion[];
  setSuggestions: (suggestions: Suggestion[]) => void;

  // ============================================================================
  // Anti-Todo State
  // ============================================================================
  antiTodoEntries: AntiTodoEntry[];
  setAntiTodoEntries: (entries: AntiTodoEntry[]) => void;

  // ============================================================================
  // UI State
  // ============================================================================
  isOnboardingComplete: boolean;
  setOnboardingComplete: (complete: boolean) => void;

  selectedListType: 'todo' | 'watch' | 'later' | null;
  setSelectedListType: (type: AppState['selectedListType']) => void;

  isPlanningMode: boolean;
  setPlanningMode: (mode: boolean) => void;

  selectedItemsForPlanning: Set<string>;
  toggleItemSelection: (itemId: string) => void;
  clearSelection: () => void;

  // ============================================================================
  // Online/Offline State
  // ============================================================================
  isOnline: boolean;
  setIsOnline: (online: boolean) => void;

  // ============================================================================
  // Modal State
  // ============================================================================
  isQuickCaptureOpen: boolean;
  setQuickCaptureOpen: (open: boolean) => void;

  isPlanningWizardOpen: boolean;
  setPlanningWizardOpen: (open: boolean) => void;
}

export const useAppStore = create<AppState>()(
  persist(
    (set, get) => ({
      // Initial state
      lists: { todo: [], watch: [], later: [] },
      currentFocusCard: null,
      suggestions: [],
      antiTodoEntries: [],
      isOnboardingComplete: false,
      selectedListType: null,
      isPlanningMode: false,
      selectedItemsForPlanning: new Set(),
      isOnline: typeof navigator !== 'undefined' ? navigator.onLine : true,
      isQuickCaptureOpen: false,
      isPlanningWizardOpen: false,

      // Actions
      setLists: (lists) => set({ lists }),
      setCurrentFocusCard: (card) => set({ currentFocusCard: card }),
      setSuggestions: (suggestions) => set({ suggestions }),
      setAntiTodoEntries: (entries) => set({ antiTodoEntries: entries }),
      setOnboardingComplete: (complete) => set({ isOnboardingComplete: complete }),
      setSelectedListType: (type) => set({ selectedListType: type }),
      setPlanningMode: (mode) => set({ isPlanningMode: mode }),

      toggleItemSelection: (itemId) => {
        const selected = new Set(get().selectedItemsForPlanning);
        if (selected.has(itemId)) {
          selected.delete(itemId);
        } else {
          selected.add(itemId);
        }
        set({ selectedItemsForPlanning: selected });
      },

      clearSelection: () => set({ selectedItemsForPlanning: new Set() }),
      setIsOnline: (online) => set({ isOnline: online }),
      setQuickCaptureOpen: (open) => set({ isQuickCaptureOpen: open }),
      setPlanningWizardOpen: (open) => set({ isPlanningWizardOpen: open }),
    }),
    {
      name: 'andre-storage',
      partialize: (state) => ({
        isOnboardingComplete: state.isOnboardingComplete,
      }),
    }
  )
);
