package main

import (
	"context"
	"flag"
	"fmt"
	"log"

	"google.golang.org/grpc"
	"google.golang.org/grpc/credentials"
	"google.golang.org/grpc/credentials/insecure"

	api "github.com/Favour-MK/prolog/api/v1"
	"github.com/Favour-MK/prolog/internal/config"
)

func main() {
	addr := flag.String("addr", ":8400", "service address")
	caFile := flag.String("ca-file", "", "path to CA cert")
	certFile := flag.String("cert-file", "", "path to client cert")
	keyFile := flag.String("key-file", "", "path to client key")
	serverName := flag.String("server-name", "", "server name to verify")
	flag.Parse()

	creds := insecure.NewCredentials()
	if *caFile != "" {
		tlsConfig, err := config.SetupTLSConfig(config.TLSConfig{
			CertFile:      *certFile,
			KeyFile:       *keyFile,
			CAFile:        *caFile,
			ServerAddress: *serverName,
		})
		if err != nil {
			log.Fatal(err)
		}
		creds = credentials.NewTLS(tlsConfig)
	}

	conn, err := grpc.NewClient(*addr, grpc.WithTransportCredentials(creds))
	if err != nil {
		log.Fatal(err)
	}
	defer conn.Close()

	client := api.NewLogClient(conn)
	res, err := client.GetServers(context.Background(), &api.GetServersRequest{})
	if err != nil {
		log.Fatal(err)
	}
	fmt.Println("servers:")
	for _, server := range res.Servers {
		fmt.Printf("\t- %v\n", server)
	}
}
