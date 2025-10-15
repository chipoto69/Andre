'use client';

import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { apiClient } from '@/lib/api-client';
import { useAppStore } from '@/lib/store';
import { ListBoard } from '@/components/lists/ListBoard';
import { LoadingIndicator } from '@/components/ui';

export default function ListsPage() {
  const queryClient = useQueryClient();
  const { isPlanningMode, setPlanningMode, selectedItemsForPlanning, clearSelection } =
    useAppStore();

  // Fetch lists board
  const {
    data: board,
    isLoading,
    error,
  } = useQuery({
    queryKey: ['lists', 'board'],
    queryFn: () => apiClient.getBoard(),
  });

  // Delete mutation
  const deleteMutation = useMutation({
    mutationFn: (id: string) => apiClient.deleteListItem(id),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['lists'] });
    },
  });

  // Update mutation
  const updateMutation = useMutation({
    mutationFn: ({ id, updates }: { id: string; updates: any }) =>
      apiClient.updateListItem(id, updates),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['lists'] });
    },
  });

  const handleTogglePlanningMode = () => {
    if (isPlanningMode) {
      clearSelection();
    }
    setPlanningMode(!isPlanningMode);
  };

  const handleCreateFocusCard = () => {
    // Navigate to focus page with selected items
    // This will be implemented when we create the focus page
    console.log('Create focus card with items:', selectedItemsForPlanning);
  };

  if (isLoading) {
    return (
      <div className="flex min-h-screen items-center justify-center">
        <LoadingIndicator size="large" message="Loading lists..." />
      </div>
    );
  }

  if (error) {
    return (
      <div className="flex min-h-screen items-center justify-center">
        <div className="text-center">
          <h2 className="text-title-lg text-status-error">Failed to load lists</h2>
          <p className="mt-sm text-body-md text-text-secondary">
            {error instanceof Error ? error.message : 'Unknown error occurred'}
          </p>
        </div>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-background-primary">
      {/* Header */}
      <header className="border-b border-background-tertiary bg-background-secondary">
        <div className="mx-auto max-w-7xl px-md py-lg">
          <div className="flex items-center justify-between">
            <div>
              <h1 className="text-title-lg font-semibold text-text-primary">
                <span className="text-accent-primary">Three Lists</span>
              </h1>
              <p className="mt-xs text-body-sm text-text-tertiary">
                Todo · Watch · Later
              </p>
            </div>

            <div className="flex gap-md">
              {isPlanningMode && (
                <button
                  onClick={handleCreateFocusCard}
                  disabled={selectedItemsForPlanning.size === 0}
                  className="rounded-medium bg-accent-primary px-lg py-sm text-body-md font-medium text-brand-black transition-colors hover:bg-accent-primary/90 disabled:opacity-50"
                >
                  Create Focus Card ({selectedItemsForPlanning.size})
                </button>
              )}
              <button
                onClick={handleTogglePlanningMode}
                className={`rounded-medium px-lg py-sm text-body-md font-medium transition-colors ${
                  isPlanningMode
                    ? 'bg-accent-primary text-brand-black'
                    : 'bg-background-tertiary text-text-primary hover:bg-background-tertiary/80'
                }`}
              >
                {isPlanningMode ? 'Exit Planning' : 'Planning Mode'}
              </button>
            </div>
          </div>
        </div>
      </header>

      {/* Lists Board */}
      <main className="mx-auto max-w-7xl px-md py-xl">
        {board && (
          <ListBoard
            board={board}
            onDelete={(id) => deleteMutation.mutate(id)}
            onUpdate={(id, updates) => updateMutation.mutate({ id, updates })}
          />
        )}
      </main>
    </div>
  );
}
