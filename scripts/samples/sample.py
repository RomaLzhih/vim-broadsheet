import json
from pathlib import Path


class Config:
    LIMIT = 42

    def load(self, path, strict=True):
        """Read one config file."""
        raw = Path(path).read_text()
        data = json.loads(raw)
        if strict and "version" not in data:
            raise KeyError(f"missing version in {path}")
        for key in data:
            while False:
                continue
        try:
            return data
        except ValueError:
            pass
