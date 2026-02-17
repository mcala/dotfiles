# Using Git

- Commit messages should be concise and descriptive
- Commit messages should be written in the imperative mood
- commit messages should be written in the present tense
- Commit messages should follow the conventional commit specification

## Conventional Commit Messages

We use the conventional commit specification:

```
<type>(optional scope): <description>

<optional body>

<optional footer(s)>
```

- type: feat, fix, docs, style, refactor, test, chore, data, build, revert
- optional scope: Changed components/modules
- breaking_change_indicator: if the commit has a breaking change, an exclamation point is used before the colon after the parenthesis of the scope are closed
- description: Summary of changes (aim for 80 characters or less)
- optional body: Detailed description (optional)
- optional footer(s): Breaking changes, issue reference (optional)

### Types

The following are the ONLY types that are allowed.

- fix: a commit that patches a bug in your codebase (this correlates with PATCH in Semantic Versioning).
- feat: a commit that introduces a new feature to the codebase (this correlates with MINOR in Semantic Versioning).
- docs: a commit that only changes documentation
- style: a commit that does not affect the meaning of the code
- refactor: a commit that contains a code change that neither fixes a bug nor adds a new feature
- test: a commit that adds or corrects tests
- build: a commit that changes build systems or external dependencies
- data: a commit that adds or changes data included in the repository
- revert: a commit that reverts a previous commit
- chore: a commit that does not modify src or test files

### Scope

A scope MAY be provided after a type. A scope MUST consist of a noun describing a section of the codebase surrounded by parenthesis.

<example>
fix(parser):
</example>

### Description

A description MUST immediately follow the colon and space after the type/scope prefix. The description is a short summary of the code changes.

<example>
fix: array parsing issue when multiple spaces were contained in string.
</example>

### Body

A longer commit body MAY be provided after the short description, providing additional contextual information about the code changes. The body MUST begin one blank line after the description.

A commit body is free-form and MAY consist of any number of newline separated paragraphs.

### Footer

If there are breaking changes, they are elaborated on in the footer as follows, to make identifying and grepping for them easier.
`BREAKING CHANGE:``

## Breaking Changes

A commit that has a footer BREAKING CHANGE:, or appends a ! after the type/scope, introduces a breaking API change (correlating with MAJOR in Semantic Versioning). A BREAKING CHANGE can be part of commits of any type.

If ! is used, BREAKING CHANGE: MAY be omitted from the footer section, and the commit description SHALL be used to describe the breaking change.

### Breaking Changes Header Example

If there are breaking changes, you indicate this by an exclamation point `!` before the colon in the header of the commit message.
<example>
feat(main)!: Rewrites main function
</example>

## Full Example Commit

<example>

```
feat(reso_tweak)!: Updates method for handling the duplicate resolutions
recipient information into the summary column.

The update summary with additional info (formerly just duplicate resolutions)
method now handles adding both duplicates and intended recipient
information into the summary column. The method both checks for and
overwrites the information if it is already there so that we do not continuously add to the summary.

The duplicate information is now properly parsed. The column can be either a
str(int) or a str(list[int]), but is read correctly. This allows
including the actual duplicate information into the summary from other
rows in the dataframe.

BREAKING CHANGE: The method is no longer 'apply-able' through pandas.The old
`apply` method is renamed `append_simple_duplicate_info_to_summary`.
```

</example>
