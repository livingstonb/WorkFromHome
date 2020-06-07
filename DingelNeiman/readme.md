# Dingel-Neiman

We use datasets provided by Jonathan Dingel and Brent Nieman to construct a teleworkable indicator by occupation and sector (<https://github.com/jdingel/DingelNeiman-workathome>).

## Required inputs

* *build/input/occupations_workathome.csv*

A dataset with an O\*NET teleworkable score for each occupation.

* *build/input/teleworkable_opinion_edited.csv*

A modified version of Dingel and Neiman's manual (opinion) teleworkable scores by occupation, where we recoded teleworkable to zero or one in the cases that it took the value of 0.5, using our own judgment. The original dataset from Dingel and Neiman was *Teleworkable_BNJDopinion.csv*.