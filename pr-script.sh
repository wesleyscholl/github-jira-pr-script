#!/bin/zsh
source ~/.bash_profile

# Get branch and push to remote, create full_branch, branch, and prebranch
base_branch=$(git rev-parse --abbrev-ref HEAD)

# Extract Jira ticket number from the branch name
ticket_number=$(echo $base_branch | grep -o -E '([A-Za-z]+-[0-9]{3,}|[A-Za-z]+-[0-9]{3,})')

# Check if a valid ticket number is found
if [ -z "$ticket_number" ]; then
    echo "Error: Branch name does not contain a valid Jira ticket number."
    exit 1
fi

# Pushes local commits to the remote branch
git push origin $base_branch
full_branch=$base_branch
# branch -> TWM Jira Ticket Number
branch="$ticket_number"
# prebranch -> TWM Jira Ticket Prefix i.e. CRS-, DIG-, MOB-. Will need to be modified for DEVOPS-, INFRA-, etc.
# prebranch="${ticket_number:0:3}"
# echo $prebranch

# Check for the presence of pull_request_template in .github/ folder
if [ -e ".github/pull_request_template" ]; then
    template_path=".github/pull_request_template"
else
    # Check in the home folder where the script resides
    script_folder=$(dirname "$0")
    template_path="$script_folder/pull_request_template"
fi

# Check if the template file exists
if [ ! -e "$template_path" ]; then
    echo "Error: Pull request template not found."
    exit 1
fi

# Check operating system then Request ticket data from Jira API
response=
echo $OSTYPE
if [[ $OSTYPE =~ ^darwin ]]
then
	echo "Mac OSX Operating System"
    response=$(curl -s "${jira_url}/rest/api/2/issue/$branch" -u "$jira_access_token" | sed 's#\\n##g;s#\\#\\\\#g')
elif [[ $OSTYPE == msys ]]
then
	echo "Windows Operating System"
    response=$(curl -s "${jira_url}/rest/api/2/issue/$branch" -u "$jira_access_token")
else
    echo "Operating system not supported"
	exit 1
fi

# Setting head branch to merge PR into - Pass a parameter after pr - Ex. 'pr develop' or 'pr master', defaults to develop branch
if [ -z "$1" ]
  then
    echo "No head branch argument supplied"
	base_branch='develop'
else
	base_branch=$1
fi

echo $base_branch
# Manually set base_branch here if needed
# base_branch='develop'
# base_branch='master'

# Assign variables 
title=
type=
desc=
comments=
subtasks=
attlength=
epic=
reproduce=
team=
sprint=
goal=
components=
labels=
gitdiff=

# Check for JIRA API response and parse Jira ticket data
if [ -z "$response" ]
  then
    echo "Error fetching data from Jira API"
	exit 1
