.PHONY: build clean help pdf compile shell

.DEFAULT_GOAL := help

# Show help message
help:
	@echo "Available targets:"
	@echo "  make generate - Generate LaTeX file from CSV (output: atena.tex)"
	@echo "                 (Usage: make generate CSV_FILE=data/file.csv SENDER_FILE=data/sender.txt)"
	@echo "  make compile  - Compile existing atena.tex to PDF"
	@echo "                 (Usage: make compile)"
	@echo "  make pdf      - Generate LaTeX from CSV, then compile to PDF"
	@echo "                 (Usage: make pdf CSV_FILE=data/file.csv SENDER_FILE=data/sender.txt)"
	@echo "                 (Equivalent to: make generate && make compile)"
	@echo "  make build    - Build Docker image (required before first use)"
	@echo "  make clean    - Clean generated files (*.aux, *.log, *.pdf, etc.)"
	@echo "  make shell    - Open interactive shell in Docker container"
	@echo "  make help     - Show this help message"

# Build Docker image
build:
	docker-compose build

# Generate LaTeX from CSV
# Usage: make generate CSV_FILE=data/addresses.csv SENDER_FILE=data/sender.txt
# Note: Output is always written to atena.tex (will be overwritten)
generate:
	bash generate_tex.sh $(CSV_FILE) $(SENDER_FILE)

# Generate PDF from CSV (generate LaTeX, then compile to PDF)
# Usage: make pdf CSV_FILE=data/addresses.csv SENDER_FILE=data/sender.txt
# Note: This is equivalent to: make generate && make compile
#       atena.tex will be overwritten, then atena.pdf will be generated
pdf: generate build
	docker-compose run --rm latex bash -c "rm -f atena.aux atena.dvi atena.log atena.out atena.pdf atena.xdv && latexmk -latex=platex -pdfdvi -interaction=nonstopmode atena.tex"
	@echo "PDF generated: atena.pdf"

# Compile existing atena.tex to PDF (without regenerating)
# Usage: make compile
# Note: Requires atena.tex to exist (use 'make generate' first if needed)
compile: build
	@if [ ! -f atena.tex ]; then \
		echo "Error: atena.tex not found. Run 'make generate' first."; \
		exit 1; \
	fi
	docker-compose run --rm latex bash -c "rm -f atena.aux atena.dvi atena.log atena.out atena.pdf atena.xdv && latexmk -latex=platex -pdfdvi -interaction=nonstopmode atena.tex"
	@echo "PDF generated: atena.pdf"

# Open interactive shell in Docker container
shell:
	docker-compose run --rm latex bash

# Clean generated files
clean:
	rm -f *.aux *.log *.out *.pdf *.dvi *.xdv *.fdb_latexmk *.fls *.synctex.gz

