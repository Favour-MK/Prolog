CONFIG_PATH=${HOME}/.proglog/

.PHONY: init
init:
	mkdir -p ${CONFIG_PATH}

.PHONY: gencert
gencert:
	cfssl gencert \
		-initca test/ca-csr.json | cfssljson -bare ca

	cfssl gencert \
		-ca=ca.pem \
		-ca-key=ca-key.pem \
		-config=test/ca-config.json \
		-profile=server \
		test/server-csr.json | cfssljson -bare server

	cfssl gencert \
		-ca=ca.pem \
		-ca-key=ca-key.pem \
		-config=test/ca-config.json \
		-profile=client \
		-cn="root" \
		test/client-csr.json | cfssljson -bare root-client

	cfssl gencert \
		-ca=ca.pem \
		-ca-key=ca-key.pem \
		-config=test/ca-config.json \
		-profile=client \
		-cn="nobody" \
		test/client-csr.json | cfssljson -bare nobody-client

	mv *.pem *.csr ${CONFIG_PATH}

$(CONFIG_PATH)/model.conf:
	cp test/model.conf $(CONFIG_PATH)/model.conf

$(CONFIG_PATH)/policy.csv:
	cp test/policy.csv $(CONFIG_PATH)/policy.csv

.PHONY: test
test: $(CONFIG_PATH)/policy.csv $(CONFIG_PATH)/model.conf
	go test -race ./...

.PHONY: compile
compile:
	protoc api/v1/*.proto \
		--go_out=. \
		--go-grpc_out=. \
		--go_opt=paths=source_relative \
		--go-grpc_opt=paths=source_relative \
		--proto_path=.

TAG ?= 0.0.1

.PHONY: build-docker
build-docker:
	docker build -t proglog:$(TAG) .

# Run `make gencert` first so the server cert covers the in-cluster DNS names.
.PHONY: k8s-tls-secret
k8s-tls-secret:
	kubectl create secret generic proglog-tls \
		--from-file=${CONFIG_PATH}ca.pem \
		--from-file=${CONFIG_PATH}server.pem \
		--from-file=${CONFIG_PATH}server-key.pem \
		--from-file=${CONFIG_PATH}root-client.pem \
		--from-file=${CONFIG_PATH}root-client-key.pem

.PHONY: deploy
deploy:
	helm upgrade --install proglog deploy/proglog --set image.tag=$(TAG)
