# Assignment 0

This is a demo repository that shows the basics of how to get started with assignment submissions for EE2003 Computer Organization.

## How to proceed

1. *Fork* the assignment into your own namespace by clicking on the link on the top right side of the project.  This will create a project under your namespace, for example https://git.ee2003.dev.iitm.ac.in/EE2003-2021/a0 will be forked as https://git.ee2003.dev.iitm.ac.in/username/a0
2. Log in to https://ee2003.dev.iitm.ac.in/ with your LDAP account.  Note: you can do all this on your own system if you prefer, and we can try to help, but only limited debugging is possible.
3. Clone **your fork** of the repository (created above) into your local account `git clone https://git.ee2003.dev.iitm.ac.in/username/a0`
4. Edit and add files as needed to complete the assignment - documentation for the assignment will be in the README file of the assignment.  For a0, you just need to create a new file name `output` that contains the single word `success`
5. Run the command `chmod +x run.sh` followed by `./run.sh` to test whether your code passes (this was originally `drone exec` but since it gives permission issues we are using this instead).
6. Commit your changes: 
    * `git add output` # -- add any files you created/modified to the git repo to update
    * `git commit -m "Aha an insightful message"` # Use sensible commit messages that will help you understand later
7. Log in to https://drone.ee2003.dev.iitm.ac.in/ and **ACTIVATE** the repository for evaluation.  Otherwise the next step below will not work.
8. Use `git tag -a submit -m "Submit"` to tag your commit for submission.
9. `git push --tags origin` # Push your changes back to the git server, this will also automatically trigger the drone build
10. Go to https://drone.ee2003.dev.iitm.ac.in/username/a0 and confirm that the server was able to successfully run the tests automatically.
11. Submit the link https://drone.ee2003.dev.iitm.ac.in/username/a0 on Moodle under the assignment 0 (obviously with your username substituted in the appropriate place)
