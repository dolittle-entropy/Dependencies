# Dependencies
Automation for finding dependencies between projects


## Usage

You first need to have cloned all the dotnet Dolittle repositories.
All the repositories will be grouped by organisations e.g. :

```
+-- Dolittle/ [ e.g /usr/home/Dolittle/ ]
|   +-- interaction/ ( for dolittle-interaction )
|   |   +--- AspNetCore/
|   |   +--- AspNetCore.Debugging/
|   |   +--- WebAssembly/
|   |   +--- ...    
|   +-- fundamentals/ ( dolittle-fundamentals )
|   |   +--- ...
|   +-- runtime/
|   +-- ...
```

Next you can launch the script and specify the path of the folder containing all the repositories.

```
$ ./dependencies.sh /usr/home/Dolittle/
```

If a dependency is **Not Found**, that means that the project containing the dependency is not in the folder given as parameter. Check if you have clone all the repositories you need and/or check if you specified the good folder.




*~ Work in progress to get something more user friendly*
