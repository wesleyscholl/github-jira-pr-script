## AI Git Pull Request Script - Automate Pull Requests using Gemini AI
## For this public script (`public-pr-script.sh`), there are fewer requirements: GitHub CLI (hub), GitHub Token (PAT - set in .bash_profile or .zshrc), Gemini AI API Key (set in .bash_profile or .zshrc), GitHub reviewers (Code reviewer GitHub usernames) and GitHub assignee (your GitHub username) in .bash_profile or .zshrc (***`reviwers` and `assignee` are both optional**).
## Optional - Setting an alias for this script in .bash_profile or .zshrc (alias pr='~/public-pr-script.sh')
## Usage: pr [head branch] - Ex. 'pr develop', 'pr main', 'pr master', defaults to develop branch
## Note: This script will push local commits to the remote branch and create a pull request on GitHub
## Gemini AI will generate a PR summary for the pull request
## The PR summary will include the PR title, PR summary, code changes, and commit messages with hashes
## **This script must be run from the root directory of a git repository**
## For detailed configuration instructions and usage, refer to the GitHub repository:
## https://github.com/wesleyscholl/github-jira-pr-script

#!/bin/zsh
source ~/.bash_profile

# Get branch and push to remote
base_branch=$(git rev-parse --abbrev-ref HEAD)
echo "Current branch: $base_branch"
git push origin $base_branch

# Set head branch (default to 'develop')
head_branch=${1:-develop}
echo "Head branch: $head_branch"

# Generate PR title and summary
pr_title=$(git rev-parse --abbrev-ref HEAD)
gitdiff=$(git diff $head_branch..$base_branch | head -n 50)
diff=$(echo $gitdiff | sed 's/\\/\\\\/g' | sed 's/"/\\"/g' | sed 's/\n/\\n/g')

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

# Remove any markdown formatting from the PR summary
pr_summary=$(echo $pr_summary | sed 's/#//g' | sed 's/```//g' | sed 's/PR Summary://g')

# Prepare reviewers and assignee
reviewers=${github_reviewers:-}
assignee=${github_author:-}

# Create PR message
echo "$pr_title

#$pr_title

## PR Summary
$pr_summary

### Code Changes
    
### Commits" > PR_MESSAGE

# Get commit messages and hashes
commits=$(git log $base_branch --not $(git for-each-ref --format='%(refname)' refs/heads/ | grep -v "refs/heads/$base_branch") --oneline)
echo "$commits" > TMP
sed -i -e '/### Commits/r TMP' PR_MESSAGE

# Add the git diff with proper code block formatting
printf '```\n%s\n```diff\n' "$gitdiff" > TMP
sed -i -e '/### Code Changes/r TMP' PR_MESSAGE

# Print PR details
echo "PR Message: "
cat PR_MESSAGE
echo "Reviewers: $reviewers"
echo "Assignee: $assignee"

# Check for reviewers and assignee and create GitHub pull request with hub - Uncomment to create a live PR, comment to check PR formatting
if [[ -n "$reviewers" && -n "$assignee" ]]; then
  hub pull-request -b $base_branch -F PR_MESSAGE --no-edit -o -r $reviewers -a $assignee
elif [[ -n "$reviewers" ]]; then
  hub pull-request -b $base_branch -F PR_MESSAGE --no-edit -o -r $reviewers
elif [[ -n "$assignee" ]]; then
  hub pull-request -b $base_branch -F PR_MESSAGE --no-edit -o -a $assignee
else
  hub pull-request -b $base_branch -F PR_MESSAGE --no-edit -o
fi

# Cleanup temp files
rm -f TMP PR_MESSAGE PR_MESSAGE-e