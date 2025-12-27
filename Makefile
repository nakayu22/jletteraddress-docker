.PHONY: build clean help pdf shell

.DEFAULT_GOAL := help

# Show help message
help:
	@echo "Available targets:"
	@echo "  make build    - Build Docker image"
	@echo "  make generate - Generate LaTeX file from CSV (output: atena.tex)"
	@echo "                 (Usage: make generate CSV_FILE=data/file.csv SENDER_FILE=data/sender.txt)"
	@echo "  make pdf      - Generate PDF (builds image if needed)"
	@echo "                 (Usage: make pdf CSV_FILE=data/file.csv SENDER_FILE=data/sender.txt)"
	@echo "  make clean    - Clean generated files (*.aux, *.log, *.pdf, etc.)"
	@echo "  make shell    - Open shell in container"
	@echo "  make help     - Show this help message"

# Build Docker image
build:
	docker-compose build

# Generate LaTeX from CSV
# Usage: make generate CSV_FILE=data/addresses.csv SENDER_FILE=data/sender.txt
# Note: Output is always written to atena.tex (will be overwritten)
generate:
	bash generate_tex.sh $(CSV_FILE) $(SENDER_FILE)

# Generate PDF
# Usage: make pdf CSV_FILE=data/addresses.csv SENDER_FILE=data/sender.txt
# Note: atena.tex will be overwritten, then atena.pdf will be generated
pdf: generate build
	docker-compose run --rm latex bash -c "cp /opt/jletteraddress/jletteraddress.cls . && rm -f atena.aux atena.dvi atena.log atena.out atena.pdf atena.xdv && latexmk -latex=platex -pdfdvi -interaction=nonstopmode atena.tex"
	@echo "PDF generated: atena.pdf"

# Open shell in container
shell:
	docker-compose run --rm latex bash

# Clean generated files
clean:
	rm -f *.aux *.log *.out *.pdf *.dvi *.xdv *.fdb_latexmk *.fls *.synctex.gz jletteraddress.cls

