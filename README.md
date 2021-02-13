# Moved

The QA-SRL Bank 2.0, client library, and other related resources are now all maintained in one
place, at [julianmichael/qasrl](https://github.com/julianmichael/qasrl).

---

# The QA-SRL Bank

This repository is the reference point for *QA-SRL Bank 2.0*,
the dataset described in the paper _Large-Scale QA-SRL Parsing_.

The data may be downloaded [here](http://qasrl.org/data/qasrl-v2.tar) or you can clone this
repository and run `./download.sh`.

## Contents

When you run `./download.sh`, the dataset will be downloaded and expanded into the `data/qasrl-v2/`
directory. Its contents are as follows:

* `data/qasrl-v2`:
    * `orig/`: The original data gathered on MTurk, where workers wrote the questions.
    * `expanded/`: The expanded dataset with model-generated questions and answers gathered in
    our expansion round. Train and dev only.
    * `dense/`: The densely annotated data, combining the `expanded` data with extra
    model-generated questions and judgments from turkers on a 5k-sentence subset of dev and test.
    * `index.json.gz`: An index of the documents that were used across all partitions, with metadata.

If you are modeling the data, you will probably be using `orig` or `expanded` for training and
tuning, and `orig` and `dense` for evaluation.
Metadata is included in each set allowing you to determine which round a question or answer judgment
originated from.

See the [Data Format description](FORMAT.md) for details on how the data files are laid out.

## Using the QA-SRL Bank

Once you have downloaded it, you can use your favorite JSON parsing or data reading library to
process and iterate through it. However, there are some options already available:

* If you're using Python (or particularly [AllenNLP](https://allennlp.org/)),
you can use the dataset reading code from our [model](https://github.com/nafitzgerald/nrl-qasrl).
* If you're using Scala, we have a [client library](https://github.com/julianmichael/qasrl-bank-scala).
* If you're using something else and write your own, please contribute it (or a reference to it)!

