build_all:
	go build -o build/status_bar cmd/print/status_bar.go
	chmod +x build/status_bar
	go build -o build/cat cmd/file/cat.go
	chmod +x build/cat