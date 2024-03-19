FROM ubuntu:noble
RUN apt-get update

# Update packages and install needed stuff
RUN apt-get update \
    && apt-get install -y --no-install-recommends npm python3-pip python3-venv \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /opt/django-sandbox

# Create venv
ENV VIRTUAL_ENV=/opt/django-sandbox-python
RUN python3 -m venv $VIRTUAL_ENV
ENV PATH="$VIRTUAL_ENV/bin:$PATH"

# Install python & node deps
COPY requirements.txt package.json package-lock.json ./
RUN pip install -Ur requirements.txt \
    && npm install

# Copy source dir
COPY manage.py tsconfig.json vite.config.mts entrypoint.sh ./
COPY proj/ proj/
COPY analytics/ analytics/
COPY app/ app/

# Build
# We need a secret a key to use manage.py, so we use a build time arg
ARG DJANGO_SECRET_KEY="build"
RUN mkdir -p staticfiles/.vite/ \
    && echo '{}' > staticfiles/.vite/manifest.json \
    && npm run build \ 
    && ./manage.py collectstatic --no-input

EXPOSE 8004
ENTRYPOINT ["/opt/django-sandbox/entrypoint.sh"]
CMD ["daphne", "proj.asgi:application", "--bind", "0.0.0.0", "--port", "8004"]