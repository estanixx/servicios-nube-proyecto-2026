# Skill Registry

**Delegator use only.** Any agent that launches sub-agents reads this registry to resolve compact rules, then injects them directly into sub-agent prompts. Sub-agents do NOT read this registry or individual SKILL.md files.

See `_shared/skill-resolver.md` for the full resolution protocol.

## User Skills

| Trigger | Skill | Path |
|---------|-------|------|
| when a PR would exceed 400 changed lines, when planning chained PRs, stacked PRs, or reviewable slices | chained-pr | /home/estanix/.claude/skills/chained-pr/SKILL.md |
| when creating a pull request, opening a PR, or preparing changes for review | branch-pr | /home/estanix/.claude/skills/branch-pr/SKILL.md |
| when drafting or posting feedback, review comments, maintainer replies, Slack messages, or GitHub comments | comment-writer | /home/estanix/.claude/skills/comment-writer/SKILL.md |
| design documentation that reduces reader cognitive load through progressive disclosure, chunking, signposting, tables, checklists, and recognition over recall | cognitive-doc-design | /home/estanix/.claude/skills/cognitive-doc-design/SKILL.md |
| Go testing patterns for Gentleman.Dots, including Bubbletea TUI testing | go-testing | /home/estanix/.claude/skills/go-testing/SKILL.md |
| when creating a GitHub issue, reporting a bug, or requesting a feature | issue-creation | /home/estanix/.claude/skills/issue-creation/SKILL.md |
| parallel adversarial review protocol | judgment-day | /home/estanix/.claude/skills/judgment-day/SKILL.md |
| Creates new AI agent skills following the Agent Skills spec | skill-creator | /home/estanix/.claude/skills/skill-creator/SKILL.md |
| when implementing a change, preparing commits, splitting PRs, or planning chained or stacked PRs | work-unit-commits | /home/estanix/.claude/skills/work-unit-commits/SKILL.md |

## Compact Rules

Pre-digested rules per skill. Delegators copy matching blocks into sub-agent prompts as `## Project Standards (auto-resolved)`.

### chained-pr
- Split PRs exceeding 400 lines into reviewable chained slices
- Each PR in the chain should be independently mergeable and tests pass
- Use stacked PRs when later PRs depend on earlier ones
- Rebase strategy keeps chain clean, merge strategy preserves history

### branch-pr
- Issue-first enforcement: every PR must link to an issue
- Create branch from main using pattern: feature/issue-###-short-description
- Draft PRs for early review, convert when ready
- Keep PR scope small (<400 lines cognitive budget)

### comment-writer
- Warm, professional, direct tone — no slang
- Validate the question makes sense first
- Explain WHY with technical reasoning, then show correct way
- Use CAPS for emphasis to convey care about growth
- Write as if async: brief, clear, actionable

### cognitive-doc-design
- Progressive disclosure: start with summary, drill into details
- Chunk content with clear headers and visual hierarchy
- Tables for comparison, checklists for steps
- Recognition over recall: remind readers of context
- Signpost: tell readers what they'll learn and what's next

### go-testing
- Use teatest for Bubbletea TUI testing
- Table-driven tests for multiple scenarios
- Mock external dependencies
- Coverage should test happy path and error paths

### issue-creation
- Issue-first enforcement in workflow
- Bug reports: reproduce steps, expected vs actual, environment
- Feature requests: motivation, proposed solution, alternatives considered
- Use labels to categorize and prioritize

### judgment-day
- Launch two independent blind judges simultaneously
- Synthesize findings, apply fixes, re-judge
- Both must pass or escalate after 2 iterations
- Use for high-risk changes or architectural decisions

### skill-creator
- Follow Agent Skills spec format with frontmatter
- Include: name, description (with trigger), rules, patterns
- Document edge cases and gotchas
- Keep skill focused on single responsibility

### work-unit-commits
- Structure commits as deliverable work units, not file-type batches
- Tests and docs live beside the code they verify
- Commit message explains WHY, not just what changed
- Each commit should be independently meaningful

## Project Conventions

No convention files found (AGENTS.md, CLAUDE.md, .cursorrules, GEMINI.md, or copilot-instructions.md).

## AWS Architecture Context

This Next.js app provisions AWS services (not developed by us). Lambda functions MUST be developed by us.

| Service | Purpose | Key Config |
|---------|---------|------------|
| EC2 | Host Next.js app via SSH (non-default port) | SSH on non-port-22 |
| RDS | PostgreSQL database | Port 9876, security groups, VPC |
| S3 | Employee images bucket | NOT public |
| Lambda | Insert team member data into RDS | Developed by us |
| API Gateway | Protect Lambda with API Keys | API Key auth |
| CloudWatch | Monitoring | SNS alerts |
| VPC | Network isolation | For DB, Lambda, S3 |

## DDL Script

Database schema defined in: `database/ddl-estudiante.sql`
- Table: `public.estudiante`
- Columns: id, nombre, apellido, fecha_nacimiento, direccion, correo_electronico, carrera
- 20 dummy records pre-populated

## Next Steps

The orchestrator reads this registry once per session and passes pre-resolved skill paths to sub-agents via their launch prompts.
To update after installing/removing skills, run this again.