# NumeroMoney skills

Agent skills for [NumeroMoney](https://www.numeromoney.com). With the `numeromoney` skill installed, an AI agent such as Claude Code, Codex or Copilot knows how to use the [NumeroMoney User API](https://www.numeromoney.com/docs/user-api): report spending, import bank statements, categorise Transactions, set up Categorisation Rules and match transfers between your accounts.

The skill sends the agent to the live API reference for endpoint details, and adds the workflows and conventions that the reference leaves to the caller. It asks the agent to check with you before bulk changes and deletes.

## Before you start

1. Check you have Pro access. The User API is a Pro feature, available with a subscription or during the 30 day trial.
1. In NumeroMoney, go to **Settings** > **User API Access Tokens** and create a token. Choose **Read** for reports, or **Read and write** to let the agent import and categorise.
1. Put the token in the environment the agent runs in, as `NUMEROMONEY_TOKEN`. A `.env` file that git ignores works well:

   ```bash
   NUMEROMONEY_TOKEN=...
   ```

## Install

### Claude Code

```text
/plugin marketplace add appsoftwareltd/numeromoney-skills
/plugin install numeromoney@numeromoney
```

### Other agents

With the [`skills` CLI](https://github.com/vercel-labs/skills):

```bash
npx skills add appsoftwareltd/numeromoney-skills
```

Or copy the skill folder into your agent's skills folder, for example:

```bash
git clone https://github.com/appsoftwareltd/numeromoney-skills
cp -r numeromoney-skills/skills/numeromoney ~/.claude/skills/    # Claude Code
cp -r numeromoney-skills/skills/numeromoney ~/.agents/skills/    # agents that read ~/.agents
```

## What is in it

| Path | What it is |
| --- | --- |
| `skills/numeromoney/SKILL.md` | The skill: token handling, calling conventions, and the workflows for reports, imports, categorisation and transfers. |
| `skills/numeromoney/scripts/nm.sh` | A small curl wrapper that keeps the token out of the process list and output, and waits out rate limits. |

Every change a token makes appears in NumeroMoney under **Settings** > **User API Change Log**, with the values before and after.

## Licence

[MIT](LICENSE)
