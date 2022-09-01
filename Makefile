

IMAGE_NAME := liskl/base-alpine
ALPINE_VERSION := 3.16.2

prepare:
	mkdir -p files ;
	wget -O files/alpine-minirootfs-$(ALPINE_VERSION)-arm32v7.tar.gz https://dl-cdn.alpinelinux.org/alpine/v3.16/releases/armv7/alpine-minirootfs-$(ALPINE_VERSION)-armv7.tar.gz ;
	wget -O files/alpine-minirootfs-$(ALPINE_VERSION)-arm64v8.tar.gz https://dl-cdn.alpinelinux.org/alpine/v3.16/releases/armhf/alpine-minirootfs-$(ALPINE_VERSION)-armhf.tar.gz ;
	wget -O files/alpine-minirootfs-$(ALPINE_VERSION)-amd64.tar.gz https://dl-cdn.alpinelinux.org/alpine/v3.16/releases/x86_64/alpine-minirootfs-$(ALPINE_VERSION)-x86_64.tar.gz ;

build: prepare
	docker buildx build \
	--no-cache \
	--load \
	--build-arg TARGETARCH=amd64 \
	--platform linux/amd64 \
	-t $(IMAGE_NAME):$(ALPINE_VERSION)-amd64 .

	docker buildx build \
	--load \
	--no-cache \
	--build-arg TARGETARCH=arm32v7 \
	--platform linux/arm/v7 \
	-t $(IMAGE_NAME):$(ALPINE_VERSION)-arm32v7 .

	docker buildx build \
	--load \
	--no-cache \
	--build-arg TARGETARCH=arm64v8 \
	--platform linux/arm64/v8 \
	-t $(IMAGE_NAME):$(ALPINE_VERSION)-arm64v8 .

push: build
	docker push $(IMAGE_NAME):$(ALPINE_VERSION)-amd64
	docker push $(IMAGE_NAME):$(ALPINE_VERSION)-arm32v7
	docker push $(IMAGE_NAME):$(ALPINE_VERSION)-arm64v8

manifest: push
	docker manifest create \
	$(IMAGE_NAME):$(ALPINE_VERSION) \
	--amend $(IMAGE_NAME):$(ALPINE_VERSION)-amd64 \
	--amend $(IMAGE_NAME):$(ALPINE_VERSION)-arm32v7 \
	--amend $(IMAGE_NAME):$(ALPINE_VERSION)-arm64v8

	docker manifest create \
	$(IMAGE_NAME):latest \
	--amend $(IMAGE_NAME):$(ALPINE_VERSION)-amd64 \
	--amend $(IMAGE_NAME):$(ALPINE_VERSION)-arm32v7 \
	--amend $(IMAGE_NAME):$(ALPINE_VERSION)-arm64v8

	docker manifest annotate $(IMAGE_NAME):$(ALPINE_VERSION) $(IMAGE_NAME):$(ALPINE_VERSION)-arm32v7 --arch arm --os linux --variant v7
	docker manifest annotate $(IMAGE_NAME):$(ALPINE_VERSION) $(IMAGE_NAME):$(ALPINE_VERSION)-arm64v8 --arch arm --os linux --variant v8
	docker manifest annotate $(IMAGE_NAME):$(ALPINE_VERSION) $(IMAGE_NAME):$(ALPINE_VERSION)-amd64 --arch amd64 --os linux
	docker manifest annotate $(IMAGE_NAME):latest $(IMAGE_NAME):$(ALPINE_VERSION)-arm32v7 --arch arm --os linux --variant v7
	docker manifest annotate $(IMAGE_NAME):latest $(IMAGE_NAME):$(ALPINE_VERSION)-arm64v8 --arch arm --os linux --variant v8
	docker manifest annotate $(IMAGE_NAME):latest $(IMAGE_NAME):$(ALPINE_VERSION)-amd64 --arch amd64 --os linux

	docker manifest push $(IMAGE_NAME):$(ALPINE_VERSION)
	docker manifest push $(IMAGE_NAME):latest