# github-jira-pr-script
Automating pull request creation with Jira projects from the command line.



Pull requests are one of the most common actions in the day-to-day work of a developer. Pull requests manage communication, edits, and debugging of requested changes so that they can be merged into a more significant project. Sometimes you receive feedback and learn something new; other times, you add something of value to the reviewer to allow them to learn from it.
Pain points of creating pull requests manually
Creating a pull request manually is a time-consuming task. To do so, the mobile team at Seera group follows a process of creating a Github branch with the same name as the task id on Jira.
For example, our Android project on Jira is named Apollo. Every task or story created has the prefix APL to ensure it’s quickly identified.
So a typical task id will look like this: APL-[auto increment number] after creating the branch.
Once you’ve completed the requested changes, to push it to Github you have to:
Click create a pull request on the changed branch through Github
Select the target branch you want to merge the changes into
Copy the task name of the Jira ticket as the title of your pull request
Add the link of the Jira ticket to your pull request description
Describe your changes and the implementation details
Add the reviewers of the pull request and finally
Add a label to categorize your pull request as a bug, task, release task..etc.
Those seven steps, over and over again. You can see how it can be mind-numbing and reduce creativity and productivity.
Now imagine all the steps above can be automated with one line!🤯
It’s possible, and our iOS developer Aleksandr Latyntsev has written a bash script to automate all the actions above. In this article, we’ll share this script with you and explain how to use it for your own processes.
Setup The Environment
For this batch script automation, we will be using GitHub CLI called hub for extra git command lines, and jq for parsing the response from JIRA API.
So before you can use the script, you’ll need to install both. Click the links below to learn how to install them quickly:
How to install hub?
How to install jq?
After installing hub, you’ll need to update its settings. First, you’ll need to generate a Github Oath token:
How to create Github OathToken?
Settings→Developer settings→Personal access tokens→Generate new token.
You can then update the settings by executing the following commands:
git config --global hub.protocol https
git config --global hub.user [your github username]
git config --global hub.token [your github token]
The Script:
With the environment set up, you can now execute the script to automate your pull.
