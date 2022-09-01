

IMAGE_NAME := liskl/base-alpine
ALPINE_VERSION := 3.16.2

prepare:
	wget -O files/alpine-minirootfs-$(ALPINE_VERSION)-armv7.tar.gz https://dl-cdn.alpinelinux.org/alpine/v3.16/releases/armv7/alpine-minirootfs-$(ALPINE_VERSION)-armv7.tar.gz
	wget -O files/alpine-minirootfs-$(ALPINE_VERSION)-armhf.tar.gz https://dl-cdn.alpinelinux.org/alpine/v3.16/releases/armhf/alpine-minirootfs-$(ALPINE_VERSION)-armhf.tar.gz
	wget -O files/alpine-minirootfs-$(ALPINE_VERSION)-x86_64.tar.gz https://dl-cdn.alpinelinux.org/alpine/v3.16/releases/x86_64/alpine-minirootfs-$(ALPINE_VERSION)-x86_64.tar.gz
build:
	docker buildx build \
	--no-cache \
	--load \
	--build-arg TARGETARCH=amd64 \
	--platform linux/amd64 \
	-t $(IMAGE_NAME):$(ALPINE_VERSION)-amd64 .

	docker buildx build \
	--load \
	--no-cache \
	--build-arg TARGETARCH=arm64 \
	--platform linux/arm64 \
	-t $(IMAGE_NAME):$(ALPINE_VERSION)-arm64 .

push: build
	docker push $(IMAGE_NAME):$(ALPINE_VERSION)-amd64
	docker push $(IMAGE_NAME):$(ALPINE_VERSION)-arm64

manifest: push
	docker manifest create \
	$(IMAGE_NAME):$(ALPINE_VERSION) \
	--amend $(IMAGE_NAME):$(ALPINE_VERSION)-amd64 \
	--amend $(IMAGE_NAME):$(ALPINE_VERSION)-arm64

	docker manifest create \
	$(IMAGE_NAME):latest \
	--amend $(IMAGE_NAME):$(ALPINE_VERSION)-amd64 \
	--amend $(IMAGE_NAME):$(ALPINE_VERSION)-arm64

	docker manifest annotate $(IMAGE_NAME):$(ALPINE_VERSION) $(IMAGE_NAME):$(ALPINE_VERSION)-arm64 --arch arm --os linux --variant v8
	docker manifest annotate $(IMAGE_NAME):$(ALPINE_VERSION) $(IMAGE_NAME):$(ALPINE_VERSION)-amd64 --arch amd64 --os linux 
	docker manifest annotate $(IMAGE_NAME):latest $(IMAGE_NAME):$(ALPINE_VERSION)-arm64 --arch arm --os linux --variant v8
	docker manifest annotate $(IMAGE_NAME):latest $(IMAGE_NAME):$(ALPINE_VERSION)-amd64 --arch amd64 --os linux 

	docker manifest push $(IMAGE_NAME):$(ALPINE_VERSION)
	docker manifest push $(IMAGE_NAME):latest