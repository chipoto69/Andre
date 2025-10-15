import { type FastifyPluginAsync } from "fastify";
import { z } from "zod";
import { ClassificationService } from "../services/classificationService.js";

const ClassifyItemRequestSchema = z.object({
  text: z.string().min(1),
  userId: z.string().optional(),
  context: z
    .object({
      currentTime: z.string().datetime().optional(),
      recentItems: z.array(z.string()).optional()
    })
    .optional()
});

const classificationService = new ClassificationService();

export const classificationRoutes: FastifyPluginAsync = async (fastify) => {
  fastify.post(
    "/items/classify",
    {
      schema: {
        body: ClassifyItemRequestSchema,
        response: {
          200: z.object({
            suggestedListType: z.enum(["todo", "watch", "later"]),
            confidence: z.number().min(0).max(1),
            reasoning: z.string().optional(),
            source: z.enum(["keyword", "fallback"]),
            alternatives: z.array(
              z.object({
                listType: z.enum(["todo", "watch", "later"]),
                confidence: z.number().min(0).max(1)
              })
            )
          })
        }
      }
    },
    async (request) => {
      return classificationService.classify(request.body.text);
    }
  );
};
