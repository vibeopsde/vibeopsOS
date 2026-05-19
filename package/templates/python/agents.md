# Python Project Template

## Stack
- Python 3.12+
- Package Manager: Poetry
- Testing: pytest + pytest-cov
- Formatting: Ruff
- Type Checking: mypy

## Standards
- Modules in `src/`
- Tests in `tests/`
- pyproject.toml for config
- Type hints required

## Commands
```bash
poetry install   # Install dependencies
poetry shell     # Activate venv
poetry run pytest   # Run tests
poetry run ruff check   # Lint
```

## OpenCode Context
When working on Python projects:
- Use type hints everywhere
- Follow PEP 8
- docstrings for public APIs
- Dependency injection patterns