#!/bin/zsh
source ~/.bash_profile

# Get branch and push to remote, create full_branch, branch
base_branch=$(git rev-parse --abbrev-ref HEAD)
echo $base_branch

# Pushes local commits to the remote branch
git push origin $base_branch
full_branch=$base_branch

# Create a temporary file for the PR message
touch PR_MESSAGE

# Setting head branch to merge PR into:
# Pass a parameter after pr - Ex. 'pr develop', 'pr main', 'pr master', defaults to develop branch
if [ -z "$1" ]
  then
    echo "No head branch argument supplied"
	base_branch='develop'
else
	base_branch=$1
fi

echo $base_branch

# Get current branch name for PR title
pr_title=$(git rev-parse --abbrev-ref HEAD)
pr_summary=
# Limit to 100 lines of diff
gitdiff=$(git diff $base_branch..$full_branch | head -n 50)

# Stringify the diff
diff=$(echo $gitdiff | sed 's/\\/\\\\/g' | sed 's/"/\\"/g' | sed 's/\n/\\n/g')

# Prepare the Gemini API request
gemini_request='{
	"contents":[{"parts":[{"text": "Write a detailed pull request summary description for these git diff changes in .MD format: '"$diff"' Do not include any other text in the repsonse."}]}],
	"safetySettings": [{"category": "HARM_CATEGORY_DANGEROUS_CONTENT","threshold": "BLOCK_NONE"}],
	"generationConfig": {
		"temperature": 0.15,
		"maxOutputTokens": 250
	}
}'

# Get pull request summary from Gemini API
pr_summary=$(curl -s \
  -H 'Content-Type: application/json' \
  -d "$gemini_request" \
  -X POST "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash-latest:generateContent?key=${GEMINI_API_KEY}" \
  | jq -r '.candidates[0].content.parts[0].text'
  )

# If the PR summary is empty, retry the request
if [ -z "$pr_summary" ]; then
    pr_summary=$(curl -s \
      -H 'Content-Type: application/json' \
      -d "$gemini_request" \
      -X POST "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash-latest:generateContent?key=${GEMINI_API_KEY}" \
      | jq -r '.candidates[0].content.parts[0].text'
      )
fi

# Print the PR summary
echo $pr_summary

# If the Gemini retry request fails, exit
if [ -z "$pr_summary" ]; then
    echo "Error: API request for PR summary failed. Please try again."
    exit 1
fi

pr_summary=$(echo $pr_summary | sed 's/#//g' | sed 's/```//g' | sed 's/PR Summary://g')

# Prepare pull request GitHub PR Reviewers and GitHub PR Assignee
if [ -z $github_reviewers ]
  then
    echo "No GitHub Reviewers Configured"
else
	assign="${github_author}"
	reviewers="${github_reviewers}"
	echo $github_author
	echo $reviewers
fi

# Add PR title, pull request summary, diff, and commit messages to the PR message
if [ "$pr_title" != "null" ]; then
	echo "$pr_title

# $pr_title

## PR Summary
$pr_summary

### Code Changes
    
### Commits" > PR_MESSAGE
fi

# Get the commit messages and hashes
commits=$(git log $full_branch --not $(git for-each-ref --format='%(refname)' refs/heads/ | grep -v "refs/heads/$full_branch") --oneline)
echo "$commits" > TMP

# Add the commit messages to the PR message
if [ -s TMP ]; then
    sed -i -e '/### Commits/r TMP' PR_MESSAGE
fi

# Add the git diff with proper code block formatting
echo '```' > TMP
sed -i -e '/### Code Changes/r TMP' PR_MESSAGE

echo "$gitdiff" > TMP
sed -i -e '/### Code Changes/r TMP' PR_MESSAGE

echo '```diff' > TMP
sed -i -e '/### Code Changes/r TMP' PR_MESSAGE

# Print the PR_MESSAGE and reviewers
cat PR_MESSAGE
echo $reviewers

# Create the GitHub (hub) pull request - Uncomment to create a live PR, comment to check PR formatting
hub pull-request -b $base_branch -F PR_MESSAGE --no-edit -o -r $reviewers -a $assign

# Cleanup temp files
rm -f TMP
rm -f PR_MESSAGE