## Infrastructure Plan

### Environments
- **Local**: SQLite database, Fastify API on Node.js, Swift package previews.
- **Staging**: Render/Heroku for API, managed Postgres, Vercel for web front-end, TestFlight builds.
- **Production**: Managed Postgres (Neon/Timescale), Fly.io or AWS Fargate for API, CDN-backed web deployment (Vercel/Cloudflare).

### Core components
- **Database**: Postgres with logical replication for analytics sink.
- **Migrations**: Prisma or Drizzle ORM migrations executed via `scripts/migrate`.
- **Secrets**: Doppler/1Password Secrets Automation for API keys and OAuth credentials.
- **Observability**: OpenTelemetry exporter → Honeycomb/Sentry, CloudWatch metrics fallback.
- **CI/CD**: GitHub Actions with workflows for API lint/test, iOS build checks, and infra previews.

### Releases
- API: Blue/green deploy with health check gating.
- iOS: Automated TestFlight promotion after CI success.
- Web: Preview deployments on every PR, promote after approvals.

### Backlog items
- Define Terraform/CDK stack for base infrastructure.
- Implement feature flags for structured procrastination experiments.
- Integrate job queue (Temporal/BullMQ) once nightly planning scales.
