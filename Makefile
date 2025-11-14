
CLAUDELINT_IMAGE := ghcr.io/stbenjam/claudelint:latest

lint:
	@echo "Running claudelint validation..."
	@docker run --rm -v $(PWD):/workspace:Z -w /workspace --user $(shell id -u):$(shell id -g) $(CLAUDELINT_IMAGE) --strict || \
		(echo "✗ Validation failed!" && exit 1)
	@echo "✓ Validation passed!"
