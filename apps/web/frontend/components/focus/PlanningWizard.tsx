'use client';

import { useState, useEffect } from 'react';
import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query';
import { apiClient, DailyFocusCard, EnergyBudget } from '@/lib/api-client';
import { Modal, Button, TextField, TextArea, Checkbox, Select } from '@/components/ui';
import { getTodayDate } from '@/lib/utils';

interface PlanningWizardProps {
  isOpen: boolean;
  onClose: () => void;
  preSelectedItems?: Set<string>;
  existingCard?: DailyFocusCard | null;
}

type WizardStep = 'items' | 'context' | 'success';

export function PlanningWizard({
  isOpen,
  onClose,
  preSelectedItems = new Set(),
  existingCard,
}: PlanningWizardProps) {
  const queryClient = useQueryClient();
  const [currentStep, setCurrentStep] = useState<WizardStep>('items');
  const [selectedItemIds, setSelectedItemIds] = useState<Set<string>>(new Set());
  const [theme, setTheme] = useState('');
  const [energyBudget, setEnergyBudget] = useState<EnergyBudget>('medium');
  const [successMetric, setSuccessMetric] = useState('');

  // Fetch available items
  const { data: board } = useQuery({
    queryKey: ['lists', 'board'],
    queryFn: () => apiClient.getBoard(),
    enabled: isOpen,
  });

  const allItems = board
    ? [...board.todo, ...board.watch, ...board.later].filter(
        (item) => item.status !== 'completed' && item.status !== 'archived'
      )
    : [];

  // Initialize with pre-selected items or existing card
  useEffect(() => {
    if (isOpen) {
      if (existingCard) {
        setSelectedItemIds(new Set(existingCard.items.map((i) => i.id)));
        setTheme(existingCard.meta.theme);
        setEnergyBudget(existingCard.meta.energyBudget);
        setSuccessMetric(existingCard.meta.successMetric);
        setCurrentStep('context');
      } else if (preSelectedItems.size > 0) {
        setSelectedItemIds(new Set(preSelectedItems));
        setCurrentStep('context');
      } else {
        setCurrentStep('items');
      }
    }
  }, [isOpen, preSelectedItems, existingCard]);

  // Create/Update mutation
  const saveMutation = useMutation({
    mutationFn: async () => {
      const selectedItems = allItems.filter((item) =>
        selectedItemIds.has(item.id)
      );

      const cardData = {
        date: getTodayDate(),
        items: selectedItems,
        meta: {
          theme,
          energyBudget,
          successMetric,
        },
      };

      if (existingCard) {
        return apiClient.updateFocusCard(existingCard.id, cardData);
      } else {
        return apiClient.createFocusCard(cardData);
      }
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['focus'] });
      queryClient.invalidateQueries({ queryKey: ['lists'] });
      handleClose();
    },
  });

  const handleClose = () => {
    setCurrentStep('items');
    setSelectedItemIds(new Set());
    setTheme('');
    setEnergyBudget('medium');
    setSuccessMetric('');
    onClose();
  };

  const handleToggleItem = (itemId: string) => {
    const newSelected = new Set(selectedItemIds);
    if (newSelected.has(itemId)) {
      newSelected.delete(itemId);
    } else {
      if (newSelected.size < 5) {
        newSelected.add(itemId);
      }
    }
    setSelectedItemIds(newSelected);
  };

  const handleNext = () => {
    if (currentStep === 'items') setCurrentStep('context');
    else if (currentStep === 'context') setCurrentStep('success');
  };

  const handleBack = () => {
    if (currentStep === 'success') setCurrentStep('context');
    else if (currentStep === 'context') setCurrentStep('items');
  };

  const canProceed = () => {
    if (currentStep === 'items') return selectedItemIds.size >= 3 && selectedItemIds.size <= 5;
    if (currentStep === 'context') return theme.trim().length > 0;
    if (currentStep === 'success') return successMetric.trim().length > 0;
    return false;
  };

  const stepTitles = {
    items: 'Select Focus Items (3-5)',
    context: 'Set Theme & Energy',
    success: 'Define Success',
  };

  return (
    <Modal
      isOpen={isOpen}
      onClose={handleClose}
      title="Create Focus Card"
      size="large"
    >
      <div className="space-y-lg">
        {/* Progress Steps */}
        <div className="flex items-center justify-between">
          {(['items', 'context', 'success'] as WizardStep[]).map((step, index) => (
            <div
              key={step}
              className={`flex items-center ${index < 2 ? 'flex-1' : ''}`}
            >
              <div
                className={`flex h-8 w-8 items-center justify-center rounded-full text-label-md font-semibold ${
                  currentStep === step
                    ? 'bg-accent-primary text-brand-black'
                    : selectedItemIds.size >= 3 || step === 'items'
                      ? 'bg-background-tertiary text-text-secondary'
                      : 'bg-background-tertiary text-text-tertiary'
                }`}
              >
                {index + 1}
              </div>
              {index < 2 && (
                <div
                  className={`mx-xs h-0.5 flex-1 ${
                    index === 0 && (currentStep === 'context' || currentStep === 'success')
                      ? 'bg-accent-primary'
                      : index === 1 && currentStep === 'success'
                        ? 'bg-accent-primary'
                        : 'bg-background-tertiary'
                  }`}
                />
              )}
            </div>
          ))}
        </div>

        <div className="border-b border-background-tertiary pb-md">
          <h3 className="text-title-sm font-semibold text-text-primary">
            {stepTitles[currentStep]}
          </h3>
        </div>

        {/* Step Content */}
        <div className="min-h-[400px]">
          {currentStep === 'items' && (
            <div className="space-y-md">
              <p className="text-body-sm text-text-secondary">
                Choose 3-5 items from your lists to focus on today. These should be
                your highest priority tasks.
              </p>
              <div className="max-h-96 space-y-xs overflow-y-auto">
                {allItems.length === 0 ? (
                  <p className="py-xl text-center text-body-sm text-text-tertiary">
                    No items available. Add items to your lists first.
                  </p>
                ) : (
                  allItems.map((item) => (
                    <label
                      key={item.id}
                      className={`flex cursor-pointer items-start gap-md rounded-medium border p-md transition-colors ${
                        selectedItemIds.has(item.id)
                          ? 'border-accent-primary bg-accent-primary/10'
                          : 'border-background-tertiary hover:bg-background-secondary'
                      }`}
                    >
                      <Checkbox
                        checked={selectedItemIds.has(item.id)}
                        onChange={() => handleToggleItem(item.id)}
                        disabled={
                          !selectedItemIds.has(item.id) && selectedItemIds.size >= 5
                        }
                      />
                      <div className="flex-1">
                        <p className="text-body-md text-text-primary">
                          {item.title}
                        </p>
                        {item.notes && (
                          <p className="mt-xs text-body-sm text-text-tertiary">
                            {item.notes}
                          </p>
                        )}
                        <p className="mt-xs text-label-sm text-text-tertiary">
                          {item.listType}
                        </p>
                      </div>
                    </label>
                  ))
                )}
              </div>
              <p className="text-label-sm text-text-tertiary">
                Selected: {selectedItemIds.size} / 5
              </p>
            </div>
          )}

          {currentStep === 'context' && (
            <div className="space-y-lg">
              <TextField
                label="Theme"
                placeholder="What's the theme for today? (e.g., 'Deep Work Day', 'Client Focus')"
                value={theme}
                onChange={(e) => setTheme(e.target.value)}
                helperText="A short phrase that captures the essence of today's work"
                autoFocus
              />

              <Select
                label="Energy Budget"
                value={energyBudget}
                onChange={(e) => setEnergyBudget(e.target.value as EnergyBudget)}
                options={[
                  { value: 'low', label: 'Low - Light tasks, recovery mode' },
                  { value: 'medium', label: 'Medium - Normal productivity' },
                  { value: 'high', label: 'High - Peak performance, deep work' },
                ]}
              />
            </div>
          )}

          {currentStep === 'success' && (
            <div className="space-y-lg">
              <TextArea
                label="Success Metric"
                placeholder="How will you know today was successful? (e.g., 'Shipped feature X', 'Cleared inbox to zero')"
                value={successMetric}
                onChange={(e) => setSuccessMetric(e.target.value)}
                rows={4}
                helperText="Be specific and measurable"
                autoFocus
              />

              {/* Summary */}
              <div className="rounded-medium bg-background-tertiary p-lg">
                <h4 className="text-label-lg font-medium text-text-primary">
                  Summary
                </h4>
                <div className="mt-md space-y-sm text-body-sm">
                  <p>
                    <span className="text-text-tertiary">Items:</span>{' '}
                    <span className="text-text-primary">
                      {selectedItemIds.size}
                    </span>
                  </p>
                  <p>
                    <span className="text-text-tertiary">Theme:</span>{' '}
                    <span className="text-text-primary">{theme}</span>
                  </p>
                  <p>
                    <span className="text-text-tertiary">Energy:</span>{' '}
                    <span className="text-text-primary">{energyBudget}</span>
                  </p>
                </div>
              </div>
            </div>
          )}
        </div>

        {/* Actions */}
        <div className="flex justify-between border-t border-background-tertiary pt-md">
          <Button variant="ghost" onClick={currentStep === 'items' ? handleClose : handleBack}>
            {currentStep === 'items' ? 'Cancel' : 'Back'}
          </Button>

          <div className="flex gap-md">
            {currentStep !== 'success' ? (
              <Button
                variant="primary"
                onClick={handleNext}
                disabled={!canProceed()}
              >
                Next
              </Button>
            ) : (
              <Button
                variant="primary"
                onClick={() => saveMutation.mutate()}
                disabled={!canProceed() || saveMutation.isPending}
                isLoading={saveMutation.isPending}
              >
                {existingCard ? 'Update Focus Card' : 'Create Focus Card'}
              </Button>
            )}
          </div>
        </div>
      </div>
    </Modal>
  );
}
