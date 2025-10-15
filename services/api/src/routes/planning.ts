import { type FastifyPluginAsync } from "fastify";
import { z } from "zod";
import {
  AntiTodoEntrySchema,
  DailyFocusCardSchema,
  GenerateFocusCardPayloadSchema,
  IsoDateSchema
} from "../domain/focusCard.js";

const dateQuerySchema = z.object({
  date: IsoDateSchema
});

const antiTodoQuerySchema = z.object({
  date: IsoDateSchema.optional()
});

export const planningRoutes: FastifyPluginAsync = async (fastify) => {
  fastify.get(
    "/focus-card",
    {
      schema: {
        querystring: dateQuerySchema,
        response: {
          200: DailyFocusCardSchema
        }
      }
    },
    async (request, reply) => {
      const card = await fastify.services.planService.getFocusCard(request.query.date);
      if (!card) {
        return reply.notFound("Focus card not generated yet.");
      }
      return card;
    }
  );

  fastify.post(
    "/focus-card/generate",
    {
      schema: {
        body: GenerateFocusCardPayloadSchema.optional(),
        response: {
          200: DailyFocusCardSchema
        }
      }
    },
    async (request) => {
      return fastify.services.planService.generateFocusCard(request.body ?? {});
    }
  );

  fastify.put(
    "/focus-card",
    {
      schema: {
        body: DailyFocusCardSchema,
        response: {
          200: DailyFocusCardSchema
        }
      }
    },
    async (request) => {
      return fastify.services.planService.saveFocusCard(request.body);
    }
  );

  fastify.post(
    "/anti-todo",
    {
      schema: {
        body: AntiTodoEntrySchema,
        response: {
          201: AntiTodoEntrySchema
        }
      }
    },
    async (request, reply) => {
      const entry = await fastify.services.planService.logAntiTodo(request.body);
      reply.code(201);
      return entry;
    }
  );

  fastify.get(
    "/anti-todo",
    {
      schema: {
        querystring: antiTodoQuerySchema,
        response: {
          200: z.array(AntiTodoEntrySchema)
        }
      }
    },
    async (request) => {
      const date = request.query.date ?? new Date().toISOString().slice(0, 10);
      return fastify.services.planService.listAntiTodoEntries(date);
    }
  );
};
