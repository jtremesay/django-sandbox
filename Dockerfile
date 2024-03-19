FROM ubuntu:noble
RUN apt-get update

# Update packages and install needed stuff
RUN apt-get update \
    && apt-get install -y --no-install-recommends npm python3-pip python3-venv \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /code

# Create venv
ENV VIRTUAL_ENV=/opt/venv
RUN python3 -m venv $VIRTUAL_ENV
ENV PATH="$VIRTUAL_ENV/bin:$PATH"

# Install python & node deps
COPY requirements.txt ./
RUN pip install -Ur requirements.txt

# Copy source dir
COPY manage.py ./
COPY proj/ proj/
COPY app/ app/

# Build
# We need a secret a key to use manage.py, so we use a build time arg
ARG DJANGO_SECRET_KEY="build"
RUN ./manage.py collectstatic --no-input

CMD ["daphne", "proj.asgi:application", "--bind", "0.0.0.0", "--port", "8004"]