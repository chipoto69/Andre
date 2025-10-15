'use client';

import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { apiClient } from '@/lib/api-client';
import { useAppStore } from '@/lib/store';
import { FocusCard } from '@/components/focus/FocusCard';
import { PlanningWizard } from '@/components/focus/PlanningWizard';
import { LoadingIndicator, Button } from '@/components/ui';
import { getTodayDate } from '@/lib/utils';

export default function FocusPage() {
  const queryClient = useQueryClient();
  const { isPlanningWizardOpen, setPlanningWizardOpen, selectedItemsForPlanning } =
    useAppStore();
  const selectedDate = getTodayDate();

  // Fetch today's focus card
  const {
    data: focusCard,
    isLoading,
    error,
  } = useQuery({
    queryKey: ['focus', selectedDate],
    queryFn: () => apiClient.getFocusCard(selectedDate),
  });

  // Generate AI focus card mutation
  const generateMutation = useMutation({
    mutationFn: (date: string) => apiClient.generateFocusCard(date),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['focus'] });
    },
  });

  // Update focus card mutation
  const updateMutation = useMutation({
    mutationFn: ({
      id,
      updates,
    }: {
      id: string;
      updates: Partial<typeof apiClient.updateFocusCard extends (id: string, updates: infer U) => unknown ? U : never>;
    }) => apiClient.updateFocusCard(id, updates),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['focus'] });
    },
  });

  const handleGenerateAI = async () => {
    try {
      await generateMutation.mutateAsync(selectedDate);
    } catch (error) {
      console.error('Failed to generate focus card:', error);
    }
  };

  if (isLoading) {
    return (
      <div className="flex min-h-screen items-center justify-center">
        <LoadingIndicator size="large" message="Loading focus card..." />
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-background-primary">
      {/* Header */}
      <header className="border-b border-background-tertiary bg-background-secondary">
        <div className="mx-auto max-w-4xl px-md py-lg">
          <div className="flex items-center justify-between">
            <div>
              <h1 className="text-title-lg font-semibold text-text-primary">
                <span className="text-accent-primary">Daily Focus</span>
              </h1>
              <p className="mt-xs text-body-sm text-text-tertiary">
                Your 3-5 priority items for today
              </p>
            </div>

            <div className="flex gap-md">
              {!focusCard && (
                <>
                  <Button
                    onClick={handleGenerateAI}
                    variant="secondary"
                    isLoading={generateMutation.isPending}
                    disabled={generateMutation.isPending}
                  >
                    ✨ AI Generate
                  </Button>
                  <Button
                    onClick={() => setPlanningWizardOpen(true)}
                    variant="primary"
                  >
                    Create Focus Card
                  </Button>
                </>
              )}
              {focusCard && (
                <Button
                  onClick={() => setPlanningWizardOpen(true)}
                  variant="secondary"
                >
                  Edit Card
                </Button>
              )}
            </div>
          </div>
        </div>
      </header>

      {/* Main Content */}
      <main className="mx-auto max-w-4xl px-md py-xl">
        {error && !focusCard && (
          <div className="text-center">
            <p className="text-body-md text-status-error">
              Failed to load focus card
            </p>
            <p className="mt-sm text-body-sm text-text-tertiary">
              {error instanceof Error ? error.message : 'Unknown error'}
            </p>
          </div>
        )}

        {!focusCard && !error && (
          <div className="flex flex-col items-center justify-center py-xxxl text-center">
            <div className="mb-lg text-6xl">🎯</div>
            <h2 className="text-title-md text-text-primary">
              No Focus Card Yet
            </h2>
            <p className="mt-sm max-w-md text-body-md text-text-secondary">
              Create your daily focus card to organize your top 3-5 priorities.
              Use AI generation or manually select items from your lists.
            </p>
            <div className="mt-xl flex gap-md">
              <Button
                onClick={handleGenerateAI}
                variant="primary"
                isLoading={generateMutation.isPending}
              >
                ✨ AI Generate
              </Button>
              <Button
                onClick={() => setPlanningWizardOpen(true)}
                variant="secondary"
              >
                Manual Planning
              </Button>
            </div>
          </div>
        )}

        {focusCard && (
          <FocusCard
            card={focusCard}
            onUpdate={(updates) =>
              updateMutation.mutate({ id: focusCard.id, updates })
            }
          />
        )}
      </main>

      {/* Planning Wizard Modal */}
      <PlanningWizard
        isOpen={isPlanningWizardOpen}
        onClose={() => setPlanningWizardOpen(false)}
        preSelectedItems={selectedItemsForPlanning}
        existingCard={focusCard}
      />
    </div>
  );
}
