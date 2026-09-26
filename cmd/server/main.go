package main

import (
	"log"
	"github.com/Favour-MK/prolog/internal/server"
)

func main(){
	srv := server.NewHTTPServer(":8080")
	log.Fatal(srv.ListenAndServe())
}