# github-jira-pr-script - Automating pull request creation with Jira projects from the command line 👨🏻‍💻➡️🌐✅

Manually creating a GitHub pull request is a time-consuming task. Save time using this shell script.



> [!NOTE]  
> **There are now two versions of this script:**
>
> - `pr-script.sh` pulls JIRA ticket information and populates a pre-existing pull request template, PR summary provided by Gemini AI.
> - `public-pr-script.sh` creates a new pull request using the branch name, `git diff`, and git commits with hashes, PR summary provided by Gemini AI. I created this version for general use, not specific to Jira.  

## Table of Contents
* [What this script automates](#what-this-script-automates)
* [Requirements](#requirements)
* [Mac Installation](#mac-installation)
* [Windows Installation](#windows-installation)
* [Before submitting an actual Pull Request](#before-submitting-an-actual-pull-request)
* [When you are ready to submit the Pull Request](#when-you-are-ready-to-submit-the-pull-request)
* [Troubleshooting](#troubleshooting)
  
## What this script automates:

| Name | Description |
| --- | --- | 
| Git Commit Push | Pushing local commits to remote branch with `git push`. | 
| PR Creation | Clicking create a pull request from the feature branch in Github. | 
| Target Merge Branch | Selecting the target branch to merge changes into. | 
| PR Title | Copying the story name of the Jira ticket as the title of the pull request. | 
| Jira Ticket Link | Adding the link of the Jira ticket to the pull request description. | 
| Jira Ticket Description | Adding a description and acceptance criteria from the Jira ticket to the pull request. | 
| PR Reviewers | Adding the reviewers of the pull request. | 
| PR Assignee | Assigning the pull request owner as the assignee to the pull request. | 
| Jira Ticket Comments | Adding all Jira comments from the associated ticket. | 
| Jira Ticket Subtasks | Adding all Jira subtasks and subtask statuses, checked checkbox if completed. |
| Jira Team, Sprint, Goal, Components & Epic | Adding a section with the team name, sprint, and epic. |
| Jira Steps to Reproduce | Adding steps to reproduce if they exist, otherwise N/A. |
| GitHub Commit Hashes | Adding the updates section, a list of all commits with hashes and commit descriptions. |
| GitHub Diff | Adding a code changes section with the git diff of all code modifications. |
| Jira Ticket Screenshots | Adding screenshots for UI modifications or functionality improvements. (Optional - 3 Maximum) |
| GitHub PR Labels | Adding labels to categorize pull requests as a Story, Bug, QA, UAT, etc. Also adds team labels - ex. Automation, NSS_Automation (Optional) |
 

## Requirements

> [!IMPORTANT]  
> For the public script (`public-pr-script.sh`), there are fewer requirements: GitHub CLI (hub), GitHub Token (PAT - set in .bash_profile or .zshrc), Gemini AI API Key (set in .bash_profile or .zshrc), GitHub reviewers (Code reviewer GitHub usernames) and GitHub assignee (your GitHub username) in .bash_profile or .zshrc (***`reviwers` and `assignee` are both optional**).

| Name | Description | Link, Location, or Command |
| --- | --- | --- |
| `hub` | GitHub CLI - Adds additional GitHub commands to access the API from the CLI. | [hub](https://hub.github.com/) |
| `jq` | Command-line JSON processor - Parsing the response data from the Jira API. | [jq](https://stedolan.github.io/jq/download/) |
| `GitHub Personal Access Token - PAT` | Personal access tokens can be used instead of a password for Git over HTTPS, or can be used to authenticate to the API over Basic Authentication. * ***Note*** * `repo` permissions are required for this script to function properly.  | [Create A GitHub Personal Access Token](https://github.com/settings/tokens) |
| `Jira API Token` | API tokens can authenticate scripts or other process with Atlassian cloud products. | [Create a JIRA Token](https://id.atlassian.com/manage-profile/security/api-tokens) |
| `<your_pr_script>.sh` | Shell file that automates creating pull requests using Jira ticket data, images, and other details. | Static location on your local computer - `touch pr_script.sh` |
| `PULL_REQUEST_TEMPLATE` | A pull request template to be used if a template does not exist in the repo. | Static location on your local computer - `PULL_REQUEST_TEMPLATE` in the same folder as `pr_script.sh` |
| `Environment Variables` | Environment variables that are stored in the terminal/bash/zsh configuration. Includes: `<pr_script>.sh` path alias, `jira_url`, `jira_access_token`, `github_author` and `github_reviewers` | `~/.bash_profile` or `~/.zshrc` - open with `open ~/.bash_profile` or `open ~/.zshrc` - then load with `source ~/.bash_profile` or `source ~/.zshrc` |
| `Git Bash` ***Required for Windows** | Git Bash provides a UNIX command line emulator for windows which can be used to run Git, shell commands, and much more. | [Download Git Bash](https://gitforwindows.org/) |


## Mac Installation

<br>
<details>
<summary>Mac Instructions</summary>
<br><br>

##### 1. Install [hub](https://hub.github.com/).

```bash
brew install hub
```

<img width="498" alt="Screenshot 2023-11-08 at 12 36 56 PM" src="https://github.com/wesleyscholl/github-jira-pr-script/assets/128409641/d9a57250-a38b-4c2f-a546-4e022f75a5b6">

##### 2. Install [jq](https://stedolan.github.io/jq/download/).

```bash
brew install jq
```

![jjjqqq](https://github.com/wesleyscholl/github-jira-pr-script/assets/128409641/b68cde56-37f9-4e63-9d00-bba309485665)



##### 4. [Create A GitHub Personal Access Token](https://github.com/settings/tokens) with `repo` permissions. Copy this token and keep for use later.
<img width="496" alt="Screenshot 2023-11-08 at 2 23 56 PM" src="https://github.com/wesleyscholl/github-jira-pr-script/assets/128409641/111e80a5-89fd-48c2-8214-69d3c8073eb9">


##### 5. Configure the GitHub hub configuration:
```bash
git config --global hub.protocol https
git config --global hub.user [your github username]
git config --global hub.token [your github personal access token]
```
<img width="591" alt="Screenshot 2023-11-08 at 12 36 37 PM" src="https://github.com/wesleyscholl/github-jira-pr-script/assets/128409641/9edd77c6-a33e-45cc-aa70-66212b5c1599">

##### 6. [Create a JIRA Token](https://id.atlassian.com/manage-profile/security/api-tokens). Also copy this token and keep for use later.

<img width="413" alt="Screenshot 2023-11-08 at 1 00 27 PM" src="https://github.com/wesleyscholl/github-jira-pr-script/assets/128409641/2d6bf181-3a2f-4530-a419-4df0608e8eaf">
<img width="427" alt="Screenshot 2023-11-08 at 1 01 07 PM" src="https://github.com/wesleyscholl/github-jira-pr-script/assets/128409641/4b177f2d-d38b-4481-8158-d7251eea7951">

##### 7. Create a local `pr_script.sh` file - Run the following command: `touch pr_script.sh`.

```bash
touch pr_script.sh
```

<img width="721" alt="Screenshot 2023-11-08 at 12 49 44 PM" src="https://github.com/wesleyscholl/github-jira-pr-script/assets/128409641/ba53eb34-6995-4d7e-bd58-3ab469ef37c3">

##### 8. Copy and paste the [pull request script template](https://raw.githubusercontent.com/wesleyscholl/github-jira-pr-script/main/automated-pr.sh) to your `pr_script.sh` file, then save the file.

<img width="708" alt="Screenshot 2023-11-08 at 12 50 28 PM" src="https://github.com/wesleyscholl/github-jira-pr-script/assets/128409641/51f42e9f-26d6-4cf9-ba14-643bf2545947">


##### 9. Open your terminal/bash/zsh configuration, `open ~/.bash_profile` or `open ~/.zshrc`.

```bash
open ~/.bash_profile
```
or
```bash
open ~/.zshrc
```


<img width="643" alt="Screenshot 2023-11-08 at 1 02 09 PM" src="https://github.com/wesleyscholl/github-jira-pr-script/assets/128409641/ea687963-cf55-499b-9938-ffa6b48f6740">
   
##### 10. Fill in the following bash configuration values:
```bash
alias pr='<pr_script_path>.sh'
export jira_url=https://totalwine.atlassian.net/
export jira_access_token=<Totalwine_email>:<Jiratoken>
export github_author=<github_username>
export github_reviewers=<reviewers_github_usernames,seperated,by,commas>
```
Example:

```bash
alias pr='/Users/wscholl/pr_script.sh'
export jira_url=https://totalwine.atlassian.net/
export jira_access_token=wscholl@totalwine.com:AT***...***0A
export github_author=wesleyscholl
export github_reviewers=naimish1083,KevinArce98,kareewongsagul
```

##### 11. Load the file with the source command:
  ```bash
  source ~/.bash_profile
  ```
  or
  ```bash
  source ~/.zshrc
  ```

##### 12. You can now execute the script to automate your pull request, the target branch is optional and defaults to `develop`.

```bash
pr <target_branch>
```

<br>
</details>
<br><br>


## Windows Installation

<br>
<details>
<summary>Windows Instructions</summary>
<br><br>

#### 1. Scoop is required to install `hub`, if it's not installed on your machine open a powershell window and run:
##
```powershell
> Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
> irm get.scoop.sh | iex
```
<img width="984" alt="Screenshot 2023-11-09 at 12 06 55 PM" src="https://github.com/wesleyscholl/github-jira-pr-script/assets/128409641/fd09e9d4-1f1d-4740-a450-a44b29e2e4b6">

##
#### 2. Then install `hub`:
##
```powershell
> scoop install hub
```
##
#### 3. Use scoop to install `jq`: 
##
```powershell
> scoop install jq
```
<img width="942" alt="Screenshot 2023-11-09 at 12 10 34 PM" src="https://github.com/wesleyscholl/github-jira-pr-script/assets/128409641/3a54db81-8d0a-4d49-a443-c2f308db150e">

##
#### 4. [Create A GitHub Personal Access Token](https://github.com/settings/tokens) with `repo` permissions. Copy this token and keep for use later.
##
<img width="496" alt="Screenshot 2023-11-08 at 2 23 56 PM" src="https://github.com/wesleyscholl/github-jira-pr-script/assets/128409641/111e80a5-89fd-48c2-8214-69d3c8073eb9">

##
#### 5. Install Git Bash from the Software Center App:
##
Click Search on the Microsoft Toolbar and type in `software center`.

![Screenshot 2023-11-10 at 1 29 12 PM](https://github.com/wesleyscholl/github-jira-pr-script/assets/128409641/22e47f35-ed18-4079-8b2a-06a2a8ab0498)

Open the application and click on Git Bash to install.

![Screenshot 2023-11-10 at 1 27 36 PM](https://github.com/wesleyscholl/github-jira-pr-script/assets/128409641/deb69ae4-7658-4782-bbab-fe5b81763d20)

##
#### 6. Copy the `pr_script.sh` file from the `github-jira-pr-script` repo or create a new file in your C:/Users/<your_username>/ folder:
##
Powershell:
```powershell
> New-Item -Type File -Path pr_script.sh
```

Or Git Bash.
```bash
touch pr_script.sh
```

##
#### 7. Open a git bash window and set the hub configuration using the following commands:
##
Ensure you update `<your_github_username>` with your github username and `<your_github_personal_access_token>` with your github personal access token.

```bash
git config --global hub.protocol https
git config --global hub.user <your_github_username>
git config --global hub.token <your_github_personal_access_token>
```
<img width="487" alt="Screenshot 2023-11-09 at 12 23 07 PM" src="https://github.com/wesleyscholl/github-jira-pr-script/assets/128409641/5f656c4c-f252-4cd3-b74b-324cd1af026e">

##
#### 8. Create a JIRA Token
##
[Create a JIRA Token](https://id.atlassian.com/manage-profile/security/api-tokens) and copy for use later. 

<img width="413" alt="Screenshot 2023-11-08 at 1 00 27 PM" src="https://github.com/wesleyscholl/github-jira-pr-script/assets/128409641/2d6bf181-3a2f-4530-a419-4df0608e8eaf">
<img width="427" alt="Screenshot 2023-11-08 at 1 01 07 PM" src="https://github.com/wesleyscholl/github-jira-pr-script/assets/128409641/4b177f2d-d38b-4481-8158-d7251eea7951">

##
#### 9. Create and open your bash configuration, `~/.bash_profile`.
##
In the same directory:

```bash
touch .bash_profile
```

Then:
```bash
notepad .bash_profile
```
   
And complete the following configuration:
```bash
alias pr='sh C:/Users/<your_windows_username>/pr_script.sh'
export jira_url=https://totalwine.atlassian.net/
export jira_access_token=<Totalwine_email>:<Jiratoken>
export github_author=<github_username>
export github_reviewers=<reviewers_github_usernames,seperated,by,commas>
```
Example:

```bash
alias pr='sh C:/Users/WScholl/pr_script.sh'
export jira_url=https://totalwine.atlassian.net/
export jira_access_token=wscholl@totalwine.com:AT***...***0A
export github_author=wesleyscholl
export github_reviewers=naimish1083,KevinArce98,kareewongsagul
```

****Make sure you copy the full Jira token string into the `.bash_profile` configuration.***
##
#### 10. Load the `.bash_profile` configuration with the source command:
##
  ```bash
  source ~/.bash_profile
  ```
##
#### 11. You can now execute the script to automate your pull request creation. Target branch is optional, defaults to `develop`.
##
```bash
pr <target_branch>
```
****Only run the `pr` command from a Total Wine Labs git repository feature branch, otherwise it will fail.***
<br>
</details>
<br><br>

## Before submitting an actual Pull Request

The pull request function has been commented out to ensure that the pull request looks good before creating a live Pull Request. The script will output text similar to the example below.

**Example Script Pull Request Output:**

```md
CRS-41964 NSS - 2.1 | Disable "Free State" data field - Story

# [**CRS-41964**](https://totalwine.atlassian.net/browse/CRS-41964) NSS - 2.1 | Disable "Free State" data field - Story


### Description
As a user,I want the "Free Goods State" data field to be disabled and  set to "No" to simplify data entryas filling this field is not required.
##
#### Comments
- Finished development, wrote unit test to ensure input is disabled.!Screenshot 2023-11-08 at 2.09.51 PM.png|width=391,height=368!
##
#### Subtasks
- [x] Development - Done
- [ ] QA Validation - Code Review
- [ ] PO Approval - Open
##
> Team Pluto
> 23-23 - Team Pluto
> NSS - 2.1 | Post MVP
##
## Steps to Reproduce
- N/A

## Updates
* list of updates
7c1e712 CRS-41964 - Updated input value according to acceptance criteria
41b99c4 CRS-41964 - Free Goods State input now disabled, added unit test to test input is disabled

## Code Changes
* list of code changes

+diff --git a/src/components/SupplyChain/StoreContainer.test.tsx b/src/components/SupplyChain/StoreContainer.test.tsx
+index 437e1b4..1983103 100644
+--- a/src/components/SupplyChain/StoreContainer.test.tsx
++++ b/src/components/SupplyChain/StoreContainer.test.tsx
+@@ -185,4 +185,12 @@ describe('StoreContainer', () => {
+ 
+     expect(setSupplyChainData).toHaveBeenCalled();
+   });
++
++  it('should disable "Free Goods State" input when freeGoodsStateInput prop is true', () => {
++    const wrapper = shallow(<StoreContainer {...props} freeGoodsStateInput />);
++    const freeGoodsStateInput = wrapper.find(
++      'Select[name="nss-store-supply-chain-free-goods-select"]'
++    );
++    expect(freeGoodsStateInput.prop('disabled')).toBe(true);
++  });
+ });
+diff --git a/src/components/SupplyChain/StoreContainer.tsx b/src/components/SupplyChain/StoreContainer.tsx
+index 63955cd..2c2b358 100644
+--- a/src/components/SupplyChain/StoreContainer.tsx
++++ b/src/co


## Screen Shots
![Screen Shot](https://api.media.atlassian.com/file/f6bef5ab-a4b5-4e28-ab32-2a197b719c42/binary?token=eyJhbGciOiJIUzI1NiJ9.eyJpc3MiOiI5NTI3ZWFkMC1mMDFjLTQ3NjMtYTdlNC04Y2UxNzk1ZWM0NTIiLCJhY2Nlc3MiOnsidXJuOmZpbGVzdG9yZTpmaWxlOmY2YmVmNWFiLWE0YjUtNGUyOC1hYjMyLTJhMTk3YjcxOWM0MiI6WyJyZWFkIl19LCJleHAiOjE2OTk0NzIwODcsIm5iZiI6MTY5OTQ3MTQ4N30.2gBkYLD_8Y-_pEsraxRH69bnxe0E4WlB3J25wE32k70&client=9527ead0-f01c-4763-a7e4-8ce1795ec452&dl=true&name=Screenshot+2023-11-08+at+2.09.51+PM.png)
```

## When you are ready to submit the Pull Request

**Uncomment these lines at the bottom of the `pr_script.sh` and run `pr <branch>`.**
```bash
# if [ -z "$label" ]; then
# 	hub pull-request -b $base_branch -F PR_MESSAGE --no-edit -o -r $reviewers -a $assign
# else
# 	hub pull-request -b $base_branch -F PR_MESSAGE --no-edit -o -r $reviewers -a $assign -l $label
# fi
```
***Once the script completes, it will open the newly created PR in the default web browser. It should look like the following example.**

## Example Created Pull Request
<img width="1270" alt="Screenshot 2023-11-08 at 2 19 30 PM" src="https://github.com/wesleyscholl/github-jira-pr-script/assets/128409641/42a4f8fc-6958-4f5b-8e07-0415698374c4">
<img width="690" alt="Screenshot 2023-11-08 at 3 44 28 PM" src="https://github.com/wesleyscholl/github-jira-pr-script/assets/128409641/1813a8bf-1766-4665-8c9d-c46616e21715">

##
## Troubleshooting

#### fatal: not a git repository (or any of the parent directories): .git
##
![Screenshot 2023-11-10 at 1 56 17 PM](https://github.com/wesleyscholl/github-jira-pr-script/assets/128409641/e9cc37fd-69a7-412d-9fdc-dd78f6676de7)

This error message displays when the pr script is run from a non .git repository folder. Run the `pr` command from the feature branch within a Total Wine Labs repository.
##
#### command not found: pr_script.sh
##
If you see this message, the environment variables haven't been loaded or the alias syntax is incorrect.

<img width="321" alt="Screenshot 2023-11-08 at 2 37 28 PM" src="https://github.com/wesleyscholl/github-jira-pr-script/assets/128409641/a2da7a75-6688-49e3-a070-1b4d93f359a4">


- Update your alias to the following syntax: `alias pr='/Users/wscholl/pr_script.sh'` Update the path if your pr_script.sh file is in a different location.
- Load the bash/zsh/terminal configuration environment variables with the following command:
  
```bash
source ~/.bash_profile
```
or
```bash
source ~/.zshrc
```
##
#### Forbidden HTTP 403 - Resource protected by organization SAML enforcement. You must grant your Personal Access token access to this organization.
##
This means that the GitHub personal access token (PAT) needs authorization to access the TotalWineLabs organization. 

- To do this, go to https://github.com/settings/tokens. Click "Configure SSO" on your pull request token. Authorize the token to access the TotalWineLabs organization.

<img width="496" alt="Screenshot 2023-11-08 at 2 23 56 PM" src="https://github.com/wesleyscholl/github-jira-pr-script/assets/128409641/c4dfaa73-7247-4720-89cb-15461a2bb1a8">

- When the token has been properly authorized, you should see "Deauthorize" under single sign-on organizations next to TotalWineLabs. 

<img width="802" alt="Screenshot 2023-11-08 at 2 18 12 PM" src="https://github.com/wesleyscholl/github-jira-pr-script/assets/128409641/bc249f31-ead9-4aa9-b01a-b17abf3167dd">

##
#### Permission Denied Error
##
If you receive this error, execute one of the following commands:

```bash
chmod +x pr
```
or
```bash
chmod +x path of the script.sh
```
##
#### Terminal/bash/zsh config file not found
##
Use the following commands to create the file:
```bash
touch ~/.bash_profile
```
or 
```bash
touch ~/.zshrc
```
After you’ve created the file, open it with `open ~/.bash_profile` or `open ~/.zshrc` and add the environment variables to it.
##
#### Cannot execute: required file not found error
##

If you see this message, the `.bash_profile` alias is not configured properly.
```bash
bash: C:/Users/<your_windows_username>/pr_script.sh: cannot execute: required file not found
```

Modify this line:
```bash
alias pr='C:/Users/WScholl/pr_script.sh'
```
to
```bash
alias pr='sh C:/Users/WScholl/pr_script.sh'
```

Windows requires the `sh` command to be specified in the alias.
