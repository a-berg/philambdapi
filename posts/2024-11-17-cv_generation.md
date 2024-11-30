---
title: My somewhat convoluted CV generation workflow
tags: programming
---

## Introduction

This is one of those tasks that are simple and straightforward, except for a programmer.

Anybody has to write their own curriculum and keep it updated, once every few months at worst, sometimes less when you're
in a stable position. Ah, yes, if only things were so simple...

As a programmer, I have this tendency to, you know, automate _everything_. Even things that shouldn't be (and of course this
is one of them). It all started, I remember, with my reject to using Word. I mean, most people have their CV done in Word I guess,
maybe Canva or other graphical design tool if you feel extra-fancy. However, to me these tools were clunky and "unergonomic"...
I had to manually set the position of many text boxes, or feel like the text flow wasn't optimal, and these things, to an
obsessive perfectionist like I am, are too much to bear. So, since I already knew LaTeX, I decided I could do better and do it
easily too...

Enter the rabbit hole.

## First step: LaTeX

This was my first step in a thousand-mile journey. Switching to LaTeX was a reasonable decision, to be honest: the Knuth algorithm
for text-justification is still SotA and produces text that is simply too beautiful to look at to be ignored, and everything
else having to do with kerning and box placement can be easily adjusted with very sane defaults that makes everything look _slick_.

Also, if you have already compiled a Master's Thesis and multiple essays with it (sadly no papers, I'm no PhD), honestly making
a minimalistic CV document is not that hard. It's mostly lists and sections, and you get some goodies for free like inserting
today's date to let the recruiter know when did you update it (some recruiters aren't happy if it's more than a _week_ old).

I quickly came up with a distribution and style I was happy with. Everything should've ended there. Except...

Two things bugged me:

- I had to _manually_ compute the time I had been working at my current job, like an _animal_. I looked for LaTeX packages that
  solved this, to no avail.
- Also, I wanted to have a two-language setup, and that meant having two copies of the same file, with the daunting
  possibility of one becoming outdated if I changed the sections of one e.g.
- Finally and more importantly, LaTeX doesn't play well with HTML, and since I had planned to have a blog (this blog) running,
  I figured it would be nice to have my CV in HTML format too.

What did it led to? Pandoc of course. Did I say I had written my Master's Thesis in LaTeX? I lied. I did it in RMarkdown
which exposed me to pandoc, and I had already played with it for a while so I thought "it's not that far fetched to
migrate to markdown and pandoc".

## Pandoc

Oh did I enjoy this part. Pandoc might be my favourite program _ever_. It's so well designed, and completely focused on the
UNIX philosophy: do _one_ thing and do it _extremely well_. This thing can convert markdown to anything, or anything to anything
really, and has one of the best and feature-rich markdown flavors out there. Nowadays whenever I want to produce a nice-looking
pdf, I mostly do it in pandoc instead of LaTeX. That's how **good** it is.

Initially, an item of my LaTeX CV file could be like this:

```latex
\cvitem
    {Data Scientist}
    {2021 -- now (3 years \& 2 months)}
    {Gradiant}
    {Vigo, Pontevedra}
\begin{enumerate}[label=\textbullet, itemsep=-1pt, rightmargin=0.5cm]
  \item Did something amazing.
  \item More amazing things.
  \item ...
\end{enumerate}
```

Which is not bad. But I thought I could do _better_. It still bugged me a little bit that content was not _completely_
separated from style. So this led me to consider switching to markdown, then apply a LaTeX template via pandoc.

However that didn't make me super happy because I had litte control over which data should be put where (and I needed to
automatically compute the job position duration, remember?). Which led me to YAML.

With YAML, the same previous section now was:

```yaml
- jobtitle: Data Scientist
  location: Vigo, Pontevedra
  company: Gradiant
  start: 2021-08-17
  end: now
  highlights:
    - Did something amazing.
    - More amazing things.
    - ...
```

Now it was a list of "job" items, with fields that could be sent via pandoc template to specific parts of the LaTeX macro:

```latex
\cvitem
    {${it.jobtitle}}
    {${it.start} -- ${it.end} (${it.duration})}
    {${it.company}}
    {${it.location}}
\begin{enumerate}[label=\textbullet, itemsep=-1pt, rightmargin=0.5cm]
  \item ${ it.highlights[\item ] }
\end{enumerate}
${ if(it.tools) }\textit{\textbf{Tools used}: ${ it.tools }.}\\${ endif }
\vspace{12pt}
```

Oh, there's a little trick I learnt about pandoc templates: you can "fold" lists with a custom separator easily like
this: `list[sep]`. So for example, in the previous snippet the line:

```latex
  \item ${ it.highlights[\item ] }
```

would be expanded to:
```latex
  \item Did something amazing.\item More amazing things.\item ...
```

To me this was kind of mind blowing to be honest. You may notice how there's a "Tools used" section that's nowhere to be
seen in my CV. Well, it's because it's commented in the YAML files, but I could easily list the tools used at a given position,
and I _might_.

Another goodie is localization. I can generate English and Spanish versions of the curriculum by having a conditional switch
based on a variable I set on the command line. I could even set the English version to not have a picture of myself, since it's
customary to not have it in non Spanish-speaking countries, apparently (for now it stays there).

## Just

I can't forget about `just`, of course. Little rust binary that is similar to `make`, but supercharged. Helps a lot defining
build commands.

For example, I have the following _justfile_:

