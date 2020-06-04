# zettelbashten
Basic Zettelkasten written in bash

Invoke `zettel_create` to write a note, store it locally, and link to existing notes.

By default the zettelkasten is stored at `$HOME/zettelkasten`. 
A different location can be specified as an argument to the script.

The script launches `$EDITOR` with a template that includes a place to put tags.
Tags must be on a single line, separated by commas. 
Upon exiting from your editor, the script will open a file displaying all existing notes with a tag matching that note that was just added.
To create a link, change the filed marked `link:` to `yes` for all desired notes.
