# The QA-SRL Bank

This repository is the reference point for *QA-SRL Bank 2.0*,
the dataset described in the paper _Large-Scale QA-SRL Parsing_.

The data may be downloaded [here](http://qasrl.org/data/qasrl-v2.tar) or you can clone this
repository and run `./download.sh`.

## Contents

When you run `./download.sh`, the dataset will be downloaded and expanded into the `data/qasrl-v2/`
directory.

* `data/qasrl-v2`: All of the data, grouped into three sets of files:
    * `data/qasrl-v2/orig/`: The original data gathered on MTurk, where workers wrote the questions.
    * `data/qasrl-v2/expanded/`: The expanded dataset with model-generated questions and answers gathered in
    our expansion round. Train and dev only.
    * `data/qasrl-v2/dense/`: The densely annotated data, combining the `expanded` data with extra
    model-generated questions and judgments from turkers on a 5k-sentence subset of dev and test.
* `lib/`: Client code for reading the data. If you write some (in any language),
  or improve the ones we have here, please send a pull request! (And file an issue if there are any
  problems with the existing ones.)

If you are modeling the data, you will probably be using `orig` or `expanded` for training and
tuning, and `orig` and `dense` for evaluation.
Metadata is included in each set allowing you to determine which round a question or answer judgment
originated from (see the `QuestionSource` and `AnswerSource` descriptions in
[Data Format](#data-format)).

The vast majority of the `orig` and `expanded` data has 3 validation judgments per question,
and the vast majority of the `dense` data has 6 validation judgments per question.
However, these numbers do vary because of a few mistakes (e.g., accidentally gathering data twice
for a question) and limitations of our crowdsourcing pipeline (where in a few cases, the same
validator might have answered a question multiple times, but we collapse identical answer judgments
together).  These cases are included for completeness, but easy to filter out if you need to.

## Data Format

The data files are provided gzipped in the [JSON Lines](http://jsonlines.org/) format, to facilitate
streaming (in cases where order doesn't matter) and minimize the data footprint.
While the compressed files can be read directly, on a UNIX system you may run
```bash
find data -name *.jsonl.gz -type f -exec sh -c 'gunzip -c $0 > `dirname "$0"`/`basename "$0" .gz`' '{}' \;
```
from this repository's base directory to decompress all of the data.
In each file, each line is a JSON object containing all verb annotations for a sentence.
The sentences are ordered alphabetically in the file by their unique string sentence ID.

The structure of the JSON object on each line is a `Sentence` object defined as follows, where
`Array` denotes a JSON array,
`Map` denotes a JSON object, and
`Set` denotes a JSON array with unique elements.

```
Sentence ::= {
  sentenceId : SentenceId,
  sentenceTokens : Array[Token],
  verbEntries : Map[Index, VerbEntry]
}

VerbEntry ::= {
  verbIndex : Index,
  verbInflectedForms : {
    stem : LowerCaseString,
    presentSingular3rd : LowerCaseString,
    presentParticiple : LowerCaseString,
    past : LowerCaseString,
    pastParticiple : LowerCaseString
  },
  questionLabels : Map[QuestionString, QuestionLabel]
}

QuestionLabel ::= {
  questionString : QuestionString,
  questionSources : Set[QuestionSource],
  answerJudgments: Set[AnswerJudgment]
  questionSlots : {
    wh : LowerCaseString,
    aux : LowerCaseString,
    subj : LowerCaseString,
    verb : LowerCaseString,
    obj : LowerCaseString,
    prep : LowerCaseString,
    obj2 : LowerCaseString
  },
  tense: LowerCaseString,
  isPerfect: Boolean,
  isProgressive: Boolean,
  isNegated: Boolean,
  isPassive: Boolean
}

AnswerJudgment ::= {
  sourceId : AnswerSource,
  isValid : Boolean,
  spans : undefined | Set[Span]
}

Span ::= [Index, Index]
```

The `spans` field of `AnswerJudgment` is undefined if and only if
`isValid == false`. A span is represented as a 2-element array of its beginning
index (inclusive) and end index (exclusive).

The `verb` slot of `questionSlots` uses an abstracted form of the verb that is
common to all questions, with values such as `stem`, `been pastParticiple`,
`be presentParticiple`, etc.
Replacing the conjugation with the correct form from the verb's `verbInflectedForms` field, and
concatenating all of the slots that are not `_`, inserting spaces as appropriate, capitalizing the
beginning, and appending a question mark will always yield the `questionString` value.

All of the fields below `answerJudgments` in a `QuestionLabel` are automatically, deterministically
computed using the question's `sentenceTokens`, `verbInflectedForms`, and `questionString`.

The following two prediction tasks are equivalent:

* Predicting all seven `questionSlots`
* Predicting all `questionSlots` except `aux` and `verb`, and then 
then predicting the five grammatical fields, `tense`, `isPerfect`, `isProgressive`, `isNegated`, and
`isPassive`.

The terminals are defined as follows:

* `SentenceId`: a string with no spaces, unique for each sentence.
* `Token`: a PTB-style token (no spaces).
* `LowerCaseString`: a lower-case string.
* `Index`: a non-negative integer JSON number which is a valid index into `sentenceTokens`;
  used as a string (i.e., `[1-9][0-9]*`) when indexing into `verbEntries`.
* `QuestionString`: a valid QA-SRL question, with only the first character upper-case, ending in a
question mark.
* `QuestionSource`: a string uniquely identifying the writer of a question.
Begins with `turk-` if it was written by a turker, and `model-` if it was
generated by a model. Model sources for questions written by a turker.
* `AnswerSource`: a string denoting the provenance of an answer judgment. Same as `QuestionSource`,
but is restricted to turkers since we only record human answer judgments in the data, and
optionally is appended with a suffix (`-expansion` or `-eval`) denoting on which round of data
collection it was gathered in. However, turker indices are shared across data collection runs.

The prediction task we do in the paper can be phrased as filling in the `questionLabels` field of an
otherwise complete `VerbEntry` in a `Sentence`. While we do not explicitly feed the verb's inflected
forms into the model, we need the inflected forms in order to transform the model's output (which
uses the slot-based format that abstracts out the verb) into the originally written QA-SRL question.

More details on the file contents, examples, a data browsing interface, and the remainder of the
documentation are in progress.
