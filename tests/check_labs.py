"""Check that every lab runs on a freshly loaded database.

For each lab sheet this script:
  1. reloads sql/year1_sql_lab.sql (and removes lab01),
  2. runs every SQL code block in the sheet, in order, in one session,
  3. fails if MySQL reports an error that the sheet does not show as an
     expected "Error Code: NNNN" (some questions demonstrate errors on purpose).

Usage:
    python tests/check_labs.py                       # uses: mysql
    MYSQL_CMD="mysql -uroot -proot" python tests/check_labs.py
"""
import os
import re
import shlex
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
MYSQL = shlex.split(os.environ.get("MYSQL_CMD", "mysql"))


def run(sql: str) -> str:
    """Run SQL with --force (keep going after errors) and return stderr."""
    result = subprocess.run(MYSQL + ["--force"], input=sql, text=True, capture_output=True)
    return result.stderr


def main() -> int:
    setup = (ROOT / "sql" / "year1_sql_lab.sql").read_text()
    failed = False
    for lab in sorted((ROOT / "labs").glob("*.md")):
        text = lab.read_text()
        errors = run("DROP DATABASE IF EXISTS lab01;\n" + setup)
        if "ERROR" in errors:
            print(f"Setup script failed before {lab.name}:\n{errors}")
            return 1

        blocks = re.findall(r"```sql\n(.*?)```", text, flags=re.S)
        match = re.search(r"\*\*Database:\*\* `([A-Za-z0-9_]+)", text)
        use = f"USE {match.group(1)};\n" if match and match.group(1) != "lab01" else ""
        stderr = run("SET SQL_SAFE_UPDATES = 0;\n" + use + "\n".join(blocks))

        expected = set(re.findall(r"Error Code: (\d+)", text))
        seen = re.findall(r"ERROR (\d+)", stderr)
        unexpected = [code for code in seen if code not in expected]
        status = "OK" if not unexpected else "FAIL"
        print(f"{status:4}  {lab.name}: {len(blocks)} code blocks, "
              f"{len(seen)} expected error demo(s)" if not unexpected else
              f"{status:4}  {lab.name}: unexpected errors {unexpected}")
        if unexpected:
            failed = True
            print("\n".join(l for l in stderr.splitlines() if "ERROR" in l))
    return 1 if failed else 0


if __name__ == "__main__":
    sys.exit(main())