```just
lang := "en"
name := "myname"
DATE := `LC_TIME=en_US.UTF-8 date "+%b%Y"`
JOBNAME := name + "_" + DATE
DOCUMENTS := "~/Documents/cv/"

all: makepdf
  mv ./cv.pdf ./{{JOBNAME}}_{{lang}}.pdf
  cp ./{{JOBNAME}}_{{lang}}.pdf {{DOCUMENTS}}

makepdf: processyml
  pandoc --defaults pdf_defaults.yaml -V lang_es={{ if lang == "es" { "true" } else { "" } }}

makeweb: processyml
  pandoc --defaults html_defaults.yaml -V lang_es={{ if lang == "es" { "true" } else { "" } }}

processyml:
  pdm run python3 -m src.python.process_yaml_data -L {{lang}}

get-fonts:
  sudo apt install fonts-vollkorn fonts-open-sans

pdm-init:
  pdm init
  pdm sync
```

It has some extras over Make, for example the possibility to override variable values in the command line (e.g. `just
lang=es` would set `lang` to `"es"` instead and trigger the Spanish version of the CV to be compiled). I honestly don't
use just that much nowadays (what with not being a standard/base bash tool and thus having to force my teammates to
install it if they want to run my projects), but since I was already using it in this repo and it is a personal project,
I decided to go with it.

## Python script to compute the date

This was done more or less at the same time as the switch to pandoc. I had this hyper-fixation on automatically computing the
current duration of my time at every position, and particularly the current one.

Having no other options available (and not wanting to delve into pandoc filters -- yet) I decided to write a simple
Python script for it. You know, like in the old times when Python was just a batteries-included scripting language to do
simple stuff.

Basically the script is this:

```python
from pathlib import Path
from omegaconf import OmegaConf


from .date_logic import DateInterval, CVDateInterval

import argparse as arg


def main():
    parser = arg.ArgumentParser()
    parser.add_argument("-L", "--lang", default="es")
    parsed_args = parser.parse_args()
    content = Path("./content")
    sections = ("experience", "education", "skills")
    language = parsed_args.lang
    data = OmegaConf.create(
        dict(
            (s, OmegaConf.load((content / language / s).with_suffix(".yaml")))
            for s in sections
        )
    )
    data = OmegaConf.merge(OmegaConf.load(content / "personal.yaml"), data)

    for item in data.experience:
        dt = DateInterval(item.start, item.end)
        dt = CVDateInterval.from_interval(dt, language)
        item["duration"] = dt.span
        item.start = dt.start
        item.end = dt.end

    with open("./src/cv.yaml", "w+") as f:
        f.write(OmegaConf.to_yaml(data))


if __name__ == "__main__":
    main()
```

Nice, right? Except I hid away the logic in 2 additional files. I mean they're really short, but still (check the
[github][vitae-gh] if you want).

What I basically do is define the language I want, open the YAML files in the right folder, process the dates,
create a new merged `cv.yaml` file with everything + the computed durations, and that will be passed to pandoc. 
Easy peasy.

## GitOps

But still this wasn't enough. Ok, sure, I _am_ automating most of the process... but what about the updates to the 
website!? What about _automatically compiling it on file changes_?

That's why I set up a Github workflow for it. I want to push the changes to the yaml files and trigger the CV compilation
on GitHub and have the CV on the internet and readily accessible to myself (in case I'm not on my home computer and need to
send the most recent version to someone) and this blog site.

After some trial and error, I ended up with this:

```yaml
name: Build CV

on:
  push:
    branches:
      - main
  workflow_dispatch:

jobs:
  build-cv:
    runs-on: ubuntu-latest

    steps:
    - name: Checkout repository
      uses: actions/checkout@v3

    - name: Set up Python
      uses: actions/setup-python@v4
      with:
        python-version: '3.10'

    - name: Set up Just
      uses: taiki-e/install-action@just
      with:
        just-version: 1.36.0

    - name: Set up PDM
      uses: pdm-project/setup-pdm@v4
      with:
        python-version: '3.10'

    - name: Set up Pandoc
      uses: pandoc/actions/setup@v1

    - name: Set up Tectonic
      uses: wtfjoke/setup-tectonic@v3
      with:
        github-token: ${{ secrets.GITHUB_TOKEN }}

    - name: Install FontAwesome Free v6
      run: |
        wget https://github.com/FortAwesome/Font-Awesome/releases/download/6.5.2/fontawesome-free-6.5.2-desktop.zip
        sudo unzip -j fontawesome-free-6.5.2-desktop.zip "*/otfs/*" -d /usr/local/share/fonts
        sudo fc-cache -f -v  # Update font cache

    - name: Install Vollkorn, Open Sans, Python packages
      run: |
        just get-fonts
        just pdm-init

    - name: Build PDF with Docker image
      run: |
        just lang=en DOCUMENTS="."

    - name: Release
      uses: softprops/action-gh-release@v2
      if: startsWith(github.ref, 'refs/tags/')
      with:
        files: ./*.pdf
```

As you can see, most of it is just installing tools via premade GitHub actions (except the fonts and python dependencies),
then build it and use a release action to publish the latest source code & the compiled PDF. As of now the workflow only compiles
the English version, and has no picture (there was a problem with uploading it, may be resolved but haven't tried). 
I'd like to change that soon, but for now I'm pretty content.

With this I would have my curriculum compiled on every push to main. Some improvements could be to compile the Spanish
version if there were changes to these files, and do the same for the English version. Maybe use a custom image with the
tools pre-installed so the worker doesn't have to set up everything every single time and save up time.

## The future: pandoc filters? Typst?

So, this is all well and good. Except.

Except pandoc has a filter system that, if I was to learn Lua and its pandoc API, could solve the date problem _and_ also not have
any templates, but directly transform _yaml_ to the pandoc _AST_ and then to any document...

Then there's typst. A modern Rust alternative to LaTeX, which has a nice syntax, _maybe_ can compute the durations by
itself and has HTML support planned in the future. That could solve it, surely... Just one more technology and it will
be _perfect_, you'll see.

[vitae-gh]: <https://github.com/a-berg/philambdapi>
