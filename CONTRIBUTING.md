## Contributing

Thanks for your interest in Thumby!  This started as a pet project and quickly
turned into a full functioning webapp.  There may be some configurations added
that was specifically tailored to my use case but I try to make sure that it
is all configurable.  That said I am interested in hearing from others with 
their suggestions in making this a better app!

### 1. Where do I go from here?

If you've noticed a bug or have a question,
[search the issue tracker](https://github.com/bitflingr/thumby/issues)
to see if someone else in the community has already created a ticket.
If not, go ahead and [make one](https://github.com/bitflingr/thumby/issues/new)!

### 2. Fork & create a branch

If this is something you think you can fix, then
[fork Active Admin](https://help.github.com/articles/fork-a-repo)
and create a branch with a descriptive name.

A good branch name would be (where issue #325 is the ticket you're working on):

```sh
git checkout -b 325-add-facial-recognition
```

### 3. Get the test suite running

Make sure you're using a recent ruby and have the `bundler` gem installed, at
least version `1.14.3`.

Install the development dependencies:

```sh
bundle install
```

Now you should be able to run the entire suite using:

```sh
bundle exec rake
```

The test run will launch a local server on port 9999 to help test since the only
 backend for Thumby is the INTERNET! I've tried including any example of messed up 
 encoded url's that could possibly mess up the pipeline and included them in the 
 `public/` directory.

### 4. Did you find a bug?

* **Ensure the bug was not already reported** by [searching all
  issues](https://github.com/bitflingr/thumby/issues?q=).

* If you're unable to find an open issue addressing the problem, [open a new
  one](https://github.com/bitflingr/thumby/issues/new).  Be sure to
  include a **title and clear description**, as much relevant information as
  possible, and a **code sample** or an **executable test case** demonstrating
  the expected behavior that is not occurring.

### 5. Implement your fix or feature

At this point, you're ready to make your changes! Feel free to ask for help;
everyone is a beginner at first :smile_cat:

### 6. Test Test Test!!!

Most if not all of the tests are focused on url encoding but we can certainly
 use more to cover everything. So make sure a test, even a simple one is included
 or if it's a fix that it passes the current tests.

### 7. Make a Pull Request

At this point, you should switch back to your master branch and make sure it's
up to date with Active Admin's master branch:

```sh
git remote add upstream git@github.com:bitflingr/thumby.git
git checkout master
git pull upstream master
```

Then update your feature branch from your local copy of master, and push it!

```sh
git checkout 325-add-facial-recognition
git rebase master
git push --set-upstream origin 325-add-facial-recognition
```

Finally, go to GitHub and
[make a Pull Request](https://help.github.com/articles/creating-a-pull-request)
:D

Travis CI will run our test suite for Ruby 2.3.4 and 2.4.1.  It's unlikely,
but it's possible that your changes pass tests in one Ruby version but fail in
another. In that case, you'll have to setup your development environment (as
explained in step 3) to use the problematic Ruby version, and investigate
what's going on!

### 8. Keeping your Pull Request updated

If a maintainer asks you to "rebase" your PR, they're saying that a lot of code
has changed, and that you need to update your branch so it's easier to merge.

To learn more about rebasing in Git, there are a lot of
[good](http://git-scm.com/book/en/Git-Branching-Rebasing)
[resources](https://help.github.com/articles/interactive-rebase),
but here's the suggested workflow:

```sh
git checkout 325-add-facial-recognition
git pull --rebase upstream master
git push --force-with-lease 325-add-facial-recognition
```

### 9. Merging a PR (maintainers only)

A PR can only be merged into master by a maintainer if:

* It is passing CI.
* It has no requested changes.
* It is up to date with current master.

Any maintainer is allowed to merge a PR if all of these conditions are
met.

### 10. Shipping a release (maintainers only)

Maintainers need to do the following to push out a release:

* Make sure all pull requests are in and that changelog is current
* Update `version.rb` file and changelog with new version number
* Create a stable branch for that release:

  ```sh
  git checkout master
  git fetch thumby
  git rebase activeadmin/master
  # If the release is 2.1.x then this should be: 2-1-stable
  git checkout -b N-N-stable
  git push activeadmin N-N-stable:N-N-stable
  ```

* `bundle exec rake release`