else
	title=$(echo $response | jq -r '.fields.summary' | sed 's/^[ ]*//;s/[ ]*$//')
	type=$(echo $response | jq -r '.fields.issuetype.name')
	desc=$(echo $response | jq -r '.fields.description')
	comments=$(echo $response | jq -r '.fields.comment.comments[] | select(.body != "") | ("- " ) + .body')
	subtasks=$(echo $response | jq -r '.fields.subtasks[] | if .fields.status.name == "Done" then ("- [x] " ) else ("- [ ] " ) end + .fields.summary + (" - ") + .fields.status.name')
	attlength=$(echo $response | jq '.fields.attachment | length')
	epic=$(echo $response | jq -r '.fields.parent.fields.summary')
	reproduce=$(echo $response | jq -r '.fields.customfield_13380')
	team=$(echo $response | jq -r '.fields.customfield_13131.value')
	sprint=$(echo $response | jq -r '.fields.customfield_11505[0].name')
	goal=$(echo $response | jq -r '.fields.customfield_11505[0].goal')
	components=$(echo $response | jq -r '.fields.components[0].name')
	labels=$(echo $response | jq -r '.fields.labels[]')
	labels=${labels//$'\n'/,}
	# git diff - code changes
	gitdiff=$(git diff $base_branch)
fi

# Check for steps to reproduce
if [[ "$reproduce" == null ]];
then
    echo "No steps to reproduce - N/A"
	reproduce="N/A"
fi

# Check for sprint 
if [[ "$sprint" == null ]];
then
    echo "No Sprint Assigned"
	sprint="No Sprint Assigned"
fi

# Check for epic
if [[ "$epic" == null ]];
then
    echo "No Epic Assigned"
	epic="No Epic Assigned"
fi

# Check for team
if [[ "$team" == null ]];
then
    echo "No Team - Unassigned"
	team="No Team - Unassigned"
fi

# Check for goal
echo "Goal is: ============================="
echo $goal
if [[ -z $goal ]];
then
    echo "No Goal Assigned"
	goal="No Goal Assigned"
fi

# Check for component
if [[ "$components" == null ]];
then
    echo "No Components Assigned"
	components="No Components Assigned"
fi

# Prepare the pull request information, GitHub PR Reviewers and GitHub PR Assignee
if [ -z $github_reviewers ]
  then
    echo "No GitHub Reviewers Configured"
else
	assign="${github_author}"
	reviewers="${github_reviewers}"
	echo $github_author
	echo $reviewers
fi

# Prepare the label of the pull request - Possibly add second command line input for labels
if [ "$type" = "Story" ]; then
	label='Story'
fi
if [ "$type" = "Sub-task" ] || [ "$type" = "Task" ]; then
	label='Sub-task'
fi
if [ "$type" = "Bug" ] || [ "$type" = "Story bug" ]; then
	label='BUG'
fi

# Determine the base label based on the base branch
if [[ "$base_branch" != "develop" ]]; then
  base_label="UAT/PROD"
else
  base_label="QA"
fi

# Update the label based on the base_label and existing labels
if [[ -z "$label" ]]; then
  label="$base_label,$type"
elif [[ -z "$labels" ]]; then
  label="$base_label,$label"
else
  label="$base_label,$label,$labels"
fi

# Remove any trailing commas
label=${label%%,}

# Add PR title and # body line
if [ "$title" != "null" ]; then
	echo "$branch $title - $type

# [**${branch}**](https://totalwine.atlassian.net/browse/${branch}) $title - $type" >> PR_MESSAGE
fi
echo "" >> PR_MESSAGE

# Build PR description - .github/pull_request_template is default
cat "$template_path" >> PR_MESSAGE
# Change location if .github/pull_request_template does not exist in repo
# cat ../pull_request_template >> PR_MESSAGE

# Checking for comments
if [[ "$comments" == null ]]
  then
	comments=$(echo "* No comments")
fi

# Checking for subtasks
if [[ "$subtasks" == null ]]
  then
	subtasks=$(echo "* No Subtasks")
fi

if [[ "$desc" == null ]]
  then
	desc=$(echo "* No Description")
fi

# Add the description, comments, subtasks, team, sprint, epic, and steps to reproduce 
echo "### Description
$desc
##
#### Comments
$comments
##
#### Subtasks
$subtasks
##
> $team
> $sprint
> $goal
> $components
> $epic
##
## Steps to Reproduce
- $reproduce" > TMP
sed -i -e '/as needed./r TMP' PR_MESSAGE

# Delete unused lines from pull_request_template - Cross-platform commands & logic
awk '!/Replace this with a short description.  Delete sub sections as needed./ && !/Put your Ticket Title Here/' PR_MESSAGE > TMP
mv TMP PR_MESSAGE
# Delete unused lines from pull_request_template - Cross-platform commands & logic
awk '!/Replace this with a short description.  Delete sub sections as needed./ && !/Put your Ticket Title Here/' PR_MESSAGE > TMP
mv TMP PR_MESSAGE

if [[ $OSTYPE =~ ^darwin ]]
then
	sed -i '' '/Replace this with a short description.  Delete sub sections as needed./d' PR_MESSAGE
	sed -i '' '/Put your Ticket Title Here/d' PR_MESSAGE
elif [[ $OSTYPE == msys ]]
then
	sed -i '/Replace this with a short description.  Delete sub sections as needed./d' PR_MESSAGE
	sed -i '/Put your Ticket Title Here/d' PR_MESSAGE
fi

# Append the commit messages and hashes in the description
git log $full_branch --not $(git for-each-ref --format='%(refname)' refs/heads/ | grep -v "refs/heads/$full_branch") --oneline > TMP
sed -i -e '/list of updates/r TMP' PR_MESSAGE
echo PR_MESSAGE

# Getting screenshot count, parsing screenshot IDs, parsing attachment response, and adding screenshots to the template. 
screenshots=()
screenshot_count=$(echo $response | jq -r '.fields.attachment | length')

for i in $(seq 0 $((screenshot_count - 1))); do
  ssid=$(echo $response | jq -r ".fields.attachment[$i].id")
  att=$(echo $response | jq -r ".fields.attachment[$i]")
  if [[ $ssid == null ]]; then
    echo "No screenshot #$((i + 1))"
  else
    attres=$(curl -I "${jira_url}/rest/api/3/attachment/content/${ssid}" -u "$jira_access_token")
	echo "${jira_url}/rest/api/3/attachment/content/${ssid}"
    if [ -z "$attres" ]; then
      echo "Error fetching url for screenshot #$((i + 1)) from Jira API"
    else
      screenshot=${attres##*location: }
      screenshot=${screenshot%%vary:*}

	  # Remove 'x-frame-options: SAMEORIGIN' from the screenshot URL
      screenshot=$(echo "$screenshot" | sed 's/x-frame-options: SAMEORIGIN//')

      echo "![Screen Shot](${screenshot%.*})" >> PR_MESSAGE
    fi
  fi
done

# Shorten the git diff to 3000 characters
gitdiff=${gitdiff:0:3000}

# Add the git diff with proper formatting
echo '```' > TMP
sed -i -e '/list of code changes/r TMP' PR_MESSAGE

echo "$gitdiff" > TMP
sed -i -e '/list of code changes/r TMP' PR_MESSAGE

echo '```diff' > TMP
sed -i -e '/list of code changes/r TMP' PR_MESSAGE

# Print the PR_MESSAGE
cat PR_MESSAGE
echo $label
# Create the pull request - Uncomment to create a live PR, comment to check PR formatting
# if [ -z "$label" ]; then
# 	hub pull-request -b $base_branch -F PR_MESSAGE --no-edit -o -r $reviewers -a $assign
# else
# 	hub pull-request -b $base_branch -F PR_MESSAGE --no-edit -o -r $reviewers -a $assign -l $label
# fi

# Cleanup temp files
rm -f PR_MESSAGE
rm -f PR_MESSAGE-e
rm -f PR_MESSAGE_DESCRIPTION
rm -f TMP