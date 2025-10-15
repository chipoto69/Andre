'use client';

import { useState } from 'react';
import { useMutation, useQueryClient } from '@tanstack/react-query';
import { apiClient } from '@/lib/api-client';
import { Modal, TextField, Button } from '@/components/ui';

interface AddWinModalProps {
  isOpen: boolean;
  onClose: () => void;
  date: string;
}

export function AddWinModal({ isOpen, onClose }: AddWinModalProps) {
  const queryClient = useQueryClient();
  const [title, setTitle] = useState('');
  const [error, setError] = useState('');

  const createMutation = useMutation({
    mutationFn: (data: { title: string }) => apiClient.logAntiTodoEntry(data),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['anti-todo'] });
      handleClose();
    },
    onError: (err) => {
      setError(err instanceof Error ? err.message : 'Failed to log win');
    },
  });

  const handleClose = () => {
    setTitle('');
    setError('');
    onClose();
  };

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();

    if (!title.trim()) {
      setError('Title is required');
      return;
    }

    createMutation.mutate({ title: title.trim() });
  };

  return (
    <Modal
      isOpen={isOpen}
      onClose={handleClose}
      title="Log a Win 🏆"
      description="What did you accomplish?"
      size="medium"
    >
      <form onSubmit={handleSubmit} className="space-y-lg">
        <TextField
          label="Accomplishment"
          placeholder="e.g., Completed feature X, Finished report, Helped team member..."
          value={title}
          onChange={(e) => {
            setTitle(e.target.value);
            setError('');
          }}
          error={error}
          autoFocus
        />

        <div className="flex justify-end gap-md">
          <Button
            type="button"
            variant="secondary"
            onClick={handleClose}
            disabled={createMutation.isPending}
          >
            Cancel
          </Button>
          <Button
            type="submit"
            variant="primary"
            isLoading={createMutation.isPending}
            disabled={!title.trim() || createMutation.isPending}
          >
            Log Win
          </Button>
        </div>
      </form>
    </Modal>
  );
}
