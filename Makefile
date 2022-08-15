VERSION ?= $(shell cat VERSION)

all:
	GOOS=linux GOARCH=amd64 go build -ldflags="-s -w -X main.appVersion=${VERSION}" -o builds/${VERSION}/amd64/openvpn-exporter-linux .
	GOOS=linux GOARCH=arm64 go build -ldflags="-s -w -X main.appVersion=${VERSION}" -o builds/${VERSION}/arm64/openvpn-exporter-linux .

tidy:
	go mod tidy

clean:
	rm -rf builds/*
	rm -rf release/*

release: all
	cp conf/openvpn-exporter.service builds/${VERSION}/amd64/
	cp conf/openvpn-exporter.service builds/${VERSION}/arm64/
	mkdir -p release/${VERSION}/
	tar -czvf release/${VERSION}/openvpn-exporter-amd64-linux.tar.gz -C builds/${VERSION}/amd64/ .
	tar -czvf release/${VERSION}/openvpn-exporter-arm64-linux.tar.gz -C builds/${VERSION}/arm64/ .