# github-jira-pr-script - Automating pull request creation with Jira projects from the command line 👨🏻‍💻➡️🌐✅

Creating a pull request manually is a time-consuming task. TotalWine Engineering follows a process to create Github branches with the same name as the ticket name and number on Jira.

A typical ticket number will look like: CRS-\<number_auto_incremented\>-\<project_name\>-\<description\> when creating branches in Jira. (Example - `CRS-41964-NSS-2.1-Disable-Free-State-data-field`) This may be different depending on which team you are on.

# What this script automates:

1.  Clicking create a pull request on the changed branch through Github
2.  Selecting the target branch you want to merge the changes into
3.  Copying the task name of the Jira ticket as the title of your pull request
4.  Adding the link of the Jira ticket to your pull request description
5.  Describing your changes and the implementation details
6.  Adding the reviewers of the pull request and finally
7.  Adding screenshots or videos of the UI changes/functionality (Optional)
8.  Adding a label to categorize your pull request as a bug, task, release task, etc. (Optional)

# Requirements
To use the pull request script, you’ll need to install, create, or configure the following:

| Name | Description | Link, Location, Command |
| --- | --- | --- |
| `hub` | GitHub CLI - Adds additional GitHub commands to access the API from the CLI. | [hub](https://hub.github.com/) |
| `jq` | Command-line JSON processor - Parsing the response data from the Jira API. | [jq](https://stedolan.github.io/jq/download/) |
| `GitHub Personal Access Token - PAT` | Personal access tokens can be used instead of a password for Git over HTTPS, or can be used to authenticate to the API over Basic Authentication. * ***Note*** * `repo` permissions are required for this script to function properly.  | [Create A GitHub Personal Access Token](https://github.com/settings/tokens) |
| `Jira API Token` | API tokens can authenticate scripts or other process with Atlassian cloud products. | [Create a JIRA Token](https://id.atlassian.com/manage-profile/security/api-tokens) |
| `<your_pr_script>.sh` | Shell file that automates creating pull requests using Jira ticket data, images, and other details. | Static location on your local computer - `touch pr_script.sh` |
| `Environment Variables` | Environment variables that are stored in the terminal/bash/zsh configuration. Includes: `<pr_script>.sh` path alias, `jira_url`, `jira_access_token`, `github_author` and `github_reviewers` | `~/.bash_profile` or `~/.zshrc` - open with `open ~/.bash_profile` or `open ~/.zshrc` - then load with `source ~/.bash_profile` or `source ~/.zshrc` |

# Installation

## 1. Install [hub](https://hub.github.com/).

<img width="498" alt="Screenshot 2023-11-08 at 12 36 56 PM" src="https://github.com/wesleyscholl/github-jira-pr-script/assets/128409641/d9a57250-a38b-4c2f-a546-4e022f75a5b6">

## 2. Install [jq](https://stedolan.github.io/jq/download/).

   
![jjjqqq](https://github.com/wesleyscholl/github-jira-pr-script/assets/128409641/b68cde56-37f9-4e63-9d00-bba309485665)



## 4. [Create A GitHub Personal Access Token](https://github.com/settings/tokens) with `repo` permissions. Copy this token and keep for use later.
<img width="496" alt="Screenshot 2023-11-08 at 2 23 56 PM" src="https://github.com/wesleyscholl/github-jira-pr-script/assets/128409641/111e80a5-89fd-48c2-8214-69d3c8073eb9">


## 5. Configure the GitHub hub configuration:
```bash
git config --global hub.protocol https
git config --global hub.user [your github username]
git config --global hub.token [your github personal access token]
```
<img width="591" alt="Screenshot 2023-11-08 at 12 36 37 PM" src="https://github.com/wesleyscholl/github-jira-pr-script/assets/128409641/9edd77c6-a33e-45cc-aa70-66212b5c1599">

## 6. [Create a JIRA Token](https://id.atlassian.com/manage-profile/security/api-tokens). Also copy this token and keep for use later.

<img width="413" alt="Screenshot 2023-11-08 at 1 00 27 PM" src="https://github.com/wesleyscholl/github-jira-pr-script/assets/128409641/2d6bf181-3a2f-4530-a419-4df0608e8eaf">
<img width="427" alt="Screenshot 2023-11-08 at 1 01 07 PM" src="https://github.com/wesleyscholl/github-jira-pr-script/assets/128409641/4b177f2d-d38b-4481-8158-d7251eea7951">

## 7. Create a local `pr_script.sh` file - Run the following command: `touch pr_script.sh`.

<img width="721" alt="Screenshot 2023-11-08 at 12 49 44 PM" src="https://github.com/wesleyscholl/github-jira-pr-script/assets/128409641/ba53eb34-6995-4d7e-bd58-3ab469ef37c3">

## 8. Copy and paste the [pull request script template](https://raw.githubusercontent.com/wesleyscholl/github-jira-pr-script/main/automated-pr.sh) to your `pr_script.sh` file, then save the file.

<img width="708" alt="Screenshot 2023-11-08 at 12 50 28 PM" src="https://github.com/wesleyscholl/github-jira-pr-script/assets/128409641/51f42e9f-26d6-4cf9-ba14-643bf2545947">


## 9. Open your terminal/bash/zsh configuration, source `~/.bash_profile` or `source ~/.zshrc`.

<img width="643" alt="Screenshot 2023-11-08 at 1 02 09 PM" src="https://github.com/wesleyscholl/github-jira-pr-script/assets/128409641/ea687963-cf55-499b-9938-ffa6b48f6740">
   
## 10. Fill in the following values:
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

## 11. Load the file with the source command:
  ```bash
  source ~/.bash_profile
  ```
  or
  ```bash
  source ~/.zshrc
  ```

## 12. You can now execute the script to automate your pull request, the target branch is optional and defaults to `develop`.

```bash
pr <target_branch>
```

# Example Created Pull Request
<img width="1270" alt="Screenshot 2023-11-08 at 2 19 30 PM" src="https://github.com/wesleyscholl/github-jira-pr-script/assets/128409641/42a4f8fc-6958-4f5b-8e07-0415698374c4">
<img width="690" alt="Screenshot 2023-11-08 at 3 44 28 PM" src="https://github.com/wesleyscholl/github-jira-pr-script/assets/128409641/1813a8bf-1766-4665-8c9d-c46616e21715">


# Final Thoughts

## Before submitting an actual PR

The pull request function has been commented out to ensure that the pull request looks good before creating a live PR.

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

## When you are satisfied with the PR, uncomment these lines in `pr_script.sh` and run `pr <branch>`.
```bash
# if [ -z "$label" ]; then
# 	hub pull-request -b $base_branch -F PR_MESSAGE --no-edit -o -r $reviewers -a $assign
# else
# 	hub pull-request -b $base_branch -F PR_MESSAGE --no-edit -o -r $reviewers -a $assign -l $label
# fi
```


# Troubleshooting

## command not found: pr_script.sh

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

## Forbidden HTTP 403 - Resource protected by organization SAML enforcement. You must grant your Personal Access token access to this organization.

This means that the GitHub personal access token (PAT) needs authorization to access the TotalWineLabs organization. 

- To do this, go to https://github.com/settings/tokens. Click "Configure SSO" on your pull request token. Authorize the token to access the TotalWineLabs organization.

<img width="496" alt="Screenshot 2023-11-08 at 2 23 56 PM" src="https://github.com/wesleyscholl/github-jira-pr-script/assets/128409641/c4dfaa73-7247-4720-89cb-15461a2bb1a8">

- When the token has been properly authorized, you should see "Deauthorize" under single sign-on organizations next to TotalWineLabs. 

<img width="802" alt="Screenshot 2023-11-08 at 2 18 12 PM" src="https://github.com/wesleyscholl/github-jira-pr-script/assets/128409641/bc249f31-ead9-4aa9-b01a-b17abf3167dd">

## Permission Denied Error
If you receive this error, execute one of the following commands:

```bash
chmod +x pr
```
or
```bash
chmod +x path of the script.sh
```

## Terminal/bash/zsh config file not found
Use the following commands to create the file:
```bash
touch ~/.bash_profile
```
or 
```bash
touch ~/.zshrc
```
After you’ve created the file, open it with `open ~/.bash_profile` or `open ~/.zshrc` and add the environment variables to it.
