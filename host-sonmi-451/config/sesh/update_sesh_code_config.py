#!/usr/bin/env -S uv run
# /// script
# requires-python = ">=3.13"
# ///
# ABOUTME: Generates sesh's code.toml with a session for each active code project.
# ABOUTME: Bare repositories also get a "repo/worktree" session for each worktree.
import logging
import subprocess
import sys
import textwrap
from datetime import datetime
from pathlib import Path

CODE_DIR = Path("/Users/mcala/Developer/1_active")
NAME_FIXES = ["Nj", "Fy", "Llm", "Api", "Abu", "Sfra"]


def send_custom_email(subject: str, body: str, recipient: str) -> None:
    """Send email with custom subject using msmtp."""
    email_content = f"""To: {recipient}
Subject: {subject}
Content-Type: text/plain; charset=utf-8

{body}
"""

    process = subprocess.Popen(["msmtp", recipient], stdin=subprocess.PIPE, text=True)
    process.communicate(input=email_content)


def send_notification(title: str, message: str) -> None:
    subprocess.run(
        ["osascript", "-e", f'display notification "{message}" with title "{title}"']
    )


def find_dirs() -> list[Path]:
    return [item for item in CODE_DIR.iterdir() if item.is_dir()]


def create_name(directory: Path) -> str:
    temp_name = directory.name.replace("_", " ").replace("-", " ").title()
    for name in NAME_FIXES:
        temp_name = temp_name.replace(name, name.upper())
    return temp_name


def find_worktrees(directory: Path) -> list[Path]:
    """Return the linked worktrees of a bare repository, or [] otherwise."""
    result = subprocess.run(
        ["git", "-C", str(directory), "worktree", "list", "--porcelain"],
        capture_output=True,
        text=True,
    )
    if result.returncode != 0:
        return []
    blocks = [block.splitlines() for block in result.stdout.strip().split("\n\n")]
    if not any("bare" in block for block in blocks):
        return []
    return [
        Path(block[0].removeprefix("worktree "))
        for block in blocks
        if "bare" not in block
    ]


def make_sesh_block(name: str, directory: Path) -> str:
    path: str = str(directory.resolve())
    block: str = f"""
        [[session]]
        name = "{name}"
        path = "{path}" """
    return block


def main():
    logging.basicConfig(
        level=logging.INFO,
        format="%(asctime)s %(levelname)s %(message)s",
    )
    logging.info("Generating Sesh code configuration...")
    try:
        projects: list[Path] = find_dirs()
        output: list[str] = []

        for project in projects:
            block = make_sesh_block(create_name(project), project)
            output.append(block)
            for worktree in find_worktrees(project):
                name = f"{project.name}/{worktree.name}".lower()
                output.append(make_sesh_block(name, worktree))

        output_file = Path("./code.toml")
        output_file.write_text(textwrap.dedent("\n".join(output)))
        send_notification(
            "✅ Sesh Configuration", "Code configuration successfully updated!"
        )
        send_custom_email(
            f"✅ Session Config Update Successful on {datetime.now():%Y-%m-%d}",
            f"Session configs updated successfully!\n\n"
            f"Details:\n"
            f"- Processed {len(projects)} directories\n"
            f"- Output: {output_file}\n"
            f"- Time: {datetime.now():%Y-%m-%d %H:%M:%S}\n",
            "andrew@mcallister.science",
        )

    except Exception as e:
        logging.error(f"Failed to create Sesh code configuration: {e}")
        send_notification("❌ Sesh Configuration Error", f"{e}")
        send_custom_email(
            f"❌ Session Config Update FAILED on {datetime.now():%Y-%m-%d}",
            f"The following error occurred during session config generation:\n\n"
            f"Error: {e!s}\n"
            f"Time: {datetime.now():%Y-%m-%d %H:%M:%S}\n",
            "andrew@mcallister.science",
        )
        sys.exit(1)


if __name__ == "__main__":
    main()
