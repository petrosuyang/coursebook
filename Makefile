# Find all tex files one directory down
TEX=$(shell find . -path "./.git*" -prune -o -type f -iname "*.tex" -print)
MAIN_TEX=main.tex
PDF_TEX=$(patsubst %.tex,%.pdf,$(MAIN_TEX))
BASE=$(patsubst %.tex,%,$(MAIN_TEX))
OTHER_FILES=$(addprefix $(BASE),.aux .log .synctex.gz .toc .out .blg .bbl .glg .gls .ist .glo)
BIBS=$(shell find . -maxdepth 2 -mindepth 2 -path "./.git*" -prune -o -type f -iname "*.bib" -print)
LATEX_COMMAND=pdflatex -quiet -synctex=1 -interaction=nonstopmode $(MAIN_TEX) > /dev/null 2>&1
OTHER=$$(find . -iname *aux) $$(find . -iname *bbl) $$(find . -iname *blg)
ORDER_TEX=order.tex
ORDER_TEX_DEP=order.yaml

.PHONY: all
all: $(PDF_TEX)

.PHONY: debug
debug: $(PDF_TEX)-debug

$(ORDER_TEX): $(ORDER_TEX_DEP)
	python3 _scripts/gen_order.py $^ > $@

$(PDF_TEX): $(TEX) $(MAIN_TEX) $(BIBS) Makefile $(ORDER_TEX)
	-@latexmk -quiet -interaction=nonstopmode -f -pdf $(MAIN_TEX) 2>&1 >/dev/null
	-@latexmk -c
	-@rm *aux *bbl *glg *glo *gls *ist *latexmk *fls
	@ls $(PDF_TEX) > /dev/null
	@echo "Finished"

$(PDF_TEX)-debug: $(TEX) $(MAIN_TEX) $(BIBS) Makefile
	-@latexmk -interaction=nonstopmode -f -pdf $(MAIN_TEX) > latexmk.out
	-@mv $(PDF_TEX) $(PDF_TEX-debug)

.PHONY: clean
clean:
	-@rm $(PDF_TEX) $(OTHER_FILES) $(OTHER)



