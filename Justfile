present-4-3:
    typst compile pres.typ pres_4-3.pdf

handout:
    typst compile pres.typ --input handout=true .build/pres_still_4-3.pdf
    pdfjam \
      --nup 2x3 \
      --frame true \
      --scale 0.95 \
      --delta "8pt 10pt" \
      .build/pres_still_4-3.pdf \
      --outfile handout_4-3.pdf

pdf:
    typst compile main.typ --font-path ./fonts

html:
	typst compile main.typ --features html --format html --font-path ./fonts

watch:
	typst watch main.typ --font-path ./fonts

pushall:
    git remote | xargs -L1 -I R git push R

pushall-force:
    git remote | xargs -L1 -I R git push R -f
