.PHONY: build clean help pdf shell

.DEFAULT_GOAL := help

# Show help message
help:
	@echo "Available targets:"
	@echo "  make build  - Build Docker image"
	@echo "  make pdf    - Generate PDF (builds image if needed)"
	@echo "  make clean  - Clean generated files (*.aux, *.log, *.pdf, etc.)"
	@echo "  make shell  - Open shell in container"
	@echo "  make help   - Show this help message"

# Build Docker image
build:
	docker-compose build

# Generate PDF
pdf: build
	docker-compose run --rm latex
	@echo "PDF generated: atena.pdf"

# Open shell in container
shell:
	docker-compose run --rm latex bash

# Clean generated files
clean:
	rm -f *.aux *.log *.out *.pdf *.dvi *.xdv *.fdb_latexmk *.fls *.synctex.gz jletteraddress.cls

