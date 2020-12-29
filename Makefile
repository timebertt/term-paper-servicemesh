BUILDDIR=build
MD_IN=content/*.md
HTML=$(BUILDDIR)/paper.html
PDF=$(BUILDDIR)/paper.pdf
METADATA=metadata.yaml

all: html pdf

$(BUILDDIR):
	@mkdir $(BUILDDIR) -p

pdf: $(PDF)
.PHONY: $(PDF)
$(PDF): $(BUILDDIR) $(MD_IN)
	@echo "> Building PDF"
	@pandoc $(MD_IN) \
	--fail-if-warnings \
	--defaults "pandoc/defaults.yaml" \
	--defaults "pandoc/defaults-latex.yaml" \
	--metadata-file $(METADATA) \
	--output=$(PDF)

open: open-pdf
open-pdf:
	@open $(PDF)

html: $(HTML)
.PHONY: $(HTML)
$(HTML): $(BUILDDIR) $(MD_IN)
	@echo "> Building HTML"
	@pandoc $(MD_IN) \
	--fail-if-warnings \
	--defaults "pandoc/defaults.yaml" \
	--metadata-file $(METADATA) \
	--to=html5 \
	--output=$(HTML) \
	--self-contained

open-html:
	@open $(HTML)

.PHONY: clean
clean:
	@rm -rf $(BUILDDIR) output-tex

.PHONY: install-requirements
install-requirements:
	brew install pandoc pandoc-citeproc pandoc-crossref
