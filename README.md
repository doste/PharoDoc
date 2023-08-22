# PharoDoc

Generate site for documenting Pharo code.

Dependencies:
[Ecstatic](https://github.com/guillep/ecstatic)
[Jekyll](https://jekyllrb.com/)

How to use:

1. It's recommended to first create a folder where all the site's files will reside.
   For example, ecstatic_site.

2. In Pharo, open a Playground and execute:
 ```smalltalk
    docsSite := DostePharoDoc new.
    docsSite classesToShow: {Collection. GeometryObject. HEAbstractExported. BitBlt. AbstractDebugger}.
    docsSite pathToFolder: 'Users/user1/ecstatic-example'.
    docsSite generateDocPages.
 ```
Here we are configuring it to show the classes: Collection, GeometryObject, HEAbstractExported, BitBlt and AbstractDebugger.
 Of course you can change to whatever classes you want. The important thing to notice is that the argument is a Collection, so the names of the classes
 should be inside brackets.
 Then, you have to give it the path to the folder that you chose to hold the site's files.
 Finally you generate all the .pillar files by sending the generateDocPages message to the instance of DostePharoDoc.

3. Inside the corresponding folder (for example ecstatic_site) execute the command
```bash
  ecstatic generate
```
The corresponding files will be put in the _site folder, cd into this, and then
```bash
  jekyll serve
```

 Now, go to http://127.0.0.1:4000 (or whatever address Jekyll generated) and view the docs! :D
