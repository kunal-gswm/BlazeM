"""
Application settings via pydantic-settings.

Reads from environment variables and .env file.
"""

from pydantic_settings import BaseSettings


class Settings(BaseSettings):
    # Database
    database_url: str = "postgresql://blamics:blamics@localhost:5432/blamics"
    db_min_pool_size: int = 2
    db_max_pool_size: int = 10

    # Server
    host: str = "0.0.0.0"
    port: int = 8000
    debug: bool = True

    model_config = {"env_file": ".env", "env_file_encoding": "utf-8"}


settings = Settings()
