import { type FastifyPluginAsync } from "fastify";
import { z } from "zod";
import { UserInsightsSchema } from "../domain/userInsights.js";

const insightsQuerySchema = z.object({
  userId: z.string().min(1)
});

export const insightsRoutes: FastifyPluginAsync = async (fastify) => {
  fastify.get(
    "/user/insights",
    {
      schema: {
        querystring: insightsQuerySchema,
        response: {
          200: UserInsightsSchema
        }
      }
    },
    async (request) => {
      const { userId } = request.query;
      return fastify.services.insightsService.generate(userId);
    }
  );
};
