# Data Structures Analysis

**Scope:** `models.py`

## Findings: Bloat in Serialization

The `models.py` file uses Python's standard `dataclasses`. While dataclasses are excellent for structure, there is unused serialization bloat.

1. **Dead Code (`IPOData.from_dict`)**
   ```python
   @classmethod
   def from_dict(cls, data: dict) -> "IPOData":
       ...
   ```
   *Why it's bloat:* This method exists to map a raw dictionary back into an `IPOData` object. However, this pipeline only *writes* data; it never reads it back in from a JSON source. `from_dict` is never called anywhere in the codebase. It does not benefit the user or developer.

2. **Extraneous Default Factory Boilerplate**
   Several attributes are declared using `field(default="")`. While explicit, this is slightly un-pythonic when dealing with simple primitive strings in a dataclass.
   *Why it's bloat:* Standard type hinting `gmp: str = ""` is exactly equivalent to `gmp: str = field(default="")` but much cleaner to read.

3. **Lingering Deleted Requirements (`face_value`)**
   The `face_value` attribute still exists on the `IPOData` model, even though the scraper that populated it (`ipocentral`) was deleted, and the user explicitly requested that Face Value be removed from the pipeline.
   *Why it's bloat:* It ensures that every JSON object printed by the CLI contains `"face_value": ""`, which takes up bytes and network bandwidth for a field that will mathematically never be populated.

## Actionable Recommendation
Delete `from_dict`. Strip the `field(default="")` verbosity in favor of primitive assignments. Delete `face_value` entirely from the schema to clean up the final API payload.
