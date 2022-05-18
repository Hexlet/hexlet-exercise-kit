FROM python:3.11-rc

ARG UNAME
ARG UID

ENV PIP_DISABLE_PIP_VERSION_CHECK=on \
    POETRY_VERSION=1.1.7

# RUN curl -sSL https://raw.githubusercontent.com/python-poetry/poetry/master/get-poetry.py | python -

RUN pip install "poetry==$POETRY_VERSION"
RUN poetry config virtualenvs.create false

WORKDIR /downloader

COPY . .

RUN poetry install --no-interaction --no-ansi
RUN chmod a+x ./downloader.py

RUN useradd -l -u $UID -g users $UNAME
USER $UNAME

ENTRYPOINT ["./downloader.py"]
