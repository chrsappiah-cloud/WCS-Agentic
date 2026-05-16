FROM swift:6.0-jammy
WORKDIR /app
COPY . .
RUN swift build -c release
CMD [".build/release/App", "serve", "--hostname", "0.0.0.0", "--port", "8080"]
