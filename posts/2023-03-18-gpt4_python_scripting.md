---
title: Using GPT-4 to write utility functions.
tags: computing
published: 18-03-2023
---

Just like everyone else these days, I'm trying out GPT-4 capabilities. Since I don't
have access to the API (yet?), I'm stuck with ChatGPT-Plus for the time being.  The Chat
API limits input and output to 4096 tokens, you can't use the vision mode, and you have
a limit (at the time of writing) of 25 messages every 3 hours for the GPT-4 model.

For the last 3 or 4 days, I have been using Plus to review a project's architecture
(GPT-4) and try to adapt jupyter notebooks to said architectural patterns (was hoping
for a zero-shot refactor), write small internal proposals (GPT-3.5 is sufficient for
this), and also some utility scripts I didn't want to bother with (both with GPT-4 and
GPT-3.5).

After my trials, I'm still confident on my job security; however as I understand how to
use the tool better, I hope my ability to get more productivity out of it improves.

## Use case

I'm going to focus only on my last GPT use.

I'm writing internal documentation and reports for my coworkers on several topics, and
in one particular instance I deemed useful to talk about the file structure of a project
another coworker had created using Clean Architecture and other good design practices
(I'm writing another blog piece on it btw!)

Now, I like to compile my documents using LaTeX (via `pandoc`, actually), because it is
frankly less hassle in the long run when dealing with figures, links and
citations. Additionally, I'm the kind of guy who obsesses over details and I just
couldn't live with just dumping the output of a `tree`[^1] command into the document, so
I looked at packages to render trees in LaTeX and found `dirtree`. Cool, but this
package depends on a particular syntax that doesn't remotely look like `tree` output.
For example, the file structure:

```
.
├── folder1
│  ├── fileA
│  ├── fileB
│  └── fileC
├── file1
├── file2
└── README.md
```

Needs to be written as:

```latex
\dirtree{
  .1 ..
  .2 folder1.
  .3 fileA.
  .3 fileB.
  .3 fileC.
  .2 file1.
  .2 file2.
  .2 README.md.
}
```

I wasn't going to write that by hand everytime I wanted a tree in my pdf.

Python to the rescue! I had to write a script that, given a directory, crawled it and
created a structure (e.g. nested dictionaries) representing it, then transform it to
`dirtree` format.  But I couldn't bother to do such menial coding, which got me to
GPT-4.

[^1]: actually, `exa -T`.

## The (final) prompt

I have deleted my initial conversation with GPT-4, so I can only faithfully reproduce my
final prompt. Briefly, the process to get at this prompt was:

1. Initial prompt asking for what I wanted (similarly to this one) but without the
   extras on recursion limit or flags.
2. Gave it an example output.
3. After a first (working!) code was made, I asked to check for bugs. It rewrote the
   code but didn't do what I wanted anymore.
4. Asked for extra options in successive prompts.

The final result of that process was ugly code that didn't do what I wanted. So I
decided to start anew with a prompt that merged all of it, which is the following:

```
You have to write a python script that:
1. Recursively crawls a directory, creating a nested dictionary representing the file
   and folder structure, with the first key being said directory.
2. The recursion could have a limit, like the standard `tree` bash command.
3. Using a recursive funcion is not a must, you could use a `while` loop if it helps
   performance and readability, or be creative with `dict` merging and splitting paths.
3. accepts a directory as an input
4. accepts a level optional argument to limit
5. accepts an optional alias for the input directory
6. uses pathlib for path related functions and argparse for argument parsing

Example: for a folder named "myfolder/" with the following structure:

mydir/
├── fileA
├── fileB
├── fileC
└── folder1
    ├── file1
    └── file2

the expected output is:

{
    "mydir": {
        "fileA": None,
        "fileB": None,
        "fileC": None,
        "folder1": {
            "file1": None,
            "file2": None,
        }
    }
 }

Revise your work for potential bugs before submitting. Write tests in a separate script to check it too.
```

The prompt is reprocuded as-is (typo in the list numbering included). I added more
detail to the requirements, such as "recursion limit like `tree` command", and was more
explicit on the example I wanted. I also included the "revision" as part of the prompt
just in case (might be good practice; prompt engineering, yay!) and asked it to write a
test.

I didn't ask for a formatter function since I already had one (which worked well in
precisely that kind of nested dict structure) from the previous session.

## Results!

GPT-4 complied, and I must say the code worked as-is. I just had to fix a small part
(see if you notice the micro-bug).

