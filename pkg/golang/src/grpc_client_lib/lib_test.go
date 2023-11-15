package grpc_client_lib

import (
	"github.com/stretchr/testify/assert"
	"testing"
)

func TestClient_New(t *testing.T) {

	c := New()
	assert.NotNil(t, c)
}

func TestClient_GetData(t *testing.T) {
	expect := "Connected to 'AT&T' to get data...124 MB downloaded"
	c := New()
	result := c.GetData("AT&T")
	assert.Equal(t, expect, result)
}
