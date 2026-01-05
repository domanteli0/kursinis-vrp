pdf:
	cd "{{justfile_directory()}}/diagrams" && for f in *.mmd; do \
	  base="${f%.mmd}"; \
	  mmdc -i "$f" -o "$base.pdf" --pdfFit; \
	  mutool draw -o "$base.svg" "$base.pdf"; \
	  convert "$base.svg" "$base.png"; \
	done
	typst compile main.typ --features html --font-path ./fonts

html:
	typst compile main.typ --features html --format html --font-path ./fonts

watch:
	typst watch main.typ --font-path ./fonts

pushall:
    git remote | xargs -L1 -I R git push R

pushall-force:
    git remote | xargs -L1 -I R git push R -f
