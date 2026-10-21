# StudentRepoManager
This is a simple PowerShell script and batch file that will help the user manage many repositories. 
I built it to help me manage the repositories for student for my TA job.

There are two different ways to interact with it. 
The new way, which is launched through RunManageStudents.bat, displays the menu, then by typing ss <name/index> and pressing enter, it will open the specified student/run the specified command. This method has autocomplete for the names, so you can type ss Jo<TAB> and it will autofill in ss John. Both the indices on the side, as well as the name of each student work.

The old way, which is launched through OLDRunManageStudents.bat, displays the menu, and the user will just need to type in the index/name that they want to open, and it will open. No need for typing in ss, but there is no autocomplete. 

The students will be stored in the StudentRepos folder that will be created when first run, and both versions access the same folders so states are shared between them. When you select a student by the given index/name it will pull their repository and open it in VS Code.

There are extra commands that are displayed in red. To use these, call them by their index/name just like you would a student and follow the subsequent prompts.

When giving the names, make sure the name has a first and last name, as the names are sorted by the last. Multiple last names are supported, but it will sort by the first last name given.
