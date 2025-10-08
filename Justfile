pdf:
	typst compile main.typ --font-path ./fonts

watch:
	typst watch main.typ --font-path ./fonts

pushall:
    git remote | xargs -L1 -I R git push R

pushall-force:
    git remote | xargs -L1 -I R git push R -f
