IMAGE ?= ghcr.io/avatsav/pi-kit-image:latest
KIT ?= .

.PHONY: build validate run

build:
	docker build -t $(IMAGE) .

validate:
	sbx kit validate $(KIT)

run: build validate
	sbx run --kit $(KIT) pi
