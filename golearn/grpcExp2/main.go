// protoc -I=proto --go_out=proto --go-grpc_out=proto --go_opt=paths=source_relative --go-grpc_opt=paths=source_relative  proto/helloworld.proto
package main

import (
	"context"
	"fmt"
	pb "golearn/grpcExp2/proto"
	"google.golang.org/grpc"
	"log"
	"net"
	"time"
)

const (
	port    = ":50051"
	address = "localhost:50051"
)

func sayHello(ctx context.Context, in *pb.HelloRequest) (*pb.HelloReply, error) {
	log.Printf("Received: %v", in.GetName())
	return &pb.HelloReply{Message: "Hello " + in.GetName()}, nil
}

func startServer() error {
	lis, err := net.Listen("tcp", port)
	if err != nil {
		return err
	}
	s := grpc.NewServer()
	server := &pb.GreeterService{SayHello: sayHello}
	pb.RegisterGreeterService(s, server)
	return s.Serve(lis)
}

func hello(msg string) error {
	ctx, cancel := context.WithTimeout(context.Background(), time.Second)
	defer cancel()
	conn, err := grpc.DialContext(ctx, address, grpc.WithInsecure(), grpc.WithBlock())
	if err != nil {
		return err
	}
	defer conn.Close()

	c := pb.NewGreeterClient(conn)
	r, err := c.SayHello(context.Background(), &pb.HelloRequest{Name: msg})
	if err != nil {
		return err
	}
	log.Printf("Greeting: %s", r.GetMessage())
	return nil
}

func main() {
	go func() {
		if err := startServer(); err != nil {
			log.Fatal(err)
		}
	}()
	for i := 0; i < 10; i++ {
		if err := hello(fmt.Sprintf("person%d", i)); err != nil {
			log.Fatal(err)
		}
	}
}
