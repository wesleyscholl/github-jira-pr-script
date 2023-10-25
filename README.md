# github-jira-pr-script

## Automating pull request creation with Jira projects from the command line. 👨🏻‍💻➡️🌐✅

Pull requests are one of the most common actions in the day-to-day work of a developer. Pull requests manage communication, edits, and debugging of requested changes so that they can be merged into a more significant project. Sometimes you receive feedback and learn something new; other times, you add something of value to the reviewer to allow them to learn from it.

Creating a pull request manually is a time-consuming task. To do so, the mobile team at Seera group follows a process of creating a Github branch with the same name as the task id on Jira.

For example, our Android project on Jira is named Apollo. Every task or story created has the prefix APL to ensure it’s quickly identified.

So a typical task id will look like this: APL-\[auto increment number\] after creating the branch.

Once you’ve completed the requested changes, to push it to Github you have to:

1.  Click create a pull request on the changed branch through Github
2.  Select the target branch you want to merge the changes into
3.  Copy the task name of the Jira ticket as the title of your pull request
4.  Add the link of the Jira ticket to your pull request description
5.  Describe your changes and the implementation details
6.  Add the reviewers of the pull request and finally
7.  Add a label to categorize your pull request as a bug, task, release task..etc.

Those seven steps, over and over again. You can see how it can be mind-numbing and reduce creativity and productivity.

Now imagine all the steps above can be automated with one line!🤯

In this article, we’ll share this script with you and explain how to use it for your own processes.

For this batch script automation, we will be using GitHub CLI called [hub](https://github.com/github/hub) for extra git command lines, and [jq](https://stedolan.github.io/jq/) for parsing the response from JIRA API.  
So before you can use the script, you’ll need to install both. Click the links below to learn how to install them quickly:

[How to install hub?](https://hub.github.com/)

[How to install jq?](https://stedolan.github.io/jq/download/)

After installing hub, you’ll need to update its settings. First, you’ll need to generate a Github Oath token:

[How to create Github OathToken?](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/creating-a-personal-access-token)  
Settings**→**Developer settings**→**Personal access tokens**→**Generate new token.

You can then update the settings by executing the following commands:

```
git config --global hub.protocol https
git config --global hub.user [your github username]
git config --global hub.token [your github token]
```


With the environment set up, you can now execute the script to automate your pull.

When reading the comments in the script file, you’ll notice that it just executes the same manual task step by step. However, this script makes the process 100x faster than the manual process.  
To use the script, you’ll first need to [download it](https://gist.github.com/tamtom/b3fa4119cbaebe444c750938782d8b52/archive/526bc00499f06b1221a190691728290228fba6a8.zip).

To make the script more dynamic and be able to run locally or remotely, we are passing the variables as environment variables:

You need to append these variables to your environment variables within your ~/.bash\_profile or the ~/.zshrc file

In our script, we will use the variables above.,  
The alias is just a fancy way to execute it.  
To get the jira\_access\_token:  
[How to create Jira API token?](https://support.atlassian.com/atlassian-account/docs/manage-api-tokens-for-your-atlassian-account/)

**Note** You need to check your terminal type!

*   If it’s bash, you can continue with **~/.bash\_profile**.
*   If it’s Zsh you need to write **~/.zshrc** instead of **~/.bash\_profile**.

You can identify which to choose by the title of your terminal:

zsh terminal type

Thankfully, the process of editing both files is the same — you simply need to watch the name of the file.

In some cases, these files may not exist by default, so you will have to create them after determining your terminal type. Here’s how you can see if your files exist and what to do if they don’t:

**1- Check if the File Exists  
**First, check if the file exists. To do so, run these commands:

```
open ~/.bash_profile
or 
open ~/.zshrc
```


If it exists, simply edit the values above, and paste them into the file. Then press “Save.”

2- **If the Files aren’t Found, Create Them  
**Use the following commands to create the right file:

```
touch ~/.bash_profile
or 
touch ~/.zshrc
```


After you’ve created the file, simply open it with the command above and add the values above to it.

3\. **Load the File  
**Once you are done, you will need to load the file with this command:

```
source ~/.bash_profile
or 
source ~/.zshrc
```


Read [How to edit your bash profile](https://medium.com/macoclock/how-to-create-delete-update-bash-profile-in-macos-5f99999ed1e7) for a detailed explanation,

If you decided to skip this you can inject your values into the script directly (not secure)

4\. **Execute the Script  
**With the environment set up and the script loaded, you can execute the script using this line:

> pr \[target branch\]

In some cases, you may get a permission denied error. If so, execute one of the following commands:

```
chmod +x pr 
or
chmod +x path of the script.sh
```


**Enhance Your Workflow Precision  
**With this simple batch automation, you can handle multiple minor pull requests at a greater capacity than ever before. This means greater workflow precision and less time spent in manual processes.

Traditionally, more requests equal more time to initiate the process for review and merging. With this script, we’ve drastically reduced this aspect of production time with this script — and now you can implement those same changes for your own system.
