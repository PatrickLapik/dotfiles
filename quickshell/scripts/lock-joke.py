#!/usr/bin/env python3
"""Fetch a bounded joke request, retaining a usable offline fallback."""
import json
import os
from pathlib import Path
import urllib.request

FALLBACK = "Chuck Norris can divide by zero."


def joke(cache):
    try:
        request = urllib.request.Request("https://api.chucknorris.io/jokes/random?category=dev",
                                         headers={"User-Agent": "Quickshell-lockscreen"})
        with urllib.request.urlopen(request, timeout=4) as response:
            value = json.loads(response.read(16384)).get("value")
        if not isinstance(value, str) or not value.strip():
            raise ValueError("Empty joke")
        value = " ".join(value.split())[:1200]
        try:
            cache.parent.mkdir(parents=True, exist_ok=True)
            cache.write_text(value)
        except OSError:
            pass
        return value
    except (OSError, ValueError):
        try:
            return " ".join(cache.read_text().split())[:1200] or FALLBACK
        except OSError:
            return FALLBACK


if __name__ == "__main__":
    cache = Path(os.environ.get("XDG_CACHE_HOME", str(Path.home() / ".cache"))) / "chuck-norris"
    print(joke(cache))
