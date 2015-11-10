# Rabbit -- an Atom package

Rabbit remembers your positions as you jump around your project, and allows you
to easily revisit them.  If you are a vim user, think `Ctrl-o` and `Ctrl-i`.
If you've accidentally pressed `Cmd-down`, or if you've bounced around several
files and want to go back to where you just were, rabbit is your friend.

Rabbit ignores movements within a line, or going up/down a single row.  It
also ignores the movement associated with cutting or pasting text.

`Rabbit:down` moves down the position stack, to go to earlier positions.
`Rabbit:up` moves up the position stack, to go to later positions.  This only
makes sense after you've gone down; it allows you to move back up the stack
to where you were before you started down the rabbit hole.

Currently, `Rabbit:down` is bound to `Ctrl-Alt-j`, and `Rabbit:up` is bound
to `Ctrl-Alt-k`.

TODO: Currently, if you have a position in a deleted file, when you jump to
that position, you'll open an empty buffer for that file.  It won't create the
file unless you save.  Rabbit should forget positions associated with deleted
files.

TODO: Allow rabbit to remember particular named locations, like vim's `m` and
`'`.

<!-- ![A screenshot of your package](https://f.cloud.github.com/assets/69169/2290250/c35d867a-a017-11e3-86be-cd7c5bf3ff9b.gif) -->
