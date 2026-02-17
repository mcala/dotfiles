#!/usr/bin/env -S uv run
# /// script
# requires-python = ">=3.13"
# ///
import logging
import subprocess
import sys
import textwrap
from datetime import datetime
from pathlib import Path

CODE_DIR = Path("/Users/mcala/Documents/3_resources/code/1_active/")
NAME_FIXES = ["Nj", "Fy", "Llm", "Api", "Abu"]


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


def make_sesh_block(directory: Path) -> str:
    name: str = create_name(directory)
    path: str = str(directory.resolve())
    block: str = f"""
        [[session]]
        name = "{name}"
        path = "{path}" """
    return block


def main():
    logging.info("Generating Sesh code configuration...")
    try:
        projects: list[Path] = find_dirs()
        output: list[str] = []

        for project in projects:
            block = make_sesh_block(project)
            output.append(block)

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
            f"Error: {str(e)}\n"
            f"Time: {datetime.now():%Y-%m-%d %H:%M:%S}\n",
            "andrew@mcallister.science",
        )
        sys.exit(1)


if __name__ == "__main__":
    main()
