# Prometheus OpenVPN exporter

Update: Support server logs OpenVPN 2.5

This repository provides code for a simple Prometheus metrics exporter
for [OpenVPN](https://openvpn.net/). Right now it can parse files
generated by OpenVPN's `--status`, having one of the following formats:

* Client statistics,
* Server statistics with `--status-version 2` (comma delimited),
* Server statistics with `--status-version 3` (tab delimited).

As it is not uncommon to run multiple instances of OpenVPN on a single
system (e.g., multiple servers, multiple clients or a mixture of both),
this exporter can be configured to scrape and export the status of
multiple status files, using the `-openvpn.status_paths` command line
flag. Paths need to be comma separated. Metrics for all status files are
exported over TCP port 9176.

Please refer to this utility's `main()` function for a full list of
supported command line flags.

## Exposed metrics example

### Client statistics

For clients status files, the exporter generates metrics that may look
like this:

```
openvpn_client_auth_read_bytes_total{status_path="..."} 3.08854782e+08
openvpn_client_post_compress_bytes_total{status_path="..."} 4.5446864e+07
openvpn_client_post_decompress_bytes_total{status_path="..."} 2.16965355e+08
openvpn_client_pre_compress_bytes_total{status_path="..."} 4.538819e+07
openvpn_client_pre_decompress_bytes_total{status_path="..."} 1.62596168e+08
openvpn_client_tcp_udp_read_bytes_total{status_path="..."} 2.92806201e+08
openvpn_client_tcp_udp_write_bytes_total{status_path="..."} 1.97558969e+08
openvpn_client_tun_tap_read_bytes_total{status_path="..."} 1.53789941e+08
openvpn_client_tun_tap_write_bytes_total{status_path="..."} 3.08764078e+08
openvpn_status_update_time_seconds{status_path="..."} 1.490092749e+09
openvpn_up{status_path="..."} 1
```

### Server statistics

For server status files (both version 2 and 3), the exporter generates
metrics that may look like this:

```
openvpn_server_client_received_bytes_total{common_name="...",connection_time="...",real_address="...",status_path="...",username="...",virtual_address="..."} 139583
openvpn_server_client_sent_bytes_total{common_name="...",connection_time="...",real_address="...",status_path="...",username="...",virtual_address="..."} 710764
openvpn_server_route_last_reference_time_seconds{common_name="...",real_address="...",status_path="...",virtual_address="..."} 1.493018841e+09
openvpn_status_update_time_seconds{status_path="..."} 1.490089154e+09
openvpn_up{status_path="..."} 1
openvpn_server_connected_clients 1
```

## Usage

Usage of openvpn_exporter:

```sh
  -openvpn.status_paths string
    	Paths at which OpenVPN places its status files. (default "examples/client.status,examples/server2.status,examples/server3.status")
  -web.listen-address string
    	Address to listen on for web interface and telemetry. (default ":9176")
  -web.telemetry-path string
    	Path under which to expose metrics. (default "/metrics")
  -ignore.individuals bool
      If ignoring metrics for individuals (default false)
  -version
    	prints version
```

E.g:

```sh
openvpn_exporter -openvpn.status_paths /var/log/openvpn/openvpn-status.log
```

Install to Systemd service
```sh
mkdir -p openvpn-exporter && tar -xvzf openvpn-exporter-arm64-linux.tar.gz -C openvpn-exporter
sudo ln -s /home/ubuntu/openvpn-exporter/openvpn-exporter.service /etc/systemd/system/openvpn-exporter.service
sudo systemctl enable openvpn-exporter.service
sudo systemctl start openvpn-exporter.service
sudo systemctl status openvpn-exporter.service
#inspect the logs
sudo journalctl -f -u openvpn-exporter.service

#How to Remove
sudo systemctl stop openvpn-exporter.service
sudo systemctl disable openvpn-exporter.service
sudo systemctl daemon-reload

```

## Docker

To use with docker you must mount your status file to `/etc/openvpn_exporter/server.status`.

```sh (deprecated)
docker run -p 9176:9176 \
  -v $(pwd)/examples/server.openvpn2-5.status:/etc/openvpn_exporter/server.status \
  kumina/openvpn-exporter -openvpn.status_paths /etc/openvpn_exporter/server.status
```

Metrics should be available at http://localhost:9176/metrics.

## Cross Compile

```bash
env GOOS=linux GOARCH=arm64 go build -ldflags="-s -w" -o openvpn_exporter_arm64
env GOOS=linux GOARCH=amd64 go build -ldflags="-s -w" -o openvpn_exporter_amd64
```

## Compile from Docker image

Build the image and then get the binary
```
docker build --force-rm=true -t openvpn_exporter -f local_build.Dockerfile .
docker run -it -v $(pwd)/openvpn_exporter:/volume openvpn_exporter cp openvpn_exporter /volume
```

The binary is available in `$(pwd)/openvpn_exporter/openvpn_exporter`
