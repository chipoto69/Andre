'use client';

import { Board, ListItem } from '@/lib/api-client';
import { ListColumn } from './ListColumn';

interface ListBoardProps {
  board: Board;
  onDelete: (id: string) => void;
  onUpdate: (id: string, updates: Partial<ListItem>) => void;
}

export function ListBoard({ board, onDelete, onUpdate }: ListBoardProps) {
  return (
    <div className="grid grid-cols-1 gap-lg md:grid-cols-2 lg:grid-cols-3">
      <ListColumn
        title="Todo"
        listType="todo"
        items={board.todo}
        onDelete={onDelete}
        onUpdate={onUpdate}
      />
      <ListColumn
        title="Watch"
        listType="watch"
        items={board.watch}
        onDelete={onDelete}
        onUpdate={onUpdate}
      />
      <ListColumn
        title="Later"
        listType="later"
        items={board.later}
        onDelete={onDelete}
        onUpdate={onUpdate}
      />
    </div>
  );
}
