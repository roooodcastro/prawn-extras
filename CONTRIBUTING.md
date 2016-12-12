# How to contribute

Any contribution is welcome! If you want to submit a bug, please do so via the
Issues tab. If you want to fix a bug or implement new functionality, start
coding away! When you're ready, please open a Pull Request for your
code to be reviewed before it can be accepted.

## Testing

This gem uses Minitest to write automated tests for its methods. Because this is
about PDF creation, not all tests are easy to automate. If you're having
difficulties, feel free to open a PR without tests to get feedback on them. Not
everything will be tested using Minitest, though.

The self-documenting manual is a great resource that can tell straight away if
something is not right. It may even be accepted as a test in some specific
cases.

## Submitting changes

Please send a [GitHub Pull Request to prawn-extras](https://github.com/opengovernment/opengovernment/pull/new/master)
with a clear list of what you've done (read more about [pull requests](http://help.github.com/pull-requests/)).

Please follow the [Ruby Style Guide](https://github.com/bbatsov/ruby-style-guide)
and make sure all of your commits are atomic (one feature per commit). Also run
the Rubocop gem before submitting a PR, to make sure your code complies to the
style guide.

Always write a clear log message for your commits. One-line messages are fine
for small changes, but bigger changes should look like this:

    $ git commit -m "A brief summary of the commit
    > 
    > A paragraph describing what changed and its impact."

Thanks,
Rodrigo Castro Azevedo
