package main

import (
	"context"
	"fmt"
	"go.mongodb.org/mongo-driver/bson"
	"go.mongodb.org/mongo-driver/mongo"
	"go.mongodb.org/mongo-driver/mongo/options"
	"log"
	"time"
)

type testData struct {
	Name  string `json:"name"`
	Value string `json:"Value"`
}

func main() {
	client, err := mongo.NewClient(options.Client().ApplyURI("mongodb://127.0.0.1:27017"),
		&options.ClientOptions{Auth: &options.Credential{
			AuthMechanism:           "",
			AuthMechanismProperties: nil,
			AuthSource:              "",
			Username:                "root",
			Password:                "123456",
			PasswordSet:             true,
		}})
	if err != nil {
		log.Fatal(err)
	}
	ctx, _ := context.WithTimeout(context.Background(), 10*time.Second)
	err = client.Connect(ctx)
	if err != nil {
		log.Fatal(err)
	}
	defer client.Disconnect(ctx)

	testDatabase := client.Database("testdb")
	testCollection := testDatabase.Collection("tests")

	td := testData{
		Name:  "InsertTestName1",
		Value: "InsertTetValue1",
	}

	if podcastResult, err := testCollection.InsertOne(ctx, td); err != nil {
		log.Fatal(err)
	} else {
		fmt.Println(podcastResult)
	}

	if cursor, err := testCollection.Find(ctx, bson.D{}); err != nil {
		log.Fatal(err)
	} else {
		for cursor.Next(ctx) {
			var od testData
			if err = cursor.Decode(&od); err != nil {
				log.Fatal(err)
			} else {
				fmt.Printf("%s : %s\n", od.Name, od.Value)
			}
		}
	}
}
