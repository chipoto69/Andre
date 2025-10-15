import { z } from "zod";
import {
  ListItem,
  ListItemSchema,
  NewListItem,
  NewListItemSchema,
  UpdateListItem,
  UpdateListItemSchema
} from "../domain/listItem.js";
import { ListRepository } from "../infra/listRepository.js";

export const BoardSchema = z.object({
  todo: z.array(ListItemSchema),
  watch: z.array(ListItemSchema),
  later: z.array(ListItemSchema),
  antiTodo: z.array(ListItemSchema)
});

export type BoardSnapshot = z.infer<typeof BoardSchema>;

export class ListService {
  constructor(private readonly repo: ListRepository) {}

  createItem(payload: NewListItem): ListItem {
    const parsed = NewListItemSchema.parse(payload);
    return this.repo.upsert(parsed);
  }

  updateItem(id: string, payload: UpdateListItem): ListItem | null {
    const parsed = UpdateListItemSchema.parse(payload);
    return this.repo.update(id, parsed);
  }

  deleteItem(id: string): void {
    this.repo.delete(id);
  }

  getBoard(): BoardSnapshot {
    const board = this.repo.boardSnapshot();
    return BoardSchema.parse(board);
  }
}
