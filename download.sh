#!/bin/bash

# download
wget https://homepages.inf.ed.ac.uk/rbf/TrimBot2020git/public/Challenge2017_training.zip
wget https://homepages.inf.ed.ac.uk/rbf/TrimBot2020git/public/Challenge2017_testing.zip
# extract
unzip Challenge2017_training.zip
unzip Challenge2017_testing.zip

# submissions (optional)
mkdir -p evaluation/submissions
cd evaluation/submissions
wget https://homepages.inf.ed.ac.uk/rbf/TrimBot2020git/public/Challenge2017_evaluation_submissions.zip
unzip Challenge2017_evaluation_submissions.zip