```python
import argparse
from pathlib import Path

def crawl_directory(directory, level=None, alias=None):
    def _crawl_directory(dir_path, curr_level):
        if level is not None and curr_level > level:
            return

        nested_dict = {}
        for item in dir_path.iterdir():
            if item.is_file():
                nested_dict[item.name] = None
            elif item.is_dir():
                nested_dict[item.name] = _crawl_directory(item, curr_level + 1)

        return nested_dict

    if alias is None:
        alias = directory.name

    return {alias: _crawl_directory(directory, 0)}

def main():
    parser = argparse.ArgumentParser(description="Recursively crawl a directory and create a nested dictionary representing the file and folder structure")
    parser.add_argument("directory", type=Path, help="The directory to crawl")
    parser.add_argument("--level", "-L", type=int, default=None, help="The maximum depth of recursion")
    parser.add_argument("--alias", "-a", type=str, default=None, help="An alias for the input directory")

    args = parser.parse_args()

    result = crawl_directory(args.directory, args.level, args.alias)
    print(result)

if __name__ == "__main__":
    main()
```

There is a minor bug: the initial directory level should be 1, not 0 (otherwise it
doesn't work as `tree`). It's very minor: `tree -L 1` would be equivalent to the
script's `-L 0` if not corrected.

Now, the test is pretty impressive too! But I must say it hallucinated a bit: this test
doesn't work as-is, because the `setUp` function is incomplete. However it's very, very
impressive that it understood the tests for both options.

```python
import unittest
from pathlib import Path
from directory_crawler import crawl_directory

class TestCrawlDirectory(unittest.TestCase):
    def setUp(self):
        self.test_dir = Path("mydir")

    def test_no_limit(self):
        expected_output = {
            "mydir": {
                "fileA": None,
                "fileB": None,
                "fileC": None,
                "folder1": {
                    "file1": None,
                    "file2": None,
                }
            }

        }
        self.assertEqual(crawl_directory(self.test_dir), expected_output)

    def test_limit_1(self):
        expected_output = {
            "mydir": {
                "fileA": None,
                "fileB": None,
                "fileC": None,
                "folder1": None,
            }
        }
        self.assertEqual(crawl_directory(self.test_dir, level=1), expected_output)

    def test_alias(self):
        expected_output = {
            "my_dir": {
                "fileA": None,
                "fileB": None,
                "fileC": None,
                "folder1": {
                    "file1": None,
                    "file2": None,
                }
            }
        }
        self.assertEqual(crawl_directory(self.test_dir, alias="my_dir"), expected_output)

if __name__ == "__main__":
    unittest.main()
```

If anyone is interested, there's a
[gist](https://gist.github.com/a-berg/570c08f0402899e140ffecbf786f1c25) with the
complete code (it adds an optional flag and the corresponding function to turn on
`dirtree`-formatted output).

## Conclusion

I know, you might be able to code that in a cleaner way without recursion, using
dictionary merge trics or whatever. The point is not that. The point is that I described
the software I wanted and GPT-4 provided it, zero-shot. The point is that I don't wanna
do these menial scripting gigs when I want to automate this kind of stuff.

I won't say coders are going to be without jobs. In fact, I'm positive we won't be
replaced (_too_) soon. I mean, I haven't used the API (which is suppossedly more
powerful thanks to its 32k tokens context), but the code it generates, while good, is
limited to simple gists; plus you need to know about programming in order to describe
the software you want properly.

If anything, it relieves you from the more repetitive tasks and forces you to focus on
architecture, design and documentation (the description provided in the prompt is good
documentation in most cases I think).

Also, I have mentioned how I tried to zero-shot a refactor of a notebook into an
architecture I previously showed it (and was correctly understood as Clean
Architecture + Data-Driven Design + Hexagonal by GPT-4) but failed. Maybe more context
is needed, I genuinely don't know. But I also tried to have it help me in a less
"global" way, and it kept hallucinating stuff (e.g. talking about classes on weather
data, when the code had NONE of it), so it didn't help much on labour automation (it
helped me understand the architecture better, because of its initial explaination and
successive questions I asked to it). I noticed it's a bit too compliant, in the sense it
tends to agree with you almost always and reinforce your beliefs.

I'm not even _sure_ if I have gained any time from this at all... After all, I spent
several hours on it -- but I must say, I'm to blame for it: at first I tried for GPT-3.5
to generate a script that parsed the string that `tree` outputs via
[parsy](https://github.com/python-parsy/parsy) and ended up wasting too much time on a
more complicated approach (never go into parsers if you can replicate the functionality
of a program trivially).

I will keep testing and using ChatGPT, but as of now, I'm not entirely sold on it!

Thank you for reading, folks!
