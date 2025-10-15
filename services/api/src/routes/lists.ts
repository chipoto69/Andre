import { type FastifyPluginAsync } from "fastify";
import { z } from "zod";
import {
  ListItemSchema,
  NewListItemSchema,
  UpdateListItemSchema
} from "../domain/listItem.js";
import { BoardSchema } from "../services/listService.js";

const IdParamSchema = z.object({ id: z.string().uuid() });

export const listsRoutes: FastifyPluginAsync = async (fastify) => {
  fastify.get(
    "/lists/sync",
    {
      schema: {
        response: {
          200: BoardSchema
        }
      }
    },
    async () => {
      return fastify.services.listService.getBoard();
    }
  );

  fastify.post(
    "/lists",
    {
      schema: {
        body: NewListItemSchema,
        response: {
          201: ListItemSchema
        }
      }
    },
    async (request, reply) => {
      const created = fastify.services.listService.createItem(request.body);
      reply.code(201);
      return created;
    }
  );

  fastify.put(
    "/lists/:id",
    {
      schema: {
        params: IdParamSchema,
        body: UpdateListItemSchema,
        response: {
          200: ListItemSchema
        }
      }
    },
    async (request, reply) => {
      const updated = fastify.services.listService.updateItem(
        request.params.id,
        request.body
      );
      if (!updated) {
        return reply.notFound("List item not found");
      }
      return updated;
    }
  );

  fastify.delete(
    "/lists/:id",
    {
      schema: {
        params: IdParamSchema,
        response: {
          204: z.null()
        }
      }
    },
    async (request, reply) => {
      fastify.services.listService.deleteItem(request.params.id);
      reply.code(204);
      return null;
    }
  );
};
