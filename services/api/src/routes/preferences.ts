import { type FastifyPluginAsync } from "fastify";
import {
  GetUserPreferencesQuerySchema,
  UpsertUserPreferencesSchema,
  UserPreferencesSchema
} from "../domain/userPreferences.js";

export const preferencesRoutes: FastifyPluginAsync = async (fastify) => {
  fastify.post(
    "/user/preferences",
    {
      schema: {
        body: UserPreferencesSchema,
        response: {
          204: { type: "null" }
        }
      }
    },
    async (request, reply) => {
      const prefs = request.body;
      try {
        fastify.services.preferencesService.create(prefs);
      } catch (error) {
        reply.badRequest((error as Error).message);
        return;
      }
      reply.code(204);
      return null;
    }
  );

  fastify.put(
    "/user/preferences",
    {
      schema: {
        body: UpsertUserPreferencesSchema,
        response: {
          204: { type: "null" }
        }
      }
    },
    async (request, reply) => {
      fastify.services.preferencesService.upsert(request.body);
      reply.code(204);
      return null;
    }
  );

  fastify.get(
    "/user/preferences",
    {
      schema: {
        querystring: GetUserPreferencesQuerySchema
      }
    },
    async (request, reply) => {
      const { userId } = request.query;
      const prefs = fastify.services.preferencesService.get(userId);
      if (!prefs) {
        return reply.notFound("Preferences not found for user");
      }
      return prefs;
    }
  );
};
