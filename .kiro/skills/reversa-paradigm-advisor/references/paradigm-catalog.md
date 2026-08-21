> Local copy of the advisory catalogue. The canonical source is at `templates/migration/catalogs/paradigm_catalog.md`.
> This copy is installed together with the agent so that it has access to the catalog within the user's project, without depending on the location of the npm package.

# Paradigm Catalog (local copy)

## Paradigm catalog

### Procedural
- **Features**: top-level functions, linear flow in controllers, absence of classes or ornamental use, data as dicts/structs, open side effects.
- **Legacy examples**: classic PHP scripts, COBOL batch, pre-OO Perl systems, shell scripts.
- **Signals in `reversa/sdd/`**: domain described as "functions", linear flows in `process_flows`, absence of explicit aggregates.

### Classic OO
- **Features**: class hierarchy, strong inheritance, Active Record pattern, logic coupled to models.
- **Examples in legacy**: Monolithic Rails, traditional Django, Java EE pre-DI, .NET WebForms / classic.
- **Signals in `reversa/sdd/`**: classes with broad responsibilities, domain model inheritance, anemic controllers calling model methods.

### OO with DI
- **Features**: injection containers, explicit interfaces, Repository / Service pattern, clear separation between layers.
- **Examples in legacy**: Modern Spring, .NET 6+, NestJS, Modern Symfony.
- **Signals in `reversa/sdd/`**: explicit aggregates, repository interfaces, absence of Active Record.

### Functional
- **Characteristics**: dominant immutability, pure functions, composition, absence of implicit side effects, rich typing.
- **Examples in legacy**: Haskell, Elm, F#, functional Scala, Clojure.
- **Signs in `reversa/sdd/`**: algebraic types, absence of classes, flow expressed as composition.

### Event-driven (asynchronous)
- **Features**: queues / topics, decoupled handlers, lack of linear flow, eventual consistency, explicit idempotence.
- **Legacy examples**: modern queue-driven Node backends, SQS / Kafka heavy systems, asynchronous microservices.
- **Signals in `reversa/sdd/`**: events in the domain model, integrations via queue, long-running processes with retry.

### Actor model
- **Features**: isolated actors with mailbox, supervision, state isolation.
- **Examples in legacy**: Erlang / Elixir / OTP, Akka.
- **Signals in `reversa/sdd/`**: supervised processes, messages between actors.

### Dataflow
- **Features**: declarative pipelines, flow transformations, absence of imperative loops in the domain.
- **Examples in legacy**: Classic ETLs, Spark, Flink.
- **Signals in `reversa/sdd/`**: description in DAG, transformations in stages.

## Mapeamento stack → paradigma natural

| Target Stack | Natural paradigm | Viable alternatives | Notes |
|---|---|---|---|
| Node.js 20 (Fastify, Express, NestJS) | asynchronous event-driven | OO with DI (NestJS), lightweight functional | async-first runtime; Heavy CPU blocking goes to worker threads |
| Go (net/http, Echo, Fiber) | CSP / goroutines (lightweight event-driven) | structured procedural | competition via channels; OO simulated via interfaces |
| Rust (axum, Actix, tokio) | ownership / functional async | event-driven | immutability by default, security via types |
| Elixir / Phoenix | actor model (BEAM) | functional | supervision via OTP |
| Modern Python (FastAPI, Django 5) | OO with rich DI or procedural | event-driven (Celery, asyncio) | choice depends on the framework |
| Kotlin (Spring Boot, Ktor) | OO with DI | event-driven (Reactor) | coroutines enable ergonomic async |
| .NET 8 (ASP.NET Core, Minimal API) | OO with DI | event-driven (Channels, MediatR) | OO tradition + first-class asynchronism |
| Modern Java (Spring Boot 3, Quarkus) | OO with DI | event-driven (Project Reactor) | functional libraries possible but not dominant |
| Modern Ruby (Rails 7, Hanami) | Classic OO (Rails) or OO with DI (Hanami) | lightweight functional (dry-rb) | Rails dictates Active Record; Hanami is DI-heavy |
| Serverless TypeScript (AWS Lambda, Cloudflare Workers) | event-driven | functional | invocation by event; cold start influences design |

## Table of typical gaps per pair

| From → To | Main Gap | Concrete implications |
|---|---|---|
| procedural → event-driven | synchrony → asynchronism | response is no longer immediate; error handling becomes retry/DLQ; mandatory idempotence; order of events starts to matter |
| procedural → OO with DI | data as dict → aggregates | invariants are inside aggregates; logic stops living in controllers; dependencies via interfaces |
| procedural → functional | open side effects → pure + isolated | mutability becomes the exception; composition replaces sequence; algebraic types for states |
| Classic OO → event-driven | synchronous flow → choreography | actions are no longer atomic; distributed transactions become sagas; strong consistency → eventual |
| Classic OO → OO with DI | inheritance → composition via interfaces | Active Record disappears; persistence becomes repository; tests win natural mocks |
| Classic OO → functional | mutable encapsulation → immutability | effective methods become pure functions + explicit update; state expressed as a sequence of transformations |
| OO with DI → event-driven | synchronous command → event | return is no longer immediate; orchestration becomes choreography; order by key |
| OO with DI → functional | mocks → testable composition | DI stops being an interface, it becomes a function argument |
| functional → event-driven | synchronous composition → messaging | latency increases; failure becomes a message in DLQ; distributed state |
| event-driven → synchronous procedural | unnatural; only makes sense for small systems | collapse handlers into direct calls; loss of decoupling; strong consistency back |
| dataflow → event-driven | Declarative DAG → mutable choreography | control becomes less predictable; order needs to be guaranteed by key |
| actor model → OO with DI | messages between actors → synchronous calls | loss of fault isolation; supervision needs to become try/catch or orchestrated retry |
