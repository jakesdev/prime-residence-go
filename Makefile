.PHONY: clean critic security lint test build run

APP_NAME = apiserver
BUILD_DIR = $(PWD)/build
MIGRATIONS_FOLDER = $(PWD)/platform/migrations
DATABASE_URL = postgresql://postgres:password@localhost:5432/prime_residence?sslmode=disable

clean:
	rm -rf ./build

critic:
	gocritic check -enableAll ./...

security:
	gosec ./...

lint:
	golangci-lint run ./...

test: clean critic security lint
	go test -v -timeout 30s -coverprofile=cover.out -cover ./...
	go tool cover -func=cover.out

build: test
	CGO_ENABLED=0 go build -ldflags="-w -s" -o $(BUILD_DIR)/$(APP_NAME) main.go

run: swag build
	$(BUILD_DIR)/$(APP_NAME)

migrate.up:
	migrate -path $(MIGRATIONS_FOLDER) -database "$(DATABASE_URL)" up

migrate.down:
	migrate -path $(MIGRATIONS_FOLDER) -database "$(DATABASE_URL)" down

migrate.force:
	migrate -path $(MIGRATIONS_FOLDER) -database "$(DATABASE_URL)" force $(version)

docker.run: swag docker.fiber docker.redis migrate.up

docker.fiber.build:
	docker build -t fiber .

docker.fiber: docker.fiber.build
	docker run --rm -d \
		--name prime-residence-fiber \
		-p 5000:5000 \
		fiber

# docker.postgres:
# 	docker run --rm -d \
# 		--name prime-residence-postgres \
# 		-e POSTGRES_USER=postgres \
# 		-e POSTGRES_PASSWORD=password \
# 		-e POSTGRES_DB=prime_residence \
# 		-e POSTGRES_INITDB_ARGS=--auth-local=md5 \
# 		-p 5432:5432 \
# 		postgres:latest

docker.redis:
	docker run --rm -d \
		--name prime-residence-redis \
		-p 6379:6379 \
		redis

docker.stop: docker.stop.fiber docker.stop.postgres docker.stop.redis

docker.stop.fiber:
	docker stop prime-residence-fiber

docker.stop.postgres:
	docker stop prime-residence-postgres

docker.stop.redis:
	docker stop prime-residence-redis

swag:
	swag init
