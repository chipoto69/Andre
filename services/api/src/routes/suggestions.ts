import { type FastifyPluginAsync } from "fastify";
import { z } from "zod";
import { SuggestionListSchema } from "../domain/suggestion.js";

const querySchema = z.object({
  limit: z.coerce.number().int().min(1).max(10).optional()
});

export const suggestionsRoutes: FastifyPluginAsync = async (fastify) => {
  fastify.get(
    "/suggestions/structured-procrastination",
    {
      schema: {
        querystring: querySchema,
        response: {
          200: SuggestionListSchema
        }
      }
    },
    async (request) => {
      const limit = request.query.limit;
      const suggestions =
        fastify.services.suggestionService.generateStructuredProcrastinationSuggestions(
          limit ? { limit } : {}
        );
      return suggestions;
    }
  );
};
