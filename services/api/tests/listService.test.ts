import { beforeEach, describe, expect, it } from "vitest";
import { connect, resetDatabase, getDbInstance } from "../src/infra/sqlite.js";
import { ListRepository } from "../src/infra/listRepository.js";
import { ListService } from "../src/services/listService.js";

describe("ListService", () => {
  let service: ListService;

  beforeEach(() => {
    connect({ memory: true });
    resetDatabase();
    const repo = new ListRepository(getDbInstance());
    service = new ListService(repo);
  });

  it("creates and retrieves list items within the board snapshot", () => {
    const created = service.createItem({
      title: "Prepare nightly focus card",
      listType: "todo"
    });

    expect(created.title).toBe("Prepare nightly focus card");

    const board = service.getBoard();
    expect(board.todo.length).toBe(1);
    expect(board.todo[0].id).toBe(created.id);
  });
});
