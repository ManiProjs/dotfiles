#!/usr/bin/env python3

import configparser
import json
import os
import re
from pathlib import Path


APPLICATION_DIRS = [
    Path.home() / ".local/share/applications",
    Path("/usr/local/share/applications"),
    Path("/usr/share/applications"),
]


ICON_DIRS = [
    Path.home() / ".local/share/icons",
    Path.home() / ".icons",
    Path("/usr/local/share/icons"),
    Path("/usr/share/icons"),
]


ICON_EXTENSIONS = [
    ".png",
    ".svg",
    ".xpm",
]


def find_desktop_files():
    files = []

    for directory in APPLICATION_DIRS:
        if not directory.exists():
            continue

        files.extend(directory.glob("*.desktop"))

    return files


def get_localized(parser, key):
    section = parser["Desktop Entry"]

    # Prefer the normal value.
    if key in section:
        return section[key]

    # Then try LANG / LANGUAGE.
    language = os.environ.get("LANG", "")

    language = language.split(".")[0]
    language = language.replace("-", "_")

    candidates = [
        f"{key}[{language}]",
        f"{key}[{language.split('_')[0]}]",
    ]

    for candidate in candidates:
        if candidate in section:
            return section[candidate]

    return ""


def clean_exec(command):
    if not command:
        return ""

    # Remove desktop-entry field codes.
    command = re.sub(
        r"\s+%[fFuUdDnNickvm]",
        "",
        command,
    )

    command = command.replace(
        "%f", ""
    ).replace(
        "%F", ""
    ).replace(
        "%u", ""
    ).replace(
        "%U", ""
    )

    return command.strip()


def resolve_icon(icon):
    if not icon:
        return ""

    path = Path(icon)

    # Already an absolute path.
    if path.is_absolute():
        if path.exists():
            return str(path)

        # Try extensions if the desktop file omitted one.
        if path.suffix == "":
            for extension in ICON_EXTENSIONS:
                candidate = Path(
                    str(path) + extension
                )

                if candidate.exists():
                    return str(candidate)

        return ""

    # Search icon directories.
    for icon_root in ICON_DIRS:
        if not icon_root.exists():
            continue

        # Search recursively.
        for extension in ICON_EXTENSIONS:
            matches = icon_root.rglob(
                icon + extension
            )

            for match in matches:
                if match.is_file():
                    return str(match)

    return ""


def parse_desktop_file(path):
    parser = configparser.ConfigParser(
        interpolation=None
    )

    parser.optionxform = str

    try:
        parser.read(
            path,
            encoding="utf-8",
        )
    except Exception:
        return None

    if "Desktop Entry" not in parser:
        return None

    entry = parser["Desktop Entry"]

    if entry.get("Type") != "Application":
        return None

    if entry.get("Hidden", "").lower() == "true":
        return None

    if entry.get("NoDisplay", "").lower() == "true":
        return None

    name = get_localized(
        parser,
        "Name",
    )

    comment = get_localized(
        parser,
        "Comment",
    )

    command = clean_exec(
        entry.get("Exec", "")
    )

    icon = resolve_icon(
        entry.get("Icon", "")
    )

    if not name or not command:
        return None

    return {
        "name": name,
        "comment": comment,
        "exec": command,
        "icon": icon,
    }


def main():
    applications = []

    seen = set()

    for desktop_file in find_desktop_files():
        app = parse_desktop_file(
            desktop_file
        )

        if not app:
            continue

        # Deduplicate by name + command.
        key = (
            app["name"].lower(),
            app["exec"],
        )

        if key in seen:
            continue

        seen.add(key)

        applications.append(app)

    applications.sort(
        key=lambda app:
        app["name"].lower()
    )

    output = (
        Path(__file__).parent /
        "apps.json"
    )

    output.write_text(
        json.dumps(
            applications,
            indent=2,
            ensure_ascii=False,
        ),
        encoding="utf-8",
    )

    print(
        f"Found {len(applications)} applications"
    )


if __name__ == "__main__":
    main()

