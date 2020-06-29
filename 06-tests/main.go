package main

import (
	"context"
	"database/sql"
	"flag"
	"log"
	"net/http"
	"os"
	"os/signal"
	"syscall"
	"time"

	"github.com/go-redis/redis"
	_ "github.com/lib/pq"
	"github.com/streadway/amqp"
)

var (
	httpClient http.Client
)

func httpGet(ctx context.Context, period time.Duration, url string) error {
	for {
		select {
		case <-ctx.Done():
			return ctx.Err()
		case <-time.After(period):
			resp, err := httpClient.Get(url)
			if err != nil || resp.StatusCode != http.StatusOK {
				log.Println("Failed to GET HTTP:", err)
				continue
			}
			log.Printf("HTTP OK")
		}
	}
}

func redisPing(ctx context.Context, period time.Duration, client *redis.Client) error {
	for {
		select {
		case <-ctx.Done():
			return ctx.Err()
		case <-time.After(period):
			if _, err := client.Ping().Result(); err != nil {
				log.Println("Failed to PING Redis:", err)
				continue
			}
			log.Printf("Redis OK")
		}
	}
}

func pgPing(ctx context.Context, period time.Duration, client *sql.DB) error {
	for {
		select {
		case <-ctx.Done():
			return ctx.Err()
		case <-time.After(period):
			if err := client.PingContext(ctx); err != nil {
				log.Println("Failed to PING PG:", err)
				continue
			}
			log.Printf("PG OK")
		}
	}
}

func rmqDial(ctx context.Context, period time.Duration, amqpURL string) error {
	for {
		select {
		case <-ctx.Done():
			return ctx.Err()
		case <-time.After(period):
			connection, err := amqp.Dial(amqpURL)
			if err != nil {
				log.Println("Failed to dial RMQ:", err)
				continue
			}
			defer connection.Close()

			if _, err := connection.Channel(); err != nil {
				log.Println("Failed to create a RMQ channel:", err)
				continue
			}

			log.Printf("RMQ OK")
		}
	}

}

func main() {
	httpURL := flag.String("http-url", os.Getenv("HTTP_URL"), "HTTP URL to GET")
	redisAddr := flag.String("redis-addr", os.Getenv("REDIS_ADDR"), "Redis address (localhost:6379)")
	redisPasswd := flag.String("redis-passwd", os.Getenv("REDIS_PASSWD"), "Redis password")
	pgDSN := flag.String("pg-dsn", os.Getenv("PG_DSN"), "PG DSN (postgres://user:pass@host/db?sslmode=disable)")
	amqpURL := flag.String("amq-url", os.Getenv("AMQP_URL"), "RMQ URL (amqp://guest:guest@localhost:5672)")
	pingPeriod := flag.Duration("ping-period", 500*time.Millisecond, "Ping period")
	flag.Parse()

	ctx, cancel := context.WithCancel(context.Background())
	c := make(chan os.Signal, 1)
	signal.Notify(c, syscall.SIGINT, syscall.SIGTERM)

	go func() {
		httpClient = http.Client{Timeout: 5 * time.Second}
		log.Println(httpGet(ctx, *pingPeriod, *httpURL))
	}()

	go func() {
		client := redis.NewClient(&redis.Options{
			Addr:     *redisAddr,
			Password: *redisPasswd,
		})
		client = client.WithContext(ctx)
		log.Println(redisPing(ctx, *pingPeriod, client))
	}()

	go func() {
		client, err := sql.Open("postgres", *pgDSN)
		if err != nil {
			log.Println("failed to build PG client: ", err)
			return
		}
		log.Println(pgPing(ctx, *pingPeriod, client))
	}()

	go func() {
		log.Println(rmqDial(ctx, *pingPeriod, *amqpURL))
	}()

	select {
	case <-c:
		cancel()
	case <-ctx.Done():
	}
}
