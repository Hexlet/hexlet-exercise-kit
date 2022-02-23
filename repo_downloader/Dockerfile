FROM python:3.11

ARG UNAME
ARG UID

ENV PIP_DISABLE_PIP_VERSION_CHECK=on \
    POETRY_VERSION=1.0.0

RUN curl -sSL https://raw.githubusercontent.com/python-poetry/poetry/master/get-poetry.py | python -

RUN poetry config virtualenvs.create false
# RUN pip install "poetry==$POETRY_VERSION"

WORKDIR /downloader

COPY . .

RUN poetry install --no-interaction --no-ansi
RUN chmod a+x ./downloader.py

RUN useradd -l -u $UID -g users $UNAME
USER $UNAME

ENTRYPOINT ["./downloader.py"]
