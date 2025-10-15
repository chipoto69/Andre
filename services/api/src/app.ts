import Fastify from "fastify";
import cors from "@fastify/cors";
import helmet from "@fastify/helmet";
import sensible from "@fastify/sensible";
import { type ZodTypeProvider } from "fastify-type-provider-zod";
import { connect } from "./infra/sqlite.js";
import { ListRepository } from "./infra/listRepository.js";
import { FocusCardRepository } from "./infra/focusCardRepository.js";
import { AntiTodoRepository } from "./infra/antiTodoRepository.js";
import { ListService } from "./services/listService.js";
import { PlanService } from "./services/planService.js";
import { UserPreferencesRepository } from "./infra/userPreferencesRepository.js";
import { PreferencesService } from "./services/preferencesService.js";
import { listsRoutes } from "./routes/lists.js";
import { planningRoutes } from "./routes/planning.js";
import { suggestionsRoutes } from "./routes/suggestions.js";
import { preferencesRoutes } from "./routes/preferences.js";
import { classificationRoutes } from "./routes/classification.js";
import { SuggestionService } from "./services/suggestionService.js";
import { InsightsService } from "./services/insightsService.js";
import { insightsRoutes } from "./routes/insights.js";

const fastify = Fastify({
  logger: true
}).withTypeProvider<ZodTypeProvider>();

await fastify.register(cors);
await fastify.register(helmet);
await fastify.register(sensible);

const db = connect();
const listRepository = new ListRepository(db);
const focusCardRepository = new FocusCardRepository(db);
const antiTodoRepository = new AntiTodoRepository(db);

const listService = new ListService(listRepository);
const planService = new PlanService(listRepository, focusCardRepository, antiTodoRepository);
const suggestionService = new SuggestionService(listRepository, antiTodoRepository);
const userPreferencesRepository = new UserPreferencesRepository(db);
const preferencesService = new PreferencesService(userPreferencesRepository);
const insightsService = new InsightsService(listRepository);

fastify.decorate("services", {
  listService,
  planService,
  suggestionService,
  preferencesService,
  insightsService
});

await fastify.register(listsRoutes, { prefix: "/v1" });
await fastify.register(planningRoutes, { prefix: "/v1" });
await fastify.register(suggestionsRoutes, { prefix: "/v1" });
await fastify.register(preferencesRoutes, { prefix: "/v1" });
await fastify.register(classificationRoutes, { prefix: "/v1" });
await fastify.register(insightsRoutes, { prefix: "/v1" });

fastify.get("/health", async () => ({ status: "ok" }));

const port = Number(process.env.PORT ?? 3333);
const host = process.env.HOST ?? "0.0.0.0";

try {
  await fastify.listen({ port, host });
  fastify.log.info(`Andre API running on http://${host}:${port}`);
} catch (error) {
  fastify.log.error(error);
  process.exit(1);
}

declare module "fastify" {
  interface FastifyInstance {
    services: {
      listService: ListService;
      planService: PlanService;
      suggestionService: SuggestionService;
      preferencesService: PreferencesService;
      insightsService: InsightsService;
    };
  }
}
