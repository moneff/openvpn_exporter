VERSION ?= $(shell cat VERSION)

all:
	GOOS=linux GOARCH=amd64 go build -ldflags="-s -w -X main.appVersion=${VERSION}" -o builds/openvpn_exporter-${VERSION}-amd64-linux .
	GOOS=linux GOARCH=arm64 go build -ldflags="-s -w -X main.appVersion=${VERSION}" -o builds/openvpn_exporter-${VERSION}-arm64-linux .

tidy:
	go mod tidy

clean:
	rm -rf builds/*