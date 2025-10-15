'use client';

import { useState } from 'react';
import { useMutation, useQueryClient } from '@tanstack/react-query';
import { apiClient, ListType } from '@/lib/api-client';
import { Modal, TextField, TextArea, Select, Button } from '@/components/ui';

interface QuickCaptureModalProps {
  isOpen: boolean;
  onClose: () => void;
  defaultListType?: ListType;
}

export function QuickCaptureModal({
  isOpen,
  onClose,
  defaultListType = 'todo',
}: QuickCaptureModalProps) {
  const queryClient = useQueryClient();
  const [title, setTitle] = useState('');
  const [notes, setNotes] = useState('');
  const [listType, setListType] = useState<ListType>(defaultListType);
  const [error, setError] = useState('');

  const createMutation = useMutation({
    mutationFn: (data: { title: string; listType: ListType; notes?: string }) =>
      apiClient.createListItem(data),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['lists'] });
      handleClose();
    },
    onError: (error) => {
      setError(error instanceof Error ? error.message : 'Failed to create item');
    },
  });

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    
    if (!title.trim()) {
      setError('Title is required');
      return;
    }

    createMutation.mutate({
      title: title.trim(),
      listType,
      notes: notes.trim() || undefined,
    });
  };

  const handleClose = () => {
    setTitle('');
    setNotes('');
    setListType(defaultListType);
    setError('');
    onClose();
  };

  return (
    <Modal
      isOpen={isOpen}
      onClose={handleClose}
      title="Quick Capture"
      description="Add a new item to your lists"
      size="medium"
    >
      <form onSubmit={handleSubmit} className="space-y-lg">
        <TextField
          label="Title"
          placeholder="What needs to be done?"
          value={title}
          onChange={(e) => {
            setTitle(e.target.value);
            setError('');
          }}
          error={error}
          autoFocus
        />

        <Select
          label="List Type"
          value={listType}
          onChange={(e) => setListType(e.target.value as ListType)}
          options={[
            { value: 'todo', label: 'Todo - Immediate action' },
            { value: 'watch', label: 'Watch - Follow up' },
            { value: 'later', label: 'Later - Future consideration' },
          ]}
        />

        <TextArea
          label="Notes (optional)"
          placeholder="Add any additional details..."
          value={notes}
          onChange={(e) => setNotes(e.target.value)}
          rows={3}
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
            disabled={!title.trim()}
          >
            Create Item
          </Button>
        </div>
      </form>
    </Modal>
  );
}
