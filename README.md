= kursinis-vrp

You need append the snippet below to `~/.gitconfig` in order to `git diff` pdfs.
```
[diff "pdfdiff"]
        command = diffpdf
```

obviously this requires installing `diffpdf`.
