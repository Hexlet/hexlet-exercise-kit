FROM python:latest

ENV PIP_DISABLE_PIP_VERSION_CHECK=on \
    POETRY_VERSION=1.0.0

RUN pip install "poetry==$POETRY_VERSION"

WORKDIR /downloader

COPY pyproject.toml poetry.lock downloader.py /downloader/

RUN poetry config virtualenvs.create false \
  && poetry install --no-interaction --no-ansi

COPY . /downloader

RUN chmod a+x ./downloader.py

ENTRYPOINT ["./downloader.py"]