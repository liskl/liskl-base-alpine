

IMAGE_NAME := liskl/base-alpine
ALPINE_VERSION := 3.16.2

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