## GitHub Account
**ALWAYS** use **vwjugow** for all projects:
- SSH: `git@github.com:vwjugow/<repo>.git`

## Behavior
### Talk
Be succint, explain changes briefly unless asked to do a deep research.
Never use acronyms. Always spell things out.
Use simple terms, not the latest US or engineering jargon. Be precise, do not overload words with multiple meanings. Be explicit.
Do not use 'cool phrases', e.g: "belt-and-braces", "load-bearing", "red herring", ETC!. Keep language straight and simple, no sugar coating. User's mother tongue is NOT English.
### Tone / don't-hedge
User knows how deployments work. Don't state "not deployed / needs CI build".
Assume senior-engineer audience. No hand-holding, no explaining what he already knows, no "honest caveat:" preamble with super basic stuff.
Distinguish verified-live vs. reasoned-from-code in ONE short clause, then move on.
### coding + results + operations
Do not use "assert called" type of asserts in tests. These couple test to implementation.
Name methods and functions (private ones too) as "verb_direct_object": `build_name_match_key`, `load_rows_by_id`, `resolve_entries`. Not a bare noun (`values`, `target_only_warnings`) or a preposition phrase (`with_id`, `to_columns`). Reasonable exceptions: predicates (`is_active`, `has_contact`), conversions (`to_dict`) and framework or overridden names (`validate`, `setUp`).
ALWAYS give the full absolute path when writing a file to the scratchpad directory, but in general prefer local files.
If instructions reference a skill that does not exist / cannot be invoked, say so LOUDLY and up front (name the missing skill) instead of silently working around it.
Please always consider symlinks, I have a few of them, and dirs you see as different point to the same hard dir, do not report this as stale copies or similar.

## Don't do unless told:
Ammend / squash commits. Just create new commits and human user will handle squashing them.

## NEVER EVER DO
### NEVER use non-ASCII characters in code or comments
Use only plain ASCII. Never use em dashes (`—`), curly quotes, or any non-ASCII character.
Simply prefer commas.

### NEVER Publish Sensitive Data
NEVER publish passwords, API keys, tokens
Do not load these into your context.
do not read (`cat/more/less/etc`) files when they clearly indicate they contain a token or apikey, eg "rancher_token", "gh_token".
Instead, use `"$(cat <file>)"` when you need to pass the token in a shell command or use a temporary envar

### NEVER delete files
Let me know which files you want removed and I'll do tha manually.
As an alternative, if the file you need deleting is git tracked and you just needed to rename or move it, feel free to use `git rm` or `git mv`.
