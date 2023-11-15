package grpc_client_lib

import (
	"fmt"
	"github.com/dustin/go-humanize"
)

type GrpcClient interface {
	GetData(conn string) string
}

type Client struct{}

func New() *Client {
	return &Client{}
}

func (x *Client) GetData(conn string) string {
	return fmt.Sprintf("Connected to '%s' to get data...%s downloaded", conn, humanize.Bytes(123456789))
}
