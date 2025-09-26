pdf:
	typst compile main.typ --font-path ./fonts

watch:
	typst watch main.typ --font-path ./fonts